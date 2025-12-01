class_name Global
extends Node

const GRID_SIZE: Vector2i = Vector2i(100, 100)
const CELL_SIZE: Vector2i = Vector2i(64, 64)

const HP_BAR_OFFSET: Vector2i = Vector2i(0,64)
const DEFAULT_POSITION: Vector2i = Vector2i(5, 5)
const INVENTORY_SIZE: Vector2i = Vector2i(3, 3)

const MENU_CURSOR_DEFAULT_POSITION: Vector2i = Vector2i.ZERO

const INVENTORY_BG_SPRITE_Z_INDEX: int = 996
const INVENTORY_CELL_SPRITE_Z_INDEX: int = 997
const INVENTORY_CURSOR_SPRITE_Z_INDEX: int = 999
const DEFAULT_INVENTORY_POSITION: Vector2i = Vector2i(1, 1) * Global.CELL_SIZE
