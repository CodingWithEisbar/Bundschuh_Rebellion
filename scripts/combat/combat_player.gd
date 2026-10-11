class_name CombatPlayer
extends RefCounted
## Combat and economy share the SAME ResourceBank instance; no shadow gold.
## Maintenance is a scenario opt-in, never a hidden global faction passive.

var id: int
var team_id: int
var faction: int
var bank: ResourceBank
var maintenance_enabled: bool
var gold_per_mercenary: int
var next_payroll_tick: int


func _init(owner: int, team: int, side: int, economy: ResourceBank,
		maintenance: bool, wage: int, due_tick: int) -> void:
	id = owner
	team_id = team
	faction = side
	bank = economy
	maintenance_enabled = maintenance
	gold_per_mercenary = wage
	next_payroll_tick = due_tick
