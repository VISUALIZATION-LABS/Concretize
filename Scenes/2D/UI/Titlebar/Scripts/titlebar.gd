extends Control

enum Buttons {
	# File
	NEW_SCENE,
	OPEN_SCENE,
	SAVE_SCENE,
	SAVE_SCENE_AS,
	#----#
	IMPORT,
	# Export sub menu,
		EXPORT_SCENE,
		EXPORT_SELECTION,
	#----#
	QUIT,

	# Edit
	CUT,
	COPY,
	PASTE,
	PREFERENCES,

	# Selection
	SELECT_ALL,
	DESELECT_ALL,
	INVERT_SELECTION,
	SNAP_TO_FLOOR,
	SNAP_TO_CEILING,

	# View
	NORMAL,
	UNLIT,
	AMBIENT,
	WIREFRAME,

	# Run
	RUN_PROJECT,
	RUN_SCENE,
	RUN_HERE,

	# Help
	ABOUT,
	WEBSITE,
	DOCUMENTATION
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Localization
	$HBoxContainer/File.text = tr("TITLEBAR_FILE_BUTTON")
	$HBoxContainer/Edit.text = tr("TITLEBAR_EDIT_BUTTON")
	$HBoxContainer/Selection.text = tr("TITLEBAR_SELECTION_BUTTON")
	$HBoxContainer/View.text = tr("TITLEBAR_VIEW_BUTTON")
	$HBoxContainer/Run.text = tr("TITLEBAR_RUN_BUTTON")
	$HBoxContainer/Help.text = tr("TITLEBAR_HELP_BUTTON")
	
	var file_button: PopupMenu = $HBoxContainer/File.get_popup()
	var edit_button: PopupMenu = $HBoxContainer/Edit.get_popup()
	var selection_button: PopupMenu = $HBoxContainer/Selection.get_popup()
	var view_button: PopupMenu = $HBoxContainer/View.get_popup()
	var run_button: PopupMenu = $HBoxContainer/Run.get_popup()
	var help_button: PopupMenu = $HBoxContainer/Help.get_popup()

	var file_button_export_sub_menu: PopupMenu = PopupMenu.new()

	file_button.add_item(tr("TITLEBAR_FILE_NEW_SCENE"), Buttons.NEW_SCENE)
	file_button.add_item(tr("TITLEBAR_FILE_OPEN_SCENE"), Buttons.OPEN_SCENE)
	file_button.add_item(tr("TITLEBAR_FILE_SAVE_SCENE"), Buttons.SAVE_SCENE)
	file_button.add_item(tr("TITLEBAR_FILE_SAVE_SCENE_AS"), Buttons.SAVE_SCENE_AS)
	file_button.add_item(tr("TITLEBAR_FILE_IMPORT"), Buttons.IMPORT)

	file_button_export_sub_menu.add_item(tr("TITLEBAR_FILE_EXPORT_EXPORT_SCENE"), Buttons.EXPORT_SCENE)
	file_button_export_sub_menu.add_item(tr("TITLEBAR_FILE_EXPORT_EXPORT_SELECTION"), Buttons.EXPORT_SELECTION)

	file_button.add_submenu_node_item(tr("TITLEBAR_FILE_EXPORT"), file_button_export_sub_menu)
	
	file_button.add_item(tr("TITLEBAR_FILE_QUIT"), Buttons.QUIT)

	edit_button.add_item(tr("TITLEBAR_EDIT_CUT"), Buttons.CUT)
	edit_button.add_item(tr("TITLEBAR_EDIT_COPY"), Buttons.COPY)
	edit_button.add_item(tr("TITLEBAR_EDIT_PASTE"), Buttons.PASTE)
	edit_button.add_item(tr("TITLEBAR_EDIT_PREFERENCES"), Buttons.PREFERENCES)
		
	selection_button.add_item(tr("TITLEBAR_SELECTION_SELECT_ALL"), Buttons.SELECT_ALL)
	selection_button.add_item(tr("TITLEBAR_SELECTION_DESELECT_ALL"), Buttons.DESELECT_ALL)
	selection_button.add_item(tr("TITLEBAR_SELECTION_INVERT_SELECTION"), Buttons.INVERT_SELECTION)
	selection_button.add_item(tr("TITLEBAR_SELECTION_SNAP_TO_FLOOR"), Buttons.SNAP_TO_FLOOR)
	selection_button.add_item(tr("TITLEBAR_SELECTION_SNAP_TO_CEILING"), Buttons.SNAP_TO_CEILING)

	view_button.add_item(tr("TITLEBAR_VIEW_NORMAL"), Buttons.NORMAL)
	view_button.add_item(tr("TITLEBAR_VIEW_UNLIT"), Buttons.UNLIT)
	view_button.add_item(tr("TITLEBAR_VIEW_AMBIENT"), Buttons.AMBIENT)
	view_button.add_item(tr("TITLEBAR_VIEW_WIREFRAME"), Buttons.WIREFRAME)

	run_button.add_item(tr("TITLEBAR_RUN_RUN_PROJECT"), Buttons.RUN_PROJECT)
	run_button.add_item(tr("TITLEBAR_RUN_RUN_SCENE"), Buttons.RUN_SCENE)
	run_button.add_item(tr("TITLEBAR_RUN_RUN_HERE"), Buttons.RUN_HERE)

