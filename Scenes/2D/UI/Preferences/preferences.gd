extends Control

enum Settings {
	# Lighting
	EFFECTS_ULTRA,
	EFFECTS_HIGH,
	EFFECTS_MEDIUM,
	EFFECTS_LOW,
	
	SHADOWS_ULTRA,
	SHADOWS_HIGH,
	SHADOWS_MEDIUM,
	SHADOWS_LOW,
	
	SCALE_NATIVE,
	SCALE_75,
	SCALE_50,
	SCALE_25
	
}

@onready var entry_container: VBoxContainer = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var effects_quality: SettingsEntry = SettingsEntry.new()
	effects_quality.item_selected.connect(_on_settings_item_selected)
	
	effects_quality.title = "Effects"
	effects_quality.add_item("Ultra", Settings.EFFECTS_ULTRA)
	effects_quality.add_item("High", Settings.EFFECTS_HIGH)
	effects_quality.add_item("Medium", Settings.EFFECTS_MEDIUM)
	effects_quality.add_item("Low", Settings.EFFECTS_LOW)
	
	var shadows_quality: SettingsEntry = SettingsEntry.new()
	shadows_quality.item_selected.connect(_on_settings_item_selected)
	
	shadows_quality.title = "Shadows"
	shadows_quality.add_item("Ultra", Settings.SHADOWS_ULTRA)
	shadows_quality.add_item("High", Settings.SHADOWS_HIGH)
	shadows_quality.add_item("Medium", Settings.SHADOWS_MEDIUM)
	shadows_quality.add_item("Low", Settings.SHADOWS_LOW)
	
	var scale_quality: SettingsEntry = SettingsEntry.new()
	scale_quality.item_selected.connect(_on_settings_item_selected)
	
	scale_quality.title = "Scaling"
	scale_quality.add_item("Native", Settings.SCALE_NATIVE)
	scale_quality.add_item("75%", Settings.SCALE_75)
	scale_quality.add_item("50%", Settings.SCALE_50)
	scale_quality.add_item("25%", Settings.SCALE_25)
	
	entry_container.add_child(effects_quality)
	entry_container.add_child(shadows_quality)
	entry_container.add_child(scale_quality)
	
func _on_settings_item_selected(id: int) -> void:
	print(id)
