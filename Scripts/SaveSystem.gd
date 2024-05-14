extends Node

onready var Main = get_node("/root/Main")
onready var Player = Main.get_node("Player")
onready var GUI = Player.get_node("GUI")
onready var SaveMenu = GUI.get_node("SaveMenu")
onready var SavingPopup = GUI.get_node("Saving")
onready var SelectedSaveLabel = GUI.get_node("PauseMenu/selectedsave")

signal SaveFinished
signal LoadFinished

var fileName = "user://ypaaf-%d.save"
var selectedSave = 0

var GroupsToSave = [
	"Enemy",
	"Item",
	"Interactable",
	"Doors",
	"Triggerable",
	"Trigger",
	"Popup"
]
var IgnoredTypes = [
	AudioStreamMP3,
	AudioStreamOGGVorbis,
]
var IgnoredProperties = [
	"DefaultControls",
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
	"Main",
	"transform",
	"rand",
	"Node",
	"global_position",
	"global_rotation",
	"global_rotation_degrees",
	"global_scale",
	"global_transform",
	"tile_set",
	"target_player",
	"friction",
	"bounce",
	"Player",
	"layers",
	"SaveMenu",
	"IngameUI",
	"MainMenu",
	"PauseMenu",
	"GUI",
	"custom_multiplayer",
	"process_priority",
	"unique_name_in_owner"
]

func playtimeFromSave(num: int):
	var file = File.new()
	if file.file_exists(fileName % num):
		file.open(fileName % num, File.READ)
		var b64 = file.get_as_text()
		var json = Marshalls.base64_to_utf8(b64)
		var result = JSON.parse(json)
		
		if result.error:
			return null
		
		if result.result.has("PlaytimeSeconds"):
			return unserialize(result.result["PlaytimeSeconds"])
	
	return null

func onSaveSelect(num: int):
	selectedSave = num
	SelectedSaveLabel.text = "Save Slot: %d" % num
	SaveMenu.visible = false
	if GUI.get_node("MainMenu").visible:
		GUI.get_node("MainMenu").visible = false
		loadSave()

func onSaveDelete(num: int):
	var file = File.new()
	if not file.file_exists(fileName % num):
		return
	
	# Write empty string to delete file on web
	file.open(fileName % num, File.WRITE)
	file.store_string("")
	
	var d = Directory.new()
	d.remove(fileName % num)
	
	render_save(num)

func render_save(i):
	var playtime = SaveMenu.get_node("s%dPlaytime" % i)
	var delete = SaveMenu.get_node("s%dDelete" % i)
	
	var savetime = playtimeFromSave(i)
	if savetime == null:
		playtime.text = "No save found"
		delete.visible = false
		return
	
	playtime.text = "Playtime: %s" % Main.time_convert(savetime)
	delete.visible = true

func _ready():
	for i in range(3):
		i+=1
		var button = SaveMenu.get_node("s%dButton" % i)
		var delete = SaveMenu.get_node("s%dDelete" % i)
		
		button.connect("pressed", self, "onSaveSelect", [i])
		delete.connect("pressed", self, "onSaveDelete", [i])
		
		render_save(i)


func getSavedNodes(addPlayer: bool = false):
	var nodes = []
	var tree = get_tree()
	
	for group in GroupsToSave:
		var groupNodes = tree.get_nodes_in_group(group)
		for node in groupNodes:
			if nodes.has(node):
				continue
			nodes.append(node)
	if addPlayer:
		nodes.append(Player)
	return nodes
	

func saveExists():
	var save_game = File.new()
	if not save_game.file_exists(fileName % selectedSave):
		return false
	return true


func loadSave():
	var startTime = Time.get_ticks_msec()
	
	var save_game = File.new()
	if not save_game.file_exists(fileName % selectedSave):
		print("Save file not found")
		return
	
	save_game.open(fileName % selectedSave, File.READ)
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
	GUI.generateWheel()
	
	print("Loaded game in %d milliseconds" % (Time.get_ticks_msec() - startTime))
	emit_signal("LoadFinished")


