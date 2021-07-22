tool
extends VBoxContainer

var dialogue_node = preload("res://addons/dialog_editor/scenes/nodes/dialogue.tscn")

var graph_edit_node = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_graph_node(node):
	graph_edit_node = node

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func add_dialogue_node():
	# instance new graph edit node
	var graph_node = dialogue_node.instance()
	print("adding ", graph_node, " to ", graph_edit_node)
	
	# add node to graph
	graph_edit_node.add_child(graph_node)
	
