extends Node2D
class_name Level

const PATH := "res://source/level/levels/"

export var id := 1

export var bottom_limit := 1000

onready var player := $Characters/Player
onready var terrain := $Terrain

onready var interface := $Interface as Interface
onready var game_cam := $GameCam

onready var events := $Events.get_children()
onready var checkpoints := $Checkpoints.get_children()

func _ready() -> void:
	SaveGame.current_level = id

	for character in get_tree().get_nodes_in_group("Character"):
		character.connect("died", self, "_on_Character_died")

	get_tree().call_group("Character", "set_bottom_limit", bottom_limit)
	get_tree().call_group("RaphiePlate", "set_max_health", player.max_health)
	get_tree().call_group("RaphiePlate", "set_max_energy", player.max_energy)

	game_cam.change_target(player)

	for event in events:

		if event is Cutscene:
			event.connect("started", self, "_on_Cutscene_started")
			event.connect("finished", self, "_on_Cutscene_finished")

		event.connect("seen", self, "_on_Event_seen")

	for checkpoint in checkpoints:
		checkpoint.connect("reached", self, "_on_Checkpoint_reached")

	if SaveGame.checkpoints.has(id):
		var new_position = checkpoints[SaveGame.checkpoints[id]].global_position
		player.global_position = new_position
		game_cam.global_position = new_position

	if SaveGame.events.has(id):

		for event_id in SaveGame.events[id]:
			events[event_id].happened = true

func _on_Event_seen(event_id: int) -> void:
	SaveGame.events[id].append(event_id)

func _on_Cutscene_started() -> void:
	interface.hide()
	get_tree().call_group("Character", "_set_disabled", true)
	player.cancel_slow_motion()

func _on_Cutscene_finished() -> void:
	yield(get_tree().create_timer(0.2), "timeout")
	interface.show()
	get_tree().call_group("Character", "_set_disabled", false)

func _on_Checkpoint_reached(id: int) -> void:
	SaveGame.checkpoints[self.id] = id

func _on_Character_died() -> void:
	player.slow_motion.hit()

func _on_Player_health_changed(health) -> void:
	get_tree().call_group("RaphiePlate", "update_health", health)

func _on_Player_energy_changed(energy) -> void:
	get_tree().call_group("RaphiePlate", "update_energy", energy)

func _on_Player_no_energy_left() -> void:
	get_tree().call_group("RaphiePlate", "shake_energy_bar")
