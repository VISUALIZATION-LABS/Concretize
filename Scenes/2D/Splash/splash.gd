extends Control

# Does nothing yet tbh

func _ready() -> void:
	
	
	var arguments = {}
	
	for argument in OS.get_cmdline_user_args():
		if argument.contains("="):
			var key_value = argument.split("=")
			arguments[key_value[0].trim_prefix("--")] = key_value[1]
		else:
			# Options without an argument will be present in the dictionary,
			# with the value set to an empty string.
			arguments[argument.trim_prefix("--")] = ""
	
	print(arguments)
	
	get_window().transparent = true
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	
	# Check if we can find any packages
	
	if DirAccess.dir_exists_absolute(OS.get_data_dir() + "/Concretize"):
		if DirAccess.dir_exists_absolute(OS.get_data_dir() + "/Concretize/Packages"):
			# Check all package folders
			
			%InfoLabel.text += "\nChecking for packages..."
			
			for directory: String in DirAccess.get_directories_at(OS.get_data_dir() + "/Concretize/Packages"):
				# Check package files
				for file: String in DirAccess.get_files_at(OS.get_data_dir() + "/Concretize/Packages/" + directory):
					if file.get_extension() == "cpkg":
						# This is the package file
						
						%InfoLabel.text += "\nAdding package: [b]%s[/b]" % file
						
						print(OS.get_data_dir() + "/Concretize/Packages/" + directory + "/" + file)
						SceneManager.package_list.append(OS.get_data_dir() + "/Concretize/Packages/" + directory + "/" + file)
			
			await SceneManager.scene_tree.create_timer(2).timeout
			
			SceneManager.load_packages()
		
		DirAccess.make_dir_recursive_absolute(OS.get_data_dir() + "/Concretize/Packages")
	
	DirAccess.make_dir_recursive_absolute(OS.get_data_dir() + "/Concretize/Packages")
	
	await SceneManager.scene_tree.create_timer(2).timeout
	
	SceneManager.change_scene(load("res://Scenes/3D/MainScene/main_scene.tscn"))
