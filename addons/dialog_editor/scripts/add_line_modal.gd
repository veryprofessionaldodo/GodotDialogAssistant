tool
extends ConfirmationDialog

signal new_line_signal(properties)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func emit_line_signal():
	print("emitting?")
	var props = {
		"id": 1,
		"name": "pedro",
		"time": 3,
		"type": "line",
		"lines": {
			"en": "adding line via signal",
			"pt": "adicionando uma linha via signal"
		},
		"audio": {
			"en": "en/line.ogg",
			"pt": "pt/line.ogg"
		},
	}
	emit_signal("new_line_signal", props)
