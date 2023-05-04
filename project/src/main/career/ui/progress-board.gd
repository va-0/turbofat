extends CanvasLayer
## Screen which shows the player's progress through career mode.
##
## This includes a chalkboard map showing the player's position, and a clock at the top showing the time.

signal progress_board_shown

signal progress_board_hidden

## Amount of time in seconds to wait before hiding the progress board after an animation.
const ANIMATED_HIDE_DELAY := 1.2

## Amount of time in seconds to wait before hiding the progress board when it is not being animated.
const STATIC_HIDE_DELAY := 2.0

## If 'true', the board will not hide itself. Used for demos/debugging.
@export var suppress_hide := false

## Backdrop which darkens parts of the scene behind the progress board.
@onready var _backdrop := $Backdrop

## Analog clock and digital text which appear above the progress board.
@onready var _clock := $Clock

## Timer which hides the progress board.
@onready var _hide_timer := $HideTimer

## Timer which triggers the animation of the player advancing and clock moving forward.
@onready var _animate_start_timer := $AnimateStartTimer

## Spots and lines drawn to show a trail across the progress board.
@onready var _trail := $ChalkboardRegion/Trail

## Title at the top of the progress board.
@onready var _title := $ChalkboardRegion/Title

## Player's chalk graphics on the progress board.
@onready var _player := $ChalkboardRegion/Player

## Chalk drawing of the region.
@onready var _map_holder := $ChalkboardRegion/MapHolder

## Animation player which makes the progress board 'pop in' and 'pop out' animations.
@onready var _show_animation_player := $ShowAnimationPlayer

func _ready() -> void:
	show_progress()


## Shows/animates the progress board based on the current 'CareerData.show_progress' value.
##
## Depending on the value of the CareerData.show_progress value, this method might show the progress board, animate the
## progress board, or not show it at all.
func show_progress() -> void:
	match PlayerData.career.show_progress:
		Careers.ShowProgress.NONE:
			visible = false
		_:
			visible = true
			_show_animation_player.play("show")
			refresh()


## Animate the progress board based on how far the player just travelled.
##
## This is only called internally and through demos. Call show_progress() to show and animate the progress board.
func play() -> void:
	if _show_animation_player.is_playing():
		# Animations are played automatically; don't play them twice
		#
		# This is an edge case specific to the ProgressBoardDemo
		return
	
	var new_hours_passed := _hours_passed_finish()
	var new_spots_travelled := _spots_travelled_finish()
	
	# Calculate the animation duration. If the player only travels 1 or 2 spaces, the animation is short. If the player
	# travels 25 spaces, the animation is longer, but not 25 times as long.
	var duration: float = 1.25 + 0.15 * (new_spots_travelled - _player.spots_travelled)
	duration = clamp(duration, 1.25, 10.0)
	
	# Animate the clock advancing.
	_clock.play(new_hours_passed, duration)
	
	# Animate the player advancing down the trail. If the player only moves a short distance, this animation plays
	# faster than the clock animation.
	var hop_duration: float = duration
	match new_spots_travelled - _player.spots_travelled:
		1:
			hop_duration = duration * 0.7
		2:
			hop_duration = duration * 0.9
	_player.play(new_spots_travelled, hop_duration)
	
	## After the animation, we hide the progress board after a delay.
	if not suppress_hide:
		_hide_timer.start(ANIMATED_HIDE_DELAY + duration)


## Update the progress board's graphics based on the player's career progress.
func refresh() -> void:
	# refresh region
	var region := PlayerData.career.current_region()
	_title.set_text(region.name)
	var icon_type := Utils.enum_from_snake_case(ProgressBoardTitle.IconType,
			region.icon_name, ProgressBoardTitle.NONE) as ProgressBoardTitle.IconType
	_title.set_icon_type(icon_type)
	_map_holder.set_region_id(region.id)
	_trail.path2d_path = _trail.get_path_to(_map_holder.path2d)
	
	# refresh spot_count
	var new_spot_count := region.length
	if not region.has_end():
		new_spot_count = 35
	_trail.spot_count = new_spot_count
	
	# refresh spots_truncated
	var new_spots_truncated := false
	if not region.has_end():
		new_spots_truncated = true
	_trail.spots_truncated = new_spots_truncated
	
	match PlayerData.career.show_progress:
		Careers.ShowProgress.ANIMATED:
			_player.spots_travelled = _spots_travelled_finish()
			_player.visual_spots_travelled = _spots_travelled_start()
			_player.refresh()
		_:
			_player.spots_travelled = _spots_travelled_finish()
	
	match PlayerData.career.show_progress:
		Careers.ShowProgress.ANIMATED:
			_clock.hours_passed = _hours_passed_start()
		_:
			_clock.hours_passed = _hours_passed_finish()


## Calculates the spot we should start from when moving the player.
func _spots_travelled_start() -> int:
	var region := PlayerData.career.current_region()
	var spots_travelled := PlayerData.career.progress_board_start_distance_travelled - region.start
	if not region.has_end():
		spots_travelled = int(min(spots_travelled, 5))
	spots_travelled = int(clamp(spots_travelled, 0, _trail.spot_count))
	return spots_travelled


## Calculates the spot we should end on when moving the player.
func _spots_travelled_finish() -> int:
	var region := PlayerData.career.current_region()
	var spots_travelled := PlayerData.career.distance_travelled - region.start
	if not region.has_end():
		var start_spots_travelled := PlayerData.career.progress_board_start_distance_travelled - region.start
		start_spots_travelled = int(min(start_spots_travelled, 5))
		
		spots_travelled = int(min(start_spots_travelled + PlayerData.career.distance_earned, 30))
	spots_travelled = int(clamp(spots_travelled, 0, _trail.spot_count))
	return spots_travelled


## Calculates the 'hours passed' value we should start from when advancing the clock.
func _hours_passed_start() -> int:
	return int(max(PlayerData.career.hours_passed - 1, 0))


## Calculates the 'hours passed' value we should finish on when advancing the clock.
func _hours_passed_finish() -> int:
	return PlayerData.career.hours_passed


## When the AnimationPlayer toggles the backdrop visibility, we emit signals so other parts of the UI can refresh.
func _on_Backdrop_visibility_changed() -> void:
	if not _backdrop:
		# A visibility_changed signal is emitted before this node's onready variables are initialized.
		return
	
	if _backdrop.visible:
		emit_signal("progress_board_shown")
	else:
		emit_signal("progress_board_hidden")


## When the AnimationPlayer's 'show' animation finishes, we schedule the 'hide' animation to play afterward.
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "show":
		match PlayerData.career.show_progress:
			Careers.ShowProgress.ANIMATED:
				# launch the clock and player animations after a delay
				_animate_start_timer.start()
			Careers.ShowProgress.STATIC:
				# hide the progress board after a delay
				if not suppress_hide:
					_hide_timer.start(STATIC_HIDE_DELAY)


## When the HideTimer times out, we hide the progress board.
func _on_HideTimer_timeout() -> void:
	_show_animation_player.play("hide")
	if not PlayerData.career.is_day_over():
		PlayerData.career.show_progress = Careers.ShowProgress.NONE


## When the AnimateStartTimer times out, we launch the clock and player animations.
func _on_AnimateStartTimer_timeout() -> void:
	play()
