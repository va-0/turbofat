extends Button
## This button changes its font dynamically based on the amount of text it needs to display. It chooses the largest
## font which will not overrun its boundaries.

## extra space needed on the left and right of the button's text
const PADDING := 6

## Different fonts to try. Should be ordered from largest to smallest.
@export var fonts: Array[Font]: set = set_fonts

func _ready() -> void:
	SystemData.misc_settings.locale_changed.connect(_on_MiscSettings_locale_changed)
	pick_largest_font()


func set_fonts(new_fonts: Array) -> void:
	fonts = new_fonts
	pick_largest_font()


## Sets the button's font to the largest font which will accommodate its text.
##
## If the button's text is modified this should be called manually. This class cannot respond to text changes or
## override set_text because of Godot #29390 (https://github.com/godotengine/godot/issues/29390)
func pick_largest_font() -> void:
	# our shown text is translated; the translated text needs to fit in the button
	var shown_text := tr(text)
	
	var chosen_font: Font
	for i in range(fonts.size()):
		# start with the largest font, and try smaller and smaller fonts
		chosen_font = fonts[i]
		var string_width := chosen_font.get_string_size(shown_text).x
		if string_width < size.x - 2 * PADDING:
			# this font is small enough to accommodate all of the text
			break
	
	set("theme_override_fonts/font", chosen_font)


func _on_MiscSettings_locale_changed(_value: String) -> void:
	pick_largest_font()
