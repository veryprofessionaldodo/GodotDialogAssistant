tool
extends GraphNode

var setting_name = "addons/Dialog Assets Folder"
var all_lines = []
var lines = []
var id = ""
var lines_path = ""

func _ready():
	id = calculate_id();
	var assets_folder = ProjectSettings.get_setting(setting_name)
	lines_path = assets_folder + "/variables/lines.json"
	if assets_folder:
		get_all_lines()

func calculate_id():
	return String(OS.get_time()).sha256_text().substr(0, 8)

func get_all_lines():
	var file = File.new()
	file.open(lines_path, File.READ)
	var content = file.get_as_text()
	
	# if there's nothing on the file, ignore
	if not content:
		return
		
	var json_file = JSON.parse(content).result
	
	if "lines" in json_file:
		all_lines = json_file.lines

# auto select is used to automatically select the correct option
func new_line_dialogue_node(auto_select_id = -1):
	# this is run to always fetch the most up to date information
	get_all_lines()
	var container = HSplitContainer.new()
	var options = OptionButton.new()
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	for line in all_lines:
		options.add_item(line["text"]["en"], int(line["id"]))
	
	if not auto_select_id == -1:
		options.select(options.get_item_index(auto_select_id))

	# can be a button to add a new line
	var delete = Button.new()
	delete.text = "DEL"
	delete.flat = true
	
	container.add_child(options)
	container.add_child(delete)
	
	$Container/Lines.add_child(container)
	options.connect("item_focused", self, "update_line")
	delete.connect("pressed", self, "remove_line", [container])

# remove the line from UI, as well as the text 
func remove_line(container):
	# remove lines
	$Container/Lines.remove_child(container)
	# resize to not have extra padding
	rect_size = Vector2(rect_size.x, 0)

func convert_to_json():
	var dict = {}
	dict.lines = []
	for split_container in $Container/Lines.get_children():
		for node in split_container.get_children():
			if not node is OptionButton:
				continue
			
			dict.lines.append(str(node.get_item_id(node.selected)))
	
	# setup the id, useful when parsing from the text
	dict.id = id
	dict.offset = [offset.x, offset.y]
	dict.type = "dialogue"
	return dict

# reconstruct node here
func construct_from_json(info):
	offset = Vector2(info.offset[0], info.offset[1])
	id = info.id
	
	# iterate over lines
	for line_id in info.lines:
		new_line_dialogue_node(int(line_id))

func create_new_line_variable():
	pass # Replace with function body.

# this is child of graph edit, so direct parent needs to remove self
func dialogue_closed():
	get_parent().delete_node(self)

func get_id():
	return id
