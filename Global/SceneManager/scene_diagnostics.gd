extends Node

# Reports on scene diagnostics, such as:
    # Node count
    # Report when node is added
    # Report when node is removed

enum ReportingLevel {
    NONE, # Disables reports (Whenever a node is added, removed, yadda yadda)
    NORMAL, # Reports nodes with specific classes
    VERBOSE # Reports every single node (a lot) 
}

var reporting_level: ReportingLevel = ReportingLevel.NORMAL

# Called when this node enters the scene tree
func _enter_tree() -> void:
    SceneManager.scene_tree.node_added.connect(_on_scene_tree_node_added)
    SceneManager.scene_tree.node_removed.connect(_on_scene_tree_node_removed)
    pass

func _on_scene_tree_node_added(node: Node) -> void:
    var node_class: String = node.get_class()

    if reporting_level != ReportingLevel.NONE:
        match node_class:
            "Node": 
                print_rich("Added node: [i][color=white]%s[/color][/i]" % node.name)
            "Node3D":
                print_rich("Added node: [i][color=pink]%s[/color][/i]" % node.name)
            "Control":
                print_rich("Added node: [i][color=green]%s[/color][/i]" % node.name)
    
    if reporting_level == ReportingLevel.VERBOSE:
        print_rich("Added node: [i]%s[/i]" % node.name)

func _on_scene_tree_node_removed(node: Node) -> void:
    var node_class: String = node.get_class()

    if reporting_level != ReportingLevel.NONE:
        match node_class:
            "Node": 
                print_rich("Removed node: [i][color=white]%s[/color][/i]" % node.name)
            "Node3D":
                print_rich("Removed node: [i][color=pink]%s[/color][/i]" % node.name)
            "Control":
                print_rich("Removed node: [i][color=green]%s[/color][/i]" % node.name)
    
    if reporting_level == ReportingLevel.VERBOSE:
        print_rich("Removed node: [i]%s[/i]" % node.name)




