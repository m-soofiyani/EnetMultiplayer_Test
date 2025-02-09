extends Control

var playernodename
var current_health
var previous_health

var camera : Camera3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_parent().get_parent().get_node("Camera3D")
	$Player/ProgressBar.max_value = get_parent().health
	$Player/Name.text = get_parent().username
##
### Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = camera.unproject_position(get_parent().global_transform.origin)
	
	
	current_health = get_parent().health
	if current_health != previous_health:
		$Player/ProgressBar.value = get_parent().health
		previous_health = current_health
