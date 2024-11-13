extends Control

@onready var popup: PopupMenu = $Titlebar/PopupMenu
@onready var inspector: VBoxContainer = $"Split_NodeTree-All/Split_Properties-Viewport_Assets/PropertiesPanel/MarginContainer/ScrollContainer/VBoxContainer"
enum ContextMenuItems{
	ADD_ITEM,
		ADD_ITEM_LIGHT_SPOT,
		ADD_ITEM_LIGHT_OMNI,
		ADD_ITEM_LIGHT_DIRECTIONAL,
	DELETE_ITEM,
	COPY_ITEM,
	PASTE_ITEM,
	RESET_TRANSFORMS
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.current_ui = self
	SignalBus.hide_section.connect(_hide_section)
	SignalBus.show_section.connect(_show_section)
	
	$"Split_NodeTree-All/NodeTreePanel/MarginContainer/VBoxContainer/ProjectSceneTreeSearchBar".placeholder_text = tr("GUI_PLACEHOLDER_SEARCH")
	
	$"Split_NodeTree-All/Split_Properties-Viewport_Assets/Split_Viewport-Assets/Control/Control/HBoxContainer/BTN_MOVE".pressed.connect(_btn_move_pressed)
	$"Split_NodeTree-All/Split_Properties-Viewport_Assets/Split_Viewport-Assets/Control/Control/HBoxContainer/BTN_ROTATE".pressed.connect(_btn_rotate_pressed)
	#SceneManager.scene_tree.node_added.connect(SceneManager.update_gui_tree)
	#SceneManager.scene_tree.node_removed.connect(SceneManager.update_gui_tree)
	#SceneManager.scene_tree.node_renamed.connect(SceneManager.update_gui_tree)
	
func _btn_move_pressed() -> void:
	SignalBus.gizmo_type_change.emit("Translate")
	
func _btn_rotate_pressed() -> void:
	SignalBus.gizmo_type_change.emit("Rotate")

# HACK
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("context_menu"):
		var context_menu: ContextMenu = ContextMenu.new()
		
		add_child(context_menu)
		
		#var context_menu_submenu_add_item: ContextMenu = ContextMenu.new()
		
		context_menu.add_item(tr("CONTEXT_MENU_ADD_ITEM"), ContextMenuItems.ADD_ITEM)
		context_menu.add_item(tr("CONTEXT_MENU_ADD_ITEM_LIGHT_SPOT"), ContextMenuItems.ADD_ITEM_LIGHT_SPOT)
		context_menu.add_item(tr("CONTEXT_MENU_ADD_ITEM_LIGHT_OMNI"), ContextMenuItems.ADD_ITEM_LIGHT_OMNI)
		context_menu.add_item(tr("CONTEXT_MENU_ADD_ITEM_LIGHT_DIRECTIONAL"), ContextMenuItems.ADD_ITEM_LIGHT_DIRECTIONAL)
		
		#context_menu_submenu_add_item.add_item("Add spot light", ContextMenuItems.ADD_ITEM_LIGHT_SPOT)
		#context_menu_submenu_add_item.add_item("Add omnidirectional light", ContextMenuItems.ADD_ITEM_LIGHT_OMNI)
		#context_menu_submenu_add_item.add_item("Add directional light", ContextMenuItems.ADD_ITEM_LIGHT_DIRECTIONAL)
		
		context_menu.add_item(tr("CONTEXT_MENU_DELETE_ITEM"), ContextMenuItems.DELETE_ITEM)
		context_menu.add_item(tr("CONTEXT_MENU_COPY_ITEM"), ContextMenuItems.COPY_ITEM)
		context_menu.add_item(tr("CONTEXT_MENU_PASTE_ITEM"), ContextMenuItems.PASTE_ITEM)
		
		context_menu.show()
		context_menu.position = get_viewport().get_mouse_position()
		context_menu.id_pressed.connect(_context_menu_id_pressed)
		

func _context_menu_id_pressed(id: int) -> void:
	match id:
		ContextMenuItems.ADD_ITEM:
			ErrorManager.raise_error("Não implementado", "Esse botão agirá como um submenu, e não realizará nenhuma functionalidade.")
		
		ContextMenuItems.ADD_ITEM_LIGHT_SPOT:
			var spot_light: SpotLight = SpotLight.new()
			spot_light.show_spot = false
			SceneManager.scene_tree.current_scene.add_child(spot_light, true)
		
		ContextMenuItems.ADD_ITEM_LIGHT_DIRECTIONAL:
			var directional_light: DirectionalLight = DirectionalLight.new()
			directional_light.show_help = false
			SceneManager.scene_tree.current_scene.add_child(directional_light, true)

func add_node_to_inspector(node: Node3D) -> void:
	var inspector_item: InspectorItem = InspectorItem.new()
	inspector_item.set_title(node.name)
	
	var data: Dictionary
	
	data["Transform"] = {
		"Position": node.position,
		"Rotation": node.rotation,
		"Scale": node.scale
		}
	
	if node.is_class("Light3D"):
		if node.get_class() == "SpotLight3D":
			data["Spot"] = {
				"Range": node.spot_range,
				"Attenuation": node.spot_attenuation,
				"Angle": node.spot_angle
			}
		
		data["Light"] = {
			"Color": node.light_color,
			"Energy": node.light_energy,
			"Size": node.light_size,
		}
		
		data["Shadow"] = {
			"Enabled": node.shadow_enabled,
			"Blur": node.shadow_blur
		}
		
			
	
	inspector_item.node = node
	inspector_item.add_inspector_info(data)
	
	
	inspector.add_child(inspector_item)

func remove_node_from_inspector(node: Node3D) -> void:
	for children: Control in inspector.get_children():
		if children.node == node:
			children.queue_free()

func remove_context_menu_data_by_node(node: Node) -> void:
	print("Removal requested for node: " + str(node))
	for children in $"Split_NodeTree-All/Split_Properties-Viewport_Assets/PropertiesPanel/MarginContainer/ScrollContainer/VBoxContainer".get_children():
		if children.node == node:
			print("Node found")
			children.queue_free()

func _hide_section(type: String) -> void:
	var ui_node: Control = get_node(type)

	if ui_node == null:
		push_error("Requested ui section \"%s\" doesn't exist." % type)
		return
	
	ui_node.hide()

func _show_section(type: String) -> void:
	var ui_node: Control = find_child(type)

	if ui_node == null:
		push_error("Requested ui section \"%s\" doesn't exist." % type)
		return

	ui_node.show()

# Hack
func add_asset_to_dock(asset_container: Control) -> void:
	$"Split_NodeTree-All/Split_Properties-Viewport_Assets/Split_Viewport-Assets/PanelContainer/MarginContainer/ModelPickerDock".add_asset(asset_container)
