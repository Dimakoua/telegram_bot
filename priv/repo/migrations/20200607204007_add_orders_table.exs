defmodule TelegramBot.Repo.Migrations.AddOrdersTable do
  use Ecto.Migration

  def change do
    create table("orders") do
      add :user_id, :integer
      add :sum, :integer
      timestamps()
    end
    create index("orders", [:user_id])
  end
end
