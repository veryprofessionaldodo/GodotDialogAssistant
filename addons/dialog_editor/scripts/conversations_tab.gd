tool
extends ItemList

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
		print(file)
	
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
