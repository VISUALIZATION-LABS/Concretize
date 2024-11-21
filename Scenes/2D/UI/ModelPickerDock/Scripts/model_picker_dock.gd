extends Control

@onready var asset_bay: HFlowContainer  = $HSplitContainer/PanelContainer2/MarginContainer/ScrollContainer/AssetBay
@onready var tree: Tree = $HSplitContainer/PanelContainer/VBoxContainer/Tree
@onready var root: TreeItem

var directory_list: PackedStringArray = [
	"root"
]

var asset_list: Array[Control] = [
	
]

func _ready() -> void:
	root = tree.create_item()
	root.set_text(0, "root")
	tree.hide_root = true
	tree.item_selected.connect(_tree_item_selected)
	
func _tree_item_selected() -> void:
	# Fucking bullshit
	# How does godot not have a "item_selected() -> TreeItem" signal what the fuck
	var selected_item: TreeItem = tree.get_next_selected(null)
	
	for asset: Control in asset_list:
		var selected_item_dir: TreeItem = _find_first_directory(asset.get_meta("class_end"), selected_item)
		
		if selected_item_dir != null:
			#print("Item found: ", selected_item_dir.get_text(0))
			asset.show()
		else:
			asset.hide()
			#print("Item with class_end = %s could not be found under selection \"%s\"" % [asset.get_meta("class_end"), selected_item.get_text(0)])
	

func add_asset(asset_container: Control, object_class_path: String) -> void:
	# Parse the path
	
	var object_class_directories: PackedStringArray = object_class_path.split("/")
	
	build_directory_tree(object_class_directories, asset_container)
	
	asset_bay.add_child(asset_container)

func clear_assets() -> void:
	for asset: Control in asset_bay.get_children():
		asset_bay.remove_child(asset)
	
	asset_list.clear()

func build_directory_tree(directories: PackedStringArray, asset_container: Control) -> void:
	# Check if the tree has a child item that's this
	if tree.get_root() != null:
		_check_tree_for_dict(directories)
		asset_container.set_meta("class_end", directories[directories.size() - 1])
		print(asset_container.get_meta("class_end"))
		
		asset_list.append(asset_container)

func _find_first_directory(directory_name: String, parent: TreeItem = root) -> TreeItem:
	if parent.get_text(0) == directory_name:
		return parent
	
	if parent.get_first_child() != null:
		var current_item: TreeItem = parent.get_first_child()
		
		while true:
			if current_item.get_text(0) == directory_name:
				return current_item
			
			else:
				var result: TreeItem = _find_first_directory(directory_name, current_item)
				
				if result != null:
					return result
				
			if current_item.get_next() != null:
				current_item = current_item.get_next()
			else:
				break
				
	return null

func _check_tree_for_dict(directories: PackedStringArray, parent: TreeItem = null) -> void:
	if parent == null:
		parent = root
	
	var create_full_dir: bool = true
	
	if parent.get_first_child() != null && directories.size() > 0:
		var current_item: TreeItem = parent.get_first_child()
		
		while true:
			if current_item.get_text(0) == directories[0]:
				var new_directory_list: PackedStringArray = directories.slice(1)
				_check_tree_for_dict(new_directory_list, current_item)
				create_full_dir = false
				
			if current_item.get_next() != null:
				current_item = current_item.get_next()
			else:
				break
	
	if create_full_dir || parent.get_first_child() == null:
		if directories.size() > 0:
			var new_tree_item: TreeItem = parent.create_child()
			new_tree_item.set_text(0, directories[0])
			directory_list.append(directories[0])

			for directory_name: String in directories.slice(1):
				new_tree_item = new_tree_item.create_child()
				new_tree_item.set_text(0, directory_name)
				directory_list.append(directory_name)
			
	
	
