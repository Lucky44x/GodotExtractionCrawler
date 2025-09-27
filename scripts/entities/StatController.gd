extends Node
class_name StatController

@export var StatValues: Array[float] = []
@export var TrackedStats: Array[GameInfo.StatType]
@export var CollectedStats: Array[GameInfo.StatType]

var mod_dictionary: Dictionary = {}
var cleanup_array: Array[StatModifierNode] = []

signal StatUpdated

func _ready():
	StatValues.resize(len(GameInfo.StatType))
	
	for val in GameInfo.StatType:
		if not TrackedStats.has(GameInfo.StatType.get(val)): continue
		
		var instance = Node.new()
		instance.name = str(val)
		print(instance.name)
		add_child(instance)
		instance.owner = self
		instance.unique_name_in_owner = true
		var subInstance = Node.new()
		subInstance.name = "_internal_oneshot"
		instance.add_child(subInstance)
		
		var stat_dict : Dictionary = get_modifier_stat_dict(GameInfo.StatType.get(val))
		stat_dict.set(subInstance.name, subInstance)

func SetStat(stat: GameInfo.StatType, value: float):
	if not TrackedStats.has(stat): return
	StatValues[stat] = value
	StatUpdated.emit(stat, StatValues[stat])

func GetStat(stat: GameInfo.StatType) -> float:
	if not TrackedStats.has(stat) and not CollectedStats.has(stat): return 0.0
	return StatValues[stat]

func _process(_delta: float):
	for idx in len(StatValues):
		var stat: GameInfo.StatType = idx as GameInfo.StatType
		if CollectedStats.has(stat): continue
		update_tracked_stat(stat)
	
	for stat in CollectedStats:
		update_stat_modifier_nodes(stat)
	
	handle_cleanup()

func update_tracked_stat(stat: GameInfo.StatType):
	StatValues[stat] += collect_stat_modifier_values(stat)
	StatUpdated.emit(stat, StatValues[stat])

func rebuild_tracked_stat(stat: GameInfo.StatType):
	StatValues[stat] = collect_stat_modifier_values(stat)
	StatUpdated.emit(stat, StatValues[stat])

func handle_cleanup():
	var dict: Dictionary = {}
	for node: StatModifierNode in cleanup_array:
		if CollectedStats.has(node.modifier_data.target_stat):
			# Modifier targets collected stat, so rebuild is in order
			dict.set(node.modifier_data.target_stat, null)
		node.Destroy()
	
	cleanup_array.clear()
	for stat in dict.keys():
		rebuild_tracked_stat(stat)

func update_stat_modifier_nodes(stat: GameInfo.StatType):
	# Get the root node for this stat
	var root_node = get_node("%" + GameInfo.StatType.keys()[stat])
	
	for sub_node in root_node.get_children():
		if sub_node.get_child_count() == 0: continue
		
		var mod_idx: int = 0
		var mod_node: StatModifierNode = sub_node.get_child(0)
		while mod_node != null:
			mod_node.update()
			mod_idx += 1
			if sub_node.get_child_count() == mod_idx: break
			mod_node = sub_node.get_child(mod_idx)
			
			if mod_node.should_die: cleanup_array.append(mod_node)

