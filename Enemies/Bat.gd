extends KinematicBody2D


const ENEMYDEATHEFFECTSCENE = preload("res://Effects/EnemyDeathEffect.tscn")

export var FlyFrictionDelta = 200
export var Acceleration = 300
export var Friction = 100
export var MaxSpeed = 50

enum {
	Idle,
	Wander,
	Chase
}

var state = Idle
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

func _ready():
	state = pick_random_state([Idle, Wander])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FlyFrictionDelta * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		Idle:
			velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				randomize_state()
		
		Wander:
			if wanderController.get_time_left() == 0:
				randomize_state()
			accelerate_towards_point(wanderController.target_position, delta)

			if global_position.distance_to(wanderController.target_position) <= 1:
				randomize_state()

		Chase:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = Idle

	velocity = move_and_slide(velocity)
	
func randomize_state():
	state = pick_random_state([Idle, Wander])
	wanderController.start_wander_timer(rand_range(1, 3))
	
func accelerate_towards_point(position, delta):
	var direction = global_position.direction_to(position)
	velocity = velocity.move_toward(direction * MaxSpeed, Acceleration * delta)
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 100
	sprite.flip_h = velocity.x < 0
	
func seek_player():
	#print(playerDetectionZone.can_see_player())
	if playerDetectionZone.can_see_player():
		state = Chase

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	print("Health: " + str(stats.health))
	knockback = area.knockback_vector * 100
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)


func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = ENEMYDEATHEFFECTSCENE.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")
