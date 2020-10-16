use Mix.Config

# Configure your database
config :telegram_bot, TelegramBot.Repo,
  username: "root",
  password: "1111",
  database: "telegram_bot_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :telegram_bot, TelegramBotWeb.Endpoint,
  http: [port: 4002],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn
