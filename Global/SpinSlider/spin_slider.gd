class_name SpinSlider
extends MarginContainer

signal value_changed(value: float)

# Extending from the margin container is fucking stupid but fuck the ui
# nodes in this engine fucking hell god fucking damn fuck this shit fuck you

@onready var background_panel: PanelContainer = PanelContainer.new()
@onready var stack: VBoxContainer = VBoxContainer.new()
@onready var slider: HSlider = HSlider.new()
@onready var input: LineEdit = LineEdit.new()

var value: float = 0.0

var step: float = 0.1


func _ready() -> void:
	slider.step = step
	slider.value = value
	slider.value_changed.connect(_slider_value_changed)
	
	background_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	input.set_anchors_preset(Control.PRESET_FULL_RECT)
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.text = str(self.value)
	
	self.add_child(background_panel)
	background_panel.add_child(stack)
	stack.add_child(input)
	stack.add_child(slider)

func _slider_value_changed(value: float) -> void:
	input.text = str(value)
	
	value_changed.emit(value)
