extends Control

@onready var preview: TextureRect = $PanelContainer/VBoxContainer/Preview
@onready var title: RichTextLabel = $PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/Title
@onready var description: RichTextLabel = $PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/Description

var node: Node3D = null

func _ready() -> void:
	$AddButton.pressed.connect(_add_node_to_tree)


func _add_node_to_tree() -> void:
	if node != null:
		SceneManager.scene_tree.current_scene.add_child(node.duplicate(), true)

func set_preview_texture(texture: ImageTexture) -> void:
	preview.texture = texture

func set_title(text: String) -> void:
	title.text = text

func set_description(text: String) -> void:
	description.text = text
