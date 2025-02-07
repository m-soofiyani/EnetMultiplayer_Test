extends CharacterBody3D

@export var thisPlayerIndex : int


var sync_interval := 1
var sp_positions = [Vector3(-2 ,0,0) , Vector3(2 ,0,0)]
var Target: Vector3

var _gravityForce := 1
#var Velocity : Vector3
var current_velocity : Vector3
var previous_velocity : Vector3

@export var clothMaterials : Array[StandardMaterial3D]

@export var digits : int
var is_me : bool

var current_pos : Vector3
var previous_pos : Vector3
var direction : Vector3

signal position_changed
signal anim_changed
signal position_spawned

var anims = ["Idle" , "Run"]
var current_anim : String
@onready var state_machine = $KixMax/AnimationTree.get("parameters/playback")

var current_color : Color
var this_player_color
func _ready() -> void:

	
	position_changed.connect(on_position_changed)
	anim_changed.connect(on_anim_changed)
	
	

	
	var splitted_name =  name.split("_" , true , 1)
	digits = int(splitted_name[1])
	is_me = digits == multiplayer.get_unique_id()
	
	
	
	#if is_me:
		#$"3dmodel/Object_5/Skeleton3D/cloth".material_override = clothMaterials[0]
	#else :
		#$"3dmodel/Object_5/Skeleton3D/cloth".material_override = clothMaterials[1]
		
	for player in get_parent().get_children():
		if player.name.begins_with("player"):
			if !player.is_me:
				add_collision_exception_with(player)
	

			
			
func _process(delta: float) -> void:

	
	if is_me:
		get_parent().get_node("Camera3D").playerTarget = position
		velocity = (Vector3(get_parent().get_node("JoyStick").joy_direction.x ,-_gravityForce,get_parent().get_node("JoyStick").joy_direction.y)) * delta*60
		
		#
		#if velocity.length() > 0:
			#velocity.normalized()
			#var _rotation = velocity.angle_to(Vector3.FORWARD)
			#rotation_degrees.y = rad_to_deg(_rotation)
		#Target =  global_transform.origin + velocity
		if velocity.length() > 0:
			move_and_slide()
			if Target != global_transform.origin:
				Target =  global_transform.origin + velocity
				look_at(Target , Vector3.UP , true)
		
		if velocity.length() > 0:
			if current_anim != anims[1]:
				current_anim = anims[1]
				
				anim_changed.emit()
				
			
			
		else:
			if current_anim != anims[0]:
				current_anim = anims[0]
				
				anim_changed.emit()
				
				
			
		#sync position
		current_pos = position
		if current_pos != previous_pos:
			if get_tree().get_frame() % sync_interval == 0:
				position_changed.emit()
				previous_pos = current_pos
				direction = current_pos - previous_pos
		

	
@rpc("any_peer")
func sync_positions_and_target(pos , target):
	pass
	

@rpc("any_peer")
func sync_anim(anim):
	pass


@rpc("authority")
func sync_other_player_position_target(pos , target):
	if !is_me:
		position = pos
		if position != target:
			look_at_from_position(position ,target , Vector3.UP , true)
			

@rpc("authority")
func sync_other_anim(anim):
	if !is_me:
		state_machine.travel(anim)
		
	
func on_position_changed():
	sync_positions_and_target.rpc_id(1 , global_transform.origin , Target)

func on_anim_changed():
	if is_me:
		state_machine.travel(current_anim)
		sync_anim.rpc_id(1 , current_anim)


func set_color(color):
	current_color = color
	var mat : Array
	mat.append(preload("res://materials/KixMax.tres"))
	mat.append(preload("res://materials/KixMax2.tres"))
	
	
	$KixMax/Rig/Skeleton3D/RETOPO_MODIF.material_override = mat[thisPlayerIndex]
		#$KixMax/Rig/Skeleton3D/Lid_l.material_override = preload("res://materials/KixMax.tres")
		#$KixMax/Rig/Skeleton3D/Lid_r.material_override = preload("res://materials/KixMax.tres")
	if current_color != Color.BLACK:
		$KixMax/Rig/Skeleton3D/RETOPO_MODIF.material_override.albedo_color = current_color
			
#
#
#@rpc("authority")
#func your_enemy_color(color):
	#if is_me:
		#for player in get_parent().get_children():
			#if player.name.begins_with("Player"):
				#if !player.is_me:
					#player.current_color = color
						#
					#player.get_node("KixMax/Rig/Skeleton3D/RETOPO_MODIF").material_override = preload("res://materials/KixMax2.tres")
					##player.get_node("KixMax/Rig/Skeleton3D/Lid_l").material_override = preload("res://materials/KixMax2.tres")
					##player.get_node("$KixMax/Rig/Skeleton3D/Lid_r").material_override = preload("res://materials/KixMax2.tres")
					#
					#if current_color != Color.BLACK:
						#player.get_node("KixMax/Rig/Skeleton3D/RETOPO_MODIF").material_override.albedo_color = current_color
func set_index(index):
	
	thisPlayerIndex = index
	position_spawned.emit(on_position_spawn)
	print(name + "index: " + str(thisPlayerIndex))
	return thisPlayerIndex
	
func on_position_spawn():
	position = sp_positions[thisPlayerIndex]
