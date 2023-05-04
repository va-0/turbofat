extends Control
## UI control for toggling the ghost piece.

@onready var _check_box := $CheckBox

func _ready() -> void:
	SystemData.gameplay_settings.ghost_piece_changed.connect(_on_GameplaySettings_ghost_piece_changed)
	_refresh()


func _refresh() -> void:
	_check_box.button_pressed = SystemData.gameplay_settings.ghost_piece


func _on_OptionButton_toggled(_button_pressed: bool) -> void:
	SystemData.gameplay_settings.ghost_piece = _check_box.button_pressed


func _on_GameplaySettings_ghost_piece_changed(_value: bool) -> void:
	_refresh()
