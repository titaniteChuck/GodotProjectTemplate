class_name Utils extends Object

static func delete_node(node: Node, free_children_first: bool = false) -> void:
	if not is_instance_valid(node):
		return
	if free_children_first:
		delete_children(node, free_children_first)
	if is_instance_valid(node.get_parent()):
		node.get_parent().remove_child(node)

	if is_instance_valid(node):
		node.queue_free()

static func delete_children(node: Node, free_children_first: bool = false) -> void:
	if not is_instance_valid(node):
		return
	for child in node.get_children():
		if free_children_first: delete_children(child, free_children_first)
		node.remove_child(child)
		child.queue_free()
