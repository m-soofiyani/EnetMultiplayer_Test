extends Control

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


#@rpc("authority")
#func spawn_world():
	#var world = preload("res://scenes/world.tscn").instantiate()
	#$root.add_child(world , true)
