extends Area3D


@export var manager_: Node
@export var is_proj: bool

var player_overlapping: bool = false
#uses bodies in order to detect entities



func _on_body_entered(body):
	
	if body.is_in_group("Player"):
		player_overlapping = true


func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_overlapping = false
