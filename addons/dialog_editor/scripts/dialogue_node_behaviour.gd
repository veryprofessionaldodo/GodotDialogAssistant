tool
extends GraphNode

var setting_name = "addons/Dialog Assets Folder"
var all_lines = []
var lines = []
var id = ""
var lines_path = ""

func _ready():
	print("ready here?")
	id = String(OS.get_time()).sha256_text();
	var assets_folder = ProjectSettings.get_setting(setting_name)
	lines_path = assets_folder + "/variables/lines.json"
	if assets_folder:
		get_all_lines()

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
		
	print("got all the lines", all_lines)

func new_line_dialogue_node():
	print("adding new line to dialog node")
	# this is run to always fetch the most up to date information
	get_all_lines()
	var container = HSplitContainer.new()
	var options = OptionButton.new()
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	for line in all_lines:
		print("adding ", line["id"], " ", str(int(line["id"])))
		options.add_item(line["text"]["en"], int(line["id"]))
	
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
	print("size, ", rect_size)

func convert_to_json():
	var dict = {}
	dict.lines = []
	for split_container in $Container/Lines.get_children():
		for node in split_container.get_children():
			print(node)
			if not node is OptionButton:
				continue
			
			print("here? ", str(node.selected))
			dict.lines.append(int(node.selected))
	
	# setup the id, useful when parsing from the text
	dict.id = id
	dict.offset = str(offset)
	print(str(dict))
	return str(dict)

func create_new_line_variable():
	pass # Replace with function body.

# this is child of graph edit, so direct parent needs to remove self
func dialogue_closed():
	get_parent().delete_node(self)
