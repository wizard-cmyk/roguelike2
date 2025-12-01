class_name StatsComponent
extends Component


func _init(_this_entity: EntityData) -> void:
	id = ComponentId.STATS
	super._init(_this_entity)

enum stat { dmg, def }

var stat_dict: Dictionary[stat, int] = { 
	stat.dmg: 0,
	stat.def: 0
	}
