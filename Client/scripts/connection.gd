extends Control
class_name EnetConnection


const Server_IP := "localhost"
const Port := 8085
var peer : ENetMultiplayerPeer
var peer_id : int

var message : String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(Server_IP , Port)
	if err != OK:
		message = "An error accured " + str(err)
	
	Singelton.EnetPeer = peer
	multiplayer.multiplayer_peer = peer
	
	
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.server_disconnected.connect(on_server_disconnected)
	
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

func on_connected_to_server() -> void:
	message = "Connected to server with id : " + str(multiplayer.get_unique_id())
	peer_id = multiplayer.get_unique_id()
	Singelton.PeerId = multiplayer.get_unique_id()
	

func on_connection_failed() -> void:
	message = "Connection failed!"
	multiplayer.multiplayer_peer = null
	
func on_server_disconnected():
	message = "Server is down!"
	multiplayer.multiplayer_peer = null

func on_peer_connected(id:int):
	#message = "New Peer connected with id : " + str(id)
	pass
	
func on_peer_disconnected(id : int):
	message = "Peer Diconnected with id : " + str(id)
	

func _exit_tree() -> void:
	peer.close()
