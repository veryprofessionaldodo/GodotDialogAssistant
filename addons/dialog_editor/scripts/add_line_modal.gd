tool
extends ConfirmationDialog

var valid_time = true
var valid_char = false
var valid_name = false
var valid_en_text = false
var valid_en_audio = false
var valid_pt_text = false
var valid_pt_audio = false
var id = -1

var line_name = ""
var character = ""
var time = -1
var en_text = ""
var en_audio = ""
var pt_text = ""
var pt_audio = ""

var setting_name = "addons/Dialog Assets Folder"
var lines_path = null
var assets_folder = null
var lines = []

var confirmation_button = null

signal new_line_signal(properties)

# Called when the node enters the scene tree for the first time.
func _ready():
	assets_folder = ProjectSettings.get_setting(setting_name)
	lines_path = assets_folder + "/lines.json"
	if assets_folder:
		read_lines()

	get_existing_line_names()
	confirmation_button = get_ok()
	is_valid()
	
# read from file
func read_lines():
	var file = File.new()
	file.open(lines_path, File.READ)
	var content = file.get_as_text()
	
	# if there's nothing on the file, ignore
	if not content:
		return
		
	var json_file = JSON.parse(content).result
	
	if "lines" in json_file:
		lines = json_file.lines

	file.close()

# read lines file to see if there's no collision of names
func get_existing_line_names():
	pass
	
func emit_line_signal():
	id = Utils. calculate_id()
	var props = {
		"id": id,
		"name": line_name,
		"time": time,
		"type": "line",
		"text": {},
		"audio": {},
		"char": character
	}
	
	if valid_en_text:
		props.text["en"] = en_text
	
	if valid_en_audio:
		props.audio["en"] = en_audio
	
	if valid_pt_text:
		props.text["pt"] = pt_text
	
	if valid_pt_audio:
		props.audio["pt"] = pt_audio

	emit_signal("new_line_signal", props)
	
	reset()
	
func reset():
	line_name = ""
	character = ""
	time = -1
	en_text = ""
	en_audio = ""
	pt_text = ""
	pt_audio = ""

	$VBoxContainer/Names/LineEdit.text = ""
	$VBoxContainer/Character/LineEdit.text = ""
	$VBoxContainer/Time/LineEdit.text = ""
	$VBoxContainer/EnText/LineEdit.text = ""
	$VBoxContainer/PtText/LineEdit.text = ""

func name_text_entered(new_text):
	line_name = new_text
	
	for line in lines:
		if line.name == new_text:
			valid_name = false
			is_valid()
			return

	if new_text != "" and not new_text.is_valid_float():
		valid_name = true
	else:
		valid_name = false
	
	is_valid()

func character_name_entered(new_text):
	if new_text != "" and not new_text.is_valid_float():
		character = new_text
		valid_char = true
	else:
		valid_char = false
	
	is_valid()

func time_entered(new_text):
	if new_text.is_valid_float():
		time = float(new_text)
		valid_time = true
	else:
		valid_time = false
	
	is_valid()
	
func en_text_entered(new_text):
	if new_text != "" and not new_text.is_valid_float():
		valid_en_text = true
		en_text = new_text
	else:
		valid_en_text = false
	
	is_valid()

func en_audio_button_pressed():
	pass # Replace with function body.

func pt_text_entered(new_text):
	if new_text != "" and not new_text.is_valid_float():
		valid_pt_text = true
		pt_text = new_text
	else:
		valid_pt_text = false
	
	is_valid()

func pt_audio_button_pressed():
	pass # Replace with function body.

func is_valid():
	var output = $VBoxContainer/Output/OutputResult
	output.text = ""
	
	if not valid_name:
		if line_name == "":
			output.text = output.text + "Invalid name, empty string.\n"
		else:
			output.text = output.text + "Invalid name, could already be in use in other line.\n"
	
	if not valid_time:
		if time == "":
			output.text = output.text + "Invalid time, empty field.\n"
		else:
			output.text = output.text + "Invalid time, needs to be a number (defaults to -1).\n"
	
	if not valid_char:
		output.text = output.text + "Invalid character name, is empty string or a number.\n"
	
	if not valid_en_text:
		output.text = output.text + "Invalid English text.\n"
	
	if not valid_en_text or not valid_name or not valid_time or not valid_char:
		confirmation_button.disabled = true
		return
	
	confirmation_button.disabled = false
