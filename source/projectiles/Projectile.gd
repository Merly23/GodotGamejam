extends Node2D

var speed := 1600
var damage := 1

var shooter : Character = null

var direction := Vector2()

var fired := false

onready var area := $Sprite/Area2D as Area2D
onready var sprite := $Sprite as Sprite

func _physics_process(delta: float) -> void:
	if fired:
		sprite.position.x += speed * delta

func fire(damage: int, speed: int, direction : Vector2 = Vector2(1, 0)) -> void:

	self.speed = speed
	self.damage = damage
	self.fired = true

	# directional shooting
	# rotation_degrees = dir2rot(direction)

	rotation_degrees = 180 if direction.x == -1 else 0

func _on_Area2D_body_entered(body: PhysicsBody2D) -> void:
	if body is Character and shooter.team_number != body.team_number:
		body.hurt(damage)
		queue_free()

func dir2rot(direction: Vector2) -> float:
	var rot := 0.0

	if direction.x == -1 and not direction.y:
		return 180.0

	if direction.y:
		rot += 90 * direction.y

	if direction.x:
		rot -= 45 * direction.x * direction.y

	return rot