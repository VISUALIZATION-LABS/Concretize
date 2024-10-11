extends Control

var title: String:
	get:
		return title
	set(value):
		title = value
		self.get_node("%TitleLabel").text = title

var description: String:
	get:
		return description
	set(value):
		description = value
		self.get_node("%DescriptionLabel").text = description

var button_primary: Button:
	get:
		return self.get_node("%ButtonPrimary")
	set(value):
		return

var button_secondary: Button:
	get:
		return self.get_node("%ButtonSecondary")
	set(value):
		return

var progress_bar: ProgressBar:
	get:
		return self.get_node("%ProgressBar")
	set(value):
		return

var type: SceneReporter.PopupType:
	get:
		return type
	set(value):
		type = value

		if type == SceneReporter.PopupType.BUTTON:
			self.get_node("PanelContainer/Description/ButtonsContainer").show()
			self.get_node("%ProgressBar")
		else: if type == SceneReporter.PopupType.LOADING:
			self.get_node("PanelContainer/Description/ButtonsContainer").hide()
			self.get_node("%ProgressBar").show()
