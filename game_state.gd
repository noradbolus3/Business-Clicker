extends RefCounted
class_name GameState

const DAYS_PER_MONTH: int = 30
const REAL_SECONDS_PER_GAME_DAY: float = 5.0

const MAX_CLICK_VALUE: float = 10.0
const BOOST_MULTIPLIER: float = 10.0
const BOOST_DURATION_DAYS: float = 3.0

var cash: float = 0.0
var total_earned: float = 0.0

var click_value: float = 1.0
var click_level: int = 1

var game_day: int = 1
var game_month: int = 1
var day_timer: float = 0.0

var boost_active: bool = false
var boost_days_left: float = 0.0

var total_months_completed: int = 0

var employee_count: int = 0
var manager_count: int = 0


func reset() -> void:
	cash = 0.0
	total_earned = 0.0

	click_value = 1.0
	click_level = 1

	game_day = 1
	game_month = 1
	day_timer = 0.0

	boost_active = false
	boost_days_left = 0.0

	total_months_completed = 0

	employee_count = 0
	manager_count = 0


func add_cash(amount: float) -> void:
	if amount <= 0.0:
		return

	cash += amount
	total_earned += amount


func spend_cash(amount: float) -> bool:
	if amount < 0.0:
		return false

	if cash < amount:
		return false

	cash -= amount
	return true


func get_click_amount() -> float:
	var amount: float = click_value

	if boost_active:
		amount *= BOOST_MULTIPLIER

	return amount


func upgrade_click(cost: float) -> bool:
	if click_value >= MAX_CLICK_VALUE:
		return false

	if not spend_cash(cost):
		return false

	click_level += 1

	click_value = min(
		MAX_CLICK_VALUE,
		float(click_level)
	)

	return true


func activate_boost() -> bool:
	if boost_active:
		return false

	boost_active = true
	boost_days_left = BOOST_DURATION_DAYS

	return true


func advance_real_time(delta: float) -> bool:
	day_timer += delta

	if day_timer < REAL_SECONDS_PER_GAME_DAY:
		return false

	day_timer -= REAL_SECONDS_PER_GAME_DAY
	advance_game_day()

	return true


func advance_game_day() -> void:
	game_day += 1

	if boost_active:
		boost_days_left -= 1.0

		if boost_days_left <= 0.0:
			boost_active = false
			boost_days_left = 0.0

	if game_day > DAYS_PER_MONTH:
		game_day = 1
		game_month += 1
		total_months_completed += 1


func hire_employee(cost: float) -> bool:
	if not spend_cash(cost):
		return false

	employee_count += 1
	return true


func hire_manager(cost: float) -> bool:
	if not spend_cash(cost):
		return false

	manager_count += 1
	return true


func get_employee_revenue_multiplier() -> float:
	return 1.0 + float(employee_count) * 0.025


func get_manager_expense_multiplier() -> float:
	return max(
		0.60,
		1.0 - float(manager_count) * 0.04
	)
