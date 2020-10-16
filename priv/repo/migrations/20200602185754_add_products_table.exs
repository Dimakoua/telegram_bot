defmodule TelegramBot.Repo.Migrations.AddProductsTable do
  use Ecto.Migration

  def change do
    create table("products") do
      add :name,    :string, size: 80
      add :price,   :integer
      add :sub_category_id, references("sub_category")
    end
    create index("products", [:name])
  end
end
