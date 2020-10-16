defmodule TelegramBotWeb.AdminController do
    use TelegramBotWeb, :controller
    alias TelegramBot.Repo
    alias TelegramBot.Model.Sub_Category

    def set_webhook(conn, params) do
      case conn.method do
        "POST" ->
            url = get_in(params, ["url"])
            telegram_api = Application.get_env(:nadia, :telegram_api)
            token = Nadia.Config.token()
            case Nadia.set_webhook([{:url, "#{url}/webhook/bot#{token}" }]) do
              :ok -> 
                  conn 
                    |> put_flash(:info, "Вебхуки змінено")
                    |> render("admin.html",  token: get_csrf_token())
              {:error, reason} -> 
                  conn 
                    |> put_flash(:error, "Помилка " <> reason.reason)
                    |> render("admin.html",  token: get_csrf_token())
            end
        "GET" -> conn |> render("admin.html",  token: get_csrf_token())
      end
    end
    def chat(conn, _params) do
        render(conn, "chat.html",  token: get_csrf_token())
    end
  end
