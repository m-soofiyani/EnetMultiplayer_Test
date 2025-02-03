extends Control


var playerIds =  []

#var connectionNode : EnetConnection
#
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var connectionNode = EnetConnection.new()
	connectionNode.name = "connection"
	add_child(connectionNode , true)
	$Label.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_node("Label").text = get_node("connection").message


@rpc("authority")
func get_ids(ids):
	playerIds = ids
	print(ids)
	for i in range(ids.size()):
		if ids[i] == multiplayer.get_unique_id():
			Singelton.myIndex = i
	
