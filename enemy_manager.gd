extends Node

# for all normal enemy managements (stats, health manager, damage dealer, state manager, etc.)

@export var navAgent_ : Node
@export var main : Node
@export var hurtbox : Node
@export var playerDectector: Node

@export var idle_p_array: Array[Vector3]
@export var idle_position_target: Vector3

@export var speed: float = 1.0
@export var health: float = 1.0
@export var damage: float = 10.0
@export var knockback_resistance: float = 1.0 #lowest
@export var attack_speed: float = 1.0
@export var acceleration: float = 7.0
@export var xp_dropped: float = 1
@export var basic_attack: bool

var can_attack: bool = true
var override: bool = false
@export var has_idle: bool = false
@onready var attack_speed_timer = $AttackSpeedTimer


enum ENTITY_STATE {
	IDLE,
	CHASE,
	ATTACK
}

@export var entity_state = ENTITY_STATE.IDLE

#knockback ---------------------------------------------------------
var can_move: bool = true # controls if the entity can move
var isKnockback: bool = false # true when is hit with knockback

#effects --------------------------------------
var can_burn = false


func _ready():
	if has_idle:
		idle_position_target = idle_p_array[0]


#applies knockback
func knockback(impulse: Impulse):
#	can_move = true
	
	isKnockback = true
	can_move = false
	main.velocity = (main.global_position - impulse.impulse_origin).normalized() * impulse.knockback_force
	main.velocity.y += (impulse.knockback_force/knockback_resistance)
#	can_move = false# if nav agent is allowed to move again

func _physics_process(delta):
	if main.player == null:
		return
		
	
	if main.is_on_floor():
		if isKnockback == false and can_move == false:
			isKnockback = true
			can_move = true
	
	if has_idle:
		if playerDectector.player_detected == false:
			entity_state = 0

	
	if override:
		return
	match entity_state: # state is determined by other nodes
		0:# if the enemy is idle
			can_move = true
			navAgent_.freeze = false
				
		1:
			can_move = true
			navAgent_.freeze = false
		2:
			
#			can_move = false
#			navAgent_.freeze = true
			
			
			if can_attack == true and hurtbox.player_overlapping:
				
				can_attack = false
				if basic_attack == false:
					main.on_attack()
				else:
					deal_damage(main.player)
				attack_speed_timer.start(attack_speed); await attack_speed_timer.timeout
				can_attack = true
				entity_state = ENTITY_STATE.CHASE
		


func deal_damage(player):
	player.update_health(damage)
	


func update_health(damage):
	health -= damage
	if health <= 0:
		PlayerManager.add_xp(xp_dropped)
		get_parent().queue_free()
		


func change_grav_effect(duration: float, grav_change: float): # DOES NOT WORK | GUESS = NAV AGENT |
	print("grav")
	main.gravity = grav_change
	var t = Timer.new()
	add_child(t)
	t.start(duration)
	await t.timeout
	main.gravity = main.dflt_grav
	t.queue_free()

func on_burn(burn_tick: float, dmg: float, t: float):
	$"../MeshInstance3D".mesh.material.albedo_color = Color(0.90588235855103, 0.32941177487373, 0)
	var tick_timer = Timer.new()
	add_child(tick_timer)
	tick_timer.wait_time = burn_tick
	tick_timer.autostart = true
	tick_timer.start()
	can_burn = true
	var et = Timer.new()
	add_child(et)
	et.wait_time = t
	et.start()
	burn(dmg,tick_timer)
	await et.timeout
	$"../MeshInstance3D".mesh.material.albedo = Color(0.84705883264542, 0.11372549086809, 0.13725490868092)
	can_burn = false
	tick_timer.queue_free()
	et.queue_free()

func burn(dmg: float, tt: Timer):
	if can_burn:
		if tt:
			await tt.timeout
			update_health(dmg)
	

func request_next_idle_pos():
	if has_idle:
		var current_i = idle_p_array.find(idle_position_target)
		var next
		if current_i+1 == idle_p_array.size():
			next = idle_p_array[0]
		else:
			next = idle_p_array[current_i + 1]
		idle_position_target = next
