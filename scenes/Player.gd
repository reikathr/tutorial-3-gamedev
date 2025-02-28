extends CharacterBody2D

@export var gravity = 500.0
@export var walk_speed = 200
@export var jump_speed = -300
@export var jump_count : int

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var colshape = $CollisionShape2D

var crouching_collision = preload("res://resources/crouch_collision.tres")
var standing_collision = preload("res://resources/stand_collision.tres")

var is_crouching = false
var is_jumping = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += delta * gravity
	else:
		jump_count = 0
	
	if jump_count < 2 and Input.is_action_just_pressed('ui_up'):
		jump_count += 1
		velocity.y = jump_speed
	
	var horizontal_direction = Input.get_axis("ui_left", "ui_right")
	if Input.is_action_just_pressed('dash'):
		velocity.x = 15 * walk_speed * horizontal_direction
	else:
		velocity.x = walk_speed * horizontal_direction
	
	if horizontal_direction != 0:
		switch_direction(horizontal_direction)
	
	if Input.is_action_just_pressed("crouch"):
		crouch()
	elif Input.is_action_just_released("crouch"):
		stand()

	# "move_and_slide" already takes delta time into account.
	move_and_slide()
	update_animation(horizontal_direction)
	
func crouch():
	if is_crouching:
		return
	is_crouching = true
	colshape.shape = crouching_collision
	colshape.position.y = 19

func stand():
	if !is_crouching:
		return
	is_crouching = false
	colshape.shape = standing_collision
	colshape.position.y = 12
	
func update_animation(horizontal_direction):
	if is_on_floor():
		if is_crouching:
			animation.play("crouch")
		else:
			animation.play("idle")
	else:
		if velocity.y < 0:
			animation.play("jump")
	
func switch_direction(horizontal_direction):
	sprite.flip_h = (horizontal_direction == -1)
	sprite.position.x = horizontal_direction * 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
