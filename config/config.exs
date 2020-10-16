# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :telegram_bot,
  ecto_repos: [TelegramBot.Repo]

# Configures the endpoint
config :telegram_bot, TelegramBotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ALkFEK61JpONalkKj/L63zVCsitW/jGGptZAKzSrWoOl4rec3nizQ1g04bZXYoEn",
  render_errors: [view: TelegramBotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TelegramBot.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
#config telegram bot key
config :nadia, 
  token: System.get_env("TELEGRAM_BOT_KEY"),
  telegram_api: "https://api.telegram.org/"

config :hound, 
  driver: "chrome_driver",
  app_host: "https://localhost", 
  app_port: 4001

#telegrambot
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
