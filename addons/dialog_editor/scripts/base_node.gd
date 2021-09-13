tool
extends GraphNode

var setting_name = "addons/Dialog Assets Folder"
var id = ""

func _enter_tree():
	id = Utils.calculate_id()

func convert_to_json():
	var dict = {}
	dict.id = id
	dict.offset = [offset.x, offset.y]
	
	return dict

# reconstruct node here
func construct_from_json(info):
	offset = Vector2(info.offset[0], info.offset[1])
	id = info.id

func get_id():
	return id

# this is child of graph edit, so direct parent needs to remove self
func node_closed():
	get_parent().delete_node(self)
	
func get_type():
	return ""

# return a string that tells if there are any problems with internal 
# info validation (for example, a line that was referenced no longer exists)
func validate_node_info():
	return