func collect_stat_modifier_values(stat: GameInfo.StatType) -> float:
	# Get the root node for this stat
	var root_node = get_node("%" + GameInfo.StatType.keys()[stat])
	var collected_stat_value_addition: float = 0.0
	var collected_stat_value_multiplication: float = 1.0
	
	for sub_node in root_node.get_children():
		if sub_node.get_child_count() == 0: continue
		
		var collected_mod_value: float = 0.0
		var highest_node_tier: int = 0
		var mod_node_idx: int = 0
		var mod_node: StatModifierNode = sub_node.get_child(0)
		
		var mod_operation: GameInfo.ModifierOperation = mod_node.operation()
		if mod_operation == GameInfo.ModifierOperation.Multiply: collected_mod_value = 1.0
		
		while mod_node_idx < sub_node.get_child_count():
			mod_node = sub_node.get_child(mod_node_idx)
			var node_value: float = mod_node.sample(self)
			var node_tier: int = mod_node.modifier_data.modifier_tier
			
			if node_tier > highest_node_tier: highest_node_tier = node_tier
			if mod_node.stacking() == GameInfo.ModifierStackingRule.Highest:
				if node_tier < highest_node_tier:
					mod_node_idx += 1
					if mod_node_idx >= sub_node.get_child_count(): break
					continue
				var idx_int = mod_node_idx
				while idx_int < sub_node.get_child_count():
					var int_node: StatModifierNode = sub_node.get_child(idx_int)
					if int_node.is_oneshot():
						idx_int += 1
						continue
					if highest_node_tier < int_node.modifier_data.modifier_tier:
						highest_node_tier = int_node.modifier_data.modifier_tier
						break
					idx_int += 1
					continue
				if highest_node_tier > node_tier:
					if mod_node_idx >= sub_node.get_child_count(): break
					continue
			
			if mod_operation == GameInfo.ModifierOperation.Multiply: collected_mod_value *= node_value
			else: collected_mod_value += node_value
			if mod_node.should_die: cleanup_array.append(mod_node)
			mod_node_idx += 1
			if mod_node_idx >= sub_node.get_child_count(): break
		
		# Add modifier value to the temporary stat-values
		if mod_operation == GameInfo.ModifierOperation.Add: collected_stat_value_addition += collected_mod_value
		else: collected_stat_value_multiplication *= collected_mod_value
	
	# Obey the rule first addition, then multiplication... should make for better results
	var final_value: float = collected_stat_value_addition * collected_stat_value_multiplication
	return final_value

func add_stat_modifier(new_modifier: StatModifier) -> StatModifierNode:
	# First, get the collection for this modifier
	var collection_node = find_modifier_node(new_modifier)
	# Check unique case:
	if new_modifier.modifier_stacking_rule == GameInfo.ModifierStackingRule.Unique:
		if collection_node.get_child_count() > 0:	# Already present, check and apply constraints
			var mod_node: StatModifierNode = collection_node.get_child(0)
			if new_modifier.modifier_tier > mod_node.modifier_data.modifier_tier:
				mod_node.setup(new_modifier)	# We don't need to bother with deleting this node, since we can just reset it
			elif new_modifier.modifier_tier == mod_node.modifier_data.modifier_tier:
				mod_node.start_time = Time.get_ticks_msec()		# Reset the elapsed time BUT NOT the time since last application, since that could lead to frame time triggering
		return
	
	# If not unique, buisness as usual
	var newInstance = $ModifierPool.pop_instance()
	newInstance.setup(new_modifier)
	newInstance.reparent(collection_node)
	
	if CollectedStats.has(new_modifier.target_stat): rebuild_tracked_stat(new_modifier.target_stat)
	return newInstance

func get_modifier_stat_dict(stat: GameInfo.StatType) -> Dictionary:
	return mod_dictionary.get_or_add(stat, {})

func find_modifier_node(new_modifier: StatModifier) -> Node:
	var mod_id_name: String = "_internal_oneshot"
	if new_modifier.modifier_type != GameInfo.ModifierType.Oneshot:
		mod_id_name = str(new_modifier.modifier_id)
	
	var stat_dictionary = get_modifier_stat_dict(new_modifier.target_stat)
	var cachedNode = stat_dictionary.get(mod_id_name)
	if cachedNode != null:
		return cachedNode
	
	# Check if directory already exists
	var mod_stat_node: Node = get_node("%" + str(GameInfo.StatType.keys()[new_modifier.target_stat]))
	var mod_id_node: Node = mod_stat_node.find_child(mod_id_name, false)
	if mod_id_node == null:
		mod_id_node = Node.new()
		mod_stat_node.add_child(mod_id_node)
		mod_id_node.name = mod_id_name
		# If the Modifier Collection does not exist, create it under it's Stat collection
	
	stat_dictionary.set(mod_id_name, mod_id_node)
	return mod_id_node

func rebuild_mod_dict():
	pass # TODO: rebuild the ENTIRE mod dictionary to allow for lazy clearing during save or othewise
