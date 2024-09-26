class_name ItemSystem_Recipe extends Resource

# TODO: With godot 4.4, to retest with typed dictionaries
@export var ingredients: Array[ItemSystem_ItemStack]
@export var results: Array[ItemSystem_ItemStack]


func can_be_crafted_with(to_evaluate: Array[ItemSystem_ItemStack]) -> bool:
	to_evaluate = to_evaluate.filter(func(stack): return stack != null)
	return to_evaluate.all(_stack_matches_recipe)
	
func _stack_matches_recipe(from_input: ItemSystem_ItemStack) -> bool:
	return ingredients.any(func(from_recipe: ItemSystem_ItemStack) -> bool: return 	from_recipe.item.id == from_input.item.id\
																					and from_input.quantity >= from_recipe.quantity)
