extends CharacterBody3D

@export var speed: int
var player_pos
var enemy_pos

func launch(enemy_p):
	player_pos = PlayerManager.player.global_transform.origin
	enemy_pos = enemy_p
	look_at(player_pos)



func _physics_process(delta):
	if player_pos == null:
		return
	
	velocity = (player_pos - enemy_pos).normalized() * speed
	move_and_slide()






func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.update_health(10)
		


func _on_timer_timeout():
	queue_free()
