extends CharacterBody2D

@export var SPEED := 200
@export var JUMP_SPEED := -400
@export var GRAVITY := 1200
@export var jump_count : int
@onready var animplayer = $AnimatedSprite2D
@onready var colshape = $CollisionShape2D
@export var KICK_DURATION := 0.3
@onready var kick_area = $KickArea
@onready var jump_sound = $JumpSound

var crouching_collision = preload("res://resources/crouch_collision.tres")
var standing_collision = preload("res://resources/stand_collision.tres")

var is_kicking = false
var is_crouching = false
var is_jumping = false

const UP = Vector2(0,-1)

func _ready():
	kick_area.monitoring = false

func _get_input():
	if is_kicking:
		return
	
	var direction := Input.get_axis("ui_left", "ui_right")
	var animation = "idle"

	if jump_count < 2 and Input.is_action_just_pressed("ui_up"):
		jump_count += 1
		velocity.y = JUMP_SPEED
		animation = "jump"
		jump_sound.play()
	
	if velocity.y < 0:  # Player is moving up (jump)
		animation = "jump"
		
	if Input.is_action_just_pressed("kick"):
		kick()
		return

	if is_kicking:
		animation = "kick"
	elif is_crouching:
		animation = "crouch"
	elif direction:
		animation = "walk right"

	if direction:
		velocity.x = direction * SPEED
		animplayer.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("crouch"):
		crouch()
	elif Input.is_action_just_released("crouch"):
		stand()
		
	if animplayer.animation!=animation:
		animplayer.play(animation)
		
	move_and_slide()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += delta * GRAVITY
	else:
		jump_count = 0
	_get_input()
	move_and_slide()
	
func crouch():
	if is_crouching:
		return
	is_crouching = true
	colshape.shape = crouching_collision
	colshape.position.y = 19

func stand():
	is_crouching = false
	is_kicking = false
	colshape.shape = standing_collision
	colshape.position.y = 12

func kick():
	is_kicking = true
	animplayer.play("kick")
	velocity.x = 0
	var prev_y_velocity = velocity.y
	velocity.y = 0
	kick_area.monitoring = true
	kick_area.set_deferred("monitorable", true)
	await get_tree().create_timer(KICK_DURATION).timeout
	velocity.y = max(velocity.y, JUMP_SPEED)
	is_kicking = false
	kick_area.monitoring = false
	kick_area.set_deferred("monitorable", false)
	stand()


func _on_area_2d_body_entered(body):
	pass # Replace with function body.
