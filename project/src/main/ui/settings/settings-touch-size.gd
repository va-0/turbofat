extends Control
## UI control for adjusting the touchscreen button size.

## step values of 1.19
const VALUES := [
	0.25, 0.30, 0.35, 0.42, 0.50, 0.59, 0.71, 0.84, 1.00, 1.19, 1.42, 1.69
]

func _ready() -> void:
	$Control/HSlider.value = Utils.find_closest(VALUES, SystemData.touch_settings.size)


func _on_HSlider_value_changed(index: float) -> void:
	var value: float = VALUES[int(index)]
	$Control/Text.text = "%04.2fx" % value
	SystemData.touch_settings.size = value
