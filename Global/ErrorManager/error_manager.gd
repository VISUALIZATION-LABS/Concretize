extends Control

@onready var toast_prefab: Control = $Toast_Prefab
var has_errored: bool = false
var count: int = 0
# Called when the node enters the scene tree for the first time.


func _process(_delta: float) -> void:
	if not has_errored:

		has_errored = true

func raise_error(text: String) -> void:
	var new_toast_prefab: Control = toast_prefab.duplicate()
	new_toast_prefab.visible = true
	self.add_child(new_toast_prefab)
	new_toast_prefab.set_error_text(text)
	
	new_toast_prefab.set_offset_amount(count)
	count += 1
	print(count)
	new_toast_prefab.appear()
	await get_tree().create_timer(3).timeout
	new_toast_prefab.disappear()
	count -= 1

func raise_warning(text: String) -> void:
	var new_toast_prefab: Control = toast_prefab.duplicate()
	new_toast_prefab.visible = true
	self.add_child(new_toast_prefab)
	new_toast_prefab.set_error_text(text)
	
	new_toast_prefab.set_offset_amount(count)
	count += 1
	print(count)
	new_toast_prefab.appear()
	await get_tree().create_timer(3).timeout
	new_toast_prefab.disappear()
	count -= 1

func raise_info(text: String) -> void:
	raise_error("Info toasts are not currently implemented")
