class_name HpComponent
extends Component

var max_hp: int
var current_hp: int

func _init(_max_hp: int, _this_entity: EntityData) -> void:
	max_hp = _max_hp
	current_hp = max_hp
	super._init(_this_entity)

func execute() -> void:
	pass
