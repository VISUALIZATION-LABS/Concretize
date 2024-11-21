extends Control

enum Type {
	ERROR,
	WARNING,
	INFO
}

@onready var toast_color_indicator: ColorRect = $"./Panel/ColorIndicator/ColorRect"
@onready var toast_title_label: RichTextLabel = $"./Panel/Title/TitleLabel"
@onready var toast_body_label: RichTextLabel = $"./Panel/Body/BodyLabel"

var error_color: Color = Color("#FF4747")
var warning_color: Color = Color("#FFB547")
var info_color: Color = Color("#B266FF")
var self_offset: int = 1
var count: int = ErrorManager.count;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide self
	self.position.x += self.size.x
	self.visible = false
	ErrorManager.make_space.connect(_make_space)

func appear(type: Type, title: String, body: String, offset: int) -> void:
	self_offset = offset

	# Set highlight colour
	match type:
		Type.ERROR:
			toast_color_indicator.color = error_color
		
		Type.WARNING:
			toast_color_indicator.color = warning_color
		
		Type.INFO:
			toast_color_indicator.color = info_color
	
	# Populate strings
	toast_title_label.text = title
	toast_body_label.text = body

	# Appear
	self.visible = true

	var appear_tween: Tween = get_tree().create_tween()
	self.position.y = self.position.y - (self.size.y * offset)
	var final_position: Vector2 = Vector2(self.position.x - self.size.x, self.position.y)

	appear_tween.set_trans(Tween.TRANS_QUAD)
	appear_tween.tween_property(self, "position", final_position, 1)
	
func _make_space() -> void:
	self_offset -= 1
	DebugDraw2D.set_text("Making space")
	var move_tween: Tween = get_tree().create_tween()

	var final_position: Vector2 = Vector2(self.position.x, self.position.y - (self.size.y * self_offset))

	move_tween.set_trans(Tween.TRANS_QUAD)
	move_tween.tween_property(self, "position", final_position, 1)

func _disappear() -> void:
	var disappear_tween: Tween = get_tree().create_tween()
	var final_position: Vector2 = Vector2(self.position.x + self.size.x, self.position.y)

	disappear_tween.set_trans(Tween.TRANS_QUAD)
	disappear_tween.tween_property(self, "position", final_position, 1)
	disappear_tween.tween_callback(self.queue_free)
