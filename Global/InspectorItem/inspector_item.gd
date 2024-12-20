class_name InspectorItem
extends VBoxContainer

var node: Node3D
var _transform_properties: Dictionary
#var _node_cache: Dictionary

func set_title(string: String) -> void:
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
	
	
	for item: String in selection_info:
		match typeof(selection_info[item]):
			TYPE_STRING:
				pass
				#print(item)
			TYPE_DICTIONARY:
				#print("\n%s" % item)
				var title_label: Label = Label.new()
				title_label.text = item
				
				match item:
					"Transform":
						title_label.text = tr("INSPECTOR_TRANSFORM")
					
					"Spot":
						title_label.text = tr("INSPECTOR_SPOT")
					
					"Light":
						title_label.text = tr("INSPECTOR_LIGHT")
					
					"Shadow":
						title_label.text = tr("INSPECTOR_SHADOW")
					
				this.add_child(title_label)
				
				# This call is unsafe but selection_info will always be a dict
				
				@warning_ignore("unsafe_call_argument")
				this.add_child(_build_inspector(selection_info[item]))
			TYPE_VECTOR3:
				var divided_entry: HBoxContainer = HBoxContainer.new()
				var vec3_container: HBoxContainer = HBoxContainer.new()
				var title: Label = Label.new()
				
				var value_X: SpinSlider = SpinSlider.new("X", false)
				var value_Y: SpinSlider = SpinSlider.new("Y", false)
				var value_Z: SpinSlider = SpinSlider.new("Z", false)
				
				print(value_X)
				
				vec3_container.add_child(value_X)
				vec3_container.add_child(value_Y)
				vec3_container.add_child(value_Z)
				
				_transform_properties[item] = {
					"x_input" = value_X,
					"y_input" = value_Y,
					"z_input" = value_Z
				}
				
				title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				title.text = item
				
				#value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				#value.size_flags_vertical = Control.SIZE_EXPAND_FILL
				
				#value.value = selection_info[item]
				
				#selection_info[item] += 10.0
				
				divided_entry.add_child(title)
				divided_entry.add_child(vec3_container)
				#divided_entry.add_child(value)
				this.add_child(divided_entry)
				
				match item:
					"Position":
						title.text = tr("INSPECTOR_POSITION")
						value_X.value_changed.connect(func(value: float) -> void:
							node.global_position.x = value
						)
						value_Y.value_changed.connect(func(value: float) -> void:
							node.global_position.y = value
						)
						value_Z.value_changed.connect(func(value: float) -> void:
							node.global_position.z = value
						)
					
					"Rotation":
						title.text = tr("INSPECTOR_ROTATION")
						value_X.value_changed.connect(func(value: float) -> void:
							node.global_rotation.x = value
						)
						value_Y.value_changed.connect(func(value: float) -> void:
							node.global_rotation.y = value
						)
						value_Z.value_changed.connect(func(value: float) -> void:
							node.global_rotation.z = value
						)
					
					"Scale":
						title.text = tr("INSPECTOR_SCALE")
						value_X.value_changed.connect(func(value: float) -> void:
							node.scale.x = value
						)
						value_Y.value_changed.connect(func(value: float) -> void:
							node.scale.y = value
						)
						value_Z.value_changed.connect(func(value: float) -> void:
							node.scale.z = value
						)
				
				
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
							title.text = tr("INSPECTOR_COLOR")
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
				
				#selection_info[item] += 10.0
				
				divided_entry.add_child(title)
				divided_entry.add_child(value)
				this.add_child(divided_entry)
				
				
				# FLOATS ONLY
				if node.is_class("Light3D"):
					match node.get_class():
						"SpotLight3D":
							match item:
								"Range":
									title.text = tr("INSPECTOR_RANGE")
									value.value_changed.connect(func(value: float) -> void:
										node.spot_range = value
									)
								
								"Attenuation":
									title.text = tr("INSPECTOR_ATTENUATION")
									value.value_changed.connect(func(value: float) -> void:
										node.spot_attenuation = value
									)
								
								"Angle":
									title.text = tr("INSPECTOR_ANGLE")
									value.value_changed.connect(func(value: float) -> void:
										node.spot_angle = value
									)
					
					match item:
						"Energy":
							title.text = tr("INSPECTOR_ENERGY")
							value.value_changed.connect(func(value: float) -> void:
								node.light_energy = value
							)
						
						"Size":
							title.text = tr("INSPECTOR_SIZE")
							value.value_changed.connect(func(value: float) -> void:
								node.light_size = value
							)
						
						"Blur":
							title.text = tr("INSPECTOR_BLUR")
							value.value_changed.connect(func(value: float) -> void:
								node.shadow_blur = value
							)

				#print("%s: %s" % [item, str(selection_info[item])])
	
	return background


func _process(_delta: float) -> void:
	# HACK for checking transforms
	if is_instance_valid(node):
		for key: String in _transform_properties:
			if is_instance_valid(_transform_properties[key].x_input) && is_instance_valid(_transform_properties[key].y_input) && is_instance_valid(_transform_properties[key].z_input):
				match key:
					"Position":
							_transform_properties[key].x_input.value = node.global_position.x
							_transform_properties[key].y_input.value = node.global_position.y
							_transform_properties[key].z_input.value = node.global_position.z
					
					"Rotation":
							_transform_properties[key].x_input.value = rad_to_deg(node.global_rotation.x)
							_transform_properties[key].y_input.value = rad_to_deg(node.global_rotation.y)
							_transform_properties[key].z_input.value = rad_to_deg(node.global_rotation.z)
					
					"Scale":
							_transform_properties[key].x_input.value = node.scale.x
							_transform_properties[key].y_input.value = node.scale.y
							_transform_properties[key].z_input.value = node.scale.z
