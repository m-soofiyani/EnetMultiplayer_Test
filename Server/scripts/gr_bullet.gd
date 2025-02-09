extends RigidBody3D



@rpc("any_peer")
func send_bullet_pos(position):
	for id in multiplayer.get_peers():
		if id!= multiplayer.get_remote_sender_id():
			get_bullet_pos.rpc_id(id , position)
	
@rpc("authority")
func get_bullet_pos(position):
	pass


	
@rpc("authority")
func this_bullet_deleted():
	pass


func _on_timer_timeout() -> void:
	for id in multiplayer.get_peers():
		this_bullet_deleted.rpc_id(id)
	self.queue_free()



@rpc("any_peer")
func bullet_hitted_to(toPlayerid):
	print("bullet hitted to" + str(toPlayerid))
	for id in multiplayer.get_peers():
		this_bullet_deleted.rpc_id(id)
	for player in get_parent().get_children():
		if player.name.begins_with("Player"):
			player.Damaged.rpc_id(int(player.name.split("_",true,1)[1]) , toPlayerid)
	self.queue_free()
