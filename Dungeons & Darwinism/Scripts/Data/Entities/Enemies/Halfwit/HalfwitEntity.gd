class_name HalfwitEntity
extends EnemyEntityData

func _init(_hp: int = 20, _name: String = "halfwit", _dmg: int = 3) -> void:
	
	var stats: StatsComponent = StatsComponent.new(self)
	stats.stat_dict.set(StatsComponent.stat.dmg, _dmg)
	component_array.append(stats)
	
	corpse = HalfwitCorpse.new()
	var enemy_texture: TextureComponent = TextureComponent.new(self)
	enemy_texture.texture = Textures.HALFWIT_SPRITE
	component_array.append(enemy_texture)
	super._init(_hp, _name)
