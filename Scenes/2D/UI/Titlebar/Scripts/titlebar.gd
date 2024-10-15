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

	# View
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
	var file_button: PopupMenu = $HBoxContainer/File.get_popup()
	var edit_button: PopupMenu = $HBoxContainer/Edit.get_popup()
	var selection_button: PopupMenu = $HBoxContainer/Selection.get_popup()
	var view_button: PopupMenu = $HBoxContainer/View.get_popup()
	var run_button: PopupMenu = $HBoxContainer/Run.get_popup()
	var help_button: PopupMenu = $HBoxContainer/Help.get_popup()

	var file_button_export_sub_menu: PopupMenu = PopupMenu.new()

	file_button.add_item("New Scene", Buttons.NEW_SCENE)
	file_button.add_item("Open Scene", Buttons.OPEN_SCENE)
	file_button.add_item("Save Scene", Buttons.SAVE_SCENE)
	file_button.add_item("Save Scene As...", Buttons.SAVE_SCENE_AS)
	file_button.add_item("Import", Buttons.IMPORT)

	file_button_export_sub_menu.add_item("Export Scene", Buttons.EXPORT_SCENE)
	file_button_export_sub_menu.add_item("Export Selection", Buttons.EXPORT_SELECTION)

	file_button.add_item("Quit", Buttons.QUIT)

	file_button.add_submenu_node_item("Export", file_button_export_sub_menu)

	edit_button.add_item("Cut", Buttons.CUT)
	edit_button.add_item("Copy", Buttons.COPY)
	edit_button.add_item("Paste", Buttons.PASTE)
	edit_button.add_item("Preferences", Buttons.PREFERENCES)
		
	selection_button.add_item("Select All", Buttons.SELECT_ALL)
	selection_button.add_item("Deselect All", Buttons.DESELECT_ALL)
	selection_button.add_item("Invert Selection", Buttons.INVERT_SELECTION)

	view_button.add_item("Unlit", Buttons.UNLIT)
	view_button.add_item("Ambient", Buttons.AMBIENT)
	view_button.add_item("Wireframe", Buttons.WIREFRAME)

	run_button.add_item("Run Project", Buttons.RUN_PROJECT)
	run_button.add_item("Run Scene", Buttons.RUN_SCENE)
	run_button.add_item("Run Here", Buttons.RUN_HERE)

	help_button.add_item("About", Buttons.ABOUT)
	help_button.add_item("Website", Buttons.WEBSITE)
	help_button.add_item("Documentation", Buttons.DOCUMENTATION)

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
		Buttons.IMPORT:
			print("FOO")
			var file_dialog: FileDialog = FileDialog.new()
			file_dialog.access = FileDialog.ACCESS_FILESYSTEM
			file_dialog.add_filter("*.obj, *.gltf, *.glb", "3D models")
			file_dialog.use_native_dialog = true
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
			file_dialog.visible = true

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
			pass
		
		Buttons.QUIT:
			get_tree().quit()
		
		Buttons.WEBSITE:
			OS.shell_open("https://visualization-labs.github.io/pocketvizwebsite/")

		Buttons.ABOUT:
			var about_panel: Control = load("Scenes/2D/UI/About/about.tscn").instantiate()
			about_panel.visible = false

			self.add_child(about_panel)
			about_panel.visible = true
			pass

		_:
			var modelBuilder: Node3D = load("res://Scenes/3D/ModelBuilder/model_builder.tscn").instantiate()
			SceneManager.scene_tree.current_scene.add_child(modelBuilder, true)
			ErrorManager.raise_error("This function has not been implemented yet", "Yeah, for real")
			#SignalBus.hide_section.emit("Titlebar")
		
