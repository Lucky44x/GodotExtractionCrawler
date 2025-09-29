@tool
extends Node
class_name CombatController

# Signals
## Triggers when Attack has finished executing: Sig: OnAttackFinished(executedProfile: AttackProfile)
signal OnAttackFinished
## Triggers if Outgoing Attack was blocked while executing current Attack
signal OnOutgoingAttackBlocked
## Triggers if Outgoing Attack was blocked while executing current Attack
signal OnOutgoingAttackParried

# Base State
var interrupt_allowed: bool = true
@export var hitscan_root: Node3D
@export var parry_window: int
@export var animation_tree: AnimationTree

@export var currentProfile: AttackProfile

# Blocking state
var blocking_since: int = -1

# Hitscan
@export var active_scan_zones: Array[bool] = []
var hitscan_hits: Array[Node3D] = []

@export_category("debug")
@export var debugAnimator: AnimationPlayer

@export_tool_button("Perform action", "Play") 
var dbgButton = debug_perform_attack_profile

func _ready():
	if animation_tree == null: return
	animation_tree.animation_finished.connect(internal_attack_end)
	pass

## TODO: Stop debug code from running in actual build
func _process(_delta: float):
	if hitscan_root == null: return
	
	if currentProfile != null && len(active_scan_zones) != len(currentProfile.colliders): internal_set_profile(currentProfile)
	
	if currentProfile != null:
		for coll in currentProfile.colliders:
			if coll == null:
				DebugDraw3D.draw_text(hitscan_root.global_position, "COLLIDER NULL " + str(currentProfile.colliders.find(coll)), 128)
				continue
			if coll.Shape == null:
				DebugDraw3D.draw_text(hitscan_root.global_position, "SHAPE NULL " + str(currentProfile.colliders.find(coll)), 128)
				continue
			
			var color = Color.RED
			if active_scan_zones[currentProfile.colliders.find(coll)]:
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
	if currentProfile == null:
		DebugDraw3D.draw_text(hitscan_root.global_position + Vector3.UP * 2, "No currentProfile set", 64, Color.RED, 5)
		return
	if not debugAnimator.has_animation(currentProfile.animation):
		DebugDraw3D.draw_text(hitscan_root.global_position + Vector3.UP * 2, "Animation " + currentProfile.animation + " not found", 64, Color.RED, 5)
		return
	
	debugAnimator.play(currentProfile.animation)

#endregion

#region Attacking

func BeginAttack(profile: AttackProfile):
	currentProfile = profile
	animation_tree.tree_root.get_node("AttackAnimation").animation = currentProfile.animation
	animation_tree["parameters/Oneshot_LightAttack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	pass

func AbortAttack() -> bool:
	if interrupt_allowed:
		animation_tree["parameters/Oneshot_LightAttack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
		active_scan_zones.fill(false)
	
	return interrupt_allowed

func internal_attack_end(animation_name: String):
	if animation_name != currentProfile.animation: return
	OnAttackFinished.emit(currentProfile)

#endregion

#region other Animation
func EnterStance(animation: String):
	animation_tree.tree_root.get_node("StanceAnimation").animation = animation
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

## Internal and used by debugAnimator for blocking
func internal_begin_blocking():
	blocking_since = Time.get_ticks_msec()
## Internal and used by debugAnimator for blocking
func internal_end_blocking():
	blocking_since = -1

## Internal and used by debugAnimator for hitscanning
func internal_begin_hitscan(zone: int):
	active_scan_zones[zone] = true
	print("Hitzone active")

## Internal and used by debugAnimator for hitscanning
func internal_end_hitscan(zone: int):
	active_scan_zones[zone] = false

# Locks the interrupt, committing the player to the animation and not allowing breaking out of it
func internal_lock_interrupt():
	interrupt_allowed = false

# Unlocks the interrupt, allowing the player to cancel out of the attack animation
func internal_unlock_interrupt():
	interrupt_allowed = true

# DEBUG
