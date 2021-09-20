tool
extends VBoxContainer

var setting_name = "addons/Dialog Assets Folder"
var conversations_folder = ""
var delete_scene = preload("res://addons/dialog_editor/scenes/modals/delete_conversation.tscn")
var delete_modal = null
var graph_node = null
var files_struct = []
var list_container = null

var selected_color = "#9dd5ff"
var error_color = "#f66d6d"

var button_being_edited = null
var container_being_edited = null
var line_edit_being_edited = null
var conversation_being_deleted = null

var current_conversation = null

func set_graph_node(node):
	graph_node = node;
	initial_setup()
	
# initial setup of entire tab
func initial_setup():
	list_container = $ConversationsList/ListContainer
	delete_modal = delete_scene.instance()
	delete_modal.connect("confirmed", self, "delete_conversation")

	# get informations	
	if ProjectSettings.has_setting(setting_name):
		conversations_folder = Utils.get_conversations_path()

		# get all the necessary information
		files_struct = Utils.get_conversations_struct()
		
		populate_list()

# add all the buttons and line edits
func populate_list():
	# insert each file name into list
	for file in files_struct:
		insert_button(file.name)
		insert_line_edit(file.name)

func insert_button(name):
	# create the container for the two buttons
	var conversation_container = HSplitContainer.new()
	list_container.add_child(conversation_container)
	
	# create the conversation button
	var conversation_button = Button.new()
	conversation_button.text = name.replace(".json", "")
	conversation_button.flat = true
	conversation_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conversation_container.add_child(conversation_button)
	
	# link the signal to handle input to here
	conversation_button.connect("gui_input", self, "handle_button_input", [conversation_button])
	conversation_button.connect("pressed", self, "change_conversation", [conversation_button])
	change_conversation(conversation_button)
	
	# create the conversation delete button
	var delete_button = Button.new()
	delete_button.text = "Delete"
	conversation_container.add_child(delete_button)
	
	# link the signal to handle input to here
	delete_button.connect("pressed", self, "prompt_to_delete", [conversation_button])

func change_conversation(new_button):
	if not current_conversation == null:
		current_conversation.add_color_override("font_color", Color(1,1,1,1))
		current_conversation.add_color_override("font_color_hover", Color(1,1,1,1))
	
	current_conversation = new_button
	new_button.add_color_override("font_color", Color(selected_color))
	new_button.add_color_override("font_color_hover", Color(selected_color))
	graph_node.load_conversation(new_button)

# initialize the process to store the setting
func prompt_to_delete(conversation_button):
	get_node("/root").add_child(delete_modal)
	conversation_being_deleted = conversation_button
	
	delete_modal.popup_centered()

# after the user confirms to delete a conversation
func delete_conversation():
	if current_conversation == conversation_being_deleted:
		graph_node.load_conversation(null)
		
	var text_id = conversation_being_deleted.text
	var deleted_line_edit = get_respective_node(text_id, LineEdit)
	var deleted_container = get_respective_node(text_id, HSplitContainer)
	
	list_container.remove_child(deleted_line_edit)
	list_container.remove_child(deleted_container)
	
	delete_file(text_id)

# deletes file from conversation
func delete_file(text_id):
	var path = conversations_folder + text_id + ".json"
	var directory = Directory.new()
	directory.remove(path)
	
# link the signal to handle double click
func handle_button_input(event, button):
	if not event is InputEventMouseButton:
		return 
	
	if event.doubleclick:
		if button_being_edited != null:
			container_being_edited.visible = true
			line_edit_being_edited.visible = false
		
		line_edit_being_edited = get_respective_node(button.text, LineEdit)
		container_being_edited = get_respective_node(button.text, HSplitContainer)
		button_being_edited = get_respective_node(button.text, Button)

		container_being_edited.visible = false
		line_edit_being_edited.visible = true

func get_respective_node(name, type):
	for node in list_container.get_children():
		# children are either a split container or a line edit
		if node is HSplitContainer and type != LineEdit: 
			for node_child in node.get_children():
				if node_child is Button and node_child.text == name:
					if type == HSplitContainer:
						return node
					
					return node_child
					
		if node is type and "text" in node and node.text == name:
			return node
	return null

