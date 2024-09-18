extends Control

@onready var toast_prefab: PackedScene = preload("res://Scenes/2D/UI/ErrorManager/Toast.tscn")
var count: int = 0



func raise_error(text: String) -> void:
	var new_toast_prefab: Control = toast_prefab.instantiate()
	self.add_child(new_toast_prefab)

	var viewport_size: Vector2 = get_viewport().size
	print(viewport_size)
	new_toast_prefab.visible = true
	pass

func raise_warning(text: String) -> void:
	pass
	

func raise_info(text: String) -> void:
	raise_error("Info toasts are not currently implemented")
