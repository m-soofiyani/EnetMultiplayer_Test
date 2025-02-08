extends RigidBody3D


const SPEED = 5
var VELOCITY :Vector3
@export var materials : Array[StandardMaterial3D]
var this_bullet_material_index = null
var this_bullet_material
var whoFired_id : int

var current_pos
var previous_pos
signal position_changed
func _ready() -> void:
	position_changed.connect(on_position_changed)
	if this_bullet_material_index != null:
		$CSGSphere3D.material_override = materials[this_bullet_material_index]
	else:
		this_bullet_material = materials.pick_random()
		$CSGSphere3D.material_override = this_bullet_material
		this_bullet_material_index = materials.rfind(this_bullet_material)
	VELOCITY *= SPEED
	if whoFired_id == Singelton.PeerId:
		apply_impulse(VELOCITY)
		
func _physics_process(delta: float) -> void:
	


	
			#sync position
	current_pos = position
	if current_pos != previous_pos:
		if get_tree().get_frame() % 5 == 0:
			position_changed.emit()
			previous_pos = current_pos


@rpc("any_peer")
func send_bullet_pos(position):
	pass
	
@rpc("authority")
func get_bullet_pos(_position):
	
	if whoFired_id != Singelton.PeerId:
		var tween = get_tree().create_tween()
		tween.tween_property(self , "position" , _position ,0.1)
	


func on_position_changed():
	if whoFired_id == Singelton.PeerId:
		send_bullet_pos.rpc_id(1 , global_transform.origin)
		
		
func _on_timer_timeout() -> void:
	queue_free()
