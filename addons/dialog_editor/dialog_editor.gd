tool
extends EditorPlugin

const MainPanel = preload("res://addons/dialog_editor/dialog_editor_main_scene.tscn")

var main_panel_instance

func _enter_tree():
	main_panel_instance = MainPanel.instance()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	make_visible(false)
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

func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()

func has_main_screen():
	return true

func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func get_plugin_name():
	return "Dialog Editor"

func get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")
