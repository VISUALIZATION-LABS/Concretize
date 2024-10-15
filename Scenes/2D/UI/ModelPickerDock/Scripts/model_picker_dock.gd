extends Control

@onready var asset_bay: HFlowContainer  = $HSplitContainer/PanelContainer2/MarginContainer/ScrollContainer/AssetBay

func add_asset(asset_container: Control) -> void:
	asset_bay.add_child(asset_container)
