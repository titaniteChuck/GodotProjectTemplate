class_name ChildrenSaver extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveSystem.save_requested.connect(_on_save_requested)
	SaveSystem.load_requested.connect(_on_load_request)
	pass # Replace with function body.

func _on_save_requested():
	SaveSystem.save_entity(get_path().get_concatenated_names()+":elements", get_children())

func _on_load_request():
	var from_save = SaveSystem.load_entity(get_path().get_concatenated_names()+":elements")
	Utils.delete_children(self)
	for el in from_save:
		add_child(el)
