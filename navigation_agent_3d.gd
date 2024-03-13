extends NavigationAgent3D

@export var main : Node
@export var manager_ : Node
@export var hurtBoxCollisionShape: CollisionShape3D
@export var is_flying: bool

@export var freeze: bool = false

@export var active:bool = true

var reached_target: bool = true:
	set(v):
		reached_target = v
		if reached_target and manager_.has_idle:
			manager_.request_next_idle_pos()




func _physics_process(delta):
	if active == false:
		return
	
	if freeze:
		target_position = main.global_transform.origin
	
	#for knockback
	if manager_.isKnockback and manager_.can_move == false:
		main.move_and_slide()
	
	#idle target position setter
	if manager_.idle_position_target:
		if freeze:
			return
		if manager_.entity_state == 0:
			target_position = manager_.idle_position_target
	
	
	if manager_.entity_state != 0 or manager_.has_idle == false: #chase player target setter
		if freeze:
			return
		if main.player:
			target_position = main.player.global_transform.origin
	
	if distance_to_target() > target_desired_distance:
		reached_target = false
		if manager_.entity_state != 0:
			manager_.entity_state = manager_.ENTITY_STATE.CHASE
	
	if distance_to_target() <= target_desired_distance:
		reached_target = true
		
		manager_.entity_state = manager_.ENTITY_STATE.ATTACK
	
	if reached_target == false:
		var current_location = main.global_transform.origin
		var next_location = get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * manager_.speed
		set_velocity(new_velocity)
#	else:
#		var current_loc = main.global_transform.origin
#		var new_velocity = (current_loc).normalized() * 1
#		set_velocity(new_velocity)
	
	if not main.is_on_floor():
#		if is_flying == false:
			main.velocity.y -= main.gravity * delta

func _on_velocity_computed(safe_velocity):

	if active == false:
		return
	main.velocity = main.velocity.move_toward(safe_velocity, .25)
	main.move_and_slide()
