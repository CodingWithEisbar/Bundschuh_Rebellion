class_name CombatTypes
extends RefCounted
## A roster identity is not an armor class: Landsknechts are both INFANTRY and
## SPEAR, and arquebusiers use ARCHER armor class, not melee INFANTRY.

enum Faction { BUNDSCHUH, SWABIAN_LEAGUE }
enum UnitType { VILLAGER, PIKEMAN, FLAILMAN, RADICAL_PREACHER, LANDSKNECHT,
	ARMOURED_RITTER, CROSSBOWMAN, SKIRMISHER, ARQUEBUSIER, LIGHT_CAVALRY }
enum ArmorClass { INFANTRY, SPEAR, CAVALRY, ARCHER, CLERGY, SIEGE, BUILDING }
enum DamageChannel { MELEE, PIERCE }

const MUTINEER_OWNER := -1
const MUTINEER_TEAM := -1 # One hostile band, allied to itself, enemy to players.
