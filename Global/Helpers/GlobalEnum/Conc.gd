extends Node
# Autoload class that holds all enum data


enum ContextMenu {
    # Used to create the context menu
    GENERIC,
    SELECTION,

    # Used whenever nothing is selected nor hovered
    GENERIC_UI_UNHIDE,
    GENERIC_UI_HIDE,
    GENERIC_UI_HIDE_ALL_GUI,
    GENERIC_UI_UNHIDE_ALL_GUI,
    GENERIC_UI_HIDE_GRID,
    GENERIC_UI_UNHIDE_GRID,
    GENERIC_UI_HELP,
    
    # Used when something is selected, overrides hovers
    SELECTION_COPY,
    SELECTION_CUT,
    SELECTION_PASE,
    SELECTION_DUPLICATE,
    SELECTION_HIDE,
    SELECTION_DELETE,
}

# Used for hiding and unhiding stuff (strictly)
enum GuiTypes {
    TITLEBAR,
    GIZMO_UI
}