extends KinematicBody2D

const FRICTION = 1
const ACCEL = 1
const MAX_SPEED = 50

var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _physics_process(delta):
	var inputVector = Vector2.ZERO;
	inputVector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");
	inputVector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up");
	inputVector = inputVector.normalized()
	
	if (inputVector != Vector2.ZERO):
		animationTree.set("parameters/Idle/blend_position", inputVector)
		animationTree.set("parameters/Run/blend_position", inputVector)
		animationState.travel("Run")
		velocity += inputVector * ACCEL * delta
		velocity = velocity.clamped(MAX_SPEED * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta);
	print(velocity)
	
	move_and_collide(velocity);
