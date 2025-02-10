extends CharacterBody3D

@export var thisPlayerIndex : int

var health := 3000
var username : String
var sync_interval := 1
var collidingwithwall: bool

var isPlayerTargeting : bool
var Target: Vector3
var canFire := true
var _gravityForce := 0
var _velocity : Vector3
var current_velocity : Vector3
var previous_velocity : Vector3

@export var clothMaterials : Array[StandardMaterial3D]

@export var digits : int
var is_me : bool

var current_pos : Vector3
var previous_pos : Vector3
var direction : Vector3
var Speed := 2

signal position_changed
signal anim_changed
signal position_spawned

var anims = ["Idle" , "Run"]
var current_anim : String
@onready var state_machine = $KixMax/AnimationTree.get("parameters/playback")

var current_color : Color
var this_player_color
func _ready() -> void:
	collidingwithwall = false
	
	position_changed.connect(on_position_changed)
	anim_changed.connect(on_anim_changed)
	
	get_parent().get_node("BulletJoyStick").fire.connect(on_fire)
	get_parent().get_node("BulletJoyStick").target.connect(on_targeting)
	
	isPlayerTargeting = false
	
	var splitted_name =  name.split("_" , true , 1)
	digits = int(splitted_name[1])
	is_me = digits == multiplayer.get_unique_id()
	
	
	
		
	for player in get_parent().get_children():
		if player.name.begins_with("player"):
			if !player.is_me:
				add_collision_exception_with(player)
	

			
			
func _process(delta: float) -> void:

	
	if is_me:
		get_parent().get_node("Camera3D").playerTarget = position
		_velocity = (Vector3(get_parent().get_node("JoyStick").joy_direction.x ,-_gravityForce,get_parent().get_node("JoyStick").joy_direction.y))
		
		if self.has_node("targeting"):
			get_node("targeting").global_transform.origin = global_transform.origin
			var target_vector = (Vector3(get_parent().get_node("BulletJoyStick").joy_direction.x ,0,get_parent().get_node("BulletJoyStick").joy_direction.y))
			get_node("targeting").look_at(get_node("targeting").global_transform.origin + target_vector.normalized())
		#

		if _velocity.length() > 0 and !collidingwithwall:
			move_and_collide( _velocity  * delta * Speed)
			if Target != global_transform.origin:
				Target =  global_transform.origin + _velocity
				look_at_direction(_velocity)
		
		if _velocity.length() > 0:
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
		
		look_at_direction(target - position)
			
			

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
func set_index(index):
	
	thisPlayerIndex = index
	
	print(name + "index: " + str(thisPlayerIndex))
	return thisPlayerIndex
	



func look_at_direction(direction : Vector3):
	var up = Vector3(0, 1, 0)
	
	direction = direction.normalized()
	if global_transform.origin + direction == global_transform.origin:
		return
	if direction.cross(up).length() < 0.0001:
		return
		
	look_at(global_transform.origin + direction , up , true)
	

func on_fire(direction):
	
	if is_me and canFire:
		$FireTimer.start(.1)
		if self.has_node("targeting"):
			get_node("targeting").queue_free()
		isPlayerTargeting = false
		canFire = false
		var bullet = preload("res://scenes/gr_bullet.tscn").instantiate()
		bullet.position = $KixMax/bulletspawn.global_transform.origin
		bullet.this_bullet_material_index = randi_range(0,3)
		bullet.whoFired_id = Singelton.PeerId
		bullet.VELOCITY = Vector3(direction.x , 0 , direction.y)
		get_parent().add_child(bullet , true)
		look_at_direction(bullet.VELOCITY)
		send_fire_info.rpc_id(1 , bullet.VELOCITY , bullet.this_bullet_material_index, Singelton.PeerId , bullet.name)
		
		
func on_targeting():
	if is_me:
		isPlayerTargeting = true
		var targeting_ui = preload("res://scenes/targeting.tscn").instantiate()
		add_child(targeting_ui)
		targeting_ui.name = "targeting"

@rpc("any_peer")
func send_fire_info(direction, materialindex , whofiredId , bulletname):
	pass


@rpc("authority")
func get_fire_info(direction, materialindex , whofiredId , bulletname):
	if !is_me:
		var bullet = preload("res://scenes/gr_bullet.tscn").instantiate()
		bullet.position = $KixMax/bulletspawn.global_transform.origin
		#bullet.sleeping = true
		bullet.whoFired_id = whofiredId
		bullet.VELOCITY = Vector3(direction.x , 0 , direction.y)
		bullet.this_bullet_material_index = materialindex
		
		get_parent().add_child(bullet , true) 
		if bullet.name != bulletname:
			bullet.name = bulletname
		#bullet.name = bulletname
		look_at_direction(direction)
		


func _on_fire_timer_timeout() -> void:
	canFire = true

func takeDamage(amount):
	damaged_ui(amount)
	health -= amount
	if health <= 0:
		if is_me:
			this_player_dead.rpc_id(1)

	
	
@rpc("authority")
func Damaged(playerId):
	
	if playerId == Singelton.PeerId:
		takeDamage(500)
		
	else:
		get_parent().get_node("Player_"+str(playerId)).takeDamage(500)
		

@rpc("any_peer")
func this_player_dead():
	pass

func damaged_ui(amount):
	var healthvalue_pop = preload("res://scenes/health_value.tscn").instantiate()
	healthvalue_pop.get_node("Label").text = str(amount)
	add_child(healthvalue_pop , true)
	healthvalue_pop.position = get_parent().get_node("Camera3D").unproject_position(global_transform.origin)
