class_name SettingsEntry
extends Control

@onready var split_container: HBoxContainer = HBoxContainer.new()
@onready var label: Label = Label.new()
@onready var options_button: OptionButton = OptionButton.new()


func _ready() -> void:
	label.text = "Lighting quality"
	
	self.add_child(split_container)
	split_container.custom_minimum_size = Vector2(228,0)
	split_container.add_child(label)
	split_container.add_child(options_button)
	
	options_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
