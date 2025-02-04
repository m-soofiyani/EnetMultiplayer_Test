extends Camera3D

var playerTarget : Vector3
var offset : float = 3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playerTarget:
		#position.x = playerTarget.x
		#position.z = playerTarget.z + offset
		#position.y = 5
		position = lerp(position,Vector3(playerTarget.x,5,playerTarget.z + offset),.06)
