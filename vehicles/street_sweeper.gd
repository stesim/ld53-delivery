extends Vehicle


@onready var _suction_sound := %suction_sound


func _on_sweeping_area_body_entered(body : Node3D) -> void:
	_suction_sound.play()
	body.queue_free()
