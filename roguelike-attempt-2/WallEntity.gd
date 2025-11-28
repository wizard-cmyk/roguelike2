class_name WallEntityData
extends EntityData

func _init() -> void:
	var wall_texture: = TextureComponent.new(self)
	var solid: = SolidComponent.new(self)
	wall_texture.texture = preload("uid://djx4y4pnx0axl")
	component_array.append(wall_texture)
	component_array.append(solid)
	
