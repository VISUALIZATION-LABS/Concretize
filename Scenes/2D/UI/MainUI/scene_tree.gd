extends Control

@onready var tree_panel: Tree = $"./Tree"

# Called when the node enters the scene tree for the first time.
func _ready():
	SceneManager.gui_tree = tree_panel
	SceneManager.update_gui_tree(Node.new())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
