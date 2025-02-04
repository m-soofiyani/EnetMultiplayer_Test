extends Node2D

@export var joy_direction : Vector2

func _input(event):
	
	#if event is InputEventScreenTouch and event.is_pressed():
	if event is InputEventScreenDrag:
		
		var origin = $Joyframe.position
		
		var distance = origin.distance_to((event.position - self.position))
		distance = clampf(distance , 0 ,120)
		$Joyframe/Joy.position = (event.position - self.position).normalized() * distance
		
		joy_direction = ($Joyframe/Joy.position - origin).normalized()
		
	
	elif event is InputEventScreenTouch and event.is_released():
		
		$Joyframe/Joy.position = Vector2.ZERO
		joy_direction = Vector2.ZERO
