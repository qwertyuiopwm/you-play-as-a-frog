extends Node

onready var Main = get_node("/root/Main")
onready var Player = Main.get_node("Player")

var fileName = "user://ypaaf.save"
var GroupsToSave = [
	"Enemy"
]
var IgnoredProperties = [
	"owner",
	"Reference",
	"_import_path",
	"network_peer",
	"refuse_new_network_connections",
	"allow_object_decoding",
	"MultiplayerAPI",
	"multiplayer",
	"source_code",
	"editor_description",
	"__meta__",
	"Focus",
	"SaveSys",
	"Resource",
	"resource_local_to_scene",
	"resource_path",
	"resource_name",
	"Script",
	"script",
	"Script Variables",
	"beam",
	"filename",
	"GUI",
	"Main",
	"transform",
	"rand",
	"Node",
	"global_position",
	"global_rotation",
	"global_rotation_degrees",
	"global_scale",
	"global_transform"
]

func getSavedNodes(addPlayer: bool = false):
	var nodes = []
	for group in GroupsToSave:
		var groupNodes = get_tree().get_nodes_in_group(group)
		for node in groupNodes:
			if nodes.has(node):
				continue
			nodes.append(node)
	if addPlayer:
		nodes.append(Player)
	return nodes
	

func loadSave():
	var save_game = File.new()
	if not save_game.file_exists(fileName):
		print("Save file not found")
		return
	
	save_game.open(fileName, File.READ)
	var b64 = save_game.get_as_text()
	var json = Marshalls.base64_to_utf8(b64)
	var result = JSON.parse(json)
	if result.error != OK:
		print("Failed to load save.")
		return
	var data = result.result
	if not data is Dictionary:
		print("Failed to load save.")
		return
	
	var nodes = getSavedNodes(true)
	for _node in nodes:
		var path = String(Main.get_path_to(_node))
		var node = Main.get_node(path)
		if not node:
			continue
		if not data.has(path):
			node.queue_free()
			continue
		unserialize(data[path], node)
		pass
	
	#Player.get_node("GUI").generateWheel()

func save():
	var save_game = File.new()
	
	save_game.open(fileName, File.WRITE)
	
	var data = {}
	
	var nodes = getSavedNodes()
	for node in nodes:
		var path = String(Main.get_path_to(node))
		data[path] = serialize(node)
	
	data["Player"] = serialize_player()
	var saveJSON = JSON.print(data)
	var b64Encoded = Marshalls.utf8_to_base64(saveJSON)
	save_game.store_string(b64Encoded)
	save_game.close()

# Pain. Only pain.

func serialize_player():
	return {
		type = TYPE_OBJECT,
		data = {
			# Player info
			PlayerSpells = serialize(Player.PlayerSpells),
			position = serialize(Player.position),
			health_per_potion = serialize(Player.health_per_potion),
			restoration_potions = serialize(Player.restoration_potions),
			# Player stats
			health = serialize(Player.health),
			mana = serialize(Player.mana),
			stamina = serialize(Player.stamina),
			melee_damage = serialize(Player.melee_damage),
			SPEED = serialize(Player.SPEED),
			# Maximum player stats
			max_health = serialize(Player.max_health),
			max_mana = serialize(Player.max_mana),
			max_stamina = serialize(Player.max_stamina),
			# Respawn info
		}
	}
func serialize(input):
	var object = {
		type = typeof(input)
	}
	
	match object.type:
		TYPE_NIL:
			object.data = null
		TYPE_BOOL:
			object.data = input
		TYPE_INT:
			object.data = input
		TYPE_REAL:
			object.data = input
		TYPE_STRING:
			object.data = input
		TYPE_VECTOR2:
			object.data = {
				x = input.x,
				y = input.y
			}
		TYPE_RECT2: 
			object.data = {
				end = serialize(input.end),
				position = serialize(input.position),
				size = serialize(input.size),
			}
		TYPE_TRANSFORM2D:
			object.data = {
				origin = serialize(input.origin),
				x = serialize(input.x),
				y = serialize(input.y),
			}
		TYPE_COLOR:
			object.data = input.to_html()
		TYPE_NODE_PATH:
			object.data = String(input)
			pass
		TYPE_OBJECT:
			if not input:
				return
			object.classname = input.get_class()
			object.data = serialize_object(input)
		TYPE_DICTIONARY:
			if not input:
				return
			var data = {}
			for i in input:
				data[i] = serialize(input[i])
			object.data = data
		TYPE_ARRAY:
			object.data = serialize_array(input)
		TYPE_INT_ARRAY:
			object.data = serialize_array(input)
		TYPE_REAL_ARRAY:
			object.data = serialize_array(input)
		TYPE_STRING_ARRAY:
			object.data = serialize_array(input)
		TYPE_VECTOR2_ARRAY:
			object.data = serialize_array(input)
		TYPE_COLOR_ARRAY:
			object.data = serialize_array(input)
		_:
			print("Unknown type %d" % object.type)
			pass
	
	return object
