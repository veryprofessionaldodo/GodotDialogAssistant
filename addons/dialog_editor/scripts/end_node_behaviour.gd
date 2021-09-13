tool
extends "res://addons/dialog_editor/scripts/base_node.gd"

var files_struct = []
var next_conversation = ""

func _ready():
	files_struct = Utils.get_conversations_struct()
	populate_options()
	
func populate_options():
	var options = $VBoxContainer/NextContainer/NextOptions 
	for file_struct in files_struct:
		options.add_item(file_struct.name, file_struct.id)
		
	options.select(len(files_struct) - 1)
	next_conversation = set_conversation_from_index(len(files_struct) - 1)

func convert_to_json():
	var dict = .convert_to_json()
	
	dict.next = next_conversation
	dict.type = "end"
	return dict

func construct_from_json(info):
	.construct_from_json(info)

	next_conversation = info.next	
	set_selected_from_id(next_conversation)
	
func get_type():
		return "end"

func set_selected_from_id(id):
	var options = $VBoxContainer/NextContainer/NextOptions 
	
	for i in range(len(files_struct)):
		if id == files_struct[i].id:
			options.select(i)
		
func set_conversation_from_index(index):
	var options = $VBoxContainer/NextContainer/NextOptions 
	var new_id = options.get_item_id(index) 
	
	for file_struct in files_struct: 
		if file_struct.id == new_id:
			next_conversation = file_struct.id
			return
	
func validate_node_info():
	if next_conversation == "":
		return "End node has no next conversation selected. \n"
		
	return ""
