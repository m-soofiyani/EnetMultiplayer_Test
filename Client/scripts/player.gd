extends CharacterBody3D

@export var thisPlayerIndex : int


var sync_interval := 1
var sp_positions = [Vector3(-2 ,0,0) , Vector3(2 ,0,0)]
var Target: Vector3

var Velocity : Vector3
var current_velocity : Vector3
var previous_velocity : Vector3

@export var clothMaterials : Array[StandardMaterial3D]

@export var digits : int
var is_me : bool

var current_pos : Vector3
var previous_pos : Vector3
var direction : Vector3

signal position_changed
signal velocity_changed

func _ready() -> void:
	thisPlayerIndex = Singelton.myIndex
	
	position_changed.connect(on_position_changed)
	velocity_changed.connect(on_velocity_changed)
	

	
	var splitted_name =  name.split("_" , true , 1)
	digits = int(splitted_name[1])
	is_me = digits == multiplayer.get_unique_id()
	
	position = sp_positions[thisPlayerIndex]
	Velocity = Vector3.ZERO
	
	if is_me:
		$"3dmodel/Object_5/Skeleton3D/cloth".material_override = clothMaterials[0]
	else :
		$"3dmodel/Object_5/Skeleton3D/cloth".material_override = clothMaterials[1]
		
	for player in get_parent().get_children():
		if player.name.begins_with("player"):
			if !player.is_me:
				add_collision_exception_with(player)
	
	
func _input(event):
	
	#if event is InputEventScreenTouch and event.pressed == true:
		#Target = Vector3(Target.x , 0 , Target.y)
		#Velocity = Target - position
	
	if event.is_action_pressed("ui_left"):
		Velocity = Vector3.LEFT
	elif event.is_action_pressed("ui_right"):
		Velocity = Vector3.RIGHT
	elif event.is_action_pressed("ui_up"):
		Velocity = Vector3.FORWARD
	elif event.is_action_pressed("ui_down"):
		Velocity = -Vector3.FORWARD
		
	else:
		Velocity = Vector3.ZERO


func _process(delta: float) -> void:

	
	if is_me:
		get_parent().get_node("Camera3D").playerTarget = position
		Velocity = Vector3(get_parent().get_node("JoyStick").joy_direction.x , 0 ,get_parent().get_node("JoyStick").joy_direction.y)
		move_and_collide(Velocity.normalized() * .01)

		if position != Velocity +  position:
			Target = Velocity +  position
			look_at_from_position(position ,Target , Vector3.UP , true)

		if Velocity.length() > 0 :
			$"3dmodel/AnimationPlayer".play("Run")
			
		else:
			$"3dmodel/AnimationPlayer".play("Idle")
			
		#sync position
		current_pos = position
		if current_pos != previous_pos:
			if get_tree().get_frame() % sync_interval == 0:
				position_changed.emit()
				previous_pos = current_pos
				direction = current_pos - previous_pos
		
		current_velocity = Velocity
		if current_velocity != previous_velocity:
			velocity_changed.emit()
			previous_velocity = current_velocity
			
	
@rpc("any_peer")
func sync_positions_and_target(pos , target):
	pass
@rpc("any_peer")
func sync_velocity(velocity):
	pass


@rpc("authority")
func sync_other_player_position_target(pos , target):
	if !is_me:
		#var tween = get_tree().create_tween()
		#tween.tween_property(self , "position" , pos ,
		#.1 ).set_trans(Tween.TRANS_LINEAR)
		position = pos
		if position != target:
			look_at_from_position(position ,target , Vector3.UP , true)
			

@rpc("authority")
func sync_other_velocity(velocity):
	if velocity.length() > 0 :
		$"3dmodel/AnimationPlayer".play("Run")
	else:
		$"3dmodel/AnimationPlayer".play("Idle")
		
	
func on_position_changed():
	sync_positions_and_target.rpc_id(1 , position , Target , Velocity)

func on_velocity_changed():
	sync_velocity.rpc_id(1 ,Velocity)
