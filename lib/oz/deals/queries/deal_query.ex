defmodule Oz.Deals.DealQuery do
  @database (for number <- 1..100 do
               %{
                 id: number,
                 name: "Test deal #{number}"
               }
             end)

  def list_paginated(filters) do
    @database
    |> by_name(filters)
    |> paginate(filters)
  end

  def fetch(id) do
    case Enum.find(@database, fn %{id: deal_id} -> deal_id == id end) do
      nil -> {:error, :not_found}
      deal -> {:ok, deal}
    end
  end

  defp by_name(deals, %{name: name}) when is_binary(name) do
    Enum.filter(deals, fn %{name: deal_name} -> String.contains?(deal_name, name) end)
  end

  defp by_name(deals, _), do: deals

  defp paginate(deals, filters) do
    page = Map.get(filters, :page, 1)
    page_size = Map.get(filters, :page_size, 10)

    offset = (page - 1) * page_size
    total_entries = Enum.count(deals)
    total_pages = ceil(total_entries / page_size)

    entries =
      deals
      |> Stream.drop(offset)
      |> Enum.take(page_size)

    %{
      page: page,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages,
      entries: entries
    }
  end
end
