extends Node3D


@export var inventory : Inventory :
	get: return %loading_area.backing_inventory
	set(value):
		%loading_area.backing_inventory = value
		%quantity_indicator.inventory = value
