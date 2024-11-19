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

# This will be read from the save data
var settings: Dictionary = {
	"SSIL_enabled": true,
	"SSIL_quality": RenderingServer.ENV_SSIL_QUALITY_ULTRA,
	"SSAO_enabled": true,
	"SSAO_quality": RenderingServer.ENV_SSAO_QUALITY_ULTRA,
		
	"SSR_enabled": true,
	"SSR_quality": RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_HIGH,
	"SSR_steps": 512,

	"shadow_resolution": 8192,
	"shadow_filter_quality": RenderingServer.SHADOW_QUALITY_SOFT_ULTRA,
	
	"scaling": 1.0,
	"scaling_method": 0
}

@onready var entry_container: VBoxContainer = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

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
	pass
