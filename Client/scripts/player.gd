extends Node2D
@export var thisPlayerIndex : int

var sp_positions = [Vector2(100 , 512) , Vector2(2460 , 512)]
var Target: Vector2
@export var Velocity : Vector2
@export var digits : int
var is_me : bool
signal position_changed
var current_pos
var previous_pos

func _ready() -> void:
	thisPlayerIndex = Singelton.myIndex
	print("my idex is :" , thisPlayerIndex)
	position_changed.connect(on_position_changed)
	if !multiplayer.is_server():
		var splitted_name =  name.split("_" , true , 1)
		digits = int(splitted_name[1])
		is_me = digits == multiplayer.get_unique_id()
		print(digits == Singelton.PeerId)
		
	
	Target = sp_positions[thisPlayerIndex]
	Velocity = Target - position
	
	
func _input(event):
	
	if event is InputEventScreenTouch and event.pressed == true:
		Target = event.position
		Velocity = Target - position
		


func _process(delta: float) -> void:
	if digits == Singelton.PeerId:
		position += Velocity.normalized() * position.distance_to(Target) * .1
		
		current_pos = position
		if current_pos != previous_pos:
			if get_tree().get_frame() % 1 == 0:
				position_changed.emit()
				previous_pos = current_pos
		


@rpc("any_peer")
func sync_positions(pos):
	pass


@rpc("authority")
func sync_other_player(pos):
	if digits != Singelton.PeerId:
		var tween = get_tree().create_tween()
		tween.tween_property(self , "position" , pos , .1 ).set_trans(Tween.TRANS_LINEAR)
		#position = pos


func on_position_changed():
	#print("position changed : " , current_pos)
	
	sync_positions.rpc_id(1 , position)
