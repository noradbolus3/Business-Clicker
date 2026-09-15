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
	"business_upgrade": _upgrade_selected_business,
	"company": _on_company_pressed
}

	ui.build(
		self,
		callbacks
	)

	_load_game()
	_recalculate_businesses()
	_check_progression()
	_refresh_ui()


func _process(delta: float) -> void:

	var previous_months: int = state.total_months_completed

	var advanced: bool = state.advance_real_time(delta)

	if not advanced:
		return

	_recalculate_businesses()

	if state.total_months_completed > previous_months:
		_pay_monthly_profit()
		_check_progression()
		_save_game()

	_refresh_ui()


# =========================================================
# EARN
# =========================================================

func _on_earn_pressed() -> void:

	var amount: float = state.get_click_amount()

	state.add_cash(
		amount
	)

	ui.set_status(
		"Revenue received: +$%s" % _money(amount)
	)

	_check_progression()
	_save_game()
	_refresh_ui()


# =========================================================
# CLICK UPGRADE
# =========================================================

func _on_upgrade_click_pressed() -> void:

	if state.click_value >= GameState.MAX_CLICK_VALUE:

		ui.set_status(
			"Clicker is already maxed at $10 per click."
		)

		return

	var cost: float = _get_click_upgrade_cost(
		state.click_level
	)

	if not state.upgrade_click(cost):

		ui.set_status(
			"Need $%s for the next click upgrade." %
			_money(cost)
		)

		return

	ui.set_status(
		"Click power increased to $%s per click." %
		_money(state.click_value)
	)

	_check_progression()
	_save_game()
	_refresh_ui()


# =========================================================
# BOOST
# =========================================================

func _on_boost_pressed() -> void:

	if not state.activate_boost():

		ui.set_status(
			"10X Boost is already active."
		)

		return

	ui.set_status(
		"10X BOOST ACTIVATED for 3 game days."
	)

	_save_game()
	_refresh_ui()


# =========================================================
# EMPLOYEE
# =========================================================

func _on_employee_pressed() -> void:

	var cost: float = (
		1000.0 +
		float(state.employee_count) * 750.0
	)

	if not state.hire_employee(cost):

		ui.set_status(
			"Need $%s to hire an employee." %
			_money(cost)
		)

		return

	_recalculate_businesses()

	ui.set_status(
		"Employee hired. Employees: %d." %
		state.employee_count
	)

	_check_progression()
	_save_game()
	_refresh_ui()


# =========================================================
# MANAGER
# =========================================================

func _on_manager_pressed() -> void:

	var cost: float = (
		5000.0 +
		float(state.manager_count) * 3000.0
	)

	if not state.hire_manager(cost):

		ui.set_status(
			"Need $%s to hire a manager." %
			_money(cost)
		)

		return

	_recalculate_businesses()

	ui.set_status(
		"Manager hired. Managers: %d." %
		state.manager_count
	)

	_check_progression()
	_save_game()
	_refresh_ui()


# =========================================================
# BUSINESS SELECT / UNLOCK
# =========================================================

func _on_business_pressed(
	index: int
) -> void:

	if not businesses.is_valid_business(index):
		return


	if businesses.is_unlocked(index):

		var selected: bool = businesses.select_business(
			index
		)

		if selected:

			ui.set_status(
				"Operating %s." %
				businesses.get_business_name(index)
			)

			_refresh_ui()

		return


	var unlock_cost: float = businesses.get_unlock_cost(
		index
	)

	if state.cash < unlock_cost:

		ui.set_status(
			"Need $%s to unlock %s." % [
				_money(unlock_cost),
				businesses.get_business_name(index)
			]
		)

		return


	var result: Dictionary = businesses.unlock_business(
		index,
		state.cash
	)

	if not bool(result.get("success", false)):

		ui.set_status(
			str(result.get("message", "Unable to unlock business."))
		)

		return


	var actual_cost: float = float(
		result.get("cost", 0.0)
	)

	if not state.spend_cash(actual_cost):

		ui.set_status(
			"Transaction failed."
		)

		return


	_recalculate_businesses()

	ui.set_status(
		"%s unlocked!" %
		businesses.get_business_name(index)
	)

	_check_progression()
	_save_game()
	_refresh_ui()


# =========================================================
# COMPANY
# =========================================================

