tool
extends Button

var node_graph = null

# Called when the node enters the scene tree for the first time.
func _ready():
	node_graph = get_node("/root/Mount/Main Window/Editor/Graph/Node Graph")
	print(node_graph)

func _pressed():
	print("yo, i am being pressed") 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
