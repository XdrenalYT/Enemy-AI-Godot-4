extends Node3D

@export var main: Node
@onready var reference_pivot = $"../ReferencePivot"

func _process(delta):
	if main.player != null:
		reference_pivot.look_at(main.player.global_transform.origin)
		rotation = lerp(rotation, reference_pivot.rotation, 0.1)
