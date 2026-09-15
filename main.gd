extends Control


const SAVE_PATH: String = "user://business_clicker_save_v3.json"


var state: GameState
var businesses: BusinessManager
var company: CompanyManager
var progression: Progression
var save_manager: SaveManager
var ui: UIManager


func _ready() -> void:

	state = GameState.new()
	businesses = BusinessManager.new()
	company = CompanyManager.new()
	progression = Progression.new()
	save_manager = SaveManager.new()
	ui = UIManager.new()

	var callbacks: Dictionary = {
		"earn": _on_earn_pressed,
		"upgrade_click": _on_upgrade_click_pressed,
		"boost": _on_boost_pressed,
		"employee": _on_employee_pressed,
		"manager": _on_manager_pressed,
		"business": _on_business_pressed,
		"company": _on_company_pressed
	}

	ui.build(
		self,
		callbacks
	)

	_load_game()

	businesses.set_company_multiplier(
		company.get_revenue_multiplier()
	)

	businesses.recalculate(
		state.employee_count,
		state.manager_count
	)

	_check_progression()

	_refresh_ui()

	set_process(true)


func _process(delta: float) -> void:

	if state.advance_real_time(delta):

		businesses.set_company_multiplier(
			company.get_revenue_multiplier()
		)

		businesses.recalculate(
			state.employee_count,
			state.manager_count
		)

		_pay_monthly_profit()

		_check_progression()

		_save_game()

		_refresh_ui()


func _on_earn_pressed() -> void:

	var amount: float = state.get_click_amount()

	state.add_cash(
		amount
	)

	_check_progression()

	_refresh_ui()


func _on_upgrade_click_pressed() -> void:

	var cost: float = _get_click_upgrade_cost(
		state.click_level
	)

	if state.upgrade_click(cost):

		ui.set_status(
			"Click upgraded successfully."
		)

		_check_progression()
		_save_game()
		_refresh_ui()

	else:

		ui.set_status(
			"Not enough cash or click is already maxed."
		)


func _on_boost_pressed() -> void:

	if state.activate_boost():

		ui.set_status(
			"10X boost activated for 3 game days."
		)

		_save_game()
		_refresh_ui()

	else:

		ui.set_status(
			"Boost is already active."
		)


func _on_employee_pressed() -> void:

	var cost: float = (
		1000.0 +
		float(state.employee_count) * 750.0
	)

	if state.hire_employee(cost):

		businesses.recalculate(
			state.employee_count,
			state.manager_count
		)

		ui.set_status(
			"Employee hired."
		)

		_check_progression()
		_save_game()
		_refresh_ui()

	else:

		ui.set_status(
			"Not enough cash to hire an employee."
		)


func _on_manager_pressed() -> void:

	var cost: float = (
		5000.0 +
		float(state.manager_count) * 3000.0
	)

	if state.hire_manager(cost):

		businesses.recalculate(
			state.employee_count,
			state.manager_count
		)

		ui.set_status(
			"Manager hired."
		)

		_check_progression()
		_save_game()
		_refresh_ui()

	else:

		ui.set_status(
			"Not enough cash to hire a manager."
		)


func _on_business_pressed(
	index: int
) -> void:

	if not businesses.is_valid_business(index):
		return

	if businesses.is_unlocked(index):

		var cost: float = businesses.get_upgrade_cost(
			index
		)

		if businesses.upgrade_business(
			index,
			state.cash
		):

			state.spend_cash(
				cost
			)

			businesses.recalculate(
				state.employee_count,
				state.manager_count
			)

			ui.set_status(
				"%s upgraded." % businesses.get_business_name(index)
			)

			_check_progression()
			_save_game()
			_refresh_ui()

		else:

			ui.set_status(
				"Not enough cash to upgrade this business."
			)

		return


	var unlock_cost: float = businesses.get_unlock_cost(
		index
	)

	if state.cash < unlock_cost:

		ui.set_status(
			"Not enough cash to unlock this business."
		)

		return


	if businesses.unlock_business(
		index
	):

		state.spend_cash(
			unlock_cost
		)

		businesses.recalculate(
			state.employee_count,
			state.manager_count
		)

		ui.set_status(
			"%s unlocked." % businesses.get_business_name(index)
		)

		_check_progression()
		_save_game()
		_refresh_ui()

	else:

		ui.set_status(
			"Business could not be unlocked."
		)


