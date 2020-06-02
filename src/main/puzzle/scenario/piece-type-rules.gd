class_name PieceTypeRules
"""
Pieces the player is given.
"""

# pieces to prepend to the piece queue before a game begins. these pieces are shuffled
var start_types: Array = []

# piece types to choose from. if empty, reverts to the default 8 types (jlopqtuv)
var types: Array = []

func from_json_string_array(json: Array) -> void:
	var json_types: Dictionary = {
		"piece-j": PieceTypes.piece_j,
		"piece-l": PieceTypes.piece_l,
		"piece-o": PieceTypes.piece_o,
		"piece-p": PieceTypes.piece_p,
		"piece-q": PieceTypes.piece_q,
		"piece-t": PieceTypes.piece_t,
		"piece-u": PieceTypes.piece_u,
		"piece-v": PieceTypes.piece_v,
	}
	
	var rules := RuleParser.new(json)
	for key in json_types:
		if rules.has(key): types.append(json_types[key])
		if rules.has("start-%s" % key): start_types.append(json_types[key])
