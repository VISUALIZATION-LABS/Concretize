class_name SpinSlider
extends MarginContainer

signal value_changed(value: float)

# Extending from the margin container is fucking stupid but fuck the ui
# nodes in this engine fucking hell god fucking damn fuck this shit fuck you

var background_panel: PanelContainer = PanelContainer.new()
var title_container: HBoxContainer = HBoxContainer.new()
var title_background: PanelContainer = PanelContainer.new()
var title_center: CenterContainer = CenterContainer.new()
var title_label: Label = Label.new()
var stack: VBoxContainer = VBoxContainer.new()
var slider: HSlider = HSlider.new()
var input: LineEdit = LineEdit.new()

var value: float = 0.0
var value_cache: float = value
var input_value_cache: String = "0.000"


var maximum: float = 0.0
var minimum: float = 0.0

var _use_slider: bool = true

var step: float = 0.1
var _title: String = ""

func _process(delta: float) -> void:
	# Check if the value changes
	if value != value_cache:
		value_cache = value
		#value_changed.emit(value)
		
		input.text = str(value).pad_decimals(3)

func _init(title: String = "", use_slider = true) -> void:
	_title = title
	_use_slider = use_slider

func _ready() -> void:
	slider.step = step
	slider.value = value
	slider.value_changed.connect(_slider_value_changed)
	input.text_changed.connect(_input_value_changed)
	
	background_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	input.set_anchors_preset(Control.PRESET_FULL_RECT)
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.text = str(self.value).pad_decimals(3)
	input_value_cache = input.text
	
	self.add_child(background_panel)
	
	background_panel.add_child(title_container)
	
	if not _title.is_empty():
		title_background.add_child(title_center)
		title_center.add_child(title_label)
		title_label.text = _title
		title_background.custom_minimum_size = Vector2(32,0)
		
		title_container.add_child(title_background)
		
	
	title_container.add_child(stack)
	
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	stack.add_child(input)
	
	if _use_slider:
		stack.add_child(slider)

func _slider_value_changed(value: float) -> void:
	input.text = str(value).pad_decimals(3)
	
	value_changed.emit(value)

func _input_value_changed(value: String) -> void:
	print("i changed")
	if value.is_valid_float():
		input_value_cache = value
		var numeric_value: float =  value.to_float()
		
		slider.set_value_no_signal(numeric_value)
		value_changed.emit(numeric_value)
		
	else:
		input.text = input_value_cache
