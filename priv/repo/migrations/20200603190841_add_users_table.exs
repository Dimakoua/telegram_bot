defmodule TelegramBot.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table("users") do
      add :first_name,   :string, size: 80
      add :last_name,    :string, size: 80
      add :phone_number, :string, size: 80
      add :user_id,      :integer
    end
    create unique_index(:users, [:user_id], name: :users_index)
  end
end
