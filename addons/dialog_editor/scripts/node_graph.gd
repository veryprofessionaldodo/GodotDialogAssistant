tool
extends GraphEdit

var setting_name = "addons/Dialog Assets Folder"
var conversations_folder = ""
var current_conversation = {"nodes": []}
var current_conversation_path = null

var start_node = preload("res://addons/dialog_editor/scenes/nodes/start.tscn")
var end_node = preload("res://addons/dialog_editor/scenes/nodes/end.tscn")
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
	conversation_parsed["scroll_offset"] = [scroll_offset.x, scroll_offset.y]
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

# adds new node to the graph via drag
func add_new_drag_node(node):
	if current_conversation_path == null:
		return

	var x_pos = node.offset.x 
	var y_pos = node.offset.y 
	
	if x_pos < rect_global_position.x or x_pos > rect_global_position.x + rect_size.x:
		return
	
	if y_pos < rect_global_position.y or y_pos > rect_global_position.y + rect_size.y:
		return

	# place the item in the place that is specified
	node.offset.x = x_pos - rect_global_position.x + scroll_offset.x - node.rect_size.x / 2
	node.offset.y = y_pos - rect_global_position.y + scroll_offset.y - node.rect_size.y / 2
	node.connect("dragged", self, "node_dragged", [])
	add_child(node)
	save_current_conversation()

# add new node to the graph
func add_new_node(node):
	if current_conversation_path == null:
		return

	# adds the conversation starting from the center
	node.offset.x = node.offset.x
	node.offset.y = node.offset.y
	node.connect("dragged", self, "node_dragged", [])
	add_child(node)

# temp function to connect a drag to save
func node_dragged(from, to):
	save_current_conversation()

func setup_graph():
	reset_graph()
	
	if current_conversation == null:
		return
	
	if not "nodes" in current_conversation:
		return
	
	# position graph to the last left place
	if "scroll_offset" in current_conversation:
		scroll_offset = Vector2(current_conversation["scroll_offset"][0], current_conversation["scroll_offset"][1])
		
	for node in current_conversation.nodes:
		var new_node = null
		if node.type == "dialogue":
			new_node = dialogue_node.instance()
		if node.type == "start":
			new_node = start_node.instance()
		if node.type == "end":
			new_node = end_node.instance()
		
		add_new_node(new_node)
		new_node.construct_from_json(node)
	
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

# remove connections associated with node
func remove_connections(node):
	for connection in get_connection_list():
		var from_node = get_node_by_name(connection.from)
		var to_node = get_node_by_name(connection.to)
		if from_node.name == node.name or to_node.name == node.name:
			disconnect_nodes(connection.from, connection.from_port, connection.to, connection.to_port)
		
func delete_node(node):
	remove_connections(node)
	remove_child(node)
	save_current_conversation()

func get_node_by_name(name):
	for node in get_children():
		if not node is GraphNode:
			continue
		
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
	save_current_conversation()

func disconnect_nodes(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
	save_current_conversation()
