extends TextureRect
## Chalkboard which displays the player's score and progress during a puzzle.

func _ready() -> void:
	CurrentLevel.changed.connect(_on_Level_settings_changed)
	_refresh()


func _refresh() -> void:
	visible = not CurrentLevel.is_tutorial()


func _on_Level_settings_changed() -> void:
	_refresh()
