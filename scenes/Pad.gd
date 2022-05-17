extends RigidBody

export (String) var direction
var position: int = 50
var lamp: bool setget set_lamp

var _max:int = 0

func set_lamp(value):
	if lamp!=value:
		lamp = value
		var material:SpatialMaterial = $MeshInstance/Lamp.get_surface_material(0)
		material.albedo_color = Color("000000" if !lamp else "ffffff")
	pass

func _ready():
	_max = 90 if direction == "left" else -90
	pass

func _process(_delta):
	if position > 0:
		rotation_degrees = Vector3(0, float(_max * (position - 50))/100, 0)
	pass
