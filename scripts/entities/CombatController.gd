extends Node
class_name CombatController

@export var combat_animator: AnimationTree
@export var parry_window: int

# Animator
var animation_sm: AnimationNodeStateMachinePlayback

# Attacking state
var active_weapon: Weapon

# Blocking state
var blocking_since: int = -1

# Hitscan
var hitscan_active: bool = false
var hitscan_hits: Array[Node3D] = []

# State related signals
## Gets called when an attack animation has finished
## Sig: function()
signal OnAttackFinished
## Gets called when any animation has finished
## Sig: function(animation_id: [String])
signal OnAnimationFinished

# Attack related Signals
## Gets called when an incoming attack has passed in status-effect changes
## Sig: function(stat_type: [enum GameInfo.StatType], value: [float])
signal OnStatChangeRecieved
## Gets called when an incoming attack was just parried
signal OnIncomingAttackParried
## Gets called when an incoming attack was just blocked
signal OnIncomingAttackBlocked
## Gets called when an outgoing attack was just blocked
signal OnOutgoingAttackParried
## Gets called when an outgoing attack was just parried
signal OnOutgoingAttackBlocked

func _ready():
	animation_sm = combat_animator["parameters/playback"]

# Exposed and used by attacking combat-controller
func IsBlocked() -> bool:
	return blocking_since > -1
func IsParried() -> bool:
	if blocking_since <= -1: return false							# Better safe than sorry
	return Time.get_ticks_msec() - blocking_since < parry_window	# Parried, when time since block started fits into the parry-window

# Block functions
func StartBlocking():
	animation_sm.travel("blocking")

func EndBlocking():
	animation_sm.travel("block_exit")

# Attack functions
func StartLightAttack(weapon: Weapon):
	animation_sm.travel("attack_light")

## Applies the given value to a given stat
func ApplyStatChange(type: GameInfo.StatType, value: float):
	OnStatChangeRecieved.emit(type, value)

## Applies a given time to a given effect
func ApplyEffect():
	pass

## Internal and used by animator for blocking
func internal_begin_blocking():
	blocking_since = Time.get_ticks_msec()
## Internal and used by animator for blocking
func internal_end_blocking():
	blocking_since = -1

## Internal and used by animator for hitscanning
func internal_begin_hitscan():
	hitscan_active = true
## Internal and used by animator for hitscanning
func internal_end_hitscan():
	hitscan_active = false
