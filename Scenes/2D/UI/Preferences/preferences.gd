extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer.add_child(SettingsEntry.new())
	$PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer.add_child(SettingsEntry.new())
	$PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer.add_child(SettingsEntry.new())
	$PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer.add_child(SettingsEntry.new())
	$PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer.add_child(SettingsEntry.new())
	$PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer.add_child(SettingsEntry.new())
	$PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer.add_child(SettingsEntry.new())
	