func _on_company_pressed() -> void:

	if company.is_active():

		var result: Dictionary = company.upgrade_company(
			state.cash
		)

		if not bool(result["success"]):

			ui.set_status(
				str(result["message"])
			)

			return

		var cost: float = float(
			result["cost"]
		)

		if not state.spend_cash(cost):

			ui.set_status(
				"Not enough cash."
			)

			return

		businesses.set_company_multiplier(
			company.get_revenue_multiplier()
		)

		businesses.recalculate(
			state.employee_count,
			state.manager_count
		)

		ui.set_status(
			"Company upgraded to Level %d." % company.get_level()
		)

		_check_progression()
		_save_game()
		_refresh_ui()

		return


	var check: Dictionary = company.can_form_company(
		businesses.get_owned_count(),
		state.cash
	)

	if not bool(check["success"]):

		ui.set_status(
			str(check["message"])
		)

		return


	if not state.spend_cash(
		CompanyManager.COMPANY_UNLOCK_COST
	):

		ui.set_status(
			"Not enough cash."
		)

		return


	var form_result: Dictionary = company.form_company(
		businesses.get_owned_count(),
		state.cash + CompanyManager.COMPANY_UNLOCK_COST
	)

	if not bool(form_result["success"]):

		state.add_cash(
			CompanyManager.COMPANY_UNLOCK_COST
		)

		ui.set_status(
			str(form_result["message"])
		)

		return


	businesses.set_company_multiplier(
		company.get_revenue_multiplier()
	)

	businesses.recalculate(
		state.employee_count,
		state.manager_count
	)

	ui.set_status(
		"Company founded successfully."
	)

	_check_progression()
	_save_game()
	_refresh_ui()


func _pay_monthly_profit() -> void:

	var profit: float = businesses.get_total_profit()

	if profit <= 0.0:
		return

	state.add_cash(
		profit
	)

	ui.set_status(
		"Month completed. Profit received: $%s" % _money(profit)
	)


func _check_progression() -> void:

	var reward: float = progression.check_mission(
		state,
		businesses,
		company
	)

	if reward > 0.0:

		state.add_cash(
			reward
		)

		ui.set_status(
			"Mission completed! Reward: $%s" % _money(reward)
		)


	var achievement_reward: float = progression.check_achievements(
		state,
		businesses,
		company
	)

	if achievement_reward > 0.0:

		state.add_cash(
			achievement_reward
		)

		ui.set_status(
			"Achievement unlocked! Reward: $%s" % _money(achievement_reward)
		)


func _refresh_ui() -> void:

	ui.refresh(
		state,
		businesses,
		company,
		progression
	)


func _save_game() -> void:

	var data: Dictionary = {
		"state": {
			"cash": state.cash,
			"total_earned": state.total_earned,
			"click_value": state.click_value,
			"click_level": state.click_level,
			"game_day": state.game_day,
			"game_month": state.game_month,
			"day_timer": state.day_timer,
			"boost_active": state.boost_active,
			"boost_days_left": state.boost_days_left,
			"total_months_completed": state.total_months_completed,
			"employee_count": state.employee_count,
			"manager_count": state.manager_count
		},
		"businesses": businesses.get_save_data(),
		"company": company.get_save_data(),
		"progression": progression.get_save_data()
	}

	save_manager.save_game(
		SAVE_PATH,
		data
	)


func _load_game() -> void:

	var data: Dictionary = save_manager.load_game(
		SAVE_PATH
	)

	if data.is_empty():
		return


	var state_data: Dictionary = data.get(
		"state",
		{}
	)

	state.cash = float(
		state_data.get(
			"cash",
			0.0
		)
	)

	state.total_earned = float(
		state_data.get(
			"total_earned",
			0.0
		)
	)

	state.click_value = float(
		state_data.get(
			"click_value",
			1.0
		)
	)

	state.click_level = int(
		state_data.get(
			"click_level",
			1
		)
	)

	state.game_day = int(
		state_data.get(
			"game_day",
			1
		)
	)

	state.game_month = int(
		state_data.get(
			"game_month",
			1
		)
	)

	state.day_timer = float(
		state_data.get(
			"day_timer",
			0.0
		)
	)

	state.boost_active = bool(
		state_data.get(
			"boost_active",
			false
		)
	)

	state.boost_days_left = float(
		state_data.get(
			"boost_days_left",
			0.0
		)
	)

	state.total_months_completed = int(
		state_data.get(
			"total_months_completed",
			0
		)
	)

	state.employee_count = int(
		state_data.get(
			"employee_count",
			0
		)
	)

	state.manager_count = int(
		state_data.get(
			"manager_count",
			0
		)
	)


	var business_data: Dictionary = data.get(
		"businesses",
		{}
	)

	businesses.load_save_data(
		business_data
	)


	var company_data: Dictionary = data.get(
		"company",
		{}
	)

	company.load_save_data(
		company_data
	)


	var progression_data: Dictionary = data.get(
		"progression",
		{}
	)

	progression.load_save_data(
		progression_data
	)


func _get_click_upgrade_cost(
	level: int
) -> float:

	var costs: Array[float] = [
		1.0,
		5.0,
		15.0,
		35.0,
		75.0,
		150.0,
		300.0,
		600.0,
		1200.0
	]

	var index: int = level - 1

	if index < 0:
		return costs[0]

	if index >= costs.size():
		return costs[costs.size() - 1]

	return costs[index]


func _money(
	value: float
) -> String:

	if value >= 1000000000.0:
		return "%.2fB" % (
			value / 1000000000.0
		)

	if value >= 1000000.0:
		return "%.2fM" % (
			value / 1000000.0
		)

	if value >= 1000.0:
		return "%.0f" % value

	return "%.2f" % value
