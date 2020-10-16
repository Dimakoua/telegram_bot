defmodule TelegramBot.Model.User do
    use TelegramBotWeb, :model
  
    schema "users" do
      field :first_name,   :string
      field :last_name,    :string
      field :phone_number, :string
      field :user_id,      :integer
    end
  
    @doc """
    Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [:first_name,:last_name,:phone_number,:user_id])
      |> validate_required([:phone_number])
      |> unique_constraint(:user_id,name: :users_index)
    end
  end