tool
extends VBoxContainer

var start_node = preload("res://addons/dialog_editor/scenes/nodes/start.tscn")
var end_node = preload("res://addons/dialog_editor/scenes/nodes/end.tscn")
var dialogue_node = preload("res://addons/dialog_editor/scenes/nodes/dialogue.tscn")

var graph_edit_node = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# sets the graph node to which will receive new nodes
func set_graph_node(node):
	graph_edit_node = node

func add_start_node():
	# instance new graph edit node
	var graph_node = start_node.instance()
	graph_node.offset = Vector2(100,100)
	
	# add node to graph
	graph_edit_node.add_new_node(graph_node)

func add_end_node():
	# instance new graph edit node
	var graph_node = end_node.instance()
	graph_node.offset = Vector2(100,100)
	
	# add node to graph
	graph_edit_node.add_new_node(graph_node)

func add_dialogue_node():
	# instance new graph edit node
	var graph_node = dialogue_node.instance()
	graph_node.offset = Vector2(100,100)
	
	# add node to graph
	graph_edit_node.add_new_node(graph_node)
	
