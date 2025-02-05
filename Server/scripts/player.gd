extends Node3D


@rpc("any_peer")
func sync_positions_and_target(pos , target):
	for id in multiplayer.get_peers():
		if id!= multiplayer.get_remote_sender_id():
			sync_other_player_position_target.rpc_id(id , pos , target)
			
			
@rpc("any_peer")
func sync_anim(anim):
	for id in multiplayer.get_peers():
		if id!= multiplayer.get_remote_sender_id():
			sync_other_anim.rpc_id(id ,anim)
			

@rpc("authority")
func sync_other_player_position_target(pos , target ):
	pass


@rpc("authority")
func sync_other_anim(anim):
	pass
		
