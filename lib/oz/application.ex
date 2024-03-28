defmodule Oz.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OzWeb.Telemetry,
      Oz.Repo,
      {DNSCluster, query: Application.get_env(:oz, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Oz.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Oz.Finch},
      # Start a worker by calling: Oz.Worker.start_link(arg)
      # {Oz.Worker, arg},
      # Start to serve requests, typically the last entry
      OzWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Oz.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OzWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
