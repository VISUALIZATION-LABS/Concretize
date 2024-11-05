class_name ContextMenu
extends Control

signal id_pressed(id: int)

var panel: PanelContainer = PanelContainer.new()
var	vbox_container: VBoxContainer = VBoxContainer.new()

# TODO: Implement submenus
# TODO: Style

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Build up ui
	
	panel.custom_minimum_size = Vector2(150, 0)
	add_child(panel)
	panel.add_child(vbox_container)


func add_item(name: String, idx: int = -1) -> void:
	var button: Button = Button.new()
	button.text = name
	button.set_meta("Index", idx)
	
	#if idx < 0:
	vbox_container.add_child(button)
	#else:
	#	vbox_container.add_child(button)
	#	vbox_container.move_child(button, idx)
	
	button.pressed.connect(_emit_button_pressed_id.bind(button))

func add_submenu(name: String, menu: ContextMenu, idx: int = -1,) -> void:
	var button: Button = Button.new()
	button.text = name
	button.set_meta("Index", idx)

	button.add_child(menu)
	
	menu.position.x += panel.size.x
	
	#if idx < 0:
	vbox_container.add_child(button)
	#else:
	#	vbox_container.add_child(button)
	#	vbox_container.move_child(button, idx)

func _emit_button_pressed_id(button: Button) -> void:
	id_pressed.emit(button.get_index())

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		await SceneManager.scene_tree.create_timer(0.1).timeout
		self.free()
