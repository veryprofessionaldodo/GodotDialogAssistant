tool
extends VBoxContainer

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
	graph_edit_node.add_new_drag_node(adding_type, position)

# sets the graph node to which will receive new nodes
func set_graph_node(node):
	graph_edit_node = node

# button to add node was clicked
func node_clicked(type):
	adding_type = type
