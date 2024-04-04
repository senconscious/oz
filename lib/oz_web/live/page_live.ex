defmodule OzWeb.PageLive do
  use OzWeb, :live_view

  import OzWeb.CustomComponents, only: [loader: 1]

  alias Phoenix.LiveView.JS

  alias OzWeb.PageParam

  alias Oz.Deals

  @impl true
  def mount(params, _session, socket) do
    IO.inspect(self(), label: "SOCKET PID")

    socket_connected? = connected?(socket)

    page_param = PageParam.changeset(%PageParam{}, params)
    {:ok, casted_params} = Ecto.Changeset.apply_action(page_param, :insert)

    {
      :ok,
      socket
      |> assign(:page_param, to_form(page_param))
      |> assign(:edited_deal, nil)
      |> assign_async(:deals, fn -> load_async_assigns(socket_connected?, casted_params) end),
      temporary_assigns: [
        deals: %{loading: false, ok?: nil, result: []},
        edited_deal: nil,
        page_param: nil
      ]
    }
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket_connected? = connected?(socket)

    page_param = PageParam.changeset(%PageParam{}, params)
    {:ok, casted_params} = Ecto.Changeset.apply_action(page_param, :insert)

    {:noreply,
     socket
     |> assign(:page_param, to_form(page_param))
     |> assign_async(:deals, fn -> load_async_assigns(socket_connected?, casted_params) end)}
  end

  @impl true
  def handle_event("show_deal_modal", %{"deal_id" => deal_id}, socket) do
    {:ok, deal} = Deals.fetch_deal(deal_id)

    {:noreply, assign(socket, :edited_deal, deal)}
  end

  @impl true
  def handle_event("validate", %{"page_param" => params}, socket) do
    page_param =
      %PageParam{}
      |> PageParam.changeset(params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, :page_param, page_param)}
  end

  @impl true
  def handle_event("search", %{"page_param" => params}, socket) do
    case PageParam.cast_and_validate(params) do
      {:ok, casted_params} ->
        socket_connected? = connected?(socket)

        {:noreply,
         assign_async(socket, :deals, fn ->
           load_async_assigns(socket_connected?, casted_params)
         end)}

      {:error, changeset} ->
        page_param =
          changeset
          |> Map.put(:action, :insert)
          |> to_form()

        {:noreply,
         socket
         |> assign(:page_param, page_param)
         |> put_flash(:error, "Please enter appropriate filters")}
    end
  end

  defp load_async_assigns(false, _), do: {:ok, %{deals: []}}

  defp load_async_assigns(true, params) do
    deals =
      params
      |> Map.from_struct()
      |> Deals.list_deals()

    {:ok, %{deals: deals}}
  end

  def push_show_deal_modal(deal_id) do
    %JS{}
    |> JS.push("show_deal_modal", value: %{deal_id: deal_id})
    |> show_modal("deal-modal")
  end

  def set_value_and_dispatch(options) do
    set_value_and_dispatch(%JS{}, options)
  end

  def set_value_and_dispatch(js, options) do
    value = Keyword.fetch!(options, :value)
    to = Keyword.fetch!(options, :to)

    js
    |> JS.set_attribute({"value", value}, to: to)
    |> JS.dispatch("input", to: to, detail: %{value: value})
  end
end
