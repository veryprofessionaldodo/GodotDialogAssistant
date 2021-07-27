tool
extends PanelContainer

var setting_name = "addons/Dialog Assets Folder"

func _ready():
	fill_information()
	# check if the settings have been initialized
	if not ProjectSettings.get_setting(setting_name):
		# if it's not declared, emit popup to set the assets location
		initial_prompt_for_settings()

# send required information to nodes
func fill_information():
	$"Main Window/Editor/Tabs/Conversations".set_graph_node($"Main Window/Editor/Graph/Node Graph")
	$"Main Window/Editor/Tabs/Nodes".set_graph_node($"Main Window/Editor/Graph/Node Graph")

# initialize the process to store the setting
func initial_prompt_for_settings():
	$"Modals/RequestAssetFolderDialog".popup_centered()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
