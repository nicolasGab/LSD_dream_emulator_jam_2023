@tool
extends Node3D

@export var next_scene : PackedScene
@export_group("Sound")
#@export_enum("all", "video",) var sfx_type: String = "video" :
	#set (value):
		#sfx_type = value
		#notify_property_list_changed()
var sound_id: int = 0
var sound: String = "none" :
	set(value):
		sound = value
		sound_id = AK.EVENTS._dict[sound]

func _get_property_list():
	var properties = []
	properties.append_array([{
			"name" = "sound",
			"type" = TYPE_STRING,
			"hint" = PROPERTY_HINT_ENUM,
			"hint_string" = ','.join(AK.EVENTS._dict.keys()),
			"usage" = PROPERTY_USAGE_DEFAULT 
		}])
	return properties
	
var wwise_id: int = 0

func _ready():
	Wwise.register_game_obj(self, name)
	wwise_id = Wwise.post_event_id(sound_id, self)

func _exit_tree():
	Wwise.stop_event(wwise_id, 500, AkUtils.AK_CURVE_CONSTANT)
