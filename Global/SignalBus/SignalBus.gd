extends Node

# Thanks to samuelfine on the godotengine documentation!
# This helps with signal emmissions between nodes that don't know eachother

# SIGNAL DEFINITIONS

# GIZMO
signal gizmo_type_change(type: String)

# GUI
signal hide_section(section: String)
signal show_section(section: String)
signal unhide_all