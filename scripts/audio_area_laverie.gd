extends Area3D

func _on_body_entered(body):
	if not body is CharacterBody3D:
		return
	Wwise.set_state_id(AK.STATES.ROOM.GROUP, AK.STATES.ROOM.STATE.YES)


func _on_body_exited(body):
	if not body is CharacterBody3D:
		return
	Wwise.set_state_id(AK.STATES.ROOM.GROUP, AK.STATES.ROOM.STATE.NO)
