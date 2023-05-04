extends Node2D
## Launches and stores the puzzle pieces which appear on the loading screen.

@export var orb_path: NodePath
@export var progress_bar_path: NodePath
@export var piece_scene: PackedScene

@onready var _orb: LoadingOrb = get_node(orb_path)
@onready var _progress_bar: LoadingProgressBar = get_node(progress_bar_path)

func _ready() -> void:
	_orb.frame_changed.connect(_on_Orb_frame_changed)


## When the orb advances to the next frame, we launch a puzzle piece.
func _on_Orb_frame_changed() -> void:
	var piece := piece_scene.instantiate()
	piece.initialize(_orb, _progress_bar)
	add_child(piece)
