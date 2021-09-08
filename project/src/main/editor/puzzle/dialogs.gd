extends Control
"""
Shows popup dialogs for the level editor.
"""

onready var _level_editor: LevelEditor = get_parent()

onready var _open_file_dialog := $OpenFile
onready var _open_resource_dialog := $OpenResource
onready var _save_dialog := $Save

func _show_save_load_not_supported_error() -> void:
	$Error.dialog_text = "Saving/loading files isn't supported over the web. Sorry!"
	$Error.popup_centered()


func _preserve_file_dialog_path(dialog: FileDialog) -> void:
	for other_dialog in [_open_file_dialog, _open_resource_dialog, _save_dialog]:
		other_dialog.current_file = dialog.current_file
		other_dialog.current_path = dialog.current_path


func _on_OpenResource_file_selected(path: String) -> void:
	_level_editor.load_level(path)
	_preserve_file_dialog_path(_open_resource_dialog)


func _on_OpenFile_file_selected(path: String) -> void:
	_level_editor.load_level(path)
	_preserve_file_dialog_path(_open_file_dialog)


func _on_Save_file_selected(path: String) -> void:
	_level_editor.save_level(path)
	_preserve_file_dialog_path(_save_dialog)


func _on_OpenFile_pressed() -> void:
	if OS.has_feature("web"):
		_show_save_load_not_supported_error()
		return
	
	Utils.assign_default_dialog_path(_open_file_dialog, "res://assets/main/puzzle/levels/practice/")
	_open_file_dialog.popup_centered()


func _on_OpenResource_pressed() -> void:
	_open_resource_dialog.popup_centered()
	Utils.assign_default_dialog_path(_open_resource_dialog, "res://assets/main/puzzle/levels/practice/")
	_open_resource_dialog.popup_centered()


func _on_Save_pressed() -> void:
	if OS.has_feature("web"):
		_show_save_load_not_supported_error()
		return
	
	Utils.assign_default_dialog_path(_save_dialog, "res://assets/main/puzzle/levels/practice/")
	_save_dialog.popup_centered()
	if not _save_dialog.current_file:
		# We assign a sensible filename based on the current level, like "level_512". Unfortunately, this filename is
		# replaced if a .json file is selected, which almost always happens immediately
		var raw_level_id := StringUtils.substring_after_last(_level_editor.level_id_label.text, "/")
		_save_dialog.current_file = "%s.json" % [raw_level_id]
