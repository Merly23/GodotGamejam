extends State

export var speed := Vector2(150, 150)

func enter(host: Node) -> void:
	host = host as Drone
	print("seeeeekk")

func update(host: Node, delta: float) -> void:
	host = host as Drone

	var direction = host.get_player_vector_direction()
	host.motion = direction * speed

	if direction.x < 0:
		host.flip_left()
	elif direction.x > 0:
		host.flip_right()

	host.move_and_slide_with_snap(host.motion, Global.DOWN, Global.UP)

	if host.is_player_in_shoot_range():
		host.fsm.change_state("shoot")
	elif not host.is_player_in_vision():
		host.fsm.change_state("retreat")
	elif host.is_too_far_from_origin():
		host.fsm.change_state("retreat")

func exit(host: Node) -> void:
	host = host as Drone
	host.motion.y = 0