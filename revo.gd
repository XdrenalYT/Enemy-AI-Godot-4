extends CharacterBody3D

var dflt_grav = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


var player

var firing = false
@onready var animation_player = $AnimationPlayer

var bullet_scene = preload("res://Entities/Enemies/Enemies/Revo/bullet.tscn")

# Called when the node enters the scene tree for the first time.

func _ready():
	$Timer.start(0.5)
	await $Timer.timeout
	player = PlayerManager.player
	animation_player.play("spin")


func _process(delta):

	if firing == false:
		return
	if $BeamPivot/RayCast3D.is_colliding():
		var distance = $BeamPivot/Scalar.global_transform.origin.distance_to($BeamPivot/RayCast3D.get_collision_point())
		$BeamPivot/Scalar.scale.z = distance/2
		if $BeamPivot/RayCast3D.get_collider().is_in_group("Player"):
			if firing:
				$BeamPivot/RayCast3D.get_collider().update_health($EnemyManager.damage * delta)
	else:
		$BeamPivot/Scalar.scale.z = $BeamPivot/RayCast3D.target_position.z

#func on_attack():
#	print("attacking")
#	firing = true
#	$BeamPivot.visible = true
#	$Timer.start(3)
#	await $Timer.timeout
#	firing = false
#	$BeamPivot.visible = false
#	$Timer.start($EnemyManager.attack_speed)
#	await $Timer.timeout
#	$EnemyManager.can_attack = true

func on_attack():
	print("firing")
	var bullet = bullet_scene.instantiate()
	PlayerManager.proj_holder.add_child(bullet)
	bullet.global_transform.origin = global_transform.origin
	bullet.launch(global_transform.origin)
	$Timer.start(3)
	await $Timer.timeout
	$EnemyManager.can_attack = true

func _on_animation_player_animation_finished(anim_name):
	animation_player.play(anim_name)
