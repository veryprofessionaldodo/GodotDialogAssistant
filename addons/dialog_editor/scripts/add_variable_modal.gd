tool
extends AcceptDialog

# Called when the node enters the scene tree for the first time.
func _ready():
	perform_validation()

func get_info():
	var dict = {}
	
	dict.id = Utils.calculate_id()

	var type = get_type()
	var value = get_value()
	dict.type = type.to_lower()
	if type == "boolean":
		dict.value = bool(value.to_lower())
	else:
		dict.value = value.to_float()
	dict.name = $Container/MarginContainer/Name/LineEdit.text
	dict.description = $Container/DescriptionEdit.text
	
	return dict

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):#	pass

func get_type():
	var node = $Container/HSplitContainer/Type/VariableType
	return node.get_item_text(node.selected)

func get_value():
	var node = $Container/HSplitContainer/Value/LineEdit
	return node.text.to_lower()

func perform_validation():
	var valid = true
	var output = ""

	# validate type
	var type = get_type()
	var value = get_value()
	if type == "Boolean" and not (value.to_lower() == "false" or value.to_lower() == "true"):
		output = output + "Value isn't a valid Boolean. \n"
		valid = false
	# check if it's a valid number
	elif type == "Number" and (value == "" or value != Utils.parse_to_numeric_string(value)):
		output = output + "Value isn't a valid Number. \n"
		valid = false
		
	var name = $Container/MarginContainer/Name/LineEdit.text
	if name.replace(" ", "") == "":
		output = output + "Must have a name. \n"
		valid = false
	
	# validate description
	var desc = $Container/DescriptionEdit.text
	if desc.replace(" ", "") == "":
		output = output + "(Warning): No description. \n"
		
	
	$"Container/Output Text".text = output
	get_ok().disabled = !valid

func validate_type(new_text):
	perform_validation()

func changed_type(index):
	perform_validation()

func name_changed(new_text):
	perform_validation()

func description_changed():
	perform_validation()
