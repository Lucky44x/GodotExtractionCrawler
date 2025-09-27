extends Object
class_name GameInfo

enum ItemRarity {
	Abundant,
	Common,
	Rare,
	Epic,
	Ancient
}

enum ItemType {
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
