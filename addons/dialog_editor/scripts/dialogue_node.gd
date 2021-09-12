tool
extends "res://addons/dialog_editor/scripts/base_node.gd"

var all_lines = []
var num_lines = 0

func _ready():
	update_lines()
	
func update_lines():
	all_lines = Utils.get_lines_from_file()

# auto select is used to automatically select the correct option
func new_line_dialogue_node(auto_select_id = -1):
	# this is run to always fetch the most up to date information
	update_lines()
	var container = HSplitContainer.new()
	var options = OptionButton.new()
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	for line in all_lines:
		options.add_item(line["text"]["en"], int(line["id"]))
	
	var found_selected_id = false
	if not auto_select_id == -1:
		for i in range(options.get_item_count()):
			print("i am going through ", options.get_item_id(i), " comparing to ", int(auto_select_id))
			if options.get_item_id(i) == int(auto_select_id):
				options.select(i)
				found_selected_id = true
				break
		
		# line no longer exists, and it will cause an error
		if not found_selected_id:
			return

	# can be a button to add a new line
	var delete = Button.new()
	delete.text = "DEL"
	delete.flat = true
	
	container.add_child(options)
	container.add_child(delete)
	
	$Container/Lines.add_child(container)
	options.connect("item_focused", self, "update_line")
	delete.connect("pressed", self, "remove_line", [container])
	
	num_lines = num_lines + 1

# remove the line from UI, as well as the text 
func remove_line(container):
	# remove lines
	$Container/Lines.remove_child(container)
	# resize to not have extra padding
	rect_size = Vector2(rect_size.x, 0)
	
	num_lines = num_lines - 1

func convert_to_json():
	var dict = .convert_to_json()
	dict.lines = []
	for split_container in $Container/Lines.get_children():
		for node in split_container.get_children():
			if not node is OptionButton:
				continue
			
			dict.lines.append(str(node.get_item_id(node.selected)))

	dict.type = "dialogue"
	return dict

# reconstruct node here
func construct_from_json(info):
	.construct_from_json(info)
	
	# iterate over lines
	for line_id in info.lines:
		new_line_dialogue_node(int(line_id))

func get_type():
	return "dialogue"

func get_num_lines():
	return num_lines

func create_new_line_variable():
	$AddLine.reset()
	$AddLine.popup_centered()
	$AddLine.connect("new_line_signal", self, "select_last_added")
	
func select_last_added(properties):
	print("vivas")
	update_lines()
	var new_line = all_lines[len(all_lines) - 1]
	print(new_line)
	new_line_dialogue_node(int(new_line.id))

func validate_node_info():
	var output = ""
	# update information
	update_lines()
	
	for split_container in $Container/Lines.get_children():
		for node in split_container.get_children():
			if not node is OptionButton:
				continue
			
			# dict.lines.append(str(node.get_item_id(node.selected)))
			var line_id = node.get_item_id(node.selected)
			
			var line_exists = false
			for line in all_lines:
				if int(line.id) == line_id:
					line_exists = true
					break
			
			if !line_exists:
				output = output + "Dialogue node references line that no longer exists. \n"
				
	return output

