class_name SpinSlider
extends Range

func _ready() -> void:
	# setup the nodes
	
	self.custom_minimum_size = Vector2(128, 32)
	
	var debug_node: ReferenceRect = ReferenceRect.new()
	debug_node.editor_only = false
	
	var background: PanelContainer = PanelContainer.new()
	var margin: MarginContainer = MarginContainer.new()
	var line_input: LineEdit = LineEdit.new()
	var slider: HSlider = HSlider.new()
	
	line_input.text = str(self.value)
	
	self.add_child(background)
	#self.add_child(debug_node.duplicate())
	background.add_child(margin)
	#background.add_child(debug_node.duplicate())
	margin.add_child(line_input)
