extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.hide_section.connect(_hide_section)
	SignalBus.show_section.connect(_show_section)
	#SceneManager.scene_tree.node_added.connect(SceneManager.update_gui_tree)
	#SceneManager.scene_tree.node_removed.connect(SceneManager.update_gui_tree)
	#SceneManager.scene_tree.node_renamed.connect(SceneManager.update_gui_tree)


func _process(delta: float) -> void:
	pass
	#var screen_resolution: Vector2 = DisplayServer.screen_get_size(DisplayServer.get_screen_from_rect(get_viewport_rect()))
	#viewport.size = screen_resolution

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
