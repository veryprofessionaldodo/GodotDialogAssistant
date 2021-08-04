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
		
		# save all connections
		var node_info = node.convert_to_json()
		node_info.next = []
		for connection in get_connection_list():
			if node.name == connection.from:
				var connecting_node_id = get_node_by_name(connection.to).get_id()
				node_info.next.append([connection.from_port, connecting_node_id, connection.to_port])
		
		conversation_parsed.nodes.append(node_info)
		
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
	
	for node in current_conversation.nodes:
		if node.type == "dialogue":
			var new_dialogue_node = dialogue_node.instance()
			add_new_node(new_dialogue_node)
			new_dialogue_node.construct_from_json(node)
	
	# do connections between nodes
	for node in current_conversation.nodes:
		if len(node.next) == 0:
			continue
		
		for next in node.next:
			# connections are of type [from port, to id, to port]
			var from_node = get_node_by_id(node.id).name
			var to_node = get_node_by_id(next[1]).name
			connect_node(from_node, next[0], to_node, next[2])

func reset_graph():
	for node in get_children():
		if node is GraphNode:
			remove_child(node)

	clear_connections()

func delete_node(node):
	remove_child(node)
	save_current_conversation()

func get_node_by_name(name):
	for node in get_children():
		if node.name == name:
			return node
	
	return null
	
func get_node_by_id(id):
	for node in get_children():
		if not node is GraphNode:
			continue
			
		if node.get_id() == id:
			return node
	
	return null

func connecting_nodes(from, from_slot, to, to_slot):
	connect_node(from, from_slot, to, to_slot)

func disconnect_nodes(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
