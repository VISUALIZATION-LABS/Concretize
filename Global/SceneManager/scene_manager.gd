extends Node

var current_scene_tree: SceneTree
var verbose: bool = false

var autoload = ["SceneManager"]

# Console reporting
func _enter_tree() -> void:
	current_scene_tree = get_tree()
	current_scene_tree.node_added.connect(Callable(self, "_on_scene_node_added"))
	current_scene_tree.node_removed.connect(Callable(self, "_on_scene_node_removed"))

func _on_scene_node_added(node: Node) -> void:
	var path: String = node.name
	if verbose:
		if path in autoload:
			print_rich("Loaded [b][i][color=yellow]%s[/color][/i][/b]." % path)
		elif node.get_class() ==  "Control":
			print_rich("Loaded [b][i][color=green]%s[/color][/i][/b]." % path)
		elif node.get_class() == "Node3D":
			print_rich("Loaded [b][i][color=purple]%s[/color][/i][/b]." % path)
		else:
			print_rich("Loaded [b][i][color=white]%s[/color][/i][/b]." % path)

func _on_scene_node_removed(node: Node) -> void:
	if verbose:
		var path: String = node.name
		print_rich("[color=cyan]Unloaded [b][i]%s[/i][/b][/color]." % path)

# Scene stuff
func change_current_scene_to_file(path: String) -> void:
	current_scene_tree.change_scene_to_file(path)

func change_current_scene_to_packed(packed_scene: PackedScene) -> void:
	current_scene_tree.change_scene_to_packed(packed_scene)

func create_mouse_context_menu(type: Conc.ContextMenu) -> void:
	var context_menu: PopupMenu = PopupMenu.new()
	var gui: Control = get_tree().root.find_child("MainMenuUI", true, false)
	
	match type:
		Conc.ContextMenu.GENERIC:
			context_menu.add_item("Unhide UI", Conc.ContextMenu.GENERIC_UI_UNHIDE)
			context_menu.add_item("Hide UI", Conc.ContextMenu.GENERIC_UI_HIDE)

	
	context_menu.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	context_menu.position = get_viewport().get_mouse_position()
	context_menu.visible = true
	gui.add_child(context_menu)

# Mesh importer
func import_mesh(path: String) -> void:
	if path.length() == 0:
		ErrorManager.raise_error("Cannot import mesh", "Cannot import the desired mesh because there isn't a path to it.")
		return
	
	
	var mesh_importer: Node3D = load("res://Scenes/3D/RuntimeAssetImporter/runtime_asset_importer.tscn").instantiate()

	current_scene_tree.current_scene.add_child(mesh_importer)	

	mesh_importer.Compile_mesh(path)

# Input Handler
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("context_menu"):
		create_mouse_context_menu(Conc.ContextMenu.GENERIC)