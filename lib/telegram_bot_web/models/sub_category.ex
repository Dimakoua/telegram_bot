defmodule TelegramBot.Model.Sub_Category do
  use TelegramBotWeb, :model
  
    schema "sub_category" do
      field :name, :string  
      belongs_to :category, TelegramBot.Model.Category
      has_many :products, TelegramBot.Model.Products
    end
  
    @doc """
    Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [:name,:category_id])
      |> validate_required([:name])
      |> unique_constraint(:name)
    end
  end