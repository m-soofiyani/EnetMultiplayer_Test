extends Control

var playernodename

var camera : Camera3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_parent().get_parent().get_node("Camera3D")
	

##
### Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = camera.unproject_position(get_parent().global_transform.origin)
