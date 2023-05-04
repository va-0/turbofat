extends Control
## Shows/hides the money label after a puzzle.

## Duration of the pop-in/pop-out animation
const TWEEN_DURATION := 0.1

## Path to the label which shows the total each customer paid. The money label responds to these totals.
@export var results_label_path: NodePath

@onready var _money_label := $MoneyLabel
@onready var _money_label_tween: Tween
@onready var _results_label: ResultsLabel = get_node(results_label_path)

func _ready() -> void:
	PuzzleState.game_prepared.connect(_on_PuzzleState_game_prepared)
	PuzzleState.after_game_ended.connect(_on_PuzzleState_after_game_ended)
	_results_label.text_shown.connect(_on_ResultsLabel_text_shown)


## Shows the money label, decrementing it so that it does not include the current customer totals.
##
## The money label is later incremented in response to 'text_shown' signals, so that it increments as customers are
## shown.
func _show_money(rank_result: RankResult) -> void:
	_money_label.set_shown_money(PlayerData.money - rank_result.score)
	_money_label_tween = Utils.recreate_tween(self, _money_label_tween)
	_money_label_tween.tween_property(_money_label, "position:y", 0.0, TWEEN_DURATION)


## Hides the money label.
func _hide_money() -> void:
	_money_label_tween = Utils.recreate_tween(self, _money_label_tween)
	_money_label_tween.tween_property(_money_label, "position:y", -32.0, TWEEN_DURATION)


func _on_PuzzleState_game_prepared() -> void:
	_hide_money()


func _on_PuzzleState_after_game_ended() -> void:
	var rank_result: RankResult = PlayerData.level_history.get_prev_result(CurrentLevel.settings.id)
	if not rank_result or CurrentLevel.settings.rank.skip_results:
		return
	
	_show_money(rank_result)


func _on_ResultsLabel_text_shown(new_text: String) -> void:
	if new_text.begins_with(tr("Customer #%s") % [""]):
		var amount := int(StringUtils.substring_after_last(new_text, "¥").replace(",", ""))
		_money_label.set_shown_money(_money_label.shown_money + amount)
