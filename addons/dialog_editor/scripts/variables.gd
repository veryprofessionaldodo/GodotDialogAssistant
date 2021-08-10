tool
extends PanelContainer

# Declare member variables here. Examples:
# var a = 2
# variable to store information
var b = "text"
var modal = null

# Called when the node enters the scene tree for the first time.
func _ready():
	modal = find_node("AddVariable");
	
	var margin_value = 100
	set("custom_constants/margin_top", margin_value)
	set("custom_constants/margin_left", margin_value)
	set("custom_constants/margin_bottom", margin_value)
	set("custom_constants/margin_right", margin_value)

# adds fetched information to scene tree
func add_information():
	pass

func create_new_variable():
	#Open "Add New Variable" popup
	modal.popup_centered();
