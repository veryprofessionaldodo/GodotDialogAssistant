tool
extends GraphEdit

var setting_name = "addons/Dialog Assets Folder"
var conversations_folder = ""
var current_conversation = {"nodes": []}
var current_conversation_path = null
var id = ""

var start_node = preload("res://addons/dialog_editor/scenes/nodes/start.tscn")
var end_node = preload("res://addons/dialog_editor/scenes/nodes/end.tscn")
var dialogue_node = preload("res://addons/dialog_editor/scenes/nodes/dialogue.tscn")
var input_node = preload("res://addons/dialog_editor/scenes/nodes/input.tscn")
var requirement_node = preload("res://addons/dialog_editor/scenes/nodes/requirement.tscn")
var effect_node = preload("res://addons/dialog_editor/scenes/nodes/effect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# get informations	
	if ProjectSettings.has_setting(setting_name):
		conversations_folder = ProjectSettings.get_setting(setting_name) + "/conversations/"

# autosave is used when changing conversation
func load_conversation(node, auto_save = true):
	# conversation was deleted, reset graph and do nothing else
	if node == null:
		current_conversation_path = null
		reset_graph()
		return

	if auto_save:
		save_current_conversation()
	
	current_conversation_path = conversations_folder + node.text + ".json"
	var file = File.new()
	var error = file.open(current_conversation_path, File.READ)
	current_conversation = JSON.parse(file.get_as_text()).result
	file.close()
	
	id = current_conversation.id 
	setup_graph()
	
# saves the current conversation directly to file
func save_current_conversation():
	if current_conversation_path == null: 
		return
		
	print("saving to ", current_conversation_path)

	var conversation_parsed = {}
	conversation_parsed.id = id
	conversation_parsed["nodes"] = [] 
	conversation_parsed["scroll_offset"] = [scroll_offset.x, scroll_offset.y]
	for node in get_children():
		if not node is GraphNode:
			continue
		
		# save all connections
		var node_info = node.convert_to_json()
		
		# if it is an end node, already has next, 
		# continue to the next node
		if "next" in node_info:
			conversation_parsed.nodes.append(node_info)
			continue
			
		node_info.next = []
		for connection in get_connection_list():
			if node.name == connection.from:
				var connecting_node_id = get_node_by_name(connection.to).get_id()
				node_info.next.append([connection.from_port, connecting_node_id, connection.to_port])
		
		conversation_parsed.nodes.append(node_info)
		
	# remove previous file
	var dir = Directory.new()
	dir.open(conversations_folder)
	print("current path ", current_conversation_path)
	dir.remove(current_conversation_path)

	# create new file with the same text
	var file = File.new()
	file.open(current_conversation_path, File.WRITE)
	file.store_string(JSON.print(conversation_parsed, "\t"))
	file.close()
	
func get_new_node_by_type(type):
	var new_node = null
	if type == "dialogue":
		new_node = dialogue_node.instance()
	if type == "start":
		new_node = start_node.instance()
	if type == "end":
		new_node = end_node.instance()
	if type == "input":
		new_node = input_node.instance()
	if type == "requirement":
		new_node = requirement_node.instance()
	if type == "effect":
		new_node = effect_node.instance()
		
	return new_node

# adds new node to the graph via drag
func add_new_drag_node(type, position):
	if current_conversation_path == null:
		return
	
	var node = get_new_node_by_type(type)
	node.offset = position
	
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
		var new_node = get_new_node_by_type(node.type)
		add_new_node(new_node)
		new_node.construct_from_json(node)
	
	# do connections between nodes
	for node in current_conversation.nodes:
		# it's an end node, continue
		if not node.next is Array:
			continue 
		
		# node has no end connections
		if len(node.next) == 0:
			continue
		
		for next in node.next:
			# if it is the end node, don't try to 
			# connect to next, it's a string for the 
			# next conversation
			if not node.next is Array:
				break
				
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
func validate(shows_modal = true):
	var output = ""
	
	# check if there is a start / end node, and it is connected to only
	# once 
	output = output + check_for_start()
	output = output + check_for_end()
	
	# check if dialogue nodes have lines
	output = output + check_for_lines()
	output = output + check_for_inputs()
	output = output + check_for_requirements_and_effects()
	
	if shows_modal:
		# launch popup with output
		if output == "":
			output = "Everything appears to be valid!"
	
		var modal = get_parent().get_node("ValidationOutput")
		modal.get_node("Container/OutputText").text = output
		modal.popup_centered()
	
	return output
	
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
		
	# input has specific rules, as it has multiple outputs
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
				var num_not_requirements = 0
				for slot_connection in slot_connections:
					if slot_connection != "requirement":
						num_not_requirements = num_not_requirements + 1
						
						# there can be only one not requirement node as a fallback
						# in case no requirement node passes
						if num_not_requirements > 2:
							inputs_connection_text = inputs_connection_text + "Input has too many outpus in slot " + str(i) + "and they're not all requirements. \n"
					
		
		return inputs_connection_text

	if len(connections) > 1:
		var num_not_requirements = 0
		for slot_connection in connections:
			if slot_connection != "requirement":
				num_not_requirements = num_not_requirements + 1
						
				# there can be only one not requirement node as a fallback
				# in case no requirement node passes
				if num_not_requirements > 2:
					return "Node of type " + node_type + " has multiple connections that are not all requirements. \n"
			
	return ""

func check_for_start():
	var num_start = 0 
	var connections = []
	var start_nodes = []
	for node in get_children():
		if not node is GraphNode:
			continue
		
		if node.get_type() == "start":
			num_start = num_start + 1
			
			connections = get_connections_for_node(node)
			start_nodes.append(node)

	# check if there are multiple start nodes
	if num_start > 1:
		for node in start_nodes:
			node.set_overlay(2)
		return "Too many start nodes in conversation (" + str(num_start) + "). \n"	
	elif num_start == 0:
		return "No start node in conversation. \n"
		
	var connections_info = check_connections(connections, start_nodes[0])
	if connections_info != "":
		start_nodes[0].set_overlay(2)
		return connections_info
	
	start_nodes[0].set_overlay(0)
	return ""
	
func check_for_end():
	var has_end = false
	var num_end = 0
	var connections = []
	var end_nodes = []
	for node in get_children():
		if not node is GraphNode:
			continue
		
		if node.get_type() == "end":
			num_end = num_end + 1 
			
			has_end = true
			end_nodes.append(node)
			connections = get_connections_to_node(node)
	
	if num_end > 1:
		for node in end_nodes:
			node.set_overlay(2)
		return "Too many end_nodes in conversation (" + str(num_end) + "). \n"
	if not has_end:
		return "No end node in conversation. \n"
		
	if len(connections) == 0:
		end_nodes[0].set_overlay(2)
		return "End node has no connected nodes. \n"
		
	var internal_info = end_nodes[0].validate_node_info()
	if internal_info != "":
		end_nodes[0].set_overlay(2)
		return internal_info
	
	
	# there is only one end node, and it is a-ok
	end_nodes[0].set_overlay(0)
	return ""

func check_for_requirements_and_effects():
	var output = ""
	
	for node in get_children():
		if not node is GraphNode:
			continue
			
		var type = node.get_type()
		
		if type != "requirement" and type != "effect":
			continue
		
		var pretty_type = node.get_type().capitalize()
		
		node.set_overlay(0)
		
		var connections_to = get_connections_to_node(node) 
		if len(connections_to) == 0:
			node.set_overlay(2)
			output = output + pretty_type + " is not connected to any previous node. \n"
		
		var connections_for = get_connections_for_node(node)
		var connections_info = check_connections(connections_for, node)
		
		if connections_info != "":
			node.set_overlay(2)
			output = output + connections_info
		
		var node_info = node.validate_node_info()
		if node_info != "": 
			node.set_overlay(2)
			
		output = output + node_info
	
	return output

func check_for_lines():
	var lines_output = ""
	
	for node in get_children():
		if not node is GraphNode:
			continue
			
		if node.get_type() != "dialogue":
			continue
		
		node.set_overlay(0)
		
		var connections_to = get_connections_to_node(node) 
		if len(connections_to) == 0:
			node.set_overlay(2)
			lines_output = lines_output + "Dialogue is not connected to any previous node. \n"
		
		var connections_for = get_connections_for_node(node)
		var connections_info = check_connections(connections_for, node)
		if connections_info != "":
			node.set_overlay(2)
			lines_output = lines_output + connections_info
		
		if node.get_num_lines() == 0:
			lines_output = lines_output + "Dialogue has no lines attached. \n"
			node.set_overlay(2)
		
		var node_validation_info = node.validate_node_info()
		if node_validation_info != "":
			node.set_overlay(2)
			lines_output = lines_output + node_validation_info
	
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
		
		node.set_overlay(0)
		
		var connections_info = check_connections(connections_for, node)
		if connections_info != "":
			node.set_overlay(2)
			inputs_output = inputs_output + connections_info
			
		if node.get_num_inputs() == 0:
			node.set_overlay(2)
			inputs_output = inputs_output + "Input has no options given. \n"
		
	return inputs_output

# refresh information for entire conversation
func refresh():
	save_current_conversation()
	var file = File.new()
	var error = file.open(current_conversation_path, File.READ)
	current_conversation = JSON.parse(file.get_as_text()).result
	file.close()
	setup_graph()
