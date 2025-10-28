extends Object
class_name GameInfo

const InventoryCellWidth : int = 64
const InventoryCellHeight : int = 64

enum ItemRarity {
	Abundant,
	Common,
	Rare,
	Epic,
	Ancient
}

enum ItemType {
	General,
	Weapon,
	Defense,
	Ranged,
	Body,
	Arm,
	Legs,
}

enum AttackType {
	Light,
	Heavy,
	Charged
}

enum ModifierType {
	Oneshot,
	Timed,
	Recurring
}

enum ModifierOperation {
	Add,
	Multiply
}

enum ModifierStackingRule {
	Unique,
	Additive,
	Highest
}

## CAUTION: Does not denote if Modifier stacks based on it's rule in this Space, but rather if it's value is stacked in what space this value is stacked
enum ModifierStackingSpace {
	Local,
	Global
}

enum ModifierFalloffTarget {
	None,
	Stat,
	Duration
}

# TODO: Add more effects
enum StatType {
	Health,
	MaxHealth,
	Stamina,
	MaxStamina,
	Speed,
	ComboScore,
	ComboDecay
}

enum HitState {
	Accepted,
	Blocked,
	Parried,
	Invalid
}

enum InteractionState {
	Accepted,
	Failed,
	Invalid,
	NoTarget
}
