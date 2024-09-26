class_name ItemSystem_RecipeService extends Node

@export var recipes: Array[ItemSystem_Recipe]

func craft_recipe(inventory: ItemSystem_Inventory, ingredients: Array[ItemSystem_ItemStack], consume_ingredients := true) -> Array[ItemSystem_ItemStack]:
	var output: Array[ItemSystem_ItemStack] = []
	var matching_recipes: Array[ItemSystem_Recipe] = recipes.filter(func(rec: ItemSystem_Recipe) -> bool: return rec.can_be_crafted_with(ingredients))
	if not matching_recipes.is_empty():
		var selected_recipe = matching_recipes[0]
		if (not consume_ingredients) or inventory.remove_items_in_bulk(selected_recipe.ingredients) == OK:
			output = selected_recipe.results
	return output