func _on_company_pressed() -> void:

	# -------------------------------------------------------
	# COMPANY ALREADY ACTIVE
	# -------------------------------------------------------

	if company.is_active():

		var upgrade_result: Dictionary = company.upgrade_company(
			state.cash
		)

		if not bool(upgrade_result.get("success", false)):

			ui.set_status(
				str(
					upgrade_result.get(
						"message",
						"Unable to upgrade company."
					)
				)
			)

			return


		var upgrade_cost: float = float(
			upgrade_result.get("cost", 0.0)
		)

		if not state.spend_cash(upgrade_cost):

			ui.set_status(
				"Transaction failed."
			)

			return


		_recalculate_businesses()

		ui.set_status(
			"Company upgraded to Level %d." %
			company.get_level()
		)

		_check_progression()
		_save_game()
		_refresh_ui()

		return


	# -------------------------------------------------------
	# FORM COMPANY
	# -------------------------------------------------------

	var owned_businesses: int = businesses.get_owned_count()

	var check: Dictionary = company.can_form_company(
		owned_businesses,
		state.cash
	)

	if not bool(check.get("success", false)):

		ui.set_status(
			str(
				check.get(
					"message",
					"Company cannot be formed."
				)
			)
		)

		return


	var company_cost: float = float(
		check.get("cost", 0.0)
	)

	if not state.spend_cash(company_cost):

		ui.set_status(
			"Transaction failed."
		)

		return


	var form_result: Dictionary = company.form_company(
		owned_businesses,
		state.cash + company_cost
	)

	if not bool(form_result.get("success", false)):

		state.add_cash(
			company_cost
		)

		ui.set_status(
			str(
				form_result.get(
					"message",
					"Company formation failed."
				)
			)
		)

		return


	_recalculate_businesses()

	ui.set_status(
		"COMPANY FOUNDED! Corporate operations are now active."
	)

	_check_progression()
	_save_game()
	_refresh_ui()


# =========================================================
# MONTHLY PROFIT
# =========================================================

func _pay_monthly_profit() -> void:

	var profit: float = businesses.get_total_profit()

	if profit <= 0.0:

		ui.set_status(
			"Month closed. No net business profit."
		)

		return


	state.add_cash(
		profit
	)

	ui.set_status(
		"Month completed. Net profit received: +$%s" %
		_money(profit)
	)


# =========================================================
# RECALCULATE BUSINESSES
# =========================================================

func _recalculate_businesses() -> void:

	var company_multiplier: float = (
		company.get_revenue_multiplier()
	)

	businesses.set_company_multiplier(
		company_multiplier
	)

	businesses.recalculate(
		state.employee_count,
		state.manager_count,
		company_multiplier
	)


# =========================================================
# PROGRESSION
# =========================================================

func _check_progression() -> void:

	var mission_reward: float = progression.check_mission(
		state,
		businesses,
		company
	)

	if mission_reward > 0.0:

		state.add_cash(
			mission_reward
		)

		ui.set_status(
			"MISSION COMPLETED! Reward: +$%s" %
			_money(mission_reward)
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
			"ACHIEVEMENT UNLOCKED! Reward: +$%s" %
			_money(achievement_reward)
	)


# =========================================================
# UI REFRESH
# =========================================================

func _refresh_ui() -> void:

	if ui == null:
		return

	ui.refresh(
		state,
		businesses,
		company,
		progression
	)


# =========================================================
# SAVE
# =========================================================

func _save_game() -> void:

	if state == null:
		return

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


# =========================================================
# LOAD
# =========================================================

func _load_game() -> void:

	var data: Dictionary = save_manager.load_game(
		SAVE_PATH
	)

	if data.is_empty():
		return


	# -------------------------------------------------------
	# GAME STATE
	# -------------------------------------------------------

	var state_value: Variant = data.get(
		"state",
		{}
	)

	if state_value is Dictionary:

		var state_data: Dictionary = state_value


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


	# -------------------------------------------------------
	# SAFETY LIMITS
	# -------------------------------------------------------

	if state.cash < 0.0:
		state.cash = 0.0


	if state.total_earned < 0.0:
		state.total_earned = 0.0


	if state.click_value < 1.0:
		state.click_value = 1.0


	if state.click_value > GameState.MAX_CLICK_VALUE:
		state.click_value = GameState.MAX_CLICK_VALUE


	if state.click_level < 1:
		state.click_level = 1


	if state.click_level > 10:
		state.click_level = 10


	if state.game_day < 1:
		state.game_day = 1


	if state.game_day > GameState.DAYS_PER_MONTH:
		state.game_day = GameState.DAYS_PER_MONTH


	if state.game_month < 1:
		state.game_month = 1


	if state.employee_count < 0:
		state.employee_count = 0


	if state.manager_count < 0:
		state.manager_count = 0


	if state.boost_days_left <= 0.0:
		state.boost_active = false
		state.boost_days_left = 0.0


	# -------------------------------------------------------
	# BUSINESSES
	# -------------------------------------------------------

	var business_value: Variant = data.get(
		"businesses",
		{}
	)

	if business_value is Dictionary:

		businesses.load_save_data(
			business_value
		)


	# -------------------------------------------------------
	# COMPANY
	# -------------------------------------------------------

	var company_value: Variant = data.get(
		"company",
		{}
	)

	if company_value is Dictionary:

		company.load_save_data(
			company_value
		)


	# -------------------------------------------------------
	# PROGRESSION
	# -------------------------------------------------------

	var progression_value: Variant = data.get(
		"progression",
		{}
	)

	if progression_value is Dictionary:

		progression.load_save_data(
			progression_value
		)


	# Runtime timer should restart cleanly.
	state.day_timer = 0.0


# =========================================================
# CLICK UPGRADE COST
# =========================================================

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


# =========================================================
# MONEY FORMAT
# =========================================================

func _money(
	value: float
) -> String:

	if value >= 1000000000000.0:

		return "%.2fT" % (
			value / 1000000000000.0
		)


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


	return "%.0f" % value
