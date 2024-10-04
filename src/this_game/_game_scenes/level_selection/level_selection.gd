class_name LevelSelection extends Node

@export var levels_parent: Node
@export var transition_data: SceneManager_TransitionData

func _ready() -> void:
	if levels_parent and GameLevelService.levels:
		for child in levels_parent.get_children():
			levels_parent.remove_child(child)
			child.queue_free()
		for i in range(GameLevelService.levels.size()):
			var level_button := LevelSelectionButton.new()
			levels_parent.add_child(level_button)
			if transition_data:
				level_button.transition_data = transition_data.duplicate(true)
			level_button.level_data = GameLevelService.levels[i]
