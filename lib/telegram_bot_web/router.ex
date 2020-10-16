defmodule TelegramBotWeb.Router do
  use TelegramBotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :telegram do
    plug :accepts, ["json"]
    plug TelegramBot.BotToken
    plug TelegramBot.Registration
    plug TelegramBot.Is_Regisered
    plug Plug.Parsers,
    parsers: [:urlencoded, :json],
      json_decoder: {Jason, :decode!, [[keys: :atoms]]},
      pass: ["*/*"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TelegramBotWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/setwebhook", AdminController, :set_webhook    
    post "/setwebhook", AdminController, :set_webhook    
    get "/chat", AdminController, :chat    
    post "/send-message", AdminController, :send_message    
    get "/test", AdminController, :test    
    
  end

  pipe_through :telegram
  scope "/webhook/:bot_token", TelegramBotWeb do
    post "/", TelegramController, :update
  end

  # Other scopes may use custom stacks.
  # scope "/api", TelegramBotWeb do
  #   pipe_through :api
  # end
end
