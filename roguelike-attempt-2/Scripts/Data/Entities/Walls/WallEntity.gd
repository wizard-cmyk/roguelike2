class_name WallEntityData
extends EntityData

func _init() -> void:
	id = EntityId.WALL_ENTITY_DATA
	var wall_texture: = TextureComponent.new(self)
	var solid: = SolidComponent.new(self)
	wall_texture.texture =  Textures.ROCKY_WALL
	component_array.append(wall_texture)
	component_array.append(solid)
	
