tool
extends HSplitContainer

var setting_name = "addons/Dialog Assets Folder"
var lines_path = null
var assets_folder = null
var lines = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	assets_folder = ProjectSettings.get_setting(setting_name)
	lines_path = assets_folder + "/variables/lines.json"
	if assets_folder:
		read_lines()
		
# read from file
func read_lines():
	print(lines_path)
	var file = File.new()
	file.open(lines_path, File.READ)
	var content = file.get_as_text()
	
	# if there's nothing on the file, ignore
	if not content:
		return
		
	var json_file = JSON.parse(content).result
	
	if "lines" in json_file:
		lines = json_file.lines
	
	display_lines()
	
func display_lines():
	var parent_container = $"LinesInfo"
	for line in lines:
		populate_line(line.name, line.text, line.char, line.time, line.audio)

func populate_line(name = "", text = "", character = "", time = -1, audio = ""):
	var parent_container = $"LinesInfo"
	
	var container = HSplitContainer.new()
	parent_container.add_child(container)
		
	var labels = VBoxContainer.new()
	container.add_child(labels)
	
	var name_label = Label.new()
	name_label.text = "Name"
	
	var character_label = Label.new()
	character_label.text = "Character"
	
	var time_label = Label.new()
	time_label.text = "Time"
	
	var en_text = Label.new()
	en_text.text = "EN Text"
	
	var en_audio = Label.new()
	en_audio.text = "EN Audio:"
	
	labels.add_child(name_label)
	labels.add_child(character_label)
	labels.add_child(time_label)
	labels.add_child(en_text)
	labels.add_child(en_audio)
	
	var info = VBoxContainer.new()
	container.add_child(info)
	
	var name_edit = LineEdit.new()
	name_edit.text = name
	
	var character_edit = LineEdit.new()
	character_edit.text = character
	
	var time_edit = LineEdit.new()
	time_edit.text = String(time)
	
	var en_text_edit = LineEdit.new()
	en_text_edit = text
	
	var en_audio_edit = LineEdit.new()
	
	info.add_child(name_edit)
	info.add_child(character_edit)
	info.add_child(time_edit)
	#info.add_child(en_text_edit)
	#info.add_child(en_audio_edit)
	
	
# store all lines to file
func write_to_file():
	var dir = Directory.new()
	var file = File.new()
	file.open(lines_path, File.READ)
	var content = file.get_as_text()
	file.close()
	
	# remove previous file
	dir.remove(lines_path)
	
	# create new file with the same text
	file.open(lines_path, File.WRITE)
	var json_string = JSON.print({lines: lines})
	file.store_string(json_string)
	file.store_line(content)
	file.close()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
