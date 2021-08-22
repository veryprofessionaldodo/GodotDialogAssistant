tool
extends VBoxContainer

var start_node = preload("res://addons/dialog_editor/scenes/nodes/start.tscn")
var end_node = preload("res://addons/dialog_editor/scenes/nodes/end.tscn")
var dialogue_node = preload("res://addons/dialog_editor/scenes/nodes/dialogue.tscn")
var input_node = preload("res://addons/dialog_editor/scenes/nodes/input.tscn")
var requirement_node = preload("res://addons/dialog_editor/scenes/nodes/requirement.tscn")

var adding_type = ""

var graph_edit_node = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
		
func _input(event):
	if adding_type != "":
		if event is InputEventMouseButton:
			# check for release
			if not event.is_pressed():
				add_node(event.position)
				adding_type = ""
				

func add_node(position):
	var new_node = null
	if adding_type == "start":
		new_node = start_node.instance()
	elif adding_type == "end":
		new_node = end_node.instance()
	elif adding_type == "dialogue":
		new_node = dialogue_node.instance()
	elif adding_type == "input":
		new_node = input_node.instance()
	elif adding_type == "requirement":
		new_node = requirement_node.instance()
	
	new_node.offset = position
	
	graph_edit_node.add_new_drag_node(new_node)

# sets the graph node to which will receive new nodes
func set_graph_node(node):
	graph_edit_node = node

# button to add node was clicked
func node_clicked(type):
	adding_type = type
