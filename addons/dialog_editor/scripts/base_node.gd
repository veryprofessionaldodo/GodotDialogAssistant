tool
extends GraphNode

var setting_name = "addons/Dialog Assets Folder"
var id = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	id = calculate_id();
	name = id;
	
func calculate_id():
	var random_seed = rand_seed(int(randi() * randi() * randf()))
	
	return String(random_seed).sha256_text().substr(16, 24)
	
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
