tool
extends FileDialog

var plugin_name = "addons/Dialog Assets Folder"

# Folder for dialog saves has been created / selected
func _on_confirmed():
	# check if there is a setting to store the information
	if not ProjectSettings.has_setting(plugin_name):
		var property_info = {
			"name": plugin_name,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_DIR,
			"hint_string": "Folder where all dialog and plugin information is stored."
		}
		
		ProjectSettings.add_property_info(property_info)
		
	# update the setting and save
	ProjectSettings.set_setting(plugin_name, current_dir)
	ProjectSettings.save()
	
	# create folder and file structure
	populate_folder()

# initial dialog has been accepted, show file dialog
func _on_AcceptDialog_confirmed():
	popup_centered()

# populate folder with the correct files 
func populate_folder():
	var asset_folder = ProjectSettings.get_setting(plugin_name)
	
	# create directories
	var directory = Directory.new()
	if directory.open(asset_folder) == OK:
		print(asset_folder + "/conversations")
		directory.make_dir(asset_folder + "/conversations")
		directory.make_dir(asset_folder + "/variables")
		directory.make_dir(asset_folder + "/graphs_info")
	
	# create final script json
	var file = File.new()
	file.open(asset_folder + "/script.json", File.WRITE)
	file.store_line("{}")
	file.close()
	
