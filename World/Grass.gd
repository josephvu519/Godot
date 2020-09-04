extends Sprite

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		var grassEffectScene = load("res://Effects/GrassEffect.tscn")
		var grassEffect = grassEffectScene.instance()
		var world = get_tree().current_scene
		world.add_child(grassEffect)
		grassEffect.global_position = global_position
		
		queue_free()
