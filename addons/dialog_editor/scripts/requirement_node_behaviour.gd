tool
extends "res://addons/dialog_editor/scripts/base_node.gd"

var variables = []

# Called when the node enters the scene tree for the first time.
func _ready():
	variables = Utils.get_variables_from_file()

func convert_to_json():
	var dict = .convert_to_json()
	
	dict.type = "requirement"
	return dict

# reconstruct node here
func construct_from_json(info):
	.construct_from_json(info)

func get_type():
		return "requirement"

func add_empty_requirement():
	var container = HBoxContainer.new()
	
	
	add_child(container)
