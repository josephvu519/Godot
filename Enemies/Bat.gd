extends KinematicBody2D


const ENEMYDEATHEFFECTSCENE = preload("res://Effects/EnemyDeathEffect.tscn")

export var FlyFrictionDelta = 200
export var Acceleration = 300
export var Friction = 100
export var MaxSpeed = 50

enum {
	Idle,
	Roam,
	Chase
}

var state = Idle
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox

func _ready():
	print("Max Health of Bat: " + str(stats.max_health))
	

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FlyFrictionDelta * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		Idle:
			velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)
			seek_player()
		Roam:
			pass
		Chase:
			var player = playerDetectionZone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MaxSpeed, Acceleration * delta)
			else:
				state = Idle
				
	sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)


func seek_player():
	#print(playerDetectionZone.can_see_player())
	if playerDetectionZone.can_see_player():
		state = Chase

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	print("Health: " + str(stats.health))
	knockback = area.knockback_vector * 100
	hurtbox.create_hit_effect()


func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = ENEMYDEATHEFFECTSCENE.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	

