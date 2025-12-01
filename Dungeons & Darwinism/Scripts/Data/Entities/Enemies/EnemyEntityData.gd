class_name EnemyEntityData
extends EntityData

var enemy_name: String

func _init(_hp: int, _name: String) -> void:
	id = EntityId.ENEMY_ENTITY_DATA
	enemy_name = _name
	var hp: HpComponent = HpComponent.new(_hp, self)
	var movement_component: MovementComponent = MovementComponent.new(self)
	var solid: SolidComponent = SolidComponent.new(self)
	var can_attack_component: CanAttackComponent = CanAttackComponent.new(self)
	var inventory: InventoryComponent = InventoryComponent.new(self)

	
	component_array.append(hp)
	component_array.append(movement_component)
	component_array.append(solid)
	component_array.append(can_attack_component)
	component_array.append(inventory)
