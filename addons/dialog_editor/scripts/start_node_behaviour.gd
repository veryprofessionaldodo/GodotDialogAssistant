tool
extends "res://addons/dialog_editor/scripts/base_node.gd"

func convert_to_json():
	var dict = .convert_to_json()
	
	dict.type = "start"
	return dict

func get_type():
	return "start"
	
