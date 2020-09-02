extends KinematicBody2D

const FRICTION = 400
const SLIPPERYFRICTION = 1
const ACCEL = 400
const SLIPPERYACCEL = 1
const MAX_SPEED = 80

var slippery = false;

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
		if slippery:
			getSlipperyMovement(inputVector, delta)
		else:
			getNormalMovement(inputVector, delta)
	else:
		animationState.travel("Idle")
		if slippery:
			brakeSlipperyMovement(delta)
		else:
			brakeNormalMovement(delta)
	print(velocity)
	
	velocity = move_and_slide(velocity);

func getSlipperyMovement(inputVector, delta):
	velocity += inputVector * SLIPPERYACCEL * delta
	velocity = velocity.clamped(MAX_SPEED * delta)
	
func brakeSlipperyMovement(delta):
	velocity = velocity.move_toward(Vector2.ZERO, SLIPPERYFRICTION * delta)
	
func getNormalMovement(inputVector, delta):
	velocity = velocity.move_toward(inputVector * MAX_SPEED, ACCEL * delta)

func brakeNormalMovement(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta);
