@tool
class_name RoadIntersection
extends Marker3D


var roads : Array[Road] = []


#signal transform_changed()
#
#
#func _init() -> void:
#	set_notify_local_transform(true)
#
#
#func _notification(what : int) -> void:
#	match what:
#		NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
#			transform_changed.emit()
