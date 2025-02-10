extends Node3D
var playerids = []
var PlayersColors : Array
var sp_positions = [Vector3(-2 ,0,0) , Vector3(2 ,0,0)]

func _ready() -> void:
	for ui in get_tree().get_nodes_in_group("UI"):
		ui.hide()


@rpc("authority")
func colors_selected(colorsarray):
	PlayersColors = colorsarray

func _exit_tree() -> void:
	for ui in get_tree().get_nodes_in_group("UI"):
		ui.show()

@rpc("authority")
func spawn_players(_Usernames):
	print(_Usernames)
	await get_tree().create_timer(2).timeout
	for id in playerids:
		var index = 0
		var _p = preload("res://scenes/player.tscn").instantiate() 
		_p.name = "Player_"+ str(id)
		_p.username = _Usernames[str(id)]
		await  _p.set_index(playerids.find(id))
		_p.set_color(PlayersColors[playerids.find(id)])
		
		add_child(_p , true)
		
		_p.global_position = sp_positions[_p.thisPlayerIndex]
		var hud = preload("res://scenes/hud.tscn").instantiate()
		hud.playernodename = _p.name
		_p.add_child(hud , true)
		index += 1


@rpc("authority")
func match_result(playerloseId):
	var result_ui = preload("res://scenes/match_result.tscn").instantiate()
	add_child(result_ui)
	print(str(playerloseId) + " loosed")
	$JoyStick.disable_process()
	$BulletJoyStick.disable_process()
	$JoyStick.hide()
	$BulletJoyStick.hide()
	result_ui.get_node("XButton").button_up.connect(_on_x_button_up)
	if playerloseId == multiplayer.get_unique_id():
		result_ui.get_node("LOSELBL").show()
		result_ui.get_node("XButton").show()
		
	else:
		result_ui.get_node("WINLBL").show()
		result_ui.get_node("XButton").show()


func _on_x_button_up() -> void:
	remove_this_world.rpc_id(1)
	get_parent().get_parent().get_node("VBoxContainer/Button").disabled = false
	get_parent().get_parent().get_node("connection").message = "Connected to server with id: " + str(multiplayer.get_unique_id())
	queue_free()
	
	
	
@rpc("any_peer")
func remove_this_world():
	pass
