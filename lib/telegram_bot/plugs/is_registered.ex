defmodule TelegramBot.Is_Regisered do
    @behaviour Plug
    import Plug.Conn
    require Logger
    alias TelegramBot.Repo
    alias TelegramBot.Model.User
    @impl Plug
    
    def init(opts), do: opts
    
    @impl Plug
    def call(conn, _opts) do
        case Map.get(conn.params, "message") do
            nil -> conn
            message -> 
                id = 
                message |> Map.get("chat")
                        |> Map.get("id")
                case Repo.get_by(User, user_id: id) do
                    nil ->  TelegramBotWeb.TelegramController.registration_msg(id)
                            conn
                            |> send_resp(:no_content, "")
                            |> halt()
                    user -> conn
                end
        end  
    end
  end 