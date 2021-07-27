tool
extends GraphNode

var all_lines = []

func _ready():
	get_all_lines()

func get_all_lines():
	# get all the lines from the variables here
	all_lines = ["line1", "line2", "line3"]

func new_line_dialogue_node():
	print("adding new line to dialog node")
	var container = HSplitContainer.new()
	var options = OptionButton.new()
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	for i in range(0, len(all_lines)):
		options.add_item(all_lines[i], i)
	
	# can be a button to add a new line
	var delete = Button.new()
	delete.text = "DEL"
	delete.flat = true
	
	container.add_child(options)
	container.add_child(delete)
	
	$"Lines".add_child(container)
	options.connect("item_focused", self, "save")
	delete.connect("pressed", self, "remove_dialogue", [container])
	
func remove_dialogue(container):
	# remove lines
	$"Lines".remove_child(container)

func save():
	get_parent().save()
	pass

func to_json():
	return "{}"

func create_new_line_variable():
	pass # Replace with function body.


# this is child of graph edit, so direct parent needs to remove self
func dialogue_closed():
	get_parent().delete_node(self)
