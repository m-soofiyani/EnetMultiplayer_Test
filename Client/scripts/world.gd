extends Node3D
var playerids = []



@rpc("authority")
func spawn_pose(_sync_interval):
	if self.get_child_count() > 0:
		for child in self.get_children():
			if child.name.begins_with("Player"):
				child.sync_interval = _sync_interval
	
	print(_sync_interval)
