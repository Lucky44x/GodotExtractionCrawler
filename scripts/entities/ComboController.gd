extends Node
class_name ComboController

var last_executed_profile: AttackProfile = null
var next_light_attack: AttackProfile = null
var next_heavy_attack: AttackProfile = null

var main_light_attack: AttackProfile = null
var main_heavy_attack: AttackProfile = null

func initialize_weapon_combos(lightAttack: AttackProfile, heavyAttack: AttackProfile):
	main_light_attack = lightAttack
	next_light_attack = lightAttack
	main_heavy_attack = heavyAttack
	next_heavy_attack = heavyAttack

func set_last_executed(profile: AttackProfile):
	last_executed_profile = profile
	next_light_attack = last_executed_profile.next_light_attacks.pick_random()
	if next_light_attack == null:
		next_light_attack = main_light_attack
	
	next_heavy_attack = last_executed_profile.next_heavy_attacks.pick_random()
	if next_heavy_attack == null:
		next_heavy_attack = main_heavy_attack

func is_heavy_attack(input_hold_time_ms: int):
	return input_hold_time_ms > next_heavy_attack.begin_charge_time_ms

func choose_next_attack(input_hold_time_ms: int) -> AttackProfile:
	var nextProfile: AttackProfile = next_light_attack
	if is_heavy_attack(input_hold_time_ms):
		nextProfile = next_heavy_attack
	
	# TODO: Link with CombatController -> OnAttackFinished instead, so that combo only increments when actually fully executed
	set_last_executed(nextProfile)
	return nextProfile
