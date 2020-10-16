defmodule TelegramBot.Repo.Migrations.AddOrderItemsTable do
  use Ecto.Migration

  def change do
    create table("order_items") do
      add :order_id, references("orders")
      add :name, :string, size: 80
      add :count, :integer
      add :sum, :integer
      timestamps()
    end
    create index("order_items", [:order_id])
  end
end
