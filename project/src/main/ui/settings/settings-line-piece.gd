extends Control
## UI control for enabling line pieces to all levels

onready var _check_box := $CheckBox

func _ready() -> void:
	SystemData.gameplay_settings.connect("line_piece_changed", self, "_on_GameplaySettings_line_piece_changed")
	_refresh()


func _refresh() -> void:
	_check_box.pressed = SystemData.gameplay_settings.line_piece


func _on_CheckBox_toggled(_button_pressed: bool) -> void:
	SystemData.gameplay_settings.line_piece = _check_box.pressed


func _on_GameplaySettings_line_piece_changed(_value: bool) -> void:
	_refresh()
