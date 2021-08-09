tool
extends "res://addons/dialog_editor/scripts/base_node.gd"

var all_inputs = []

var input_modal = preload("res://addons/dialog_editor/scenes/modals/add_input.tscn")

func populate_new_input(inputs):
	var container = HBoxContainer.new()
	var options = OptionButton.new()
	var edit = Button.new()
	var delete = Button.new()
	edit.text = "Edit"
	delete.text = "DEL"
	
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options.add_item(inputs["en"])
	
	edit.connect("pressed", self, "edit_input", [container, inputs])
	delete.connect("pressed", self, "remove_input", [container, inputs])
	
	container.add_child(options)
	container.add_child(edit)
	container.add_child(delete)
	$Inputs.add_child(container)
	
	all_inputs.append(inputs)

func edit_input(container, inputs):
	var modal = input_modal.instance()
	get_parent().add_child(modal)
	modal.popup_centered()
	modal.connect("confirmed", self, "finished_editing_input", [modal, container, inputs])
	for lang in inputs:
		modal.set_lang_text(lang, inputs[lang])

func finished_editing_input(modal, container, previous_inputs):
	var new_inputs = modal.get_values()
	for i in range(0, len(all_inputs)):
		if str(all_inputs[i]) == str(previous_inputs):
			# found index to change
			for lang in new_inputs:
				all_inputs[i][lang] = new_inputs[lang]
				
	# change container info
	container.get_child(0).text = new_inputs["en"]

func remove_input(container, input):
	$Inputs.remove_child(container)
	rect_size.y = 0

func convert_to_json():
	var dict = .convert_to_json()
	
	dict.type = "input"
	return dict

# reconstruct node here
func construct_from_json(info):
	.construct_from_json(info)
	
func get_type():
	return "input"

func get_num_inputs():
	return len(all_inputs)

func add_new_input(modal):
	var result = modal.get_values()
	print(result)
	
	populate_new_input(result)

func create_input():
	var modal = input_modal.instance()
	get_parent().add_child(modal)
	modal.popup_centered()
	modal.connect("confirmed", self, "add_new_input", [modal])
