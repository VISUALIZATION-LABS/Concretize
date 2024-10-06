extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.hide_section.connect(_hide_section)
	SignalBus.show_section.connect(_show_section)

func _hide_section(type: String) -> void:
	var ui_node: Control = get_node(type)

	if ui_node == null:
		push_error("Requested ui section \"%s\" doesn't exist." % type)
		return
	
	ui_node.hide()

func _show_section(type: String) -> void:
	var ui_node: Control = find_child(type)

	if ui_node == null:
		push_error("Requested ui section \"%s\" doesn't exist." % type)
		return

	ui_node.show()