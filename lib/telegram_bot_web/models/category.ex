defmodule TelegramBot.Model.Category do
    use TelegramBotWeb, :model
  
    schema "category" do
      field :name, :string
      has_many :category, TelegramBot.Model.Sub_Category
    end
  
    @doc """
    Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [:name])
      |> validate_required([:name])
      |> unique_constraint(:name)
    end
  end