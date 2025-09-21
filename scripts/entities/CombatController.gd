@tool
extends Node
class_name CombatController

@export var hitscan_root: Node3D
@export var parry_window: int
@export var animator: AnimationPlayer

# Blocking state
var blocking_since: int = -1

# Hitscan
@export var active_scan_zones: Array[bool] = []
var hitscan_hits: Array[Node3D] = []

@export_category("DEBUG")
@export var profile: AttackProfile
@export_tool_button("Perform action", "Play") 
var dbgButton = debug_perform_attack_profile

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
	pass

## TODO: REMOVE -- THIS IS ENTIRELY DEBUG SPECIFIC
func _process(_delta: float):
	if profile != null && len(active_scan_zones) != len(profile.colliders): internal_set_profile(profile)
	
	if profile != null:
		for coll in profile.colliders:
			if coll == null:
				DebugDraw3D.draw_text(hitscan_root.global_position, "COLLIDER NULL " + str(profile.colliders.find(coll)), 128)
				continue
			if coll.Shape == null:
				DebugDraw3D.draw_text(hitscan_root.global_position, "SHAPE NULL " + str(profile.colliders.find(coll)), 128)
				continue
			
			var color = Color.RED
			if active_scan_zones[profile.colliders.find(coll)]: color = Color.GREEN
			var pos = hitscan_root.global_position + (hitscan_root.global_basis.x.normalized() * coll.Position.x) + (hitscan_root.global_basis.y.normalized() * coll.Position.y) + (hitscan_root.global_basis.z.normalized() * coll.Position.z)
			var rot = Quaternion.from_euler(hitscan_root.global_rotation + Vector3(deg_to_rad(coll.Rotation.x), deg_to_rad(coll.Rotation.y), deg_to_rad(coll.Rotation.z)))
			var up_vec = Basis.from_euler(rot.get_euler()).y
			
			if coll.Shape is BoxShape3D:
				DebugDraw3D.draw_box(pos, rot, coll.Shape.size, color, true)
			elif coll.Shape is SphereShape3D:
				DebugDraw3D.draw_sphere(pos, coll.Shape.radius, color)
			elif coll.Shape is CapsuleShape3D:
				var capOff = coll.Shape.radius
				var cylinderOff = (coll.Shape.height/2)
				var cylinderHeight = cylinderOff - capOff
				DebugDraw3D.draw_cylinder_ab(pos - up_vec * cylinderHeight, pos + up_vec * cylinderHeight, coll.Shape.radius, color)
				DebugDraw3D.draw_sphere(pos - up_vec * cylinderHeight, coll.Shape.radius, color)
				DebugDraw3D.draw_sphere(pos + up_vec * cylinderHeight, coll.Shape.radius, color)
			elif coll.Shape is CylinderShape3D:
				DebugDraw3D.draw_cylinder_ab(pos - up_vec * (coll.Shape.height/2), pos + up_vec * (coll.Shape.height/2), coll.Shape.radius, color)

func debug_perform_attack_profile():
	if not Engine.is_editor_hint(): return
	if profile == null:
		DebugDraw3D.draw_text(hitscan_root.global_position + Vector3.UP * 2, "No profile set", 64, Color.RED, 5)
		return
	if not animator.has_animation(profile.animation):
		DebugDraw3D.draw_text(hitscan_root.global_position + Vector3.UP * 2, "Animation " + profile.animation + " not found", 64, Color.RED, 5)
		return
	
	if profile.attack_type == GameInfo.AttackType.Light:
		animator.play(profile.animation)
	else: debug_perform_heavy_attack(profile)

func debug_perform_heavy_attack(attackProfile: AttackProfile):
	if attackProfile.attack_type == GameInfo.AttackType.Light: return
	animator.play(profile.charging_entry_animation)
	animator.queue(profile.animation)

func internal_set_profile(prof: AttackProfile):
	active_scan_zones.clear()
	active_scan_zones.resize(len(prof.colliders))
	active_scan_zones.fill(false)

# Exposed and used by attacking combat-controller
func IsBlocked() -> bool:
	return blocking_since > -1
func IsParried() -> bool:
	if blocking_since <= -1: return false							# Better safe than sorry
	return Time.get_ticks_msec() - blocking_since < parry_window	# Parried, when time since block started fits into the parry-window

# Block functions
func StartBlocking():
	pass

func EndBlocking():
	pass

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
func internal_begin_hitscan(zone: int):
	active_scan_zones[zone] = true
	print("Hitzone active")
## Internal and used by animator for hitscanning
func internal_end_hitscan(zone: int):
	active_scan_zones[zone] = false

# DEBUG
