@tool
extends Node
class_name AttackController

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
@export var animation_tree: AnimationTree

# Attack
@export var currentProfile: AttackProfile
var _hit_modifiers: Array[StatModifier]

# Hitscan
@onready var hitzone_pool = $HitzonePool
@export var active_scan_zones: Array[bool] = []
var hitzone_instances: Array[HitzoneInstance] = []
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
	
	if currentProfile != null && len(active_scan_zones) != len(currentProfile.colliders): _setup_hitscan_states(currentProfile)
	
	if currentProfile != null:
		# Hitscan
		_perform_hitsweep()
		
		# Debug draw
		for coll in currentProfile.colliders:
			_render_debug_gizmos(coll)

#region Debug Editor Functionallity

func _render_debug_gizmos(coll: HitscanCollider):
	var idx: int = currentProfile.colliders.find(coll)
	if coll == null:
		DebugDraw3D.draw_text(hitscan_root.global_position, "COLLIDER NULL " + str(currentProfile.colliders.find(coll)), 128)
		return
	if coll.Shape == null:
		DebugDraw3D.draw_text(hitscan_root.global_position, "SHAPE NULL " + str(currentProfile.colliders.find(coll)), 128)
		return
	
	var color = Color.RED
	if active_scan_zones[idx]:
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
func BeginAttack(profile: AttackProfile, weapon: WeaponData = null):
	currentProfile = profile
	# Setup Hitscanning
	_clear_hitzones()
	_setup_hitzones(currentProfile)
	
	# Collect appropriate modifiers:
	_hit_modifiers.clear()
	_hit_modifiers.append_array(profile.hit_effects)
	if weapon != null: _hit_modifiers.append_array(weapon.hit_modifiers)
	
	animation_tree.tree_root.get_node("AttackAnimation").animation = currentProfile.animation
	animation_tree["parameters/Oneshot_LightAttack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	pass

func AbortAttack() -> bool:
	if not interrupt_allowed: return false
	animation_tree["parameters/Oneshot_LightAttack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	active_scan_zones.fill(false)
	hitscan_hits.clear()
	
	return true

func internal_attack_end(animation_name: String):
	if animation_name != currentProfile.animation: return
	hitscan_hits.clear()
	OnAttackFinished.emit(currentProfile)

#endregion

#region Hitzone Management
func _resolve_hits(hits: Array[Node3D]):
	if hits == null or len(hits) <= 0: return
	for hit in hits:
		var hit_controller: HitController = hit.find_child("HitController")
		if hit_controller == null: continue
		var result: HitResult = hit_controller.transmit_hit(_hit_modifiers, currentProfile.parry_timing)
		## TODO: Handl result -> Hit-Parry -Block and -Land signals

func _perform_hitsweep():
	var final_new_hits: Array[Node3D] = []
	var idx = 0
	for active in active_scan_zones:
		idx += 1
		if not active: continue
		var hits = _perform_hitscan(currentProfile.colliders[idx-1])
		final_new_hits.append_array(hits)
	
	_resolve_hits(final_new_hits)

func _perform_hitscan(coll: HitscanCollider) -> Array[Node3D]:
	if Engine.is_editor_hint(): return [] # Early return if in editor
	
	var idx = currentProfile.colliders.find(coll)
	# Check if existing and enabled
	if coll == null or coll.Shape == null: return []
	# Check if zone is active
	if not active_scan_zones[idx]: return []
	
	var ret: Array[Node3D] = []
	var rawHits = hitzone_instances[idx].GetHitInstances()
	for node in rawHits:
		if hitscan_hits.has(node): continue # Ignore previously hit targets
		ret.append(node)
		hitscan_hits.append(node)
	return ret

func _setup_hitscan_states(prof: AttackProfile):
	active_scan_zones.clear()
	active_scan_zones.resize(len(prof.colliders))
	active_scan_zones.fill(false)

func _setup_hitzones(profile: AttackProfile):
	_setup_hitscan_states(profile) #Idk why I'm referring back to this function instead of inlining it, but whatever, it works...
	for coll in profile.colliders:
		_setup_hitzone(coll)

func _setup_hitzone(hitscan_collider: HitscanCollider):
	var instance: HitzoneInstance = hitzone_pool.pop_instance()
	instance.SetupHitzone(hitscan_root, hitscan_collider)
	hitzone_instances.append(instance)

func _clear_hitzones():
	for inst in hitzone_instances:
		inst.Destroy()
	hitzone_instances.clear()

#endregion

#region other Animation
func EnterStance(animation: String):
	animation_tree.tree_root.get_node("StanceAnimation").animation = animation
#endregion

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