# called when the user clicks on enter when editing the name
func insert_line_edit(name):
	var line_edit = LineEdit.new()
	line_edit.text = name.replace(".json", "")
	line_edit.visible = false
	list_container.add_child(line_edit)
	
	line_edit.connect("text_entered", self, "line_edit_updated")
	line_edit.connect("text_change_rejected", self, "rejected_line_edit")

func rejected_line_edit(): 
	line_edit_being_edited.text = button_being_edited.text
	container_being_edited.visible = true
	line_edit_being_edited.visible = false
	line_edit_being_edited = null
	button_being_edited = null
	container_being_edited = null

func line_edit_updated(raw_text):
	print("editing", raw_text)
	var text = raw_text.replace(".json","").replace("/","")
	# the old path is stored in the name of the button, the first children of the container
	var old_path = conversations_folder + container_being_edited.get_children()[0].text + ".json"
	var new_path = conversations_folder + text + ".json"
	
	# check if file already exists with that name 
	var dir = Directory.new()
	dir.open(conversations_folder)

	if dir.file_exists(new_path): 
		print("File already exists, rejecting.")
		rejected_line_edit()
		return
	
	# if it doesn't exist, store current variables
	var file = File.new()
	file.open(old_path, File.READ)
	var content = file.get_as_text()
	file.close()
	
	# remove previous file
	dir.remove(container_being_edited.get_children()[0].text + ".json")

	# create new file with the same text
	file.open(new_path, File.WRITE)
	file.store_line(content)
	file.close()
	
	button_being_edited.text = text
	container_being_edited.visible = true
	line_edit_being_edited.visible = false
	line_edit_being_edited = null
	button_being_edited = null
	container_being_edited = null
	graph_node.load_conversation(current_conversation, false)

func add_conversation():
	var found_new = false
	var index = 1
	while not found_new:
		if get_respective_node("new conversation " + String(index), Button) == null:
			break
		
		index += 1

	var new_name = "new conversation " + String(index)
	create_file(new_name)
	insert_button(new_name)
	insert_line_edit(new_name)
	
func create_file(name): 
	var file = File.new()
	var dict = {}
	dict.id = Utils.calculate_id()
		
	file.open(conversations_folder + name + ".json", File.WRITE)
	var json_string = JSON.print(dict, "\t")
	
	file.store_line(json_string)
	file.close()

func validate_conversations():
	var previous_conversation = current_conversation
	var has_error = false
	# iterate through all conversations
	for conversation in list_container.get_children():
		if not conversation is HSplitContainer:
			continue 
	 
		var button = conversation.get_child(0)

		# make node graph load conversation 
		graph_node.load_conversation(button)
		
		button.add_color_override("font_color", Color(1,1,1,1))
		button.add_color_override("font_color_hover", Color(1,1,1,1))
		
		# validate conversation, if output is returned,
		# there's an error
		var output = graph_node.validate(false)
		
		if output != "":
			has_error = true
			button.add_color_override("font_color", Color(error_color))
			button.add_color_override("font_color_hover", Color(error_color))
			
	current_conversation = previous_conversation
	graph_node.load_conversation(current_conversation)
	
	return has_error

func export_final():
	var has_errors = validate_conversations()
	
	var modal = ConfirmationDialog.new()
	modal.window_title = "Export Status"
	
	var final_dict = {}
	
	var variables = Utils.get_variables_from_file()
	var lines = Utils.get_lines_from_file()
	var conversations_struct = Utils.get_conversations_struct()
	
	final_dict.variables = variables
	final_dict.lines = lines
	final_dict.conversations = conversations_struct
	var json_string = JSON.print(final_dict, "\t")
	
	var script_path = ProjectSettings.get_setting(setting_name) + "/script.json"
	var dir = Directory.new()
	dir.open(ProjectSettings.get_setting(setting_name))
	dir.remove("script.json")
	
	# create new file with the same text
	var file = File.new()
	file.open(script_path, File.WRITE)
	file.store_line(json_string)
	file.close()
	
	if has_errors: 
		modal.dialog_text = "There were conversations with errors. Exporting anyways, but might lead to runtime crashes."
	else:
		modal.dialog_text = "Successfully exported to 'script.json'!"

	modal.popup_exclusive = true
	add_child(modal)
	modal.popup_centered()

