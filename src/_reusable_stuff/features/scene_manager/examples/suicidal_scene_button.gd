extends Button

@export var transition_data: SceneManager_TransitionData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(close_panel)
	pass # Replace with function body.

func close_panel():
	if transition_data:
		SceneManager.unload_scene_with_transition(transition_data.to_transition_data(self))
	else:
		get_parent().remove_child(self)
		queue_free()

func _init_new_scene(just_instantiated: Node):
	pass
