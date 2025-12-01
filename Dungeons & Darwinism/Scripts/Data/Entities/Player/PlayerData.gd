class_name PlayerEntityData
extends EntityData

var username: String
var player_texture: TextureComponent
var hp: HpComponent
var movement_component: MovementComponent
var solid: SolidComponent
var inventory: InventoryComponent
var stats: StatsComponent

func _init(_name: String) -> void:
	corpse = PlayerCorpse.new()
	id = EntityId.PLAYER_ENTITY_DATA
	username = _name
	
	player_texture = TextureComponent.new(self)
	player_texture.texture = Textures.PLAYER_TEXTURE
	component_array.append(player_texture)
	
	stats = StatsComponent.new(self)
	component_array.append(stats)
	stats.stat_dict.set(StatsComponent.stat.dmg, 1)
	
	hp = HpComponent.new(20, self)
	component_array.append(hp)
	
	movement_component = MovementComponent.new(self)
	component_array.append(movement_component)
	
	solid = SolidComponent.new(self)
	component_array.append(solid)
	
	inventory = InventoryComponent.new(self)
	component_array.append(inventory)
	
