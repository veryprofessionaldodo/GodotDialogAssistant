extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	print("fosgasse")
	ProjectSettings.set("addons/teste", 0)

	var property_info = {
		"name": "addons/teste",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "one,two,three"
	}

	ProjectSettings.add_property_info(property_info)
	print(ProjectSettings)
	
func _button_pressed():
	print("oh caralho")
	ProjectSettings.set("addons/dialogAssistant", 0)

	var property_info = {
		"name": "category/property_name",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "one,two,three"
	}

	ProjectSettings.add_property_info(property_info)
	print("shiiet")
	print(ProjectSettings)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
