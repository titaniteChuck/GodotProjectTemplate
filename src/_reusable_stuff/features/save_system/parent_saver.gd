class_name ParentSaver extends Node

@export var properties_to_save: Array[String] = []

var node_to_monitor = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveSystem.save_requested.connect(_on_save_requested)
	SaveSystem.load_requested.connect(_on_load_request)
	node_to_monitor = get_parent()
	pass # Replace with function body.

func _on_save_requested():
	var list: Array[String] = []
	for prop in node_to_monitor.get_property_list():
		if prop.type != Variant.Type.TYPE_NIL:
			list.append(prop.name)
		if node_to_monitor.get(prop.name) is Resource:
			SaveSystem.save_entity(node_to_monitor.get_path().get_concatenated_names()+":"+prop.name, node_to_monitor.get(prop.name))
	

func _on_load_request():
	var list: Array[String] = []
	for prop in node_to_monitor.get_property_list():
		if prop.type != Variant.Type.TYPE_NIL:
			list.append(prop.name)
		if node_to_monitor.get(prop.name) is Resource:
			var saved_resource = SaveSystem.load_entity(node_to_monitor.get_path().get_concatenated_names()+":"+prop.name)
			node_to_monitor.set(prop.name, saved_resource)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
