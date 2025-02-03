extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("any_peer")
func sync_positions(pos):
	for id in multiplayer.get_peers():
		if id!= multiplayer.get_remote_sender_id():
			sync_other_player.rpc_id(id , pos)
	
@rpc("authority")
func sync_other_player(pos):
	pass
