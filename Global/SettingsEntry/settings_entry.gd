class_name SettingsEntry
extends Control

signal item_selected(id: int)

var _split_container: HBoxContainer = HBoxContainer.new()
var _label: Label = Label.new()
var _options_button: OptionButton = OptionButton.new()

var title: String:
	get:
		return title
	set(value):
		title = value
		_label.text = title

func _ready() -> void:
	self.add_child(_split_container)
	_split_container.custom_minimum_size = Vector2(228,0)
	_split_container.add_theme_constant_override("separation", 10)
	_split_container.add_child(_label)
	_split_container.add_child(_options_button)
	
	_options_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	_options_button.item_selected.connect(_on_item_pressed)

func add_item(label: String = "", id: int = -1) -> void:
	_options_button.add_item(label, id)

func _on_item_pressed(id: int) -> void:
	item_selected.emit(id)
