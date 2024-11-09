class_name InspectorItem
extends VBoxContainer

var node: Node

func set_title(string: String):
	var background: PanelContainer = PanelContainer.new()
	var margin: MarginContainer = MarginContainer.new()
	var center: CenterContainer = CenterContainer.new()
	var label: Label = Label.new()
	
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	
	label.text = string
	
	background.add_child(margin)
	margin.add_child(center)
	center.add_child(label)
	
	self.add_child(background)


func add_inspector_info(selection_info: Dictionary) -> void:
	var background: PanelContainer = PanelContainer.new()
	var margin: MarginContainer = MarginContainer.new()
	var inspector_items: Control = _build_inspector(selection_info)
	
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	
	background.add_child(margin)
	margin.add_child(inspector_items)
	self.add_child(background)


func _build_inspector(selection_info: Dictionary) -> Control:
	var background: PanelContainer = PanelContainer.new()
	var margin: MarginContainer = MarginContainer.new()
	
	#print(selection_info)
	
	
	var this: VBoxContainer = VBoxContainer.new()
	
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	
	background.add_child(margin)
	margin.add_child(this)
	
	#AHAHAHA DOESN'T FUCKING WORK MATE, WE CAN'T CONNECT SIGNALS!!!
	
	
	for item in selection_info:
		match typeof(selection_info[item]):
			TYPE_STRING:
				pass
				#print(item)
			TYPE_DICTIONARY:
				#print("\n%s" % item)
				var title_label: Label = Label.new()
				title_label.text = item
				
				this.add_child(title_label)
				this.add_child(_build_inspector(selection_info[item]))
			TYPE_VECTOR3:
				pass
				#print("%s: %s" % [item, str(selection_info[item])])
			TYPE_COLOR:
				var divided_entry: HBoxContainer = HBoxContainer.new()
				var title: Label = Label.new()
				var value: ColorPickerButton = ColorPickerButton.new()
				
				value.custom_minimum_size = Vector2i(128,48)
				
				title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				title.text = item
				
				value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				value.color = selection_info[item]
				
				divided_entry.add_child(title)
				divided_entry.add_child(value)
				this.add_child(divided_entry)
				
				if node.is_class("Light3D"):
					match item:
						"Color":
							value.color_changed.connect(func(value: Color) -> void:
								node.light_color = value
							)
				
			TYPE_BOOL:
				pass
				#print("%s: %s" % [item, str(selection_info[item])])
			TYPE_INT:
				var divided_entry: HBoxContainer = HBoxContainer.new()
				var title: Label = Label.new()
				var value: SpinBox = SpinBox.new()
				
				title.text = item
				value.value = selection_info[item]
				
				
				
				divided_entry.add_child(title)
				divided_entry.add_child(value)
				this.add_child(divided_entry)
				
				#print("%s: %s" % [item, str(selection_info[item])])
			TYPE_FLOAT:
				
				var divided_entry: HBoxContainer = HBoxContainer.new()
				var title: Label = Label.new()
				var value: SpinSlider = SpinSlider.new()
				
				title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				title.text = item
				
				value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				#value.size_flags_vertical = Control.SIZE_EXPAND_FILL
				
				value.value = selection_info[item]
				
				selection_info[item] += 10.0
				
				divided_entry.add_child(title)
				divided_entry.add_child(value)
				this.add_child(divided_entry)
				
				
				# FLOATS ONLY
				if node.is_class("Light3D"):
					match node.get_class():
						"SpotLight3D":
							match item:
								"Range":
									value.value_changed.connect(func(value: float) -> void:
										node.spot_range = value
									)
								
								"Attenuation":
									value.value_changed.connect(func(value: float) -> void:
										node.spot_attenuation = value
									)
								
								"Angle":
									value.value_changed.connect(func(value: float) -> void:
										node.spot_angle = value
									)
					
					match item:
						"Energy":
							value.value_changed.connect(func(value: float) -> void:
								node.light_energy = value
							)
						
						"Size":
							value.value_changed.connect(func(value: float) -> void:
								node.light_size = value
							)
						
						"Blur":
							value.value_changed.connect(func(value: float) -> void:
								node.shadow_blur = value
							)

				#print("%s: %s" % [item, str(selection_info[item])])
	
	return background
