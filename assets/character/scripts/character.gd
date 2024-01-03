extends Node3D

func _ready():
	$AnimationPlayer.play("idle")
	await get_tree().create_timer(5).timeout
	$AnimationPlayer.play("run")
