class_name GameLevel_Service extends Node

@export var levels: Array[GameLevelData] = []: set = _set_levels

func _set_levels(array: Array[GameLevelData]):
	levels = array
	for lvl in levels:
		if not lvl.level_solved.is_connected(_on_level_solved):
			lvl.level_solved.connect(_on_level_solved)
			
func _ready() -> void:
	SaveSystem.save_requested.connect(_on_save_requested)
	SaveSystem.load_requested.connect(_on_load_requested)
	
	if levels.size() > 0:
		levels[0].unlocked = true


func _on_level_solved(_level: GameLevelData) -> void:
	_unlock_next_level()

func _unlock_next_level():
	for level in levels:
		if not level.unlocked:
			level.unlocked = true
			break

func _on_save_requested() -> void:
	SaveSystem.save_entity("levels_data", levels)

func _on_load_requested() -> void:
	levels = SaveSystem.load_entity("levels_data")
