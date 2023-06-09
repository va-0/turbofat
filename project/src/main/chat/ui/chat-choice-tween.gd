extends Node
## Tweens pop-in/pop-out effects for chat choices.

## applies scale/modulate effects
var _tween: Tween

## size the chat shrinks to when it disappears
const POP_OUT_SCALE := Vector2(0.5, 0.5)

@onready var _chat_choice := get_parent()

func _ready() -> void:
	#	_reset_chat_choice()
	pass


## Makes the chat choice appear.
##
## Enlarges the chat choice in a bouncy way and makes it opaque.
func pop_in() -> void:
	# All container controls in Godot reset the scale of their children to their own scale. If we don't reassign the
	# scale before launching the tween then the rect_scale property won't be interpolated.
	_chat_choice.scale = POP_OUT_SCALE
	
	_interpolate_pop(true)


## Makes the chat choice disappear.
##
## Shrinks the chat choice in a bouncy way and makes it transparent.
func pop_out() -> void:
	_interpolate_pop(false)


func remove_all() -> void:
	_tween = Utils.kill_tween(_tween)


## Pops the chat choice in/out.
func _interpolate_pop(popping_in: bool) -> void:
	_tween = Utils.recreate_tween(self, _tween).set_parallel()
	
	var chat_choice_modulate := Color.WHITE if popping_in else Color.TRANSPARENT
	var chat_choice_scale := Vector2.ONE if popping_in else POP_OUT_SCALE
	
	_tween.tween_property(_chat_choice, "modulate",
			chat_choice_modulate, 0.1).set_trans(Tween.TRANS_LINEAR)
	_tween.tween_property(_chat_choice, "scale:x",
			chat_choice_scale.x, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_chat_choice, "scale:y",
			chat_choice_scale.y, 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


## Presets the chat choice to a known invisible state.
##
## This doesn't use a tween. It's meant for setup/teardown steps the player should never see.
func _reset_chat_choice() -> void:
	remove_all()
	
	_chat_choice.modulate = Color.TRANSPARENT
	_chat_choice.scale = POP_OUT_SCALE
