extends Control

var life = 4 setget set_life
var max_life = 4 setget set_max_life

onready var label = $Label

func set_life(value):
	life = clamp(value, 0, max_life)
	if label != null:
		label.text = "HP = " + str(life)
	
	
func set_max_life(value):
	max_life = max(value, 1)
	
func _ready():
	self.max_life = PlayerStats.max_health
	self.life = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_life")
