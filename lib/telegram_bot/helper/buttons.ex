defmodule TelegramBot.Helper.Buttons do
    def menu() do
        %Nadia.Model.ReplyKeyboardMarkup{
            keyboard: [
              [
                %{text: "📖Меню"},
                %{text: "Корзина"}
              ],
              [
                %{text: "Допомога"},
                %{text: "Про нас"}
              ]
              ],
            resize_keyboard: :true,
            one_time_keyboard: :true
        }
    end
    def bucket_keyboard do
        %Nadia.Model.InlineKeyboardMarkup{
            inline_keyboard: [
                [%{text: "Очистити корзину", callback_data: "/clean_bucket"}],
                [%{text: "Редагувати замовлення", callback_data: "/edit"}],
                [%{text: "Підтвердити замовлення", callback_data: "/approve"}]
            ]
        }
    end
    def navigate_buttons() do
        [
            %{"text" => "<<<","callback_data" => "/next"},
            %{"text" => ">>>","callback_data" => "/prev"}
        ]
    end
    def back_button(name) do
        [
            %{"text" => "Назад","callback_data" => "/backto_#{name}"}
        ]
    end
    def plus_minus(id) do
        [
            %{"text" => "+","callback_data" => "/plus#{id}"},
            %{"text" => "-","callback_data" => "/minus#{id}"}
        ]
    end
    def approve() do
        [
            %{"text" => "Підтвердити","callback_data" => "/approve"},
        ]
    end
end