extends Control

func _ready() -> void:
	$AnimationPlayer.play("healthvalue_pop")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !$AnimationPlayer.is_playing():
		
		queue_free()
