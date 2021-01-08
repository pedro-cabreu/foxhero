extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn") #Pré-carrega o efeito da grama

func create_grass_effect():
		
	var grassEffect = GrassEffect.instance()
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_HurtBox_area_entered(_area):
	create_grass_effect()
	queue_free()
