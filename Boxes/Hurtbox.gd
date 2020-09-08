extends Area2D

export(Vector2) var hitOffset = Vector2.ZERO

const HitEffect = preload("res://Effects/HitEffect.tscn")

onready var timer = $Timer

var invincible = false setget set_invincible

signal invincibility_started
signal invincibility_ended

func is_invincible():
	return invincible

func set_invincible(value):
	invincible = value
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

#in seconds
func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position - hitOffset


func _on_Timer_timeout():
	#self is needed to fire the set_invincible function
	self.invincible = false


func _on_Hurtbox_invincibility_started():
	#must use set_deferred because setting monitorable directly will be blocked by the physics process
	set_deferred("monitorable", false)

func _on_Hurtbox_invincibility_ended():
	#should be fine since it hits the end of the timer
	monitorable = true
