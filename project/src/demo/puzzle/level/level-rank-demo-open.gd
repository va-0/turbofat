extends HBoxContainer
## UI input for specifying the level to open

## Level to open
## Virtual property; value is only exposed through getters/setters
var value: String: get = get_value, set = set_value

func set_value(new_value: String) -> void:
	$LineEdit.text = new_value


func get_value() -> String:
	return $LineEdit.text
