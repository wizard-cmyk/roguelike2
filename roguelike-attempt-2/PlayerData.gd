class_name PlayerEntityData
extends EntityData

func _init() -> void:
	var player_texture: TextureComponent = TextureComponent.new(self)
	var hp: HpComponent = HpComponent.new(20, self)
	var movement_component: MovementComponent = MovementComponent.new(self)
	var solid: SolidComponent = SolidComponent.new(self)
	
	player_texture.texture = preload("uid://d4hvs7nvtxjvd")
	
	component_array.append(player_texture)
	component_array.append(hp)
	component_array.append(movement_component)
	component_array.append(solid)
	
	
