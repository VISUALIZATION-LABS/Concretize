extends Control

var resting_position: Vector2 = Vector2(1155, 599)
var y_offset: float = 0.0


func appear(offset: int) -> void:
	var tween: Tween = self.create_tween()

	tween.set_trans(tween.TRANS_QUAD)

	print(y_offset)
	self.position.y -= y_offset

	var finalPosition: Vector2 = Vector2(self.position.x - self.size.x, self.position.y * offset)

	tween.tween_property(self, "position", finalPosition, 1)

	tween.play()

func make_space(offset: int) -> void:
	var tween: Tween = self.create_tween()

	tween.set_trans(tween.TRANS_QUAD)

	var finalPosition: Vector2 = Vector2(self.position.x, self.position.y - y_offset * offset)

	tween.tween_property(self, "position", finalPosition, 1)




func disappear() -> void:
	var tween: Tween = self.create_tween()

	tween.set_trans(tween.TRANS_QUAD)

	var finalPosition: Vector2 = Vector2(self.position.x + self.size.x, self.position.y)

	tween.tween_property(self, "position", finalPosition, 1)
	

func set_error_text(text: String) -> void:
	#var label: RichTextLabel = $self/PanelContainer/Control/RichTextLabel
	label.text = text