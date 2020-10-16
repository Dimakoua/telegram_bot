defmodule TelegramBot.Model.Order do
  use TelegramBotWeb, :model

  schema "orders" do
    field :user_id, :integer
    field :sum, :integer
    has_many :order_items, TelegramBot.Model.OrderItem
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :sum])
    |> validate_required([:user_id,:sum])
  end
end