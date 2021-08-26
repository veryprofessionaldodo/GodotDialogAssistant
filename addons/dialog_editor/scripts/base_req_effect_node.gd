tool
extends "res://addons/dialog_editor/scripts/base_node.gd"

var variables = []
var boolean_check_ui = null
var number_check_ui = null
var comparisons = ["<=", "<", "==", ">", ">="]
var operations = ["-","+","="]

# type is defined in the children
export var type = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	variables = Utils.get_variables_from_file()
	create_base_ui()
	
func create_base_ui():
	boolean_check_ui = HBoxContainer.new()
	var boolean_label = Label.new()
	boolean_label.text = " is "
	
	var boolean_options = OptionButton.new()
	boolean_options.add_item("False")
	boolean_options.add_item("True")
	boolean_options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	boolean_check_ui.add_child(boolean_label)
	boolean_check_ui.add_child(boolean_options)
	
	number_check_ui = HBoxContainer.new()
	var options_array = get_options_array()
		
	var number_options = OptionButton.new()
	for option in options_array:
		number_options.add_item(option)

	number_options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var number_value = LineEdit.new()
	number_check_ui.add_child(number_options)
	number_check_ui.add_child(number_value)

func new_element_value(new_text, node):
	var parsed_numeric = Utils.parse_to_numeric_string(new_text)
	node.text = parsed_numeric
	node.caret_position = len(parsed_numeric)

func get_options_array():
	if type == "requirement":
		return comparisons
	else:
		return operations

func convert_to_json():
	var dict = .convert_to_json()
	
	dict.type = type
	
	var type_struct = type + "s"
	var options_array = get_options_array()
	
	dict[type_struct] = []
	
	for child in $Info.get_children():
		if not child is HBoxContainer:
			continue
		
		var element = {}
		
		var options = child.get_child(0)
		var boolean_check = child.get_child(1)
		var number_check = child.get_child(2)
		
		var variable_id = options.get_item_id(options.selected)
	
		for variable in variables:
			if int(variable.id) == variable_id:
				element.variable = variable.id
				if variable.type == "boolean":
					element.operation = "=="
					element.target = bool(boolean_check.get_child(1).selected)
				else:
					element.operation = comparisons[number_check.get_child(0).selected]
					element.target = number_check.get_child(1).text.to_float()
				
				break

		if element != {}:
			dict[type_struct].append(element)
	
	return dict

# reconstruct node here
func construct_from_json(node_info):
	.construct_from_json(node_info)

	var info_type = type + "s"
	for info in node_info[info_type]:
		var container = add_empty()
		var options = container.get_child(0)
		var boolean_check = container.get_child(1)
		var number_check = container.get_child(2)
		
		var selected_final = -1
		# select the correct option
		for i in range(0, options.get_item_count()):
			if options.get_item_id(i) == int(info.variable):
				options.select(i)
				selected_final = i
		
		# variable no longer exists, don't add
		if selected_final == -1:
			$Info.remove_child(container)
			break
		
		hide_incorrect_check(container)
		
		# after hiding the incorrect check, we can now select the
		# visible one
		if boolean_check.visible:
			var bool_value = bool(info.target)
			boolean_check.get_child(1).select(int(bool_value))
		else: 
			var options_array = get_options_array()
				
			var operation = info.operation
			for i in range(len(options_array)):
				if options_array[i] == operation:
					number_check.get_child(0).select(i)
					break
			
			number_check.get_child(1).text = str(info.target)

func get_num_elements():
	var num = 0
	for child in $Info.get_children():
		if child is HBoxContainer:
			num = num + 1
			
	return num

func get_type():
		return type

func hide_incorrect_check(container):
	var options = container.get_child(0)
	var boolean_check = container.get_child(1)
	var number_check = container.get_child(2)
	
	var variable_id = options.get_item_id(options.selected)
	
	for variable in variables:
		if int(variable["id"]) == variable_id:
			if variable.type == "boolean":
				number_check.visible = false
				boolean_check.visible = true
			else:
				number_check.visible = true
				boolean_check.visible = false

func add_empty():
	var container = HBoxContainer.new()
	
	var options = OptionButton.new()
	for variable in variables:
		options.add_item(variable["name"], int(variable["id"]))
	
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options.select(len(variables) - 1)
	container.add_child(options)
	
	var new_boolean_check = boolean_check_ui.duplicate()
	var new_number_check = number_check_ui.duplicate()
	
	new_number_check.get_child(1).connect("text_changed", self, "new_element_value", [new_number_check.get_child(1)])
	
	options.connect("item_selected", self, "options_updated", [container])
	
	container.add_child(new_boolean_check)
	container.add_child(new_number_check)
	
	hide_incorrect_check(container)
	
	var delete_button = Button.new()
	delete_button.text = "DEL"
	delete_button.connect("pressed", self, "remove_element", [container])
		
	container.add_child(delete_button)
	
	$Info.add_child(container)
	
	return container

func options_updated(idx, container):
	hide_incorrect_check(container)
	
func remove_element(container):
	$Info.remove_child(container)
	rect_size.y = 0
	rect_size.x = 0
	
func validate_node_info():
	var pretty_type = type.capitalize()
	var output = ""
	if get_num_elements() == 0:
		output = output + pretty_type + " node has no " + type + "s. \n"
		return output
		
	for child in $Info.get_children():
		if not child is HBoxContainer:
			continue
			
		var options = child.get_child(0)
		var variable_id = options.get_item_id(options.selected)
		var variable_exists = false
		for variable in variables:
			if int(variable.id) == variable_id:
				variable_exists = true
				break
		
		if not variable_exists: 
			output = output + pretty_type + " features variable that no longer exists. \n"
		
		var boolean_check = child.get_child(1)
		var number_check = child.get_child(2)
		
		if number_check.visible == true:
			var value = number_check.get_child(1).text
			
			if value == "":
				output = output + "Node with number " + pretty_type + " that is comparing against an empty string. \n"
		 
	return output
