tool
extends VBoxContainer

var setting_name = "addons/Dialog Assets Folder"
var conversations_folder = ""
var file_names = []

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_setup()
	
# initial setup of entire tab
func initial_setup():
	# delete all children to fully reset the list
	#for child in get_children():
	#	child.queue_free()
	
	# get informations	
	if ProjectSettings.has_setting(setting_name):
		conversations_folder = ProjectSettings.get_setting(setting_name) + "/conversations/"

		# get all the necessary information
		get_all_files()
		
		populate_list()

func populate_list():
	# insert each file name into list
	for file in file_names:
		insert_button(file)
		insert_line_edit(file)
		
func insert_button(name):
	# create the button
	var button = Button.new()
	button.text = name.replace("_", " ").replace(".json", "")
	button.flat = true
	add_child(button)
	
	# link the signal to handle input to here
	button.connect("gui_input", self, "handle_button_input", [button.text])
	
	# link the signal to handle double click
func handle_button_input(event, name):
	if event.type==InputEvent.MOUSE_BUTTON:
		print("shit")
	if event.type==InputEvent.MOUSE_BUTTON and event.is_pressed() and event.doubleclick:
		print("handling button ", name)

func line_edit_updated(name):
	print("updating line ", name)

func insert_line_edit(name):
	var line_edit = LineEdit.new()
	line_edit.text = name.replace("_", " ").replace(".json", "")
	line_edit.visible = false
	print(line_edit.visible)
	add_child(line_edit)
	
	# line_edit.connect("text_entered", self, "line_edit_updated", [line_edit.text])
	
func get_all_files():
	# find every json in conversations folder
	var dir = Directory.new()
	dir.open(conversations_folder)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(".json"):
			file_names.append(file)

	dir.list_dir_end()
