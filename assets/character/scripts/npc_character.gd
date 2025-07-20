class_name NPCCharacter extends Character

@export var wander_range: float = 5.0

@onready var initial_position = global_position
@onready var clickable: ClickableObject3D = %Clickable

var dialogue_script: String

func _ready():
	super._ready()
	$AnimationPlayer.play("idle")
	clickable.clicked.connect(on_click)

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		velocity = Vector3.ZERO
	super._physics_process(delta)

func perform_wander():
	var wander_x = randf_range(-wander_range, wander_range)
	var wander_z = randf_range(-wander_range, wander_range)
	var wander_position = initial_position + Vector3(wander_x, 0, wander_z)
	wander_position.y = 0.5
	navigate_to(wander_position)

func on_click():
	GameManager.initiate_dialogue(dialogue_script)
