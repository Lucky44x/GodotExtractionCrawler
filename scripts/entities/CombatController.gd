@tool
extends Node
class_name CombatController

# Base State
var interrupt_allowed: bool = true
@export var hitscan_root: Node3D
@export var parry_window: int
@export var animator: AnimationPlayer

# Attacking state
var selected_profile: AttackProfile
var current_profile_selection: Array[AttackProfile]
var began_current_charge: int
var current_charge_tier: int
var current_charge_time: int

# Blocking state
var blocking_since: int = -1

# Hitscan
@export var active_scan_zones: Array[bool] = []
var hitscan_hits: Array[Node3D] = []

@export_category("DEBUG")
@export var debugProfile: AttackProfile
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

## TODO: Stop debug code from running in actual build
func _process(_delta: float):
	if not Engine.is_editor_hint():
		internal_charge_tick()
		return
	
	if debugProfile != null && len(active_scan_zones) != len(debugProfile.colliders): internal_set_profile(debugProfile)
	
	if debugProfile != null:
		for coll in debugProfile.colliders:
			if coll == null:
				DebugDraw3D.draw_text(hitscan_root.global_position, "COLLIDER NULL " + str(debugProfile.colliders.find(coll)), 128)
				continue
			if coll.Shape == null:
				DebugDraw3D.draw_text(hitscan_root.global_position, "SHAPE NULL " + str(debugProfile.colliders.find(coll)), 128)
				continue
			
			var color = Color.RED
			if active_scan_zones[debugProfile.colliders.find(coll)]:
				if interrupt_allowed: color = Color.GREEN
				else: color = Color.SLATE_GRAY
			elif not interrupt_allowed: color = Color.SALMON
			
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

func internal_set_profile(prof: AttackProfile):
	active_scan_zones.clear()
	active_scan_zones.resize(len(prof.colliders))
	active_scan_zones.fill(false)

#region Debug Editor Functionallity
func debug_perform_attack_profile():
	if not Engine.is_editor_hint(): return
	if debugProfile == null:
		DebugDraw3D.draw_text(hitscan_root.global_position + Vector3.UP * 2, "No debugProfile set", 64, Color.RED, 5)
		return
	if not animator.has_animation(debugProfile.animation):
		DebugDraw3D.draw_text(hitscan_root.global_position + Vector3.UP * 2, "Animation " + debugProfile.animation + " not found", 64, Color.RED, 5)
		return
	
	if debugProfile.attack_type == GameInfo.AttackType.Light:
		animator.play(debugProfile.animation)
	else: debug_perform_heavy_attack(debugProfile)

func debug_perform_heavy_attack(attackProfile: AttackProfile):
	if attackProfile.attack_type == GameInfo.AttackType.Light: return
	animator.play(debugProfile.charging_entry_animation)
	animator.queue(debugProfile.animation)
#endregion

#region Attacking

func BeginCharge(profile_selection: Array[AttackProfile]):
	internal_set_profile(debugProfile)
	current_profile_selection = profile_selection
	began_current_charge = Time.get_ticks_msec()

func internal_charge_tick():
	if current_profile_selection == null: return
	var elapsed: int = Time.get_ticks_msec() - began_current_charge
	
	var foundProfile: AttackProfile = null
	for profile in current_profile_selection:
		# Filter out light attacks, as they are not charged at all
		# If no other profile selected, selected light attack as default selection
		if profile.attack_type == GameInfo.AttackType.Light:
			if foundProfile == null: foundProfile = profile
			continue
		
		# Loop over charge tiers to determine highest charge_tier
		for tier in profile.charging_tiers:
			if tier.Required_Time_ms > elapsed:
				# Any checks at tiers beyond here would be waste resources
				break
			var tmp_tier: int = profile.charging_tiers.find(tier)
			if tier.Required_Time_ms > current_charge_time: # When charge tier found that meets time requirements and takes more "effort" than current tier, select it
				foundProfile = profile
				current_charge_tier = tmp_tier
				current_charge_time = tier.Required_Time_ms
	
	selected_profile = foundProfile		# Set selected profile to found profile

func CommenceAttack():
	BeginAttack(selected_profile, current_charge_tier)

func BeginAttack(profile: AttackProfile, charge_tier: int = 0):
	pass

func AbortAttack() -> bool:
	if interrupt_allowed:
		pass
	
	return interrupt_allowed

#endregion

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

# Locks the interrupt, committing the player to the animation and not allowing breaking out of it
func internal_lock_interrupt():
	interrupt_allowed = false

# Unlocks the interrupt, allowing the player to cancel out of the attack animation
func internal_unlock_interrupt():
	interrupt_allowed = true

# DEBUG
