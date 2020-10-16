defmodule TelegramBot.Model.Products do
  use TelegramBotWeb, :model

    schema "products" do
      field :name, :string  
      field :price, :integer
      belongs_to :sub_category, TelegramBot.Model.Sub_Category
    end

    @doc """
    Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [:name,:price])
      |> validate_required([:name,:price])
    end
  end