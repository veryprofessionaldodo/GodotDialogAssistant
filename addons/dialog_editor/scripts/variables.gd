tool
extends PanelContainer

var variable_ui = preload("res://addons/dialog_editor/scenes/base_variable.tscn")
var variable_modal = preload("res://addons/dialog_editor/scenes/modals/add_new_variable.tscn")
var b = "text"
var variables = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var margin_value = 100
	set("custom_constants/margin_top", margin_value)
	set("custom_constants/margin_left", margin_value)
	set("custom_constants/margin_bottom", margin_value)
	set("custom_constants/margin_right", margin_value)
	
	variables = Utils.get_variables_from_file()
	display_variables()

# show all variables on screen
func display_variables():
	for variable in variables: 
		add_variable_to_list(variable)
	
# adds fetched information to scene tree
func add_variable_to_list(info):
	var separator = HSeparator.new()
	var new_variable = variable_ui.instance()
	new_variable.populate_with_info(info)
	new_variable.get_node("Container/Options/DeleteButton").connect("pressed", self, "delete_variable", [new_variable, new_variable.id, separator])
	
	var col1 = $Base/VariablesColumns/Column1
	var col2 = $Base/VariablesColumns/Column2
	# check which column to add
	if col1.get_child_count() > col2.get_child_count():
		col2.add_child(new_variable)
		col2.add_child(separator)
	else:
		col1.add_child(new_variable)
		col1.add_child(separator)

func delete_variable(node, id, separator):
	var col1 = $Base/VariablesColumns/Column1
	var col2 = $Base/VariablesColumns/Column2
	
	col1.remove_child(node)
	col2.remove_child(node)
	col1.remove_child(separator)
	col2.remove_child(separator)
	
	for i in range(0, len(variables)):
		if variables[i].id == id:
			variables.remove(i)
			break

	save()

func add_new_variable(modal):
	var info = modal.get_info()
	add_variable_to_list(info)
	variables.append(info)
	save()
	
# store current information to file
func save():
	var variables_path = Utils.get_variables_path()
	# remove previous file
	var dir = Directory.new()
	dir.remove(variables_path)
	
	# create new file with the same text
	var file = File.new()
	file.open(variables_path, File.WRITE)
	var json_string = JSON.print({"variables": variables}, "\t")
	file.store_string(json_string)
	file.close()

func create_new_variable():
	var modal = variable_modal.instance()
	add_child(modal)
	
	modal.popup_centered()
	modal.connect("confirmed", self, "add_new_variable", [modal])
	
func collapse_all():
	var col1 = $Base/VariablesColumns/Column1
	var col2 = $Base/VariablesColumns/Column2
	
	for child in col1.get_children():
		if not child is HSeparator:
			child.collapse()
	for child in col2.get_children():
		if not child is HSeparator:
			child.collapse()

func expand_all():
	var col1 = $Base/VariablesColumns/Column1
	var col2 = $Base/VariablesColumns/Column2
	
	for child in col1.get_children():
		if not child is HSeparator:
			child.expand()
	for child in col2.get_children():
		if not child is HSeparator:
			child.expand()
