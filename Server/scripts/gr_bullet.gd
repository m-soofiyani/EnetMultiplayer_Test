extends Node3D



@rpc("any_peer")
func send_bullet_pos(position):
	for id in multiplayer.get_peers():
		if id!= multiplayer.get_remote_sender_id():
			get_bullet_pos.rpc_id(id , position)
	
@rpc("authority")
func get_bullet_pos(position):
	pass
