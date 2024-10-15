class_name ProjectSceneTree
extends Tree

var tree_items: Array[TreeItem] = []
var selections: Array[SelectionModule.Selection] = []

func _ready() -> void:
	SceneManager.project_scene_tree = self
	update_tree()

func update_tree() -> void:
	if SceneManager.scene_tree.current_scene != null:
		tree_items.clear()
		var nodes_to_search: Array[Node] = []
		clear()

		var root: TreeItem = create_item()
		root.set_text(0, SceneManager.scene_tree.current_scene.name)

		nodes_to_search = SceneManager.scene_tree.current_scene.get_children()
		_build_tree(root, nodes_to_search)
		

func set_selections(selections: Array[SelectionModule.Selection]):
	for selection: SelectionModule.Selection in selections:
		for tree_item: TreeItem in tree_items:
			if selection.selected_node.name == tree_item.get_text(0):
				set_selected(tree_item, 0)

func _build_tree(parent: TreeItem, nodes: Array[Node]) -> void:
	for node: Node in nodes:
		if not node.name.begins_with("_") && not node.name.begins_with("@"):
			#print(node.name)
			var child: TreeItem = create_item(parent)
			child.set_text(0, node.name)
			
			tree_items.append(child)
			#gui_tree_items.append(child.get_instance_id())
			
			if node.get_children() && not node.name.begins_with("_") && not node.name.begins_with("@"):
				_build_tree(child, node.get_children())
