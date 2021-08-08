tool
extends "res://addons/dialog_editor/scripts/base_node.gd"

var num_inputs = 0
var all_inputs = []
var inputs_path = ""

func _ready():
	var assets_folder = ProjectSettings.get_setting(setting_name)
	inputs_path = assets_folder + "/variables/lines.json"
	if assets_folder:
		get_all_inputs()

func get_all_inputs():
	var file = File.new()
	file.open(inputs_path, File.READ)
	var content = file.get_as_text()
	
	# reset array, to be re-filled with information 
	all_inputs = []
	
	# if there's nothing on the file, ignore
	if not content:
		return
		
	var json_file = JSON.parse(content).result
	
	if "lines" in json_file:
		all_inputs = json_file.lines

func add_existing_input():
	var container = HSplitContainer.new()
	var options = OptionButton.new()
	var delete = Button.new()
	delete.text = "DEL"
	
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# fill options with 
	delete.connect("pressed", self, "remove_input", [container])
	
	container.add_child(options)
	container.add_child(delete)
	add_child(container)
	
	num_inputs = num_inputs + 1
	
func remove_input(container):
	remove_child(container)
	num_inputs = num_inputs - 1
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
	return num_inputs