func serialize_array(input):
	var data = []
	for v in input:
		data.append(serialize(v))
	return data
func serialize_object(input):
	var data = {}
	if not input:
		return
	if input.has_method("get_class") and input.get_class() == "PackedScene":
		return {
			path = input.get_path()
		}
	for property in input.get_property_list():
		var propName = property.name
		if propName in IgnoredProperties:
			continue
		var propValue = input.get(propName)
		if typeof(propValue) == typeof(input) and propValue == input:
			continue
		if input.has_method("get_children") and propValue in input.get_children():
			continue
		data[propName] = serialize(input.get(propName))
	return data
	
func unserialize_array(input):
	var data = []
	for elem in input.data:
		data.push_back(unserialize(elem))
	return data
func unserialize_object(input, _obj:Object = null):
	if input.has("classname") and input.classname == "PackedScene":
		return load(input.data.path)
	
	var obj = _obj
	if input.has("classname") and input.classname.begins_with("InputEvent"):
		match input.classname:
			"InputEventKey":
				obj = InputEventKey.new()
			"InputEventMouseButton":
				obj = InputEventMouseButton.new()
			"InputEventJoypadMotion":
				obj = InputEventJoypadMotion.new()
	
	if _obj and not _obj is InputEvent:
		obj = Main.get_node(Main.get_path_to(_obj))
	
	for property in obj.get_property_list():
		if not input.data.has(property.name):
			continue
		if obj.get(property.name) == null:
			continue
		if property.type == TYPE_NIL:
			continue
		
		var data = input.data[property.name]
		var unserializedProperty
		
		if data.has("classname") and data.classname == "PackedScene":
			unserializedProperty = load(data.path)
		
		if not unserializedProperty:
			unserializedProperty = unserialize(data)
			
		obj[property.name] = unserializedProperty
	
	return obj
func unserialize(input, obj: Node = null):
	if typeof(input) != TYPE_DICTIONARY:
		return
	if not input:
		return
	if not input.type:
		return
	var type = 1*input.type
	match int(type):
		TYPE_NIL:
			return null
		TYPE_BOOL:
			return input.data
		TYPE_INT:
			return int(input.data)
		TYPE_REAL:
			return float(input.data)
		TYPE_STRING:
			return String(input.data)
		TYPE_VECTOR2:
			return Vector2(input.data.x, input.data.y)
		TYPE_TRANSFORM2D:
			return Transform2D(
				Vector2(input.data.x.data.x, input.data.y.data.y),
				Vector2(input.data.y.data.x, input.data.y.data.y),
				Vector2(input.data.origin.data.x, input.data.origin.data.y)
			);
		TYPE_OBJECT:
			if obj:
				return unserialize_object(input, obj)
				
			if not input.has("classname"):
				return null
			if input.classname == "PackedScene":
				return unserialize_object(input)
			if input.classname.begins_with("InputEvent"):
				return unserialize_object(input)
			
		TYPE_DICTIONARY:
			if not input:
				return
			var data = {}
			for i in input:
				data[i] = unserialize(input[i])
			return data
		TYPE_ARRAY:
			return unserialize_array(input)
		TYPE_INT_ARRAY:
			return unserialize_array(input)
		TYPE_STRING_ARRAY:
			return unserialize_array(input)
		TYPE_COLOR:
			return Color(input.data)
		_:
			print("Could not parse type %d" % type)
