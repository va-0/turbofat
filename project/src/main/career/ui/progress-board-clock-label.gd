extends Label
## Draws the analog clock which appears above the progress board.
##
## The clock shows text like '12:30 pm', and can flash and emit particles.

## Duration in seconds that the clock should flash white.
const FLASH_DURATION := 1.5

## Default font outline color, when not flashing.
const OUTLINE_COLOR := Color("6c4331")

## Tween that handles the clock's flash effect.
@onready var _flash_tween: Tween

## Particles emitted when the clock flashes.
@onready var _particles := $Particles

## Make the clock flash white and emit particles.
##
## This is called when the text changes to get the player's attention.
func flash() -> void:
	for particles_2d_node in _particles.get_children():
		var particles_2d: GPUParticles2D = particles_2d_node
		particles_2d.restart()
		particles_2d.emitting = true
	
	set("theme_override_colors/font_outline_color", Color.WHITE)
	_flash_tween = Utils.recreate_tween(self, _flash_tween)
	_flash_tween.tween_property(self, "theme_override_colors/font_outline_color", OUTLINE_COLOR, 1.5) \
			.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
