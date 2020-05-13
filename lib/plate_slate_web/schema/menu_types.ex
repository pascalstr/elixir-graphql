defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation

  alias PlateSlateWeb.Resolvers

  object :menu_item_result do
    field :menu_item, :menu_item
    field :errors, list_of(:input_error)
  end

  object :menu_queries do
    field :menu_items, list_of(:menu_item) do
      arg(:filter, :menu_item_filter)
      arg(:order, type: :sort_order, default_value: :asc)
      resolve(&Resolvers.Menu.menu_items/3)
    end

    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))
      resolve(&Resolvers.Menu.search/3)
    end
  end

  object :menu_mutations do
    field :create_menu_item, :menu_item_result do
      arg(:input, non_null(:menu_item_input))
      resolve(&Resolvers.Menu.create_item/3)
    end

    field :update_menu_item, :menu_item_result do
      arg(:id, non_null(:id))
      arg(:input, non_null(:update_item_input))
      resolve(&Resolvers.Menu.update_item/3)
    end
  end

  input_object :menu_item_input do
    field :name, non_null(:string)
    field :description, :string
    field :price, non_null(:decimal)
    field :category_id, non_null(:id)
  end

  input_object :update_item_input do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :category_id, :id
  end

  object :category do
    field(:name, :string)
    field(:description, :string)

    field :items, list_of(:menu_item) do
      resolve(&Resolvers.Menu.items_for_category/3)
    end
  end

  union :search_result do
    types([:menu_item, :category])
    # Almost done...
    resolve_type(fn
      %PlateSlate.Menu.Item{}, _ ->
        :menu_item

      %PlateSlate.Menu.Category{}, _ ->
        :category

      _, _ ->
        nil
    end)
  end

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    @desc "Matching a name"
    field(:name, :string)

    @desc "Matching a category name"
    field(:category, :string)

    @desc "Matching a tag"
    field(:tag, :string)

    @desc "Priced above a value"
    field(:priced_above, :float)

    @desc "Priced below a value"
    field(:priced_below, :float)

    @desc "Added to the menu before this date"
    field(:added_before, :date)

    @desc "Added to the menu after this date"
    field(:added_after, :date)
  end

  object :menu_item do
    field(:id, :id)
    field(:name, :string)
    field(:description, :string)
    field(:price, :decimal)
    field(:added_on, :date)
  end
end
