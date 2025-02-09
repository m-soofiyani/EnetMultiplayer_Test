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
		


@rpc("authority")
func get_fire_info(direction, materialindex , whofiredId):
	pass


@rpc("any_peer")
func send_fire_info(direction, materialindex , whofiredId , bulletname):
	var bullet = preload("res://scenes/gr_bullet.tscn").instantiate()
	bullet.name = bulletname
	get_parent().add_child(bullet)
	
	for id in multiplayer.get_peers():
		if id!= multiplayer.get_remote_sender_id():
			get_fire_info.rpc_id(id , direction , materialindex , whofiredId)

@rpc("authority")
func Damaged(playerId):
	pass


@rpc("any_peer")
func this_player_dead():
	get_parent().match_result.rpc(multiplayer.get_remote_sender_id())
