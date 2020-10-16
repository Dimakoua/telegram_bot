defmodule TelegramBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      TelegramBot.Repo,
      # Start the endpoint when the application starts
      TelegramBotWeb.Endpoint,
      # Starts a worker by calling: TelegramBot.Worker.start_link(arg)
      # {TelegramBot.Worker, arg},
      TelegramBot.Bucket
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TelegramBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TelegramBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
