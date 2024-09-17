extends Button
@export var data: SceneManager_EditorTransitionData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_open_details_panel)

func _open_details_panel():
	if not Engine.is_editor_hint() and data:
		SceneManager.load_scene_with_transition(data.to_transition_data(self), _init_new_scene)

func _init_new_scene(just_instantiated: Node):
	pass
