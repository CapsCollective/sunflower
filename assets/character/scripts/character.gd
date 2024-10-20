class_name Character extends CharacterBody3D

@export var speed = 3
@export var fall_acceleration = 75

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var target_velocity = Vector3.ZERO
var current_action: CharacterAction = null

func _ready():
	navigation_agent.velocity_computed.connect(on_velocity_computed)

func run_action(action: CharacterAction):
	if current_action:
		current_action.abort()
	current_action = action
	current_action.ended.connect(func(): current_action = null)
	current_action.start()

func navigate_to(pos: Vector3):
	run_action(CharacterActionNavigateTo.new(self, pos))

func _physics_process(delta):
	if current_action:
			current_action.tick(delta)
	if not navigation_agent.is_navigation_finished():
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		next_path_position += Vector3(0, 0.5, 0)
		var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
		if navigation_agent.avoidance_enabled:
			navigation_agent.set_velocity(new_velocity)
		else:
			on_velocity_computed(new_velocity)
	
	var vel_pos: Vector3 = (position + velocity)
	var look_at_target = Vector3(vel_pos.x, global_position.y, vel_pos.z)
	if look_at_target != global_position:
		look_at(look_at_target, Vector3.UP)
	
	if not is_on_floor():
		velocity.y = velocity.y - (fall_acceleration * delta)
	move_and_slide()

func on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
