extends Node3D

const Port := 8085
var server_peer : ENetMultiplayerPeer
var ConnectedPlayers = []
signal playerDisconnect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	server_peer = ENetMultiplayerPeer.new()
	var err = server_peer.create_server(8085)
	if err != OK:
		print(err)
			
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.multiplayer_peer = server_peer
		
	print("Server is Running With ID : " + str(multiplayer.get_unique_id()))


func on_peer_connected(id):
	print("New peer connected with id : %s" %id)
	ConnectedPlayers.append(id)
	if ConnectedPlayers.size() == 2:
		var _ids = [ConnectedPlayers[0] , ConnectedPlayers[1]]
		for i in _ids:
			get_ids.rpc_id(i , _ids)
		spawn_world.call_deferred(_ids)

func on_peer_disconnected(id):
	print("Peer with id : %s disconnected " %id)
	ConnectedPlayers.erase(id)
	playerDisconnect.emit()
	for _world in $Matches.get_children():
		if _world.PlayersIds.has(id):
			_world.queue_free()


func spawn_world(ids : Array):
	var world = preload("res://scenes/world.tscn").instantiate()
	$Matches.add_child(world , true)
	world.PlayersIds = ids

@rpc("authority")
func get_ids(ids):
	pass
