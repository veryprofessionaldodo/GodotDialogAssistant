tool
extends GraphEdit

var setting_name = "addons/Dialog Assets Folder"
var conversations_folder = ""
var current_conversation = {"nodes": []}
var current_conversation_path = null

var start_node = preload("res://addons/dialog_editor/scenes/nodes/start.tscn")
var end_node = preload("res://addons/dialog_editor/scenes/nodes/end.tscn")
var dialogue_node = preload("res://addons/dialog_editor/scenes/nodes/dialogue.tscn")
var input_node = preload("res://addons/dialog_editor/scenes/nodes/input.tscn")

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
		if node.type == "input":
			new_node = input_node.instance()
		
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

# SIGNALS

func connecting_nodes(from, from_slot, to, to_slot):
	connect_node(from, from_slot, to, to_slot)
	save_current_conversation()

func disconnect_nodes(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
	save_current_conversation()

# outputs the validation state for the conversation
func validate():
	var output = ""
	
	# check if there is a start / end node, and it is connected to only
	# once 
	output = output + check_for_start()
	output = output + check_for_end()
	
	# check if dialogue nodes have lines
	output = output + check_for_lines()
	output = output + check_for_inputs()
	
	# launch popup with output
	if output == "":
		output = "Everything appears to be valid!"
		
	$ValidationOutput/Container/OutputText.text = output
	$ValidationOutput.popup_centered()
	
# VALIDATION RULES

func get_connections_to_node(node):
	var connections = []
	for connection in get_connection_list():
		var from_node = get_node_by_name(connection.from)
		var to_node = get_node_by_name(connection.to)
		
		if to_node.get_id() == node.get_id():
			connections.append(str(connection.from_port) + ":" + from_node.get_type())
	
	return connections
		
func get_connections_for_node(node):
	var connections = []
	for connection in get_connection_list():
		var from_node = get_node_by_name(connection.from)
		var to_node = get_node_by_name(connection.to)
		
		if from_node.get_id() == node.get_id():
			connections.append(str(connection.from_port) + ":" + to_node.get_type())
			
	return connections
	
func check_connections(connections, node):
	var node_type = node.get_type()

	if len(connections) == 0:
		return "No connections found for " + node_type + " node. \n"
		
	# input has specific rules
	if node_type == "input":
		# iterate over every input
		var inputs_connections = {}
		var inputs_connection_text = ""
		
		for connection in connections:
			var slot = int(connection.split(":")[0])
			var to_node_type = connection.split(":")[1]
			if slot in inputs_connections:
				inputs_connections[slot].append(to_node_type)
			else:
				inputs_connections[slot] = [to_node_type]
				
		# check all the connections
		for i in range(0, node.get_num_inputs()):
			if not i in inputs_connections:
				inputs_connection_text = inputs_connection_text + "Input does not have connection in slot " + str(i) + ".\n"
				continue
			
			var slot_connections = inputs_connections[i]
			
			# has multiple connections from the same slot, they need to be
			# requirements
			if len(slot_connections) > 1:
				for slot_connection in slot_connections:
					if slot_connection != "requirement":
						inputs_connection_text = inputs_connection_text + "Input has too many outpus in slot " + str(i) + "and they're not all requirements. \n"
					
		
		return inputs_connection_text

	if len(connections) > 1: 
		for connection in connections:
			if "requirement" in connection:
				return "Node of type " + node_type + " has multiple connections that are not all requirements. \n"
	

	return ""

func check_for_start():
	var num_start = 0 
	var connections = []
	var start_node = null
	for node in get_children():
		if not node is GraphNode:
			continue
		
		if node.get_type() == "start":
			num_start = num_start + 1
			
			connections = get_connections_for_node(node)
			start_node = node

	# check if there are multiple start nodes
	if num_start != 1:
		return "Too many start nodes in conversation (" + str(num_start) + "). \n"	
	elif num_start == 0:
		return "No start node in conversation. \n"
	return check_connections(connections, start_node)
	
func check_for_end():
	var has_end = false
	var num_end = 0
	var connections = []
	for node in get_children():
		if not node is GraphNode:
			continue
		
		if node.get_type() == "end":
			num_end = num_end + 1 
			
			has_end = true
			connections = get_connections_to_node(node)
	
	if num_end > 1:
		return "Too many end_nodes in conversation (" + str(num_end) + "). \n"
	if not has_end:
		return "No end node in conversation. \n"
	elif len(connections) == 0:
		return "End node has no connected nodes. \n"
		
	return ""
	
func check_for_lines():
	var lines_output = ""
	
	for node in get_children():
		if not node is GraphNode:
			continue
			
		if node.get_type() != "dialogue":
			continue
		
		var connections_to = get_connections_to_node(node) 
		if len(connections_to) == 0:
			lines_output = lines_output + "Dialogue is not connected to any previous node. \n"
		var connections_for = get_connections_for_node(node)
		
		lines_output = lines_output + check_connections(connections_for, node)
		
		if node.get_num_lines() == 0:
			lines_output = lines_output + "Dialogue has no lines attached. \n"
	
	return lines_output

func check_for_inputs():
	var inputs_output = ""
	
	for node in get_children():
		if not node is GraphNode:
			continue
			
		if node.get_type() != "input":
			continue
			
		var connections_to = get_connections_to_node(node) 
		if len(connections_to) == 0:
			inputs_output = inputs_output + "Input is not connected to any previous node. \n"
		var connections_for = get_connections_for_node(node)
		
		inputs_output = inputs_output + check_connections(connections_for, node)
		
		if node.get_num_inputs() == 0:
			inputs_output = inputs_output + "Input has no options given. \n"
	
	return inputs_output
