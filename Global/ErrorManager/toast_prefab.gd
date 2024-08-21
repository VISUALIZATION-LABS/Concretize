extends Control

var resting_position: Vector2 = Vector2(1155, 599)
var y_offset: float = 0.0
@onready var label: RichTextLabel = self.get_node("PanelContainer").get_node("Control").get_node("RichTextLabel")

func set_offset_amount(count: int) -> void:
	y_offset = self.size.y * count

func appear() -> void:
	var tween: Tween = self.create_tween()

	tween.set_trans(tween.TRANS_QUAD)

	print(y_offset)
	self.position.y -= y_offset

	var finalPosition: Vector2 = Vector2(self.position.x - self.size.x, self.position.y)

	tween.tween_property(self, "position", finalPosition, 1)

func disappear() -> void:
	var tween: Tween = self.create_tween()

	tween.set_trans(tween.TRANS_QUAD)

	var finalPosition: Vector2 = Vector2(self.position.x + self.size.x, self.position.y)

	tween.tween_property(self, "position", finalPosition, 1)
	

func set_error_text(text: String) -> void:
	#var label: RichTextLabel = $self/PanelContainer/Control/RichTextLabel
	label.text = text