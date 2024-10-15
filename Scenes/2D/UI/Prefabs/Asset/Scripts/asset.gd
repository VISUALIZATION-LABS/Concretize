#class_name AssetContainer
extends Control

@onready var preview: TextureRect = $PanelContainer/VBoxContainer/Preview
@onready var title: RichTextLabel = $PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/Title
@onready var description: RichTextLabel = $PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/Description

func set_preview_texture(texture: ImageTexture) -> void:
	preview.texture = texture
