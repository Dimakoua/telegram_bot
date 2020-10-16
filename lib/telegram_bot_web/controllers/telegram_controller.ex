defmodule TelegramBotWeb.TelegramController do
  use TelegramBotWeb, :controller
  alias TelegramBot.Repo
  alias TelegramBot.Model.User
  alias TelegramBot.Model.Category
  alias TelegramBot.Model.Sub_Category
  alias TelegramBot.Model.Products
  alias TelegramBot.Bucket
  alias TelegramBot.Helper.Buttons
  alias TelegramBot.Model.Order
  alias TelegramBot.Model.OrderItem
  require Logger
  @limit 100
  
  def update(conn, params) do
    chat_id = get_in(params, ["message", "chat", "id"])
    Nadia.send_chat_action(chat_id, :typing)
    case get_in(params, ["message", "text"]) do
      nil -> parse_callback(chat_id, params)
      message -> parse_commands(chat_id, message)
    end
    conn
    |> render(:update)
  end

  def registration_msg(chat_id) do
    Nadia.send_message(chat_id, "Перш ніж розпочати роботу з ботом зареєструйтесь",[reply_markup: %Nadia.Model.ReplyKeyboardMarkup{
    keyboard: [[%Nadia.Model.KeyboardButton{text: "Відправити номер", request_contact: true}]],
    resize_keyboard: :true,
    one_time_keyboard: :true
    }])
  end

  def registration(contact,chat_id) do
    changeset = User.changeset(%User{},contact)
    case Repo.insert(changeset) do
    {:ok, _params} -> 
        Nadia.send_message(chat_id, "Успішно зареєстровано")
        send_menu(chat_id)
        :ok
    _ -> 
        Nadia.send_message(chat_id, "Здається щось пішло не за планом")
        :error
    end
  end

  defp parse_callback(chat_id, callback_query) do
    chat_id = get_in(callback_query, ["callback_query","message", "chat", "id"])
        case Bucket.get(chat_id) do
          nil -> Bucket.put(chat_id, %{})
          map -> {:ok, "has already started"}
        end
    parse_commands(chat_id, callback_query)
  end

  defp parse_commands(chat_id, "/start") do
    Nadia.send_message(chat_id, "Привіт!",[reply_markup: Buttons.menu()])
  end

  defp parse_commands(chat_id, "/help") do
    Nadia.send_message(chat_id, "message help")
  end

  defp parse_commands(chat_id, "Допомога") do
    Nadia.send_message(chat_id, "З усіх питань звертатися за адресою dimakoua@gmail.com")
  end

  defp parse_commands(chat_id, "📖Меню") do
    query = from u in "category", select: %{"text" => u.name, "callback_data" => u.id}, limit: @limit
    category = Repo.all(query) 
    |> Enum.map(fn %{"text" => name, "callback_data" => id} -> [%{"text" => name, "callback_data" => "/category#{id}"}] end)
    send_menu(chat_id, "Оберіть категорію")
    Nadia.send_message(chat_id, "Категорії", [reply_markup: %Nadia.Model.InlineKeyboardMarkup{
      inline_keyboard: category,
    }])
  end

  defp parse_commands(chat_id, %{"callback_query" => %{"data" => "/menu", "message" => %{"message_id" => msg_id}}, "update_id" => update_id}) do
    query = from u in "category", select: %{"text" => u.name, "callback_data" => u.id}, limit: @limit
    category = Repo.all(query) |> Enum.map(fn %{"text" => name, "callback_data" => id} -> [%{"text" => name, "callback_data" => "/category#{id}"}] end)
    Nadia.edit_message_reply_markup(chat_id, msg_id, update_id, [reply_markup: %Nadia.Model.InlineKeyboardMarkup{ inline_keyboard: category }])
  end

  defp parse_commands(chat_id, "Корзина") do
    # беремо корзину і перевіряємо чи там вже шось є
    bucket = Bucket.get(chat_id)
    cond do 
      bucket == nil -> Nadia.send_message(chat_id, "Корзина порожня", [parse_mode: "Markdown", reply_markup: Buttons.menu()])
      true ->
        bucket = Map.delete(bucket, "0")
        # формуємо текст з товарами який буде відображено в корзині і рахуємо загальну суму замовлення
        {text, total} = 
          bucket 
          |> Enum.reduce({"Ваше замовлення:",0}, fn {id, %{"count" => count}},{acc,total} -> 
            query = from u in "products",
                    where: u.id == ^id,
                    select: %{"name" => u.name, "price" => u.price}
            %{"name" => name, "price" => price} = Repo.one!(query) |> IO.inspect label: "name"

            bucket = Bucket.get(chat_id)
            new_bucket = bucket
                |> Map.get(id)
                |> Map.put("name", name)
                |> Map.put("sum", count*price)

            Bucket.put(chat_id,%{bucket | id => new_bucket})
            {acc <> "\n   -- #{name} x#{count} * #{count*price}грн *",total = total + count*price}
          end)
          # додаємо до корзини загальну суму замовлення
          bucket = Bucket.get(chat_id)
          new_bucket = Map.put(bucket, "0", %{id: 0, count: 0, sum: total, name: "Всього"})
          Bucket.put(chat_id,new_bucket)
          Bucket.get(chat_id)
          
          text = text <> "\nВсього: #{total} грн"
          Nadia.send_message(chat_id, text, [parse_mode: "Markdown", reply_markup: Buttons.bucket_keyboard()])
      end
  end

  defp parse_commands(chat_id,  %{"callback_query" => %{"data" => "/clean_bucket", "message" => %{"text" => text,"message_id" => msg_id}}}) do
    Bucket.put(chat_id,nil)
    parse_commands(chat_id, "Корзина")
    Nadia.delete_message(chat_id, msg_id)
    Nadia.delete_message(chat_id, msg_id - 1)
  end

  defp parse_commands(chat_id,  %{"callback_query" => %{"data" => "/approve", "from" =>%{"id" => user_id}, "message" => %{"text" => text,"message_id" => msg_id}},"update_id" => update_id}) do
    
    bucket = Bucket.get(chat_id)
    sum = bucket |> Map.get("0") |> Map.get(:sum)
    changeset = Order.changeset(%Order{},%{user_id: user_id, sum: sum})
    case Repo.insert(changeset) do
      {:ok, order} -> 
        bucket = Map.delete(bucket, "0")

        bucket 
        |> Enum.each(fn {id, %{"count" => count_item, "id" => id, "name" => name, "sum" => sum}} ->
          changeset = OrderItem.changeset(%OrderItem{},%{name: name, count: count_item, sum: sum, order_id: order.id})
          case Repo.insert(changeset) do
            {:ok, order_item} -> :ok
            {:error, msg} -> 
              Logger.error(msg)
              Nadia.send_message(chat_id, "Виникла помилка при підтвердженні")
          end
         end)
         Nadia.delete_message(chat_id, msg_id)
         Nadia.delete_message(chat_id, msg_id - 1)
         Nadia.send_message(chat_id, "Успішно підтвердженно", [reply_markup: Buttons.menu])
      {:error, msg} -> 
        Logger.error(msg)
        Nadia.send_message(chat_id, "Виникла помилка при підтвердженні")
    end
  end

  defp parse_commands(chat_id, %{"callback_query" => %{"data" => "/category"<>id, "message" => %{"message_id" => msg_id}}, "update_id" => update_id}) do
    query = from u in "sub_category",
            where: u.category_id == ^id,
            select: %{"text" => u.name, "callback_data" => u.id}
    sub_category = 
            Repo.all(query) 
                |> Enum.map(fn %{"text" => name, "callback_data" => id} -> 
                  [%{"text" => name, "callback_data" => "/sub_category#{id}"}] 
                end)
    sub_category = sub_category |> List.insert_at(-1,Buttons.back_button("category"))

    Nadia.edit_message_reply_markup(chat_id, msg_id, update_id, [reply_markup: %Nadia.Model.InlineKeyboardMarkup{ inline_keyboard: sub_category }])
  end
  
  defp parse_commands(chat_id,  %{"callback_query" => %{"data" => "/sub_category"<>id, "message" => %{"message_id" => msg_id}}, "update_id" => update_id}) do
    query = from products in Products,
    left_join: sub_category in Sub_Category, on: products.sub_category_id == sub_category.id,
    where: products.sub_category_id == ^id,
    preload: [:sub_category]

    products = 
          Repo.all(query) 
              |> Enum.map(fn item -> 
                product = Bucket.get(chat_id) |> Map.get("#{item.id}")
                count = case product do
                  nil -> 0
                  product -> Map.get(product,"count")
                end
                [%{"text" => "#{item.name} #{item.price}грн (#{count})", "callback_data" => "/product#{item.id}", "category_id"=> item.sub_category.category_id}] 
              end)
    case products do 
      []     -> Nadia.send_message(chat_id,"Товарів нема")
      _else  -> 
        category_id = 
          products 
            |> List.first 
            |> List.first
            |> Map.get("category_id")
        products = products  |> List.insert_at(-1,Buttons.back_button("sub_category#{category_id}")) |> IO.inspect
        Nadia.edit_message_reply_markup(chat_id, msg_id, update_id, [reply_markup: %Nadia.Model.InlineKeyboardMarkup{ inline_keyboard: products }])
      end
  end

  defp parse_commands(chat_id, %{"callback_query" => %{"data" => "/product"<>id, "message" => %{"message_id" => msg_id, "reply_markup" => reply_markup}}, "update_id" => update_id} ) do
    %{"inline_keyboard" => keyboard} = reply_markup
    add_to_bucket(chat_id,id)
    keyboard = get_new_keyboard(chat_id,keyboard,id) 
    # додаємо товар в корзину
    Nadia.edit_message_reply_markup(chat_id, msg_id,update_id,[reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboard}])
    send_menu(chat_id, "")
  end

  defp parse_commands(chat_id,  %{"callback_query" => %{"data" => "/backto_"<>name, "message" => %{"message_id" => msg_id}}, "update_id" => update_id}) do
    case name do
      "category" -> parse_commands(chat_id, %{"callback_query" => %{"data" => "/menu", "message" => %{"message_id" => msg_id}}, "update_id" => update_id})
      "sub_category" <> id -> parse_commands(chat_id, %{"callback_query" => %{"data" => "/category"<>id, "message" => %{"message_id" => msg_id}}, "update_id" => update_id})
    end
  end

  defp parse_commands(chat_id,  %{"callback_query" => %{"data" => "/edit", "message" => %{"message_id" => msg_id, "reply_markup" => reply_markup}}, "update_id" => update_id}) do
    bucket = Bucket.get(chat_id)
    {_, keyboard} = bucket 
            |> Map.delete("0") 
            |> Enum.map_reduce([], fn { id, %{"count" => count, "name" => name, "id" => id, "sum" => sum}},acc ->
        plus_minus = Buttons.plus_minus(id)
        el = %{"callback_data" => "/","text" => "#{name} - #{sum}грн (#{count})"}
        {el,acc ++ [[el],plus_minus]}
    end)
    approve = Buttons.approve()
    Nadia.edit_message_reply_markup(chat_id, msg_id, update_id, [reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboard ++ [approve]}])
  end

  defp parse_commands(chat_id,  %{"callback_query" => %{"data" => "/plus"<>product_id, "message" => %{"message_id" => msg_id, "reply_markup" => reply_markup}}, "update_id" => update_id}) do
    count_plus(chat_id,product_id) 
    bucket = Bucket.get(chat_id) |> IO.inspect
    {map, keyboard} = bucket 
            |> Map.delete("0") 
            |> Enum.map_reduce([], fn { id, %{"count" => count, "name" => name, "id" => id, "sum" => sum}},acc ->
        plus_minus = Buttons.plus_minus(id)
        el = %{"callback_data" => "/plus"<>id,"text" => "#{name} - #{sum}грн (#{count})"}
        {el,acc ++ [[el],plus_minus]}
    end)
    Nadia.edit_message_reply_markup(chat_id, msg_id, update_id, [reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboard }])
  end

  defp parse_commands(chat_id,  %{"callback_query" => %{"data" => "/minus"<>product_id, "message" => %{"message_id" => msg_id, "reply_markup" => reply_markup}}, "update_id" => update_id}) do
    count_minus(chat_id,product_id) 
    bucket = Bucket.get(chat_id) |> IO.inspect
    {map, keyboard} = bucket 
            |> Map.delete("0") 
            |> Enum.map_reduce([], fn { id, %{"count" => count, "name" => name, "id" => id, "sum" => sum}},acc ->
        plus_minus = Buttons.plus_minus(id)
        el = %{"callback_data" => "/plus"<>id,"text" => "#{name} - #{sum}грн (#{count})"}
        {el,acc ++ [[el],plus_minus]}
    end)
    Nadia.edit_message_reply_markup(chat_id, msg_id, update_id, [reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboard }])
  end

  defp parse_commands(chat_id, "Читати інструкцію") do
    Nadia.send_message(chat_id, "sub_categoty корзина")
  end

  defp parse_commands(chat_id, _params) do
    Nadia.send_message(chat_id, "Невідома команда")
    send_menu(chat_id)
  end

  defp parse_callback(chat_id, %{"message" => %{"contact" => contacts}}) do
    changeset = User.changeset(%User{},contacts)
    case Repo.insert(changeset) do
      {:ok, _params} -> 
        Nadia.send_message(chat_id, "Успішно зареєстровано")
        send_menu(chat_id)
      _ -> Nadia.send_message(chat_id, "Здається щось пішло не за планом")
    end
  end

  defp send_menu(chat_id, text\\ "Меню") do
    Nadia.send_message(chat_id, text, [reply_markup: Buttons.menu()])
  end

  defp get_new_keyboard(chat_id,keyboard,id) do
    keyboard |> Enum.map(fn item -> 
      case item do
        [%{"callback_data" => "/product"<>product_id, "text" => text}] ->
          [product, price, _count] = String.split(text, " ")
          product_b = Bucket.get(chat_id) |> Map.get(product_id)
          count_int = case product_b do
            nil -> 0
            product_b -> 
              case Map.get(product_b,"count") do
                nil -> 0
                count -> count
              end
          end
          [%{"callback_data" => "/product#{product_id}", "text" => "#{product} #{price} (#{count_int})"}]
        [params] -> [params]
      end
    end)
  end

  defp add_to_bucket(chat_id,id) do
    bucket = Bucket.get(chat_id)
    count_exist? = Bucket.get(chat_id) |> Map.get(id)
    new_bucket = 
      case count_exist? do
        nil -> Map.put(bucket,id, %{"id" => id, "count" => 1})
        %{"count" => count, "id" => id} -> 
          Map.put(bucket, id, %{"id" => id, "count" => count + 1})
      end
    Bucket.put(chat_id,new_bucket)
  end

  defp count_plus(chat_id,id) do
    bucket = Bucket.get(chat_id)
    count_exist? = Bucket.get(chat_id) |> Map.get(id)
    new_bucket = 
    case count_exist? do
      nil -> bucket
      map ->
        count = Map.get(map,"count")
        new_map = Map.get(bucket,id) |> Map.put("count",count + 1)
        Map.put(bucket, id, new_map)
    end
    Bucket.put(chat_id,new_bucket)
  end

  defp count_minus(chat_id,id) do
    bucket = Bucket.get(chat_id)
    count_exist? = Bucket.get(chat_id) |> Map.get(id)
    new_bucket = 
    case count_exist? do
      nil -> bucket
      map -> 
        count = Map.get(map,"count")
        new_map = Map.get(bucket,id) |> Map.put("count",count - 1)
        Map.put(bucket, id, new_map)
    end
    Bucket.put(chat_id,new_bucket)
  end
end

# KeyboardButton
# [reply_markup: %Nadia.Model.ReplyKeyboardMarkup{
#   keyboard: [
#     [
#       %{
#         callback_data: "/set_language en",
#         text: "Читати інструкцію",
#       }
#     ]
#   ],
#   resize_keyboard: :true,
#   one_time_keyboard: :true
# }]