extends Node2D

var sp_positions = [Vector2(100 , 512) , Vector2(2460 , 512)]
var PlayersIds : Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for id in multiplayer.get_peers():
		var index = 0
		var _p = preload("res://scenes/player.tscn").instantiate() 
		_p.name = "Player_" + str(id)
		_p.position = sp_positions[index]
		#spawn_pose.rpc_id(id , sp_positions[index])
		add_child(_p)
		
#@rpc("authority")
#func spawn_pose(pos):
	#pass
