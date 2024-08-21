extends Control

# TODO: Find a better way to do this
@onready var file_panel: Panel = $Titlebar/MarginContainer/HBoxContainer/File/FilePanel
@onready var tools_panel: Panel = $Titlebar/MarginContainer/HBoxContainer/Tools/ToolsPanel
@onready var help_panel: Panel = $Titlebar/MarginContainer/HBoxContainer/Help/HelpPanel
@onready var about_panel: Panel = $Titlebar/MarginContainer/HBoxContainer/About/AboutPanel
var model_importer: Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	
	#self.add_child.call_deferred(model_importer)

	call_deferred("_compile")	

func _compile() -> void:
	model_importer = load("res://Scenes/3D/RuntimeAssetImporter/runtime_asset_importer.tscn").instantiate()
	get_tree().current_scene.add_child(model_importer)
	model_importer.Compile_mesh("/home/felipe/Development/Blender/Projects/GotDam/monke.obj")


func _on_button_button_button_down() -> void:
	SignalBus.emit_signal("gizmo_type_change", "Transform")


func _on_button_button_button_button_down() -> void:
	SignalBus.emit_signal("gizmo_type_change", "Scale")


func _on_file_button_down() -> void:
	_close_all_title_bar_panels()
	file_panel.visible = !file_panel.visible

func _on_tools_button_down() -> void:
	_close_all_title_bar_panels()
	tools_panel.visible = !tools_panel.visible
	
func _on_help_button_down() -> void:
	_close_all_title_bar_panels()
	help_panel.visible = !help_panel.visible

func _on_about_button_down() -> void:
	_close_all_title_bar_panels()
	about_panel.visible = !about_panel.visible

func _close_all_title_bar_panels() -> void:
	file_panel.visible = false
	tools_panel.visible = false
	help_panel.visible = false
	about_panel.visible = false


func _on_import_model_button_down():
	pass # Replace with function body.
