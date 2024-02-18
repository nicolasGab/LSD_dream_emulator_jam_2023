@tool
extends Node3D

@export_group("Sound")
@export_enum("all", "video",) var sfx_type: String = "video" :
	set (value):
		sfx_type = value
		notify_property_list_changed()
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
			"hint_string" = ','.join(AK.EVENTS._dict.keys().filter(func(key: String):
				if key == "none": return true
				return key.contains(sfx_type)
				)),
			"usage" = PROPERTY_USAGE_DEFAULT 
		}])
	return properties

func _ready():
	Wwise.register_game_obj(self, name + str(get_instance_id()))
	Wwise.set_3d_position(self, get_parent().transform.translated_local(position))
	Wwise.post_event_id(sound_id, self)
