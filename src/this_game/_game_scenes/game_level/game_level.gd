class_name GameLevel extends Node

@export var level_data: GameLevelData: set = _set_level_data
@export var back_to_level_selection_transition_data: SceneManager_TransitionData
@onready var results: ItemSystem_UI_InventorySlots = %Results
@onready var ingredients: ItemSystem_UI_InventorySlots = %Ingredients
@onready var inventory: ItemSystem_UI_InventorySlots = %Inventory
@onready var crafting_machine: BoxContainer = %Crafting_Machine
@onready var on_victory_h_box_container: HBoxContainer = %OnVictory_HBoxContainer
@onready var back_to_level_selection_button: Button = %BackToLevelSelection_Button

func _set_level_data(new_level_data: GameLevelData) -> void:
	level_data = new_level_data
	_read_model()

func _read_model() -> void:
	if not is_inside_tree(): await ready
	assert(level_data)
	inventory.inventory = level_data.inventory
	results.inventory = level_data.result_inventory
	ingredients.inventory = level_data.ingredients_inventory
	ItemSystem.RecipeService.recipes = level_data.level_recipes

func _ready() -> void:
	on_victory_h_box_container.modulate = Color.TRANSPARENT
	back_to_level_selection_button.pressed.connect(_on_back_to_level_selection)
	ItemSystem.RecipeService.recipe_crafted.connect(_check_if_level_is_solved)


func _on_back_to_level_selection() -> void:
	assert(back_to_level_selection_transition_data)
	SceneManager.play_transition(self, back_to_level_selection_transition_data)
	
func _check_if_level_is_solved(crafted_recipe: ItemSystem_Recipe) -> void:
	var s1 = crafted_recipe.resource_path
	var s2 = level_data.recipe_to_win.resource_path
	if crafted_recipe.id == level_data.recipe_to_win.id:
		level_data.solved = true
		on_victory_h_box_container.modulate = Color.WHITE
		
