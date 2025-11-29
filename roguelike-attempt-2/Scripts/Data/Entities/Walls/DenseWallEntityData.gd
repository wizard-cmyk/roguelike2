class_name DenseWallEntity
extends WallEntityData

func _init() -> void:
	id = EntityId.WALL_ENTITY_DATA
	var wall_texture: = TextureComponent.new(self)
	var solid: = SolidComponent.new(self)
	solid.dense = true
	wall_texture.texture = Textures.DARK_ROCKY_WALL
	component_array.append(wall_texture)
	component_array.append(solid)
	
