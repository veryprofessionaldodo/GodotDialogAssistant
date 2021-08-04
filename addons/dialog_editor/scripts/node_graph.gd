tool
extends GraphEdit

var setting_name = "addons/Dialog Assets Folder"
var conversations_folder = ""
var current_conversation = {"nodes": []}
var current_conversation_path = null

var dialogue_node = preload("res://addons/dialog_editor/scenes/nodes/dialogue.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# get informations	
	if ProjectSettings.has_setting(setting_name):
		conversations_folder = ProjectSettings.get_setting(setting_name) + "/conversations/"

func load_conversation(node):
	# conversation was deleted, reset graph and do nothing else
	if node == null:
		current_conversation_path = null
		reset_graph()
		return

	save_current_conversation()
	
	var path = conversations_folder + node.text + ".json"
	var file = File.new()
	file.open(path, File.READ)
	current_conversation_path = conversations_folder + node.text + ".json"
	current_conversation = JSON.parse(file.get_as_text()).result
	file.close()
	
	setup_graph()
	
# saves the current conversation directly to file
func save_current_conversation():
	if current_conversation_path == null: 
		return

	var conversation_parsed = {}
	conversation_parsed["nodes"] = [] 
	for node in get_children():
		if not node is GraphNode:
			continue
		
		conversation_parsed.nodes.append(node.convert_to_json())
		
	# remove previous file
	var dir = Directory.new()
	dir.remove(current_conversation_path)
	
	# create new file with the same text
	var file = File.new()
	file.open(current_conversation_path, File.WRITE)
	file.store_string(JSON.print(conversation_parsed, "\t"))
	file.close()

# add new node to the graph
func add_new_node(node):
	if current_conversation_path == null:
		return
		
	add_child(node)

func setup_graph():
	reset_graph()
	
	if current_conversation == null:
		return
	
	if not "nodes" in current_conversation:
		return
	
	print("setting up ", current_conversation)
	
	for node in current_conversation.nodes:
		if node.type == "dialogue":
			var new_dialogue_node = dialogue_node.instance()
			add_new_node(new_dialogue_node)
			new_dialogue_node.construct_from_json(node)
	
	# do connections between nodes

func reset_graph():
	for node in get_children():
		if node is GraphNode:
			remove_child(node)

func delete_node(node):
	remove_child(node)
	save_current_conversation()

