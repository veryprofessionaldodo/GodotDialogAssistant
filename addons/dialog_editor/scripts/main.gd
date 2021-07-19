tool
extends PanelContainer

func _ready():
	# check if the settings have been initialized
	if not ProjectSettings.get_setting("addons/Dialog Assets Folder"):
		# if it's not declared, emit popup to set the assets location
		initial_prompt_for_settings()

# initialize the process to store the setting
func initial_prompt_for_settings():
	$"Modals/RequestAssetFolderDialog".popup_centered()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
