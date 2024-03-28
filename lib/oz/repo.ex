defmodule Oz.Repo do
  use Ecto.Repo,
    otp_app: :oz,
    adapter: Ecto.Adapters.Postgres
end
