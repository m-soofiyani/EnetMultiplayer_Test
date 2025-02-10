extends Area3D



@rpc("any_peer")
func send_bullet_pos(position):
	for id in get_parent().PlayersIds:
		if id!= multiplayer.get_remote_sender_id():
			get_bullet_pos.rpc_id(id , position)
	
@rpc("authority")
func get_bullet_pos(position):
	pass


	
@rpc("authority")
func this_bullet_deleted():
	pass


func _on_timer_timeout() -> void:
	for id in get_parent().PlayersIds:
		this_bullet_deleted.rpc_id(id)
	self.queue_free()



@rpc("any_peer")
func bullet_hitted_to(toPlayerid):
	print("bullet hitted to" + str(toPlayerid))
	if toPlayerid != 0:

		for player in get_parent().get_children():
			if player.name.begins_with("Player"):
				player.Damaged.rpc_id(int(player.name.split("_",true,1)[1]) , toPlayerid)
		for id in get_parent().PlayersIds:
			this_bullet_deleted.rpc_id(id)
		self.queue_free()
	else:
		for id in get_parent().PlayersIds:
			this_bullet_deleted.rpc_id(id)
		self.queue_free()
