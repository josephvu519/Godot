extends KinematicBody2D

const FLYFRICTIONDELTA = 200

var knockback = Vector2.ZERO

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FLYFRICTIONDELTA * delta)
	knockback = move_and_slide(knockback)

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 100
