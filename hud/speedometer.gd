extends Control


@export var speed := 0.0 :
	set(value):
		speed = value
		_value_label.text = str(roundi(speed))


@onready var _value_label := %value_label
