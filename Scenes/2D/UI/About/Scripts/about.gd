extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		self.queue_free()
