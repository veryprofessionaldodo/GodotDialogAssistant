tool
extends PanelContainer

var id = ""

func collapse():
	$Container/Info.visible = false
	rect_size.y = 0
	
func expand():
	$Container/Info.visible = true
	rect_size.y = 0

func toggle_collapse():
	$Container/Info.visible = !$Container/Info.visible
	rect_size.y = 0 

func populate_with_info(info):
	id = info.id
	$Container/Options/Name.text = info.name
	$Container/Info/HBoxContainer/DescContainer/DescriptionEdit.text = info.description
	$Container/Info/HBoxContainer/TypeContainer/TypeValue.text = info.type
	$Container/Info/HBoxContainer/ValueContainer/Value.text = str(info.value)
	rect_size.y = 0
