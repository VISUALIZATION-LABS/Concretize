extends Node

var current_scene_tree: SceneTree

var autoload = ["SceneManager"]

func _enter_tree() -> void:
	current_scene_tree = get_tree()
	current_scene_tree.node_added.connect(Callable(self, "_on_scene_node_added"))
	current_scene_tree.node_removed.connect(Callable(self, "_on_scene_node_removed"))

func _on_scene_node_added(node):
	if node.get_parent() == current_scene_tree.root:
		var path = node.name
		if path in autoload:
			print_rich("Loaded [b][i][color=yellow]%s[/color][/i][/b]." % path)
		elif node.get_class() ==  "Control":
			print_rich("Loaded [b][i][color=green]%s[/color][/i][/b]." % path)
		elif node.get_class() == "Node3D":
			print_rich("Loaded [b][i][color=purple]%s[/color][/i][/b]." % path)
		else:
			print_rich("Loaded [b][i][color=white]%s[/color][/i][/b]." % path)

func _on_scene_node_removed(node):
	if node.get_parent() == current_scene_tree.root:
		var path = node.name
		print_rich("[color=cyan]Unloaded [b][i]%s[/i][/b][/color]." % path)

func change_current_scene_to_file(path: String):
	current_scene_tree.change_scene_to_file(path)

func change_current_scene_to_packed(packed_scene: PackedScene):
	current_scene_tree.change_scene_to_packed(packed_scene)
