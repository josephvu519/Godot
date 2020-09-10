extends KinematicBody2D

export var FRICTION = 500
export var SLIPPERYFRICTION = 50
export var ACCEL = 500
export var SLIPPERYACCEL = 50
export var MAX_SPEED = 80
export var ROLL_SPEED = 100

enum {
	Attack,
	Move,
	Roll
}

var state = Move
var slippery = false
var stats = PlayerStats
var velocity = Vector2.ZERO
var rollVector = Vector2.RIGHT

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $PositionPivot/SwordHitbox
onready var hurtbox = $Hurtbox

func _ready():
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true;
	swordHitbox.knockback_vector = rollVector

func _process(delta):
	match state:
		Move:
			move_state(delta)
		Attack:
			attack_state(delta)
		Roll:
			roll_state(delta)
			
	velocity = move_and_slide(velocity)
		
	
func attack_state(delta):
	animationState.travel("Attack")
	brake(delta);
func roll_state(delta):
	animationState.travel("Roll")
	hurtbox.start_invincibility(0.75)
	
func attack_animation_finished():
	state = Move
func roll_animation_finished():
	velocity = Vector2.ZERO
	state = Move
	
func getNormalizedInputVector():
	var inputVector = Vector2.ZERO;
	inputVector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");
	inputVector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up");
	return inputVector.normalized()
	
func move_state(delta):
	var inputVector = getNormalizedInputVector()
	
	if (inputVector != Vector2.ZERO):
		rollVector = inputVector
		swordHitbox.knockback_vector = inputVector
		animationTree.set("parameters/Idle/blend_position", inputVector)
		animationTree.set("parameters/Run/blend_position", inputVector)
		animationTree.set("parameters/Attack/blend_position", inputVector)
		animationTree.set("parameters/Roll/blend_position", inputVector)
		animationState.travel("Run")
		if slippery:
			getSlipperyMovement(inputVector, delta)
		else:
			getNormalMovement(inputVector, delta)
	else:
		animationState.travel("Idle")
		brake(delta);
	#print(rollVector)
	
	if Input.is_action_just_pressed("attack"):
		state = Attack
	elif Input.is_action_just_pressed("roll"):
		if !slippery:
			velocity = rollVector * ROLL_SPEED
		state = Roll
		
func getNormalMovement(inputVector, delta):
	velocity = velocity.move_toward(inputVector * MAX_SPEED, ACCEL * delta)
func getSlipperyMovement(inputVector, delta):
	#velocity += inputVector * SLIPPERYACCEL * delta
	#velocity = velocity.clamped(MAX_SPEED)
	velocity = velocity.move_toward(inputVector * MAX_SPEED, SLIPPERYACCEL * delta)
func brake(delta):
	if slippery:
		brakeSlipperyMovement(delta)
	else:
		brakeNormalMovement(delta)
func brakeSlipperyMovement(delta):
	velocity = velocity.move_toward(Vector2.ZERO, SLIPPERYFRICTION * delta)
func brakeNormalMovement(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta);

func _on_Hurtbox_area_entered(area):
	if !hurtbox.is_invincible():
		stats.health -= 1
		print("Health after hit: " + str(stats.health))
		hurtbox.start_invincibility(0.75)
		hurtbox.create_hit_effect()
