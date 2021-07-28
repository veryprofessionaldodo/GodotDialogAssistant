tool
extends VBoxContainer

var setting_name = "addons/Dialog Assets Folder"
var lines_path = null
var assets_folder = null
var lines = []
var languages = ["en", "pt", "fr"]

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
	for line in lines:
		populate_line(line.id, line.name, line.text, line.char, line.time, line.audio)

func populate_line(id = -1, name = "", texts = {}, character = "", time = -1, audios = {}):
	var parent_container = $"LinesInfo"
			
	var container = VBoxContainer.new()
	parent_container.add_child(container)
	
	# Name Field
	var name_container = HSplitContainer.new()
	var name_label = Label.new()
	name_label.text = "Name"
	name_label.rect_min_size = Vector2(80,0)
	
	var name_edit = LineEdit.new()
	name_edit.text = name
	name_edit.connect("text_entered", self, "value_changed", [id, "name"])
	
	name_container.add_child(name_label)
	name_container.add_child(name_edit)
	
	container.add_child(name_container)
	
	# Character Field
	var character_container = HSplitContainer.new()
	var character_label = Label.new()
	character_label.text = "Character"
	character_label.rect_min_size = Vector2(80,0)
	
	var character_edit = LineEdit.new()
	character_edit.text = character
	character_edit.connect("text_entered", self, "value_changed", [id, "character"])
	
	character_container.add_child(character_label)
	character_container.add_child(character_edit)
	
	container.add_child(character_container)
	
	# Time Field
	var time_container = HSplitContainer.new()
	var time_label = Label.new()
	time_label.text = "Time"
	time_label.rect_min_size = Vector2(80,0)
	
	var time_edit = LineEdit.new()
	time_edit.text = String(time)
	time_edit.connect("text_entered", self, "value_changed", [id, "time"])
	
	time_container.add_child(time_label)
	time_container.add_child(time_edit)
	
	container.add_child(time_container)
	
	var all_lines_container = VBoxContainer.new()
	
	for lang in texts:
		var full_dialogue_container = HBoxContainer.new()
		var language_options = OptionButton.new()
		
		# add options to languages
		for i in range(0, len(languages)):
			language_options.add_item(languages[i], i)
			# select given option
			if languages[i] == lang:
				language_options.select(i)
	
		var text_value_edit = LineEdit.new()
		text_value_edit.text = texts[lang]
		text_value_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		full_dialogue_container.add_child(language_options)
		full_dialogue_container.add_child(text_value_edit)
		
		var audio_label = Label.new()
		audio_label.text = "Audio File"
		
		var audio_text = Label.new()
		audio_text.text = audios[lang]
		audio_text.rect_min_size = Vector2(90,0)
		
		var change_audio_file = Button.new()
		change_audio_file.text = "Change File"
		
		full_dialogue_container.add_child(audio_label)
		full_dialogue_container.add_child(audio_text)
		full_dialogue_container.add_child(change_audio_file)
		
		all_lines_container.add_child(full_dialogue_container)
	
	container.add_child(all_lines_container)
	
	# add separator
	var separator = HSeparator.new()
	container.add_child(separator)

func value_changed(text, id, property):
	for line in lines: 
		if line.id == id:
			line[property] = text
			write_to_file()
			return

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
	var json_string = JSON.print({"lines": lines}, "\t")
	file.close()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
