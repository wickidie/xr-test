extends CharacterBody3D

var movement_speed: float = 2.0
var movement_target_position: Vector3

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	Global.enemy_killed.connect(enemy_killed)

	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	movement_target_position = Global.player_pos
	if navigation_agent.is_navigation_finished():
		call_deferred("actor_setup")
		return

	call_deferred("actor_setup")

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	velocity = new_velocity
	move_and_slide()

func enemy_killed():
	audio_stream_player_3d.play()
#	self.queue_free()
	pass

