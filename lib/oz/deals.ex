defmodule Oz.Deals do
  alias Oz.Deals.DealQuery

  defdelegate list_deals(filters), to: DealQuery, as: :list_paginated

  defdelegate fetch_deal(id), to: DealQuery, as: :fetch
end
