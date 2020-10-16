defmodule TelegramBot.Registration do
    @behaviour Plug
    import Plug.Conn
    require Logger
    alias TelegramBot.Repo
    alias TelegramBot.Model.User
    @impl Plug
    
    def init(opts), do: opts
    
    @impl Plug
    def call(conn, _opts) do
        chat_id = get_chat_id(conn)
        contact = get_contact(conn)
        case contact do
            nil -> conn
            contact -> 
            case TelegramBotWeb.TelegramController.registration(contact,chat_id) do
                :ok -> conn
                :error -> conn
                            |> send_resp(:no_content, "")
                            |> halt() 
            end
        end
    end 
    defp get_chat_id(conn) do
        case Map.get(conn.params, "message") do
            nil -> 590575618 #my id
            message -> 
                message |> Map.get("chat")
                        |> Map.get("id")
        end
    end
    defp get_contact(conn) do
        case Map.get(conn.params, "message") do
            nil -> nil
            message -> message |> Map.get("contact")
        end
    end
end