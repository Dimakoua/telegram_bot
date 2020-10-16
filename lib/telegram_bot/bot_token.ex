defmodule TelegramBot.BotToken do
    @behaviour Plug
    import Plug.Conn
    require Logger
    @impl Plug
    
    def init(opts), do: opts
      def call(conn, _opts) do
        token = Nadia.Config.token()
      if Map.get(conn.path_params, "bot_token") == "bot#{token}" do
        conn
      else
      Logger.warn("Webhook request didn't provide a valid bot token")
        conn
        |> send_resp(:no_content, "")
        |> halt()
      end
    end
  end