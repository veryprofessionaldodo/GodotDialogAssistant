tool
extends "res://addons/dialog_editor/scripts/base_node.gd"

var variables = []
var boolean_check_ui = null
var number_check_ui = null
var comparisons = ["<=", "<", "==", ">", ">="]

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
	var number_label = Label.new()
	number_label.text = " is "
	
	var number_options = OptionButton.new()
	for comparison in comparisons:
		number_options.add_item(comparison)

	number_options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var number_value = LineEdit.new()
	number_check_ui.add_child(number_label)
	number_check_ui.add_child(number_options)
	number_check_ui.add_child(number_value)

func new_requirement_value(new_text, node):
	var parsed_numeric = Utils.parse_to_numeric_string(new_text)
	node.text = parsed_numeric
	node.caret_position = len(parsed_numeric)

func convert_to_json():
	var dict = .convert_to_json()
	
	dict.type = "requirement"
	dict.requirements = []
	
	for child in $Info.get_children():
		if not child is HBoxContainer:
			continue
		
		var requirement = {}
		
		var options = child.get_child(0)
		var boolean_check = child.get_child(1)
		var number_check = child.get_child(2)
		
		var variable_id = options.get_item_id(options.selected)
	
		for variable in variables:
			if int(variable.id) == variable_id:
				requirement.variable = variable.id
				if variable.type == "boolean":
					requirement.operation = "=="
					requirement.target = bool(boolean_check.get_child(1).selected)
				else:
					requirement.operation = comparisons[number_check.get_child(1).selected]
					requirement.target = number_check.get_child(2).text.to_float()
				
				break

		if requirement != {}:
			dict.requirements.append(requirement)

	return dict

# reconstruct node here
func construct_from_json(info):
	.construct_from_json(info)

	for requirement in info.requirements:
		var container = add_empty_requirement()
		var options = container.get_child(0)
		var boolean_check = container.get_child(1)
		var number_check = container.get_child(2)
		
		var selected_final = -1
		# select the correct option
		for i in range(0, options.get_item_count()):
			if options.get_item_id(i) == int(requirement.variable):
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
			var bool_value = bool(requirement.target)
			boolean_check.get_child(1).select(int(bool_value))
		else: 
			var comparison = requirement.operation
			for i in range(len(comparisons)):
				if comparisons[i] == comparison:
					number_check.get_child(1).select(i)
					break
			
			number_check.get_child(2).text = str(requirement.target)

func get_num_requirements():
	var num = 0
	for child in $Info.get_children():
		if child is HBoxContainer:
			num = num + 1
			
	return num

func get_type():
		return "requirement"

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
				
func create_boolean_check():
	return 
	
func add_empty_requirement():
	var container = HBoxContainer.new()
	
	var options = OptionButton.new()
	for variable in variables:
		options.add_item(variable["name"], int(variable["id"]))
	
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options.select(len(variables) - 1)
	container.add_child(options)
	
	var new_boolean_check = boolean_check_ui.duplicate()
	var new_number_check = number_check_ui.duplicate()
	
	new_number_check.get_child(2).connect("text_changed", self, "new_requirement_value", [new_number_check.get_child(2)])
	
	options.connect("item_selected", self, "options_updated", [container])
	
	container.add_child(new_boolean_check)
	container.add_child(new_number_check)
	
	hide_incorrect_check(container)
	
	var delete_button = Button.new()
	delete_button.text = "DEL"
	delete_button.connect("pressed", self, "remove_requirement", [container])
		
	container.add_child(delete_button)
	
	$Info.add_child(container)
	
	return container

func options_updated(idx, container):
	hide_incorrect_check(container)
	
func remove_requirement(container):
	$Info.remove_child(container)
	rect_size.y = 0
	rect_size.x = 0
	
func validate_node_info():
	var output = ""
	if get_num_requirements() == 0:
		output = output + "Requirement Node has no requirements. \n"
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
			output = output + "Requirement features variable that no longer exists. \n"
		
		var boolean_check = child.get_child(1)
		var number_check = child.get_child(2)
		
		if number_check.visible == true:
			var value = number_check.get_child(2).text
			
			if value == "":
				output = output + "One number requirement is comparing against an empty string. \n"
		 
	return output
