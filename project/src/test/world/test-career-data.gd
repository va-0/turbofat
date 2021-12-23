extends "res://addons/gut/test.gd"

const TEMP_PLAYER_FILENAME := "test997.save"

var _data: CareerData

func before_each() -> void:
	_data = CareerData.new()
	
	CareerLevelLibrary.worlds_path = "res://assets/test/ui/level-select/career-worlds-simple.json"
	PlayerSave.data_filename = "user://%s" % TEMP_PLAYER_FILENAME
	PlayerData.reset()

func test_prev_daily_earnings() -> void:
	for i in range(10, 100):
		_data.daily_earnings = i
		_data.advance_calendar()
	
	assert_eq(_data.prev_daily_earnings.size(), CareerData.MAX_DAILY_HISTORY)
	assert_eq(99, _data.prev_daily_earnings[0])
	assert_eq(60, _data.prev_daily_earnings[CareerData.MAX_DAILY_HISTORY - 1])


func test_advance_clock_stops_at_boss_level_0() -> void:
	_data.advance_clock(50, false)
	assert_eq(_data.distance_earned, 50)
	assert_eq(_data.distance_travelled, 9)


func test_advance_clock_stops_at_boss_level_1() -> void:
	_data.distance_travelled = 8 # just before a boss level
	_data.advance_clock(3, true)
	assert_eq(_data.distance_earned, 3)
	assert_eq(_data.distance_travelled, 9)


## The player skips one boss level, but gets stopped by the next boss level
func test_advance_clock_skips_boss_level() -> void:
	PlayerData.career.max_distance_travelled = 10 # they've only cleared the first boss level
	_data.advance_clock(50, false)
	assert_eq(_data.distance_earned, 50)
	assert_eq(_data.distance_travelled, 19)


func test_advance_clock_clears_boss_level() -> void:
	_data.distance_travelled = 9 # boss level
	_data.advance_clock(4, true)
	assert_eq(_data.distance_earned, 4)
	assert_eq(_data.distance_travelled, 13)


func test_advance_clock_fails_boss_level() -> void:
	_data.distance_travelled = 9 # boss level
	_data.advance_clock(4, false)
	assert_true(_data.distance_earned < 0,
			"distance_earned should be less than 0 but was %s" % [_data.distance_earned])
	assert_true(_data.distance_travelled < 9,
			"distance_travelled should be less than 9 but was %s" % [_data.distance_travelled])


func test_distance_penalties_short() -> void:
	_data.distance_earned = 0
	assert_eq(_data.distance_penalties(), [0, 0, 0])
	
	_data.distance_earned = 1
	assert_eq(_data.distance_penalties(), [0, 0, 0])
	
	_data.distance_earned = 2
	assert_eq(_data.distance_penalties(), [1, 1, 0])


func test_distance_penalties_medium() -> void:
	_data.distance_earned = 3
	assert_eq(_data.distance_penalties(), [2, 1, 0])
	
	_data.distance_earned = 5
	assert_eq(_data.distance_penalties(), [2, 1, 0])
	
	_data.distance_earned = 6
	assert_eq(_data.distance_penalties(), [3, 2, 0])
	
	_data.distance_earned = 7
	assert_eq(_data.distance_penalties(), [4, 2, 0])


func test_distance_penalties_long() -> void:
	_data.distance_earned = 10
	assert_eq(_data.distance_penalties(), [4, 2, 0])
	
	_data.distance_earned = 15
	assert_eq(_data.distance_penalties(), [4, 2, 0])
	
	_data.distance_earned = 25
	assert_eq(_data.distance_penalties(), [4, 2, 0])


func test_distance_penalties_negative() -> void:
	_data.distance_earned = -1
	assert_eq(_data.distance_penalties(), [1, 0, 0])

	_data.distance_earned = -10
	assert_eq(_data.distance_penalties(), [1, 0, 0])


func test_distance_penalties_boss_level() -> void:
	_data.advance_clock(50, false)
	assert_eq(_data.distance_penalties(), [0, 0, 0])
