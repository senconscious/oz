defmodule OzWeb.PageLive do
  use OzWeb, :live_view

  import OzWeb.CustomComponents, only: [loader: 1]

  alias Phoenix.LiveView.JS

  alias OzWeb.PageParam

  alias Oz.Deals

  @impl true
  def mount(params, _session, socket) do
    socket_connected? = connected?(socket)

    {:ok, casted_params} = PageParam.cast_and_validate(params)

    {
      :ok,
      socket
      |> assign(:filters, casted_params)
      |> assign(:edited_deal, nil)
      |> assign_async(:deals, fn -> load_async_assigns(socket_connected?, casted_params) end),
      temporary_assigns: [deals: %{loading: false, ok?: nil, result: []}, edited_deal: nil]
    }
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket_connected? = connected?(socket)

    {:ok, casted_params} = PageParam.cast_and_validate(socket.assigns.filters, params)

    {:noreply,
     socket
     |> assign(:filters, casted_params)
     |> assign_async(:deals, fn -> load_async_assigns(socket_connected?, casted_params) end)}
  end

  @impl true
  def handle_event("show_deal_modal", %{"deal_id" => deal_id}, socket) do
    {:ok, deal} = Deals.fetch_deal(deal_id)

    {:noreply, assign(socket, :edited_deal, deal)}
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
end
