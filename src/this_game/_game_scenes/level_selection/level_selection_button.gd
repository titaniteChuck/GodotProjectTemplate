class_name LevelSelectionButton extends Button

@export var level_data: GameLevelData: set= _set_level_data
@export var transition_data: SceneManager_TransitionData

func _set_level_data(value: GameLevelData) -> void:
	level_data = value
	_read_model()

func _read_model() -> void:
	_update_ui()

func _update_ui() -> void:
	if not is_inside_tree(): await draw
	text = str(get_index())
	var texture := StyleBoxFlat.new()
	if level_data.solved:
		texture.bg_color = Color("689f00")
	elif level_data.unlocked:
		texture.bg_color = Color("b7b700")
	else: 
		texture.bg_color = Color.BLACK
		disabled = true
	add_theme_stylebox_override("normal", texture)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_button_pressed)
	custom_minimum_size = Vector2(100, 100)
	name = "LevelSelectionButton_"+str(get_index())
	SceneManager.node_loaded.connect(_init_game_level)
	pass # Replace with function body.

func _on_button_pressed() -> void:
	if transition_data:
		SceneManager.play_transition(get_parent().get_parent(), transition_data)

func _init_game_level(associated_transition_data: SceneManager_TransitionData, gamelevel: Node) -> void:
	if transition_data == associated_transition_data:
		gamelevel.level_data = level_data

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
