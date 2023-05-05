class_name TrackingCameraConfig
extends Resource


const MAX_PITCH := 0.5 * PI - 0.1


@export_range(0.0, MAX_PITCH / PI * 180.0, 0.01, "radians") var pitch := 0.25 * PI
@export_range(-180.0, 180.0, 0.01, "radians") var yaw := 0.0
@export_range(1.0, 20.0, 0.01, "or_greater") var distance := 5.0
