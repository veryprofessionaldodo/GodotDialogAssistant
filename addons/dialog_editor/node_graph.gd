tool
extends GraphEdit

var setting_name = "addons/Dialog Assets Folder"
var conversations_folder = ""
var current_conversation = {"nodes": []}
var current_conversation_path = null

var start_node = preload("res://addons/dialog_editor/start.tscn")
var end_node = preload("res://addons/dialog_editor/end.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# get informations	
	if ProjectSettings.has_setting(setting_name):
		conversations_folder = ProjectSettings.get_setting(setting_name) + "/conversations/"
	
	var new_start = start_node.instance()
	var new_end = end_node.instance()
	
	new_start.offset = Vector2(-100, -60)
	new_end.offset = Vector2(100, 30)
	
	add_child(new_start)
	add_child(new_end)
	
	var new_start2 = start_node.instance()
	var new_end2 = end_node.instance()
	
	new_start2.offset = Vector2(10, 100)
	new_end2.offset = Vector2(300, 100)
	
	add_child(new_start2)
	add_child(new_end2)
	
