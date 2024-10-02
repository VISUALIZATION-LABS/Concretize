extends Node
@onready var toast_prefab: PackedScene = preload("res://Scenes/2D/UI/ErrorManager/Toast.tscn")
signal make_space
var count: int = 0


func raise_error(title: String, body: String) -> void:
	var new_toast_prefab: Control = toast_prefab.instantiate()
	self.add_child(new_toast_prefab)
	
	
	print("Count is: " + str(count))
	new_toast_prefab.appear(new_toast_prefab.Type.ERROR, title, body, count)
	count += 1
	await get_tree().create_timer(4).timeout
	
	new_toast_prefab._disappear()
	count -= 1
	make_space.emit()
	print("Count is: " + str(count))
	pass

func raise_warning(title: String, body: String) -> void:
	var new_toast_prefab: Control = toast_prefab.instantiate()
	self.add_child(new_toast_prefab)

	new_toast_prefab.appear(new_toast_prefab.Type.WARNING, title, body, 0)
	await get_tree().create_timer(10).timeout

	new_toast_prefab._disappear()
	pass
	

func raise_info(text: String) -> void:
	raise_error("Information toasts not implemented", "Cannot raise an information notification since there is no information toast code yet written.")
