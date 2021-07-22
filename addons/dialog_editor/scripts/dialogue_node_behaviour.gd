tool
extends GraphNode

var all_lines = []

func _ready():
	# get all the lines from the variables here
	pass

func new_line_dialogue_node():
	print("adding new line to dialog node")
	var container = HSplitContainer.new()
	var options = OptionButton.new()
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# can be a button to add a new line
	var extra = Button.new()
	extra.text = "+"
	extra.flat = true
	
	container.add_child(options)
	container.add_child(extra)
	
	$"Lines".add_child(container)
	options.connect("item_focused", self, "update_line", [container, extra])
	extra.connect("pressed", self, "add_new_dialogue_variable")
	
func add_new_dialogue_variable():
	# launch the modal here
	print("going to add here a new dialogue")
	
func update_line(index, container, extra):
	extra.text = "DEL"
	extra.connect("pressed", self, "remove_dialogue", [container])
	
func remove_dialogue(container, options, extra):
	# remove lines
	$"Lines".remove_child(container)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func to_json():
	return "{}"
