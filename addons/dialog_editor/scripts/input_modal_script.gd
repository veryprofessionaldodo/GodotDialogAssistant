tool
extends ConfirmationDialog

func _ready():
	get_ok().disabled = true

# returns information from the input variables dialog
func get_values():
	var base_container = $Container
	var dict = {}
	for language in base_container.get_children():
		var key = language.get_child(0).text.replace(":","").to_lower()
		var value = language.get_child(1).text
		
		dict[key] = value
		
	return dict

# check if valid inputs have been given
func text_changed(new_text, lang):
	if new_text == "" and lang == "en":
		get_ok().disabled = true
	elif new_text != "" and lang == "en":
		get_ok().disabled = false

func set_lang_text(lang, text):
	var base_container = $Container
	for language in base_container.get_children():
		var key = language.get_child(0).text.replace(":","").to_lower()
		
		if lang == key:
			language.get_child(1).text = text
			
	if lang == "en" and text != "":
		get_ok().disabled = false
