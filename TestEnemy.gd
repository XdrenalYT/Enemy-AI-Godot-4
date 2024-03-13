extends CharacterBody3D

var player

var dflt_grav = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start(0.5)
	await $Timer.timeout
	player = PlayerManager.player





