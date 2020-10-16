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

    def send_message(conn, %{"text" => message}) do
        Nadia.send_message(590575618, message, [reply_markup: %Nadia.Model.InlineKeyboardMarkup{
          inline_keyboard: [
            [
              %{
                callback_data: "/set_language en",
                text: "English",
              },
              %{
                callback_data: "/set_language ru",
                text: "Russian",
              },
            ]
          ],
        }])
        render(conn, "chat.html",  token: get_csrf_token())
    end

    def test(conn, _params) do
      # text = "text(1)"
      # param1 <>"(" <> param2 <>")" = text
      # IO.inspect param1
      # IO.inspect param2
      text = "Регіна 12грн (0)"
      query = from u in "category",
          select: %{"text" => u.name, "callback_data" => u.id}
      category = Repo.all(query)
      |> Enum.map(fn %{"text" => name, "callback_data" => id} -> %{"text" => name, "callback_data" => "/category#{id}"} end) 
    # Nadia.send_message(chat_id, "sdsd")
      conn |> json(category)
    end
  end
