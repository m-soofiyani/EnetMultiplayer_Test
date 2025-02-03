extends Node2D

var Colors = [Color.WHITE , Color.RED]
var PlayersIds : Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for id in multiplayer.get_peers():
		var index = 0
		var _p = preload("res://scenes/player.tscn").instantiate() 
		_p.name = "Player_" + str(id)
		 
		add_child(_p)
		
