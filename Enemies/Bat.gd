extends KinematicBody2D

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
const BatDeathEffect = preload("res://Effects/BatDeathEffect.tscn")
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $Sprite
onready var hurtBox = $HurtBox

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

enum{
	IDLE,
	WANDER,
	CHASE
}
var state = IDLE

func _ready():
	print(stats.maxHealth)

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
		
		CHASE:
			var player = playerDetectionZone.player
			if player != null: # Se o player estiver na zona de detecção
				var direction = (player.global_position - global_position).normalized() #Posição x, y do player - x,y do morcego
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
				
			sprite.flip_h = velocity.x < 0
			
	velocity = move_and_slide(velocity)
		
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage #Mesmo não chamando a função set diretamente o godot utiliza ela para atualizar a variavel health em Stats.gd
	print(stats.health)
	hurtBox.create_hit_effect(area)
	knockback = area.knockback_vector * 120
	
func _on_Stats_no_health(): # O sinal emitido pelo Stats.gd quando o inimigo morre
	queue_free()
	var batDeathEffect = BatDeathEffect.instance()
	get_parent().add_child(batDeathEffect)
	batDeathEffect.global_position = global_position
