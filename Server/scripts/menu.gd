extends Control

const Port := 8085
var server_peer : ENetMultiplayerPeer
var ConnectedPlayers = []
signal playerDisconnect
var ReadyForMatchIds : Array
var usernames : Dictionary
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

func _process(delta: float) -> void:
	pass
		
		
func on_peer_connected(id):
	print("New peer connected with id : %s" %id)
	ConnectedPlayers.append(id)


func on_peer_disconnected(id):
	print("Peer with id : %s disconnected " %id)
	ConnectedPlayers.erase(id)
	ReadyForMatchIds.erase(id)
	playerDisconnect.emit()
	for _world in $Matches.get_children():
		if _world.PlayersIds.has(id):
			_world.queue_free()

@rpc("authority")
func spawn_world(ids : Array):
	var world = preload("res://scenes/world.tscn").instantiate()
	$Matches.add_child(world , true)
	world.PlayersIds = ids

		

@rpc("authority")
func get_ids(ids):
	pass
@rpc("any_peer")
func On_Ready_For_Match(username):
	usernames[str(multiplayer.get_remote_sender_id())] = username
	ReadyForMatchIds.append(multiplayer.get_remote_sender_id())
	if ReadyForMatchIds.size() == 2:
		var _ids = [ReadyForMatchIds[0] , ReadyForMatchIds[1]]
		
		var world = preload("res://scenes/world.tscn").instantiate()
		
		$Matches.add_child(world , true)
		world.PlayersIds = _ids
		for id in _ids:
			world.Usernames = usernames
			get_ids.rpc_id(id , _ids)
			spawn_world.rpc_id(id , _ids)
			
		ReadyForMatchIds.clear()
