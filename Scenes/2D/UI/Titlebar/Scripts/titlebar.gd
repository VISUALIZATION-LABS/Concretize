extends Control

enum BUTTONS {
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

	file_button.add_item("New Scene", BUTTONS.NEW_SCENE)
	file_button.add_item("Open Scene", BUTTONS.OPEN_SCENE)
	file_button.add_item("Save Scene", BUTTONS.SAVE_SCENE)
	file_button.add_item("Save Scene As...", BUTTONS.SAVE_SCENE_AS)
	file_button.add_item("Import", BUTTONS.IMPORT)

	file_button_export_sub_menu.add_item("Export Scene", BUTTONS.EXPORT_SCENE)
	file_button_export_sub_menu.add_item("Export Selection", BUTTONS.EXPORT_SELECTION)

	file_button.add_item("Quit", BUTTONS.QUIT)

	file_button.add_submenu_node_item("Export", file_button_export_sub_menu)

	edit_button.add_item("Cut", BUTTONS.CUT)
	edit_button.add_item("Copy", BUTTONS.COPY)
	edit_button.add_item("Paste", BUTTONS.PASTE)
	edit_button.add_item("Preferences", BUTTONS.PREFERENCES)
		
	selection_button.add_item("Select All", BUTTONS.SELECT_ALL)
	selection_button.add_item("Deselect All", BUTTONS.DESELECT_ALL)
	selection_button.add_item("Invert Selection", BUTTONS.INVERT_SELECTION)

	view_button.add_item("Unlit", BUTTONS.UNLIT)
	view_button.add_item("Ambient", BUTTONS.AMBIENT)
	view_button.add_item("Wireframe", BUTTONS.WIREFRAME)

	run_button.add_item("Run Project", BUTTONS.RUN_PROJECT)
	run_button.add_item("Run Scene", BUTTONS.RUN_SCENE)
	run_button.add_item("Run Here", BUTTONS.RUN_HERE)

	help_button.add_item("About", BUTTONS.ABOUT)
	help_button.add_item("Website", BUTTONS.WEBSITE)
	help_button.add_item("Documentation", BUTTONS.DOCUMENTATION)

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
		BUTTONS.IMPORT:
			SceneManager.import_mesh(["place"])
			pass
		
		BUTTONS.QUIT:
			get_tree().quit()
		
		BUTTONS.WEBSITE:
			OS.shell_open("https://visualization-labs.github.io/pocketvizwebsite/")

		BUTTONS.ABOUT:
			var about_panel: Control = load("Scenes/2D/UI/About/about.tscn").instantiate()

			about_panel.visible = false

			self.add_child(about_panel)
			about_panel.visible = true
			pass

		_:
			ErrorManager.raise_error("Not implemented")
		