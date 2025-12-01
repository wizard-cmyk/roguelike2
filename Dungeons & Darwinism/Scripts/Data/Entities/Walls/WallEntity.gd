class_name WallEntityData
extends EntityData

var wall_texture: TextureComponent
var solid: SolidComponent

func _init() -> void:
	id = EntityId.WALL_ENTITY_DATA
	wall_texture = TextureComponent.new(self)
	solid = SolidComponent.new(self)
	wall_texture.texture =  Textures.ROCKY_WALL
	component_array.append(wall_texture)
	component_array.append(solid)
	
