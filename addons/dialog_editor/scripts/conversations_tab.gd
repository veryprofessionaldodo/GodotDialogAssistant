tool
extends VBoxContainer

var setting_name = "addons/Dialog Assets Folder"
var delete_modal = null
var conversations_folder = ""
var file_names = []

var button_being_edited = null
var container_being_edited = null
var line_edit_being_edited = null
var conversation_being_deleted = null

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_setup()
	
# initial setup of entire tab
func initial_setup():	
	delete_modal = get_node("/root/Mount/Modals/DeleteConversation")
	# get informations	
	if ProjectSettings.has_setting(setting_name):
		conversations_folder = ProjectSettings.get_setting(setting_name) + "/conversations/"

		# get all the necessary information
		get_all_files()
		
		populate_list()

# get files from assets directory
func get_all_files():
	# find every json in conversations folder
	var dir = Directory.new()
	dir.open(conversations_folder)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(".tres"):
			file_names.append(file)

	dir.list_dir_end()

# add all the buttons and line edits
func populate_list():
	# insert each file name into list
	for file in file_names:
		insert_button(file)
		insert_line_edit(file)
		
func insert_button(name):
	# create the container for the two buttons
	var conversation_container = HSplitContainer.new()
	add_child(conversation_container)
	
	# create the conversation button
	var conversation_button = Button.new()
	conversation_button.text = name.replace(".tres", "")
	conversation_button.flat = true
	conversation_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conversation_container.add_child(conversation_button)
	
	# link the signal to handle input to here
	conversation_button.connect("gui_input", self, "handle_button_input", [conversation_button])
	
	# create the conversation delete button
	var delete_button = Button.new()
	delete_button.text = "Delete"
	conversation_container.add_child(delete_button)
	
	# link the signal to handle input to here
	delete_button.connect("pressed", self, "prompt_to_delete", [conversation_button])

# initialize the process to store the setting
func prompt_to_delete(conversation_button):
	conversation_being_deleted = conversation_button
	
	delete_modal.popup_centered()

# after the user confirms to delete a conversation
func delete_conversation():
	var text_id = conversation_being_deleted.text
	var deleted_line_edit = get_respective_node(text_id, LineEdit)
	var deleted_container = get_respective_node(text_id, HSplitContainer)
	
	remove_child(deleted_line_edit)
	remove_child(deleted_container)
	
	delete_file(text_id)

# deletes file from conversation
func delete_file(text_id):
	var path = conversations_folder + text_id + ".tres"
	var directory = Directory.new()
	directory.remove(path)
	
# link the signal to handle double click
func handle_button_input(event, button):
	if not event is InputEventMouseButton:
		return 
	
	if event.doubleclick:
		if button_being_edited != null:
			button_being_edited.visible = true
			line_edit_being_edited.visible = false
		
		line_edit_being_edited = get_respective_node(button.text, LineEdit)
		container_being_edited = get_respective_node(button.text, HSplitContainer)
		button_being_edited = get_respective_node(button.text, Button)

		container_being_edited.visible = false
		line_edit_being_edited.visible = true

func get_respective_node(name, type):
	for node in get_children():
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
	line_edit.text = name.replace(".tres", "")
	line_edit.visible = false
	add_child(line_edit)
	
	line_edit.connect("text_entered", self, "line_edit_updated")
	line_edit.connect("text_changed", self, "update_button_text")
	line_edit.connect("text_change_rejected", self, "rejected_line_edit")

func rejected_line_edit(): 
	line_edit_being_edited.text = button_being_edited.text
	container_being_edited.visible = true
	line_edit_being_edited.visible = false
	line_edit_being_edited = null
	button_being_edited = null
	container_being_edited = null

func update_button_text(text):
	if ".tres" in text:
		line_edit_being_edited.text = text.replace(".tres", "")

func line_edit_updated(text):
	# the old path is stored in the name of the button, the first children of the container
	var old_path = conversations_folder + container_being_edited.get_children()[0].text + ".tres"
	var new_path = conversations_folder + text + ".tres"
	
	# check if file already exists with that name 
	var dir = Directory.new()
	
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
	dir.remove(old_path)
	
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

func add_conversation():
	var found_new = false
	var index = 1
	while not found_new:
		if get_respective_node("new conversation " + String(index), Button) == null:
			break
		
		index += 1

	var new_name = "new conversation " + String(index)
	insert_button(new_name)
	insert_line_edit(new_name)
	create_file(new_name)

func create_file(name): 
	var file = File.new()

	file.open(conversations_folder + name + ".tres", File.WRITE)
	file.store_line("{}")
	file.close()
