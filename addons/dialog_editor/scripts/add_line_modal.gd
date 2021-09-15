tool
extends ConfirmationDialog

var valid_time = true
var valid_char = false
var valid_en_text = false
var valid_en_audio = false
var valid_pt_text = false
var valid_pt_audio = false
var id = -1

var character = ""
var time = -1
var en_text = ""
var en_audio = ""
var pt_text = ""
var pt_audio = ""

signal new_line_signal(properties)

var confirmation_button = null

# Called when the node enters the scene tree for the first time.
func _ready():
	confirmation_button = get_ok()
	confirmation_button.connect("pressed", self, "finish_new_line")
	is_valid()

# checks to see if the user can quickly add a line
func _input(event):
	if event is InputEventKey and event.is_action_released("ui_accept") and not confirmation_button.disabled:
		confirmation_button.emit_signal("pressed")
	
func finish_new_line():
	id = Utils.calculate_id()
	var props = {
		"id": id,
		"time": time,
		"type": "line",
		"text": {},
		"audio": {},
		"char": character
	}
	
	if valid_en_text:
		props.text["en"] = en_text
		valid_en_text = false
	
	if valid_en_audio:
		props.audio["en"] = en_audio
		valid_en_audio = false
	
	if valid_pt_text:
		props.text["pt"] = pt_text
		valid_pt_text = false
	
	if valid_pt_audio:
		props.audio["pt"] = pt_audio
		valid_pt_audio = false
	
	var lines_tab = get_tree().get_root().find_node("BaseLinesContainer", true, false)
	lines_tab.line_signal_received(props)
	
	reset()

	emit_signal("new_line_signal", props)
	
func reset():
	character = ""
	time = -1
	en_text = ""
	en_audio = ""
	pt_text = ""
	pt_audio = ""

	$VBoxContainer/Character/LineEdit.text = ""
	$VBoxContainer/Time/LineEdit.text = "-1"
	$VBoxContainer/EnText/LineEdit.text = ""
	$VBoxContainer/PtText/LineEdit.text = ""
	
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
	
	if not valid_time:
		if time == "":
			output.text = output.text + "Invalid time, empty field.\n"
		else:
			output.text = output.text + "Invalid time, needs to be a number (defaults to -1).\n"
	
	if not valid_char:
		output.text = output.text + "Invalid character name, is empty string or a number.\n"
	
	if not valid_en_text:
		output.text = output.text + "Invalid English text.\n"
	
	if not valid_en_text or not valid_time or not valid_char:
		confirmation_button.disabled = true
		return
	
	confirmation_button.disabled = false
