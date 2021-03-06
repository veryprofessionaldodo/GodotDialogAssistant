tool
extends VBoxContainer

var lines = []
var ui_lines = []
var languages = ["en", "pt", "fr"]

# Called when the node enters the scene tree for the first time.
func _ready():
	lines = Utils.get_lines_from_file()
	display_lines()

func display_lines():
	for line in lines:
		populate_line(line.id, line.text, line.char, line.time, line.audio)

func populate_line(id = -1, texts = {}, character = "", time = -1, audios = {}):
	var parent_container = $"LinesInfo"
			
	var container = VBoxContainer.new()
	parent_container.add_child(container)
	
	var buttons_container = HBoxContainer.new()
	
	var delete_button = Button.new()
	delete_button.text = "Delete Line"
	delete_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	delete_button.connect("pressed", self, "delete_line", [container, id])
	delete_button.margin_top = delete_button.margin_top + 10
	delete_button.margin_bottom = delete_button.margin_bottom + 10
	
	var collapse_toggle_button = Button.new()
	collapse_toggle_button.text = "Collapse/Expand"
	
	buttons_container.add_child(delete_button)
	buttons_container.add_child(collapse_toggle_button)
	
	container.add_child(buttons_container)
	
	var info_container = VBoxContainer.new()
	
	# Character Field
	var character_container = HSplitContainer.new()
	var character_label = Label.new()
	character_label.text = "Character"
	character_label.rect_min_size = Vector2(80,0)
	
	var character_edit = LineEdit.new()
	character_edit.text = character
	character_edit.connect("text_entered", self, "value_changed", [{"id":id, "type":"char"}])
	
	character_container.add_child(character_label)
	character_container.add_child(character_edit)
	
	info_container.add_child(character_container)
	
	# Time Field
	var time_container = HSplitContainer.new()
	var time_label = Label.new()
	time_label.text = "Time"
	time_label.rect_min_size = Vector2(80,0)
	
	var time_edit = LineEdit.new()
	time_edit.text = String(time)
	time_edit.connect("text_entered", self, "value_changed", [{"id":id, "type":"time"}])
	
	time_container.add_child(time_label)
	time_container.add_child(time_edit)
	
	info_container.add_child(time_container)
	
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
		text_value_edit.connect("text_entered", self, "value_changed", [{"id": id, "type": "text", "lang":lang}])
	
		full_dialogue_container.add_child(language_options)
		full_dialogue_container.add_child(text_value_edit)
		
		var audio_label = Label.new()
		audio_label.text = "Audio File"
		
		var audio_text = Label.new()
		if lang in audios:
			audio_text.text = audios[lang]
		else: 
			audio_text.text = "None"
		audio_text.rect_min_size = Vector2(90,0)
		
		var change_audio_file = Button.new()
		change_audio_file.text = "Change File"
		
		full_dialogue_container.add_child(audio_label)
		full_dialogue_container.add_child(audio_text)
		full_dialogue_container.add_child(change_audio_file)
		
		all_lines_container.add_child(full_dialogue_container)
	
	info_container.add_child(all_lines_container)
	container.add_child(info_container)
	ui_lines.append(info_container)
	collapse_toggle_button.connect("pressed", self, "collapse_toggle", [info_container])

	# add separator
	var separator = HSeparator.new()
	container.add_child(separator)

func collapse_all():
	for line in ui_lines:
		line.visible = false
		
func expand_all():
	for line in ui_lines:
		line.visible = true
		
func add_new_line():
	# launch new add line modal
	$"Modals/AddLineDialog".popup_centered()

func delete_line(container, id):
	for i in range(0, len(lines)):
		if str(lines[i].id) == str(id):
			lines.remove(i)
			$"LinesInfo".remove_child(container)
			save()
			return

func collapse_toggle(container):
	container.visible = !container.visible

func value_changed(value, props = {}):
	for line in lines: 
		if line.id == props.id:
			if props.type == "text" or props.type == "audio":
				line[props.type][props.lang] = value
			else:
				line[props.type] = value
			save()
			return

# store all lines to file
func save():
	var lines_path = Utils.get_lines_path()
	# remove previous file
	var dir = Directory.new()
	dir.remove(lines_path)
	
	# create new file with the same text
	var file = File.new()
	file.open(lines_path, File.WRITE)
	var json_string = JSON.print({"lines": lines}, "\t")
	file.store_string(json_string)
	file.close()

func line_signal_received(line):
	lines.append(line)	
	populate_line(line.id, line.text, line.char, line.time, line.audio)
	save()
