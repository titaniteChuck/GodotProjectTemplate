class_name Menu_ContinueButton extends SceneManager_TransitionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_button_pressed_2)
	super._ready()

func _on_button_pressed_2() -> void:
	SaveSystem.load_savefile()
