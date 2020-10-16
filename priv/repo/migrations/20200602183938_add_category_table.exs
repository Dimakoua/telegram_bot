defmodule TelegramBot.Repo.Migrations.AddCategoryTable do
  use Ecto.Migration

  def change do
    create table("category") do
      add :name,    :string, size: 40
    end
    create unique_index(:category, [:name], name: :category_index)
  end
end
