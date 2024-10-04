class_name GameLevelData extends Resource

signal level_solved(level: GameLevelData)

@export var id: String
@export var inventory: ItemSystem_Inventory = ItemSystem_Inventory.new()
@export var result_inventory: ItemSystem_Inventory = ItemSystem_Inventory.new()
@export var ingredients_inventory: ItemSystem_Inventory = ItemSystem_Inventory.new()
@export var solved := false:
	set(value):
		solved = value
		level_solved.emit(self)
@export var unlocked := false
@export var recipe_to_win: ItemSystem_Recipe
@export var level_recipes: Array[ItemSystem_Recipe] = []