func save():
	if selectedSave == 0:
		SaveMenu.visible = true
		return
	
	var startTime = Time.get_ticks_msec()
	var pauseGame = not Main.Paused
	if pauseGame:
		Main.pause(true, [self])
	
	SavingPopup.visible = true
	yield(Main.wait(0.25), "completed")
	
	var save_game = File.new()
	
	save_game.open(fileName % selectedSave, File.WRITE)
	
	var data = {}
	
	var nodes = getSavedNodes()
	for node in nodes:
		var path = String(Main.get_path_to(node))
		data[path] = serialize(node)
	
	data["Player"] = serialize_player()
	data["PlaytimeSeconds"] = serialize(Main.PlaytimeSeconds)
	var saveJSON = JSON.print(data)
	var b64Encoded = Marshalls.utf8_to_base64(saveJSON)
	save_game.store_string(b64Encoded)
	save_game.close()
	
	if pauseGame:
		Main.pause(false, [self])
		
	SavingPopup.visible = false
	print("Saved game in %d milliseconds" % (Time.get_ticks_msec() - startTime))
	emit_signal("SaveFinished")


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
	
	if input == null:
		return null
	if typeof(input) == TYPE_OBJECT and !weakref(input).get_ref():
		return null
	
	for type in IgnoredTypes:
		if input is type:
			return null
	
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
			if input.is_empty():
				object.data = serialize(null)
			
			object.data = String(input)
		TYPE_OBJECT:
			if not input:
				return
			if !weakref(input).get_ref():
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
		TYPE_RAW_ARRAY:
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
	if input.has_method("get_class") and input.get_class() == "TileMap":
		var tiles = []
		for tilePosition in input.get_used_cells():
			var tileID = input.get_cellv(tilePosition)
			tiles.append({
				position = serialize(tilePosition),
				x_flipped = input.is_cell_x_flipped(tilePosition.x, tilePosition.y),
				y_flipped = input.is_cell_y_flipped(tilePosition.x, tilePosition.y),
				tileID = tileID
			})
		data.cells = tiles
	for property in input.get_property_list():
		var propName = property.name
		if propName in IgnoredProperties:
			continue
		
		var propValue = input.get(propName)
		if typeof(propValue) == typeof(input) and propValue == input:
			continue
		#if input.has_method("get_children") and propValue in input.get_children():
		#	continue
		
		if property.name == "collision_mask":
			data[propName] = {}
			for layer in range(32):
				data[propName][layer] = input.get_collision_mask_bit(layer)
			continue
		if property.name == "collision_layer":
			data[propName] = {}
			for layer in range(32):
				data[propName][layer] = input.get_collision_layer_bit(layer)
			continue
		
		data[propName] = serialize(input.get(propName))
	return data
	
func unserialize_array(input, _obj:Object = null):
	var data = []
	for elem in input.data:
		data.push_back(unserialize(elem, _obj))
	return data
func unserialize_object(input, _obj:Object = null):
	if input.has("classname") and input.classname == "PackedScene":
		return load(input.data.path)
	
	if input.has("classname") and input.classname == "TileMap":
		for tile in input.data.cells:
			_obj.set_cellv(unserialize(tile.position), tile.tileID, tile.x_flipped, tile.y_flipped)
	
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
	
	if not obj:
		return null
	
	for property in obj.get_property_list():
		if property.name in IgnoredProperties:
			continue
		if not input.data.has(property.name):
			continue
		if obj.get(property.name) == null:
			continue
		if property.type == TYPE_NIL:
			continue
		
		var data = input.data[property.name]
		var unserializedProperty
		
		if not data:
			continue
		
		if property.name == "collision_layer":
			for key in data:
				var layer = int(key)
				obj.set_collision_layer_bit(layer, data[key])
			continue
		
		if property.name == "collision_mask":
			for key in data:
				var layer = int(key)
				obj.set_collision_mask_bit(layer, data[key])
			continue
		
		if data.has("classname") and data.classname == "PackedScene":
			unserializedProperty = load(data.path)
		
		if not unserializedProperty and data.type == TYPE_NODE_PATH:
			unserializedProperty = unserialize(data, obj)
		
		if not unserializedProperty:
			unserializedProperty = unserialize(data)
		
		if !weakref(obj).get_ref():
			return
		if unserializedProperty == null:
			return
			
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
			var x = Vector2.ZERO
			var y = Vector2.ZERO
			var origin = Vector2.ZERO
			if typeof(input.data.x) == TYPE_OBJECT:
				x = Vector2(input.data.x.data.x, input.data.x.data.y)
			if typeof(input.data.y) == TYPE_OBJECT:
				y = Vector2(input.data.y.data.x, input.data.y.data.y)
			if typeof(input.data.origin) == TYPE_OBJECT:
				origin = Vector2(input.data.origin.data.x, input.data.origin.data.y)
			
			return Transform2D(x, y, origin);
		TYPE_OBJECT:
			if obj:
				return unserialize_object(input, obj)
				
			if not input.has("classname"):
				return null
			var classname = input.classname
			if classname == "PackedScene":
				return unserialize_object(input)
			if classname.begins_with("InputEvent"):
				return unserialize_object(input)
			
		TYPE_DICTIONARY:
			if not input:
				return
			var data = {}
			for i in input:
				data[i] = unserialize(input[i])
			return data
		TYPE_ARRAY:
			return unserialize_array(input, obj)
		TYPE_INT_ARRAY:
			return unserialize_array(input, obj)
		TYPE_STRING_ARRAY:
			return unserialize_array(input, obj)
		TYPE_RAW_ARRAY:
			return unserialize_array(input, obj)
		TYPE_COLOR:
			return Color(input.data)
		TYPE_NODE_PATH:
			return NodePath(input.data)
		_:
			print("Could not parse type %d" % type)
