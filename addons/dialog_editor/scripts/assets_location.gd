tool
extends FileDialog

var setting_name = "addons/Dialog Assets Folder"

# Folder for dialog saves has been created / selected
func _on_confirmed():
	# check if there is a setting to store the information
	if not ProjectSettings.has_setting(setting_name):
		var property_info = {
			"name": setting_name,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_DIR,
			"hint_string": "Folder where all dialog and plugin information is stored."
		}
		
		ProjectSettings.add_property_info(property_info)
		
	# update the setting and save
	ProjectSettings.set_setting(setting_name, current_dir)
	ProjectSettings.save()
	
	# create folder and file structure
	populate_folder()

# initial dialog has been accepted, show file dialog
func _on_AcceptDialog_confirmed():
	popup_centered()

# populate folder with the correct files 
func populate_folder():
	var asset_folder = ProjectSettings.get_setting(setting_name)
	
	# create directories
	var directory = Directory.new()
	var file = File.new()
	
	if directory.open(asset_folder) == OK:
		# create base files to populate folders
		directory.make_dir(asset_folder + "/conversations")
		file.open(asset_folder + "/conversations/conversation_1.json", File.WRITE)
		file.store_line("{}")
		file.close()
		
		directory.make_dir(asset_folder + "/variables")
		file.open(asset_folder + "/variables/lines.json", File.WRITE)
		file.store_line("{}")
		file.close()
		file.open(asset_folder + "/variables/events.json", File.WRITE)
		file.store_line("{}")
		file.close()
		file.open(asset_folder + "/variables/statistics.json", File.WRITE)
		file.store_line("{}")
		file.close()

	# create final script json
	
	file.open(asset_folder + "/script.json", File.WRITE)
	file.store_line("{}")
	file.close()
	
