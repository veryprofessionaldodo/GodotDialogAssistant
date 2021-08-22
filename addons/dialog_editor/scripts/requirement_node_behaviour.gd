tool
extends "res://addons/dialog_editor/scripts/base_node.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func convert_to_json():
	var dict = .convert_to_json()
	
	dict.type = "requirement"
	return dict

func get_type():
		return "requirement"
		
