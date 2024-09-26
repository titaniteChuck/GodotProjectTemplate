class_name ItemSystem_UI_InventorySlots extends Control

@export var inventory: ItemSystem_Inventory:
	set(value):
		if inventory != value:
			inventory = value
			_read_model()
@export var ui_slots: Array[ItemSystem_UI_ItemSlot]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_slots()
	pass # Replace with function body.
	
func _init_slots():
	if not ui_slots:
		ui_slots = []
		ui_slots.assign(get_children().filter(func(child): return child is ItemSystem_UI_ItemSlot))
	
	
func _read_model():
	if not is_inside_tree(): await draw
	if inventory:
		inventory.changed.connect(_update_ui)
		for item in inventory.item_stacks:
			item.changed.connect(_update_ui)
		inventory.set_minimum_size(ui_slots.size())
		for index in range(0, ui_slots.size()):
			ui_slots[index].part_of_inventory = inventory
			ui_slots[index].slot_index = index
		_update_ui()

func _update_ui():
	if not is_inside_tree(): await draw
