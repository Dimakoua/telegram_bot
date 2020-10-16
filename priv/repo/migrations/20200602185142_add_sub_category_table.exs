defmodule TelegramBot.Repo.Migrations.AddSubCategoryTable do
  use Ecto.Migration

  def change do
    create table("sub_category") do
      add :name,    :string, size: 40
      add :category_id, references("category")
    end
    create index("sub_category", [:name])
  end
end
