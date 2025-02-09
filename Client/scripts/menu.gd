extends Control


var playerIds =  []

#var connectionNode : EnetConnection
#
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var connectionNode = EnetConnection.new()
	connectionNode.name = "connection"
	add_child(connectionNode , true)
	connectionNode.connectedToServer.connect(on_connected_to_server)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$VBoxContainer/Label.text = get_node("connection").message

func on_connected_to_server():
	$VBoxContainer/Button.show()
	$VBoxContainer/LineEdit.show()
	
@rpc("authority")
func get_ids(ids):
	playerIds = ids
	print(ids)
	for i in range(ids.size()):
		if ids[i] == multiplayer.get_unique_id():
			Singelton.myIndex = i
	
@rpc("any_peer")
func On_Ready_For_Match(username):
	pass

func _on_button_button_up() -> void:
	if $VBoxContainer/LineEdit.text.is_empty():
		Singelton.Username = str(multiplayer.get_unique_id())
		
	else:
		Singelton.Username = $VBoxContainer/LineEdit.text
		
	On_Ready_For_Match.rpc_id(1 , Singelton.Username)
	get_node("connection").message = "Searching for Players!"
	$VBoxContainer/Button.disabled = true
	

@rpc("authority")
func spawn_world(ids : Array):
	var world = preload("res://scenes/world.tscn").instantiate()
	$Matches.add_child(world , true)
	world.playerids = ids
