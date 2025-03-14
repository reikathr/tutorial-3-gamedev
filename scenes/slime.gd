extends RigidBody2D
@export var health := 3
@onready var hit_sound = $HitSound
@onready var animplayer = $AnimatedSprite2D
@onready var colshape = $CollisionShape2D
var live_collision = preload("res://resources/living_slime_colshape.tres")
var dead_collision = preload("res://resources/full_slime.tres")

func _ready():
	animplayer.play("default")
	colshape.shape = live_collision
	colshape.position.y = 49
	$HitboxArea.connect("area_entered", _on_hitbox_entered)

func _on_hitbox_entered(area):
	if area.name == "KickArea":
		get_hit()

func get_hit():
	if hit_sound:
		hit_sound.play()
	health -= 1
	animplayer.play("hit")
	await get_tree().create_timer(0.3).timeout

	if health <= 0:
		die()
		colshape.shape = dead_collision
		colshape.position.y = 34
	else:
		animplayer.play("default")

func die():
	animplayer.play("dead")
	await animplayer.animation_finished
	
	
