extends Control

var life = 4 setget set_life
var max_life = 4 setget set_max_life

onready var heartUIFull = $FullHeartUI
onready var heartUIEmpty = $EmptyHeartUI

func set_life(value):
	life = clamp(value, 0, max_life)
	if heartUIFull != null:
		heartUIFull.rect_size.x = life * 15
	
func set_max_life(value):
	max_life = max(value, 1)
	self.life = min(life, max_life)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_life * 15
	
func _ready():
	self.max_life = PlayerStats.max_health
	self.life = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_life")
	PlayerStats.connect("max_health_changed", self, "set_max_life")
