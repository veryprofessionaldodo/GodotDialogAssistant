tool
extends GraphNode

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func new_line_dialogue_node():
	print("adding new line to dialog node")
	var container = HSplitContainer.new()
	var options = OptionButton.new()
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# can be a button to add a new line
	var extra = Button.new()
	extra.text = "+"
	extra.flat = true
	
	$"Lines".add_child(container)
	options.connect("item_focused", self, "update_line", [container, options, extra])
	
func update_line(index, container, options, extra):
	extra.text = "DEL"
	extra.connect("pressed", self, "remove_line", 
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func to_json():
	return "{}"
