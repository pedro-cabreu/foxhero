extends KinematicBody2D

var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var state = MOVE
var stats = PlayerStats #global definida em: ProjectSettings > AutoLoad

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

enum {
	MOVE,
	ROLL,
	ATTACK
}
#Player Stats
export var MAX_SPEED = 100 
export var ACCELERATION = 500
export var ROLL_SPEED = 120
export var FRICTION = 400
#Scenes Imports
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var blinkAnimationPlayer = $BlinkAnimation
onready var swordHitbox = $HitBoxPivot/SwordHitBox
onready var hurtBox = $HurtBox
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector
	
func _physics_process(delta):
	
	match state:
		
		MOVE:
			move_state(delta)
		
		ROLL:
			roll_state()
		
		ATTACK:
			attack_state()
	
func move_state(delta):
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		
	else:
		
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL

func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()
	
func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func move():
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	velocity = velocity * 0.85
	state = MOVE
	
func attack_animation_finished():
	state = MOVE

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	hurtBox.start_invincibility(0.6)
	hurtBox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)


func _on_HurtBox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_HurtBox_invincibility_ended():
	blinkAnimationPlayer.play("End")
