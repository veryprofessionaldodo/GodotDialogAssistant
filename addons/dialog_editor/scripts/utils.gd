extends Reference
class_name Utils

static func parse_to_numeric_string(text) -> String:
	var final = ""
	var valid = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]
	for character in text: 
		if character in valid:
			final = final + character
			
	print("got text ", text, " parsed to ", final)
	return final 

static func calculate_id() -> String: 
	return String(randi()).sha256_text().substr(0, 24)

static func get_lines_path() -> String: 
	var setting_name = "addons/Dialog Assets Folder"
	var assets_folder = ProjectSettings.get_setting(setting_name)
	return assets_folder + "/lines.json"
	
static func get_variables_path() -> String:
	var setting_name = "addons/Dialog Assets Folder"
	var assets_folder = ProjectSettings.get_setting(setting_name)
	return assets_folder + "/variables.json"
	
static func get_variables_from_file() -> Array:
	var variables_path = get_variables_path()
	var file = File.new()
	file.open(variables_path, File.READ)
	var content = file.get_as_text()
	file.close()

	# if there's nothing on the file, ignore
	if not content:
		return []
		
	var json_file = JSON.parse(content).result
	
	if "variables" in json_file:
		return json_file.variables
	
	return []
	
static func get_lines_from_file() -> Array:
	var lines_path = get_lines_path()
	var file = File.new()
	file.open(lines_path, File.READ)
	var content = file.get_as_text()
	file.close()

	# if there's nothing on the file, ignore
	if not content:
		return []
		
	var json_file = JSON.parse(content).result
	
	if "lines" in json_file:
		return json_file.lines
	
	return []
