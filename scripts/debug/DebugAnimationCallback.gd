@tool
extends Node

@export var Animator: AnimationPlayer

var current_animation: Animation
@export var track_targets: Array[Node] = []
@export var callArray: Array = []
@export var keyTimes: Array = []
@export var currentKeyFrames: Array[int] = []

var call_tracks: int = 0
var animationRunning: bool = false

func _ready():
	if Animator == null: return
	Animator.animation_started.connect(on_animation_changed)
	Animator.animation_finished.connect(on_animation_end)

func _process(_delta: float):
	if not Engine.is_editor_hint() or not animationRunning: return
	# Check collected tracks to see if animator has passed keys
	for track_idx in call_tracks:
		if currentKeyFrames[track_idx] >= len(keyTimes[track_idx]): continue
		var keyTime = keyTimes[track_idx][currentKeyFrames[track_idx]]
		if absf(keyTime - Animator.current_animation_position) <= 0.005:
			var callDict = callArray[track_idx][currentKeyFrames[track_idx]]
			track_targets[track_idx].callv(callDict["method"], callDict["args"])
			# print("passed key " + str(currentKeyFrames[track_idx]) + " on track " + str(track_idx) + "calling: ", callDict["method"], " with args: ", callDict["args"], " on node: ", track_targets[track_idx])
			currentKeyFrames[track_idx] += 1

func on_animation_end(animation: String):
	if not Engine.is_editor_hint(): return
	animationRunning = false
	
	# Finish up final keys that may not have played
	for track_idx in call_tracks:
		if currentKeyFrames[track_idx] >= len(keyTimes[track_idx]): continue	# If we are already over out key limit, we have finished up fine
		var callDict = callArray[track_idx][currentKeyFrames[track_idx]]		# If not, we need to call the last remaining key of this track
		track_targets[track_idx].callv(callDict["method"], callDict["args"])

func on_animation_changed(animation: String):
	if not Engine.is_editor_hint(): return
	
	current_animation = Animator.get_animation(animation)
	parse_keys()
	animationRunning = true

func parse_keys():
	if current_animation == null:
		push_error("Current Animation is null")
		return
	
	call_tracks = 0
	track_targets.clear()
	keyTimes.clear()
	callArray.clear()
	currentKeyFrames.clear()
	
	for track_idx in current_animation.get_track_count():
		# Collect only tracks that target method calls
		if current_animation.track_get_type(track_idx) != Animation.TrackType.TYPE_METHOD: continue
		track_targets.append(get_node(Animator.root_node).get_node(current_animation.track_get_path(track_idx)))
		
		callArray.append([])
		keyTimes.append([])
		currentKeyFrames.append(0)
		
		# Collect all keys on this track
		var keyCount = current_animation.track_get_key_count(track_idx)
		
		for key_idx in keyCount:
			keyTimes[call_tracks].append(current_animation.track_get_key_time(track_idx, key_idx))
			callArray[call_tracks].append(current_animation.track_get_key_value(track_idx, key_idx))
		
		call_tracks += 1
		# print(keyTimes)
		# print(callArray)
