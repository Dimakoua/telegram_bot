defmodule TelegramBot.Model.OrderItem do
  use TelegramBotWeb, :model

  schema "order_items" do
    field :name, :string
    field :count, :integer
    field :sum, :integer
    belongs_to :order, TelegramBot.Model.Order
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:order_id, :name, :count, :sum])
    |> validate_required([:order_id, :name, :count, :sum])
  end
end