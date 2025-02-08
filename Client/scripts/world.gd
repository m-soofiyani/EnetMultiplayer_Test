extends Node3D
var playerids = []
var PlayersColors : Array


func _ready() -> void:
	for ui in get_tree().get_nodes_in_group("UI"):
		ui.hide()

#@rpc("authority")
#func spawn_pose(_sync_interval):
	#if self.get_child_count() > 0:
		#for child in self.get_children():
			#if child.name.begins_with("Player"):
				#child.sync_interval = _sync_interval

@rpc("authority")
func colors_selected(colorsarray):
	PlayersColors = colorsarray

func _exit_tree() -> void:
	for ui in get_tree().get_nodes_in_group("UI"):
		ui.show()

@rpc("authority")
func spawn_players():
	print("spawning players")
	await get_tree().create_timer(2).timeout
	for id in playerids:
		var index = 0
		var _p = preload("res://scenes/player.tscn").instantiate() 
		_p.name = "Player_"+ str(id)
		
		await  _p.set_index(playerids.find(id))
		_p.set_color(PlayersColors[playerids.find(id)])
		
		add_child(_p , true)
		var hud = preload("res://scenes/hud.tscn").instantiate()
		hud.playernodename = _p.name
		_p.add_child(hud , true)
		index += 1
