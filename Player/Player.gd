extends KinematicBody2D

const FRICTION = 1
const ACCEL = 1
const MAX_SPEED = 100

var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer

func _physics_process(delta):
	var inputVector = Vector2.ZERO;
	inputVector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");
	inputVector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up");
	
	if (inputVector != Vector2.ZERO):
		animationPlayer.play("RunRight")
		velocity += inputVector.normalized() * ACCEL * delta
		velocity = velocity.clamped(MAX_SPEED * delta)
	else:
		animationPlayer.play("IdleRight")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta);
	print(velocity)
	
	move_and_collide(velocity);
