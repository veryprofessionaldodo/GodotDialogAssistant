tool
extends HSplitContainer

# Declare member variables here. Examples:
# var a = 2
# variable to store information
var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	# code to read the variables files
	pass # Replace with function body.

# adds fetched information to scene tree
func add_information():
	pass
	

func create_new_variable():
	#Open "Add New Variable" popup
	$Modal/AddVariable.popup_centered();
