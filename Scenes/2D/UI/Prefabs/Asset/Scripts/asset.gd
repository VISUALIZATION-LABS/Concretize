extends Control

@onready var preview: TextureRect = $PanelContainer/VBoxContainer/Preview
@onready var title: RichTextLabel = $PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/Title
@onready var description: RichTextLabel = $PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/Description
var object_class: String = "local"
var title_text: String = ""
var description_text: String = ""
var preview_texture: ImageTexture = null

signal selected(node: Control)

var node: Node3D = null
var is_selectable: bool = false
var is_addable: bool = true

func _ready() -> void:
	$PanelContainer.gui_input.connect(_self_input)
	if is_addable:
		$AddButton.pressed.connect(_add_node_to_tree)
		$AddButton.text = "Add"
	else:
		$AddButton.pressed.connect(_add_node_to_tree)
		$AddButton.text = "Remove"
	
	if not title_text.is_empty():
		title.text = title_text
	
	if not description_text.is_empty():
		description.text = description_text
		
	if not preview_texture == null:
		preview.texture = preview_texture

func _remove_self() -> void:
	self.queue_free()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && $Panel.visible:
			$Panel.visible = false

func _self_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if $Panel.visible == false:
				selected.emit(self)
				
			$Panel.visible = !$Panel.visible 

func _add_node_to_tree() -> void:
	if node != null:
		SceneManager.scene_tree.current_scene.add_child(node.duplicate(), true)
		SceneManager.project_scene_tree.update_tree()
	else:
		push_error("No mesh to add.")

func set_preview_texture(texture: ImageTexture) -> void:
	preview.texture = texture

func set_title(text: String) -> void:
	title.text = text
	title_text = text

func set_description(text: String) -> void:
	description.text = text
	description_text = text
