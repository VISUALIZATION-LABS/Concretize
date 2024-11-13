extends Control

# Does nothing yet tbh

func _ready() -> void:
	get_window().transparent = true
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	
	#await SceneManager.scene_tree.create_timer(3).timeout
	
	SceneManager.change_scene(load("res://Scenes/3D/MainScene/main_scene.tscn"))
