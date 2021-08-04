tool
extends GraphEdit

var setting_name = "addons/Dialog Assets Folder"
var conversations_folder = ""
var current_conversation = null
var current_conversation_path = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	# get informations	
	if ProjectSettings.has_setting(setting_name):
		conversations_folder = ProjectSettings.get_setting(setting_name) + "/conversations/"

func load_conversation(node):
	save_current_conversation()
	
	var path = conversations_folder + node.text + ".json"
	var file = File.new()
	file.open(path, File.READ)
	current_conversation_path = conversations_folder + node.text + ".json"
	current_conversation = file.get_as_text()
	file.close()
	
	setup_graph()
	
func save_current_conversation():
	var conversation_parsed = {}
	conversation_parsed.nodes = [] 
	for node in get_children():
		if not node is GraphNode:
			continue
		
		conversation_parsed.nodes.append(node.convert_to_json())

func setup_graph():
	print("setting up ", current_conversation)
	reset_graph()

func reset_graph():
	for node in get_children():
		if node is GraphNode:
			remove_child(node)

func delete_node(node):
	print("here!!!")
	remove_child(node)
	save()
	
func save():
	print("saving!")
