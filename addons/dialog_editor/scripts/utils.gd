extends Reference
class_name Utils

const MAX_CHAR_NUM = 10

static func parse_to_numeric_string(text) -> String:
	var final = ""
	var valid = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]
	for character in text: 
		if character in valid:
			final = final + character

	return final 

static func calculate_id() -> String: 
	var pos_start = randi() % 10
	return String(randi() * randf() * randi() * randf()).sha256_text().substr(pos_start, pos_start + MAX_CHAR_NUM)

static func get_conversations_path() -> String: 
	var setting_name = "addons/Dialog Assets Folder"
	var assets_folder = ProjectSettings.get_setting(setting_name)
	return assets_folder + "/conversations/"

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
	
# get conversations in the form of an array of 
# { name: "name of file", id: "id from file" }
static func get_conversations_struct() -> Array:
	var conversations_folder = get_conversations_path()
	var files_struct = []
	# find every json in conversations folder
	var dir = Directory.new()
	dir.open(conversations_folder)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(".json"):
			# get name
			var new_struct = {"name": file.replace(".json", "")}
			
			# get id
			var json_file = File.new()
			json_file.open(conversations_folder + file, File.READ)
			var content = json_file.get_as_text()
			json_file.close()
		
			var parsed_json = JSON.parse(content).result
			new_struct.id = parsed_json.id
			new_struct.nodes = parsed_json.nodes
			
			files_struct.append(new_struct)
			
	dir.list_dir_end()
	
	return files_struct
	
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
