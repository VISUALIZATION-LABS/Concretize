extends Node

# Used for reporting things to the user, it's part of the 
# scene handling system because it should be universally
# callable, and is part of scene management.

enum PopupType {
	NONE,
	BUTTON,
	LOADING
}

func create_popup(title: String = "Title", description: String = "Description", type: PopupType = PopupType.BUTTON, primary_button_text: String = "Ok", secondary_button_text: String = "Cancel") -> Control:
	var popup: Control = load("res://Scenes/2D/UI/Prefabs/Popup/internal_popup.tscn").instantiate()

	popup.title = title
	popup.description = description
	popup.button_primary.text = primary_button_text
	popup.button_secondary.text = secondary_button_text
	popup.type = type


	#SceneManager.scene_tree.current_scene.get_node("UI").add_child(popup)

	return popup
