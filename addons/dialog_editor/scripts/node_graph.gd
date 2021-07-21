tool
extends GraphEdit

var setting_name = "addons/Dialog Assets Folder"
var conversations_folder = ""
var current_conversation = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# get informations	
	if ProjectSettings.has_setting(setting_name):
		conversations_folder = ProjectSettings.get_setting(setting_name) + "/conversations/"

func load_conversation(node):
	var path = conversations_folder + node.text + ".json"
	var file = File.new()
	file.open(path, File.READ)
	current_conversation = file.get_as_text()
	file.close()
	
	setup_graph()
	
func setup_graph():
	print("setting up ", current_conversation)