	help_button.add_item(tr("TITLEBAR_HELP_ABOUT"), Buttons.ABOUT)
	help_button.add_item(tr("TITLEBAR_HELP_WEBSITE"), Buttons.WEBSITE)
	help_button.add_item(tr("TITLEBAR_HELP_DOCUMENTATION"), Buttons.DOCUMENTATION)

	# Connect all buttons

	file_button.id_pressed.connect(_on_titlebar_menu_button_pressed)
	edit_button.id_pressed.connect(_on_titlebar_menu_button_pressed)
	selection_button.id_pressed.connect(_on_titlebar_menu_button_pressed)
	view_button.id_pressed.connect(_on_titlebar_menu_button_pressed)
	run_button.id_pressed.connect(_on_titlebar_menu_button_pressed)
	help_button.id_pressed.connect(_on_titlebar_menu_button_pressed)

	file_button_export_sub_menu.id_pressed.connect(_on_titlebar_menu_button_pressed)


func _on_titlebar_menu_button_pressed(id: int) -> void:
	match id:
		Buttons.NEW_SCENE:
			SceneManager.change_scene(preload("res://Scenes/3D/MainScene/main_scene.tscn"))
		
		Buttons.IMPORT:
			var file_dialog: FileDialog = FileDialog.new()
			file_dialog.access = FileDialog.ACCESS_FILESYSTEM
			file_dialog.add_filter("*.obj, *.gltf, *.glb", "3D models")
			
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
			file_dialog.use_native_dialog = true
			
			file_dialog.files_selected.connect(func(paths: PackedStringArray) -> void:
				print("Selected paths: ")
				SceneManager.import_mesh(paths)
				print(paths)
				)

			file_dialog.file_selected.connect(func(path: String) -> void:
				var path_array: PackedStringArray = [path]
				SceneManager.import_mesh(path_array)	
				print(path)
				)
			
			file_dialog.show()

			
			pass
		
		Buttons.SAVE_SCENE:
			var file_dialog: FileDialog = FileDialog.new()
			file_dialog.access = FileDialog.ACCESS_FILESYSTEM
			
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
			file_dialog.use_native_dialog = true
			
			file_dialog.dir_selected.connect(func(path: String) -> void:
				var path_array: PackedStringArray = [path]
				ProjectManager.save_project(path)
				#print(path)
			)
			
			file_dialog.show()
		
		Buttons.OPEN_SCENE:
			var file_dialog: FileDialog = FileDialog.new()
			file_dialog.access = FileDialog.ACCESS_FILESYSTEM
			file_dialog.add_filter("*.csave")
			
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file_dialog.use_native_dialog = true

			file_dialog.file_selected.connect(func(path: String) -> void:
				var path_array: PackedStringArray = [path]
				ProjectManager.load_project(path)
				#print(path)
			)
			
			file_dialog.show()
		Buttons.QUIT:
			get_tree().quit()
			
		
		Buttons.NORMAL:
			SceneManager.current_viewport.debug_draw = Viewport.DEBUG_DRAW_DISABLED
		
		Buttons.UNLIT:
			SceneManager.current_viewport.debug_draw = Viewport.DEBUG_DRAW_UNSHADED
		
		Buttons.AMBIENT:
			SceneManager.current_viewport.debug_draw = Viewport.DEBUG_DRAW_LIGHTING
			
		Buttons.WIREFRAME:
			SceneManager.current_viewport.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
		
		Buttons.WEBSITE:
			OS.shell_open("https://visualization-labs.github.io/pocketvizwebsite/")

		Buttons.ABOUT:
			var about_panel: Control = load("Scenes/2D/UI/About/about.tscn").instantiate()
			about_panel.visible = false

			self.add_child(about_panel)
			about_panel.visible = true
			pass
		
		Buttons.PREFERENCES:
			var preferences_panel: Control = preload("res://Scenes/2D/UI/Preferences/preferences.tscn").instanciate()
			self.add_child(preferences_panel)
			preferences_panel.show()
		
		Buttons.SNAP_TO_FLOOR:
			var selection_aabb: AABB = AABB(Vector3(0,0,0), Vector3(0,0,0))
			var center_position: Vector3
			var counter: int = 0
			var exclusion_list: Array = []
			
			# HACK
			var space_state: PhysicsDirectSpaceState3D = SceneManager.selections[0].child_meshes[0].get_world_3d().direct_space_state
			
			exclusion_list.clear()
			for selection: SelectionModule.Selection in SceneManager.selections:
				exclusion_list.append(selection.selected_node)
				for mesh: MeshInstance3D in selection.child_meshes:
					center_position = mesh.global_position + mesh.get_aabb().get_center()
					counter += 1
					
					selection_aabb = selection_aabb.merge(mesh.get_aabb())
			
			center_position /= counter

			var raycast_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
				center_position - Vector3(0, (selection_aabb.size.y / 2), 0),
				(center_position - Vector3(0, (selection_aabb.size.y / 2), 0)) - Vector3(0,100,0),
			)
			
			raycast_query.exclude = exclusion_list
			
			var result = space_state.intersect_ray(raycast_query)
			

			if result:
				print("Result: ", result.position)
				for selection: SelectionModule.Selection in SceneManager.selections:
					selection.selected_node.position = result.position
		_:
			#var modelBuilder: Node3D = load("res://Scenes/3D/ModelBuilder/model_builder.tscn").instantiate()
			#SceneManager.scene_tree.current_scene.add_child(modelBuilder, true)
			ErrorManager.raise_error("This function has not been implemented yet", "Yeah, for real")
			#SignalBus.hide_section.emit("Titlebar")
		
