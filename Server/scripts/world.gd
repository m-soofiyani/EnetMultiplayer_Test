extends Node3D

var _Colors = [Color.RED , Color.HOT_PINK , Color.GREEN , Color.YELLOW]
var PlayersIds : Array
var PlayersColors: Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_Colors.shuffle()
	PlayersColors.append(_Colors[0])
	PlayersColors.append(_Colors[1])
	await get_tree().create_timer(2).timeout
	var index = 0
	for id in PlayersIds:
		
		
		var _p = preload("res://scenes/player.tscn").instantiate() 
		_p.name = "Player_" + str(id)
		


		spawn_players.rpc_id(id)
		colors_selected.rpc_id(id , PlayersColors)

		add_child(_p , true)
		index += 1

		
@rpc("authority")
func colors_selected(colorsarray):
	pass
@rpc("authority")
func spawn_players():
	pass
