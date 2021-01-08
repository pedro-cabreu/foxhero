extends Node

export(int) var maxHealth = 1 setget max_health_changed
var health = maxHealth setget set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func max_health_changed(value):
	maxHealth = value
	self.health = min(health, maxHealth)
	emit_signal("max_health_changed", maxHealth)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	print("Entered the setter function")
	if health <= 0:
		emit_signal("no_health") # Quando a vida do morcego for <= 0 um sinal é emitido para o Bat.gd

func _ready():
	self.health = maxHealth
