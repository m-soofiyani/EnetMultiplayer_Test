extends Area3D


const SPEED = 5
var VELOCITY :Vector3
@export var materials : Array[StandardMaterial3D]
var this_bullet_material_index = -1
var this_bullet_material
var whoFired_id : int
var damagable := true
var current_pos
var previous_pos
var bulletThereshold := .3

signal position_changed
signal bullet_hitted

func _ready() -> void:
	position_changed.connect(on_position_changed)
	bullet_hitted.connect(on_bullet_hitted)
	
	$CSGSphere3D.material_override = materials[this_bullet_material_index]

	



func _physics_process(delta: float) -> void:
	position += VELOCITY * delta * SPEED
	for p in get_parent().get_children():
		if p.name.begins_with("Player"):
			if global_transform.origin.distance_to(p.global_transform.origin) < bulletThereshold and damagable:
				if p.digits != whoFired_id:
					bullet_hitted.emit(p.digits)
					print("bullet hitted")
					damagable = false
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

func on_bullet_hitted(id):
	if whoFired_id == Singelton.PeerId:
		bullet_hitted_to.rpc_id(1 , id)

@rpc("authority")
func this_bullet_deleted():
	queue_free()



@rpc("any_peer")
func bullet_hitted_to(toPlayerid):
	pass




func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "StaticBody3D" :
		bullet_hitted_to.rpc_id(1 ,0)
		
