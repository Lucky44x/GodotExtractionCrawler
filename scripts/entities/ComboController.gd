extends Node
class_name ComboController

const _db: Database = preload("res://dbs/combat.gddb")

@export var combat_controller: CombatController
@export var equipment_controller: EquipmentController

var _current_stance: StanceProfile
var _current_stance_id: StringName
var _current_attack: AttackProfile

func _ready():
	combat_controller.OnAttackFinished.connect(_on_finish_attack)

func intialize_state():
	if equipment_controller == null: return
	var main_weapon: WeaponData = equipment_controller.get_main_weapon()
	if main_weapon == null or main_weapon.initial_stance.is_empty(): return
	_set_stance(main_weapon.initial_stance)

func _set_stance(stance_id: StringName):
	if !_db._has_string_id(&"stance_profiles", stance_id):
		push_error("Could not find stance with id ", stance_id, " try reloading the project?")
		return
	_current_stance = _db.fetch_data(&"stance_profiles", stance_id)
	_current_stance_id = stance_id
	combat_controller.EnterStance(_current_stance.stance_animation)

func _on_finish_attack(prof: AttackProfile):
	if prof != _current_attack: return
	if prof.next_stance == _current_stance_id: return
	_set_stance(prof.next_stance)

func choose_next_attack(is_heavy: bool) -> AttackProfile:
	if is_heavy: return choose_next_heavy_attack()
	return choose_next_light_attack()

func choose_next_light_attack() -> AttackProfile:
	if _current_stance == null: return null
	if _current_stance.next_light_attacks.size() == 0: return null
	
	var nextID: StringName = _current_stance.next_light_attacks.pick_random()
	if not _db._has_string_id(&"attack_profiles", nextID):
		push_error("Attack with ID: ", nextID, " was not found")
		return null
	
	_current_attack = _db.fetch_data(&"attack_profiles", nextID)
	return _current_attack

func choose_next_heavy_attack() -> AttackProfile:
	if _current_stance == null: return null
	if _current_stance.next_heavy_attacks.size() == 0: return null
	
	var nextID: StringName = _current_stance.next_heavy_attacks.pick_random()
	if not _db._has_string_id(&"attack_profiles", nextID):
		push_error("Attack with ID: ", nextID, " was not found")
		return null
	
	_current_attack = _db.fetch_data(&"attack_profiles", nextID)
	return _current_attack
