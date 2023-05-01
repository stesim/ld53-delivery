@tool
extends Node3D


@export var mesh : Mesh :
	get: return %mesh.mesh
	set(value): %mesh.mesh = value
