extends Control

const SAVE_PATH := "user://business_clicker_save.json"

# =========================================================
# GAME STATE
# =========================================================

var cash: float = 0.0
var total_earned: float = 0.0

var selected_business: int = 0

var tap_value: float = 10.0
var passive_income: float = 0.0

var upgrade_level: int = 0
var manager_level: int = 0
var employee_count: int = 0

var salary_expense: float = 0.0

var unlocked_businesses: Array = [true, false, false]
var business_levels: Array = [1, 0, 0]
var business_income: Array = [0.0, 0.0, 0.0]

var mission_index: int = 0
var missions_completed: int = 0

var achievement_earned: Array = [false, false, false, false, false]

var last_save_time: int = 0


# =========================================================
# BUSINESS DATA
# =========================================================

var business_names: Array = [
	"Retail Shop",
	"Car Wash",
	"Coffee Shop"
]

var business_unlock_costs: Array = [
	0.0,
	10000.0,
	50000.0
]

var business_base_income: Array = [
	2.0,
	35.0,
	150.0
]


# =========================================================
# MISSION DATA
# =========================================================

var mission_names: Array = [
	"Earn your first ₹1,000",
	"Reach ₹10,000 total revenue",
	"Own 2 businesses",
	"Hire 5 employees",
	"Reach ₹100,000 total revenue"
]

var mission_targets: Array = [
	1000.0,
	10000.0,
	2.0,
	5.0,
	100000.0
]

var mission_rewards: Array = [
	500.0,
	2500.0,
	5000.0,
	10000.0,
	50000.0
]


# =========================================================
# UI
# =========================================================

var cash_label: Label
var income_label: Label
var expense_label: Label
var business_label: Label
var status_label: Label

var earn_button: Button
var upgrade_button: Button
var manager_button: Button
var employee_button: Button

var retail_button: Button
var carwash_button: Button
var coffee_button: Button

var mission_label: Label
var achievement_label: Label
var stats_label: Label


# =========================================================
# START
# =========================================================

func _ready() -> void:

	_build_ui()
	_load_game()
	_recalculate_income()
	_refresh_ui()


# =========================================================
# GAME LOOP
# =========================================================

func _process(delta: float) -> void:

	if passive_income > 0.0:

		cash += passive_income * delta
		total_earned += passive_income * delta

		_refresh_ui()

	_check_achievements()


# =========================================================
# BUILD UI
# =========================================================

func _build_ui() -> void:

	var background := ColorRect.new()

	background.color = Color("#090d18")

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	add_child(background)


	var scroll := ScrollContainer.new()

	scroll.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	add_child(scroll)


	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		24
	)

	margin.add_theme_constant_override(
		"margin_right",
		24
	)

	margin.add_theme_constant_override(
		"margin_top",
		30
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		30
	)

	margin.custom_minimum_size.x = 672

	scroll.add_child(margin)


	var main := VBoxContainer.new()

	main.add_theme_constant_override(
		"separation",
		16
	)

	margin.add_child(main)


	# =====================================================
	# HEADER
	# =====================================================

	var title := Label.new()

	title.text = "BUSINESS CLICKER"

	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	title.add_theme_font_size_override(
		"font_size",
		30
	)

	main.add_child(title)


	var subtitle := Label.new()

	subtitle.text = "START SMALL • BUILD BIG • OWN EVERYTHING"

	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	subtitle.add_theme_font_size_override(
		"font_size",
		14
	)

	main.add_child(subtitle)


	# =====================================================
	# MONEY
	# =====================================================

	cash_label = Label.new()

	cash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	cash_label.add_theme_font_size_override(
		"font_size",
		48
	)

	main.add_child(cash_label)


	income_label = Label.new()

	income_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	income_label.add_theme_font_size_override(
		"font_size",
		19
	)

	main.add_child(income_label)


	expense_label = Label.new()

	expense_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	expense_label.add_theme_font_size_override(
		"font_size",
		17
	)

	main.add_child(expense_label)


	# =====================================================
	# CURRENT BUSINESS
	# =====================================================

	business_label = Label.new()

	business_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	business_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	business_label.add_theme_font_size_override(
		"font_size",
		22
	)

	main.add_child(business_label)


	# =====================================================
	# EARN
	# =====================================================

	earn_button = Button.new()

	earn_button.custom_minimum_size = Vector2(
		0,
		220
	)

	earn_button.add_theme_font_size_override(
		"font_size",
		32
	)

	earn_button.pressed.connect(
		_on_earn_pressed
	)

	main.add_child(earn_button)


	status_label = Label.new()

	status_label.text = (
		"Your business journey starts here."
	)

	status_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	status_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	main.add_child(status_label)


	# =====================================================
	# UPGRADES
	# =====================================================

	var upgrades_title := Label.new()

	upgrades_title.text = "UPGRADES & MANAGEMENT"

	upgrades_title.add_theme_font_size_override(
		"font_size",
		24
	)

	main.add_child(upgrades_title)


	upgrade_button = Button.new()

	upgrade_button.custom_minimum_size.y = 75

	upgrade_button.pressed.connect(
		_buy_upgrade
	)

	main.add_child(upgrade_button)


	manager_button = Button.new()

	manager_button.custom_minimum_size.y = 75

	manager_button.pressed.connect(
		_hire_manager
	)

	main.add_child(manager_button)


	employee_button = Button.new()

	employee_button.custom_minimum_size.y = 75

	employee_button.pressed.connect(
		_hire_employee
	)

	main.add_child(employee_button)


	# =====================================================
	# BUSINESSES
	# =====================================================

	var businesses_title := Label.new()

	businesses_title.text = "BUSINESSES"

	businesses_title.add_theme_font_size_override(
		"font_size",
		24
	)

	main.add_child(businesses_title)


	retail_button = Button.new()

	retail_button.custom_minimum_size.y = 75

	retail_button.pressed.connect(
		_select_retail
	)

	main.add_child(retail_button)


	carwash_button = Button.new()

	carwash_button.custom_minimum_size.y = 75

	carwash_button.pressed.connect(
		_select_carwash
	)

	main.add_child(carwash_button)


	coffee_button = Button.new()

	coffee_button.custom_minimum_size.y = 75

	coffee_button.pressed.connect(
		_select_coffee
	)

	main.add_child(coffee_button)


	# =====================================================
	# MISSIONS
	# =====================================================

	var missions_title := Label.new()

	missions_title.text = "MISSIONS"

	missions_title.add_theme_font_size_override(
		"font_size",
		24
	)

	main.add_child(missions_title)


	mission_label = Label.new()

	mission_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	mission_label.add_theme_font_size_override(
		"font_size",
		19
	)

	main.add_child(mission_label)


	# =====================================================
	# ACHIEVEMENTS
	# =====================================================

	var achievements_title := Label.new()

	achievements_title.text = "ACHIEVEMENTS"

	achievements_title.add_theme_font_size_override(
		"font_size",
		24
	)

	main.add_child(achievements_title)


	achievement_label = Label.new()

	achievement_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	achievement_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main.add_child(achievement_label)


	# =====================================================
	# COMPANY STATS
	# =====================================================

	var stats_title := Label.new()

	stats_title.text = "COMPANY STATS"

	stats_title.add_theme_font_size_override(
		"font_size",
		24
	)

	main.add_child(stats_title)


	stats_label = Label.new()

	stats_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	stats_label.add_theme_font_size_override(
		"font_size",
		19
	)

	main.add_child(stats_label)


	# =====================================================
	# SAVE
	# =====================================================

	var save_button := Button.new()

	save_button.text = "SAVE GAME"

	save_button.custom_minimum_size.y = 62

	save_button.pressed.connect(
		_save_game
	)

	main.add_child(save_button)


# =========================================================
# EARN
# =========================================================

func _on_earn_pressed() -> void:

	cash += tap_value

	total_earned += tap_value

	status_label.text = (
		"Revenue received!"
	)

	_refresh_ui()

	_check_achievements()


# =========================================================
# BUSINESS UPGRADE
# =========================================================

func _buy_upgrade() -> void:

	var cost := _upgrade_cost()

	if cash < cost:

		status_label.text = (
			"Not enough cash for upgrade."
		)

		return


	cash -= cost

	upgrade_level += 1

	tap_value = (
		10.0 *
		pow(1.55, upgrade_level)
	)

	# Upgrade selected business too.

	business_levels[selected_business] += 1

	status_label.text = (
		"%s upgraded to Level %d!"
		% [
			business_names[selected_business],
			business_levels[selected_business]
		]
	)

	_recalculate_income()

	_refresh_ui()

	_save_game()


# =========================================================
# MANAGER
# =========================================================

func _hire_manager() -> void:

	var cost := _manager_cost()

	if cash < cost:

		status_label.text = (
			"Not enough cash for manager."
		)

		return


	cash -= cost

	manager_level += 1

	status_label.text = (
		"Manager hired!"
	)

	_recalculate_income()

	_refresh_ui()

	_save_game()


# =========================================================
# EMPLOYEE
# =========================================================

func _hire_employee() -> void:

	var cost := _employee_cost()

	if cash < cost:

		status_label.text = (
			"Not enough cash to hire employee."
		)

		return


	cash -= cost

	employee_count += 1

	status_label.text = (
		"Employee hired. Monthly salary added."
	)

	_recalculate_income()

	_refresh_ui()

	_save_game()

	_check_achievements()


# =========================================================
# EMPLOYEE COST
# =========================================================

func _employee_cost() -> float:

	return (
		500.0 *
		pow(1.45, employee_count)
	)


# =========================================================
# EMPLOYEE SALARY
# =========================================================

func _employee_salary() -> float:

	return (
		25.0 *
		float(employee_count)
	)


# =========================================================
# UPGRADE COST
# =========================================================

func _upgrade_cost() -> float:

	return (
		100.0 *
		pow(1.7, upgrade_level)
	)


# =========================================================
# MANAGER COST
# =========================================================

func _manager_cost() -> float:

	return (
		750.0 *
		pow(1.85, manager_level)
	)


# =========================================================
# BUSINESS SELECTORS
# =========================================================

func _select_retail() -> void:

	_select_business(0)


func _select_carwash() -> void:

	_select_business(1)


func _select_coffee() -> void:

	_select_business(2)


func _select_business(index: int) -> void:

	if not unlocked_businesses[index]:

		var cost: float = (
			business_unlock_costs[index]
		)

		if cash < cost:

			status_label.text = (
				"Need ₹%s to unlock %s."
				% [
					_money(cost),
					business_names[index]
				]
			)

			return


		cash -= cost

		unlocked_businesses[index] = true

		business_levels[index] = 1

		selected_business = index

		status_label.text = (
			"%s joined your company!"
			% business_names[index]
		)

		_recalculate_income()

		_refresh_ui()

		_save_game()

		_check_achievements()

		return


	selected_business = index

	status_label.text = (
		"Operating %s."
		% business_names[index]
	)

	_refresh_ui()


# =========================================================
# INCOME
# =========================================================

func _recalculate_income() -> void:

	passive_income = 0.0

	for i in range(
		business_names.size()
	):

		if unlocked_businesses[i]:

			var level: int = (
				business_levels[i]
			)

			var income: float = (
				business_base_income[i] *
				float(level)
			)

			business_income[i] = income

			passive_income += income


	# Managers increase business efficiency.

	if manager_level > 0:

		passive_income *= (
			1.0 +
			(float(manager_level) * 0.25)
		)


	# Employees add operational capacity.

	passive_income += (
		float(employee_count) *
		5.0
	)


	# Employee salaries are expenses.

	salary_expense = (
		_employee_salary()
	)


# =========================================================
# MISSIONS
# =========================================================

func _mission_progress() -> float:

	if mission_index >= mission_targets.size():

		return 0.0


	match mission_index:

		0:
			return total_earned

		1:
			return total_earned

		2:
			return float(_business_count())

		3:
			return float(employee_count)

		4:
			return total_earned


	return 0.0


func _check_mission() -> void:

	if mission_index >= mission_targets.size():

		return


	var progress := _mission_progress()

	var target: float = (
		mission_targets[mission_index]
	)


	if progress >= target:

		var reward: float = (
			mission_rewards[mission_index]
		)

		cash += reward

		missions_completed += 1

		status_label.text = (
			"MISSION COMPLETE! +₹%s"
			% _money(reward)
		)

		mission_index += 1

		_save_game()


# =========================================================
# ACHIEVEMENTS
# =========================================================

func _check_achievements() -> void:

	# Achievement 1: First money

	if not achievement_earned[0] and total_earned >= 100.0:

		achievement_earned[0] = true

		cash += 100.0

		status_label.text = (
			"ACHIEVEMENT: First Revenue! +₹100"
		)


	# Achievement 2: ₹10K

	if not achievement_earned[1] and total_earned >= 10000.0:

		achievement_earned[1] = true

		cash += 1000.0

		status_label.text = (
			"ACHIEVEMENT: Rising Entrepreneur! +₹1K"
		)


	# Achievement 3: Two businesses

	if not achievement_earned[2] and _business_count() >= 2:

		achievement_earned[2] = true

		cash += 2500.0

		status_label.text = (
			"ACHIEVEMENT: Business Owner! +₹2.5K"
		)


	# Achievement 4: Five employees

	if not achievement_earned[3] and employee_count >= 5:

		achievement_earned[3] = true

		cash += 5000.0

		status_label.text = (
			"ACHIEVEMENT: Team Builder! +₹5K"
		)


	# Achievement 5: ₹100K

	if not achievement_earned[4] and total_earned >= 100000.0:

		achievement_earned[4] = true

		cash += 10000.0

		status_label.text = (
			"ACHIEVEMENT: Entrepreneur! +₹10K"
		)


	_check_mission()

	_refresh_ui()


# =========================================================
# BUSINESS COUNT
# =========================================================

func _business_count() -> int:

	var count := 0

	for unlocked in unlocked_businesses:

		if unlocked:

			count += 1

	return count


# =========================================================
# UI REFRESH
# =========================================================

func _refresh_ui() -> void:

	if cash_label == null:

		return


	cash_label.text = (
		"₹%s"
		% _money(cash)
	)


	income_label.text = (
		"Income: ₹%s / sec"
		% _money(passive_income)
	)


	expense_label.text = (
		"Operating salaries: ₹%s / sec"
		% _money(salary_expense)
	)


	business_label.text = (
		"CURRENT BUSINESS\n%s\nLEVEL %d"
		% [
			business_names[selected_business],
			business_levels[selected_business]
		]
	)


	earn_button.text = (
		"EARN CASH\n+₹%s"
		% _money(tap_value)
	)


	upgrade_button.text = (
		"UPGRADE %s\nLEVEL %d  •  ₹%s"
		% [
			business_names[selected_business],
			business_levels[selected_business] + 1,
			_money(_upgrade_cost())
		]
	)


	manager_button.text = (
		"HIRE MANAGER\n"
		+ "Managers: %d  •  Cost ₹%s"
		% [
			manager_level,
			_money(_manager_cost())
		]
	)


	employee_button.text = (
		"HIRE EMPLOYEE\n"
		+ "Employees: %d  •  Cost ₹%s"
		% [
			employee_count,
			_money(_employee_cost())
		]
	)


	# =====================================================
	# BUSINESS BUTTONS
	# =====================================================

	if unlocked_businesses[0]:

		retail_button.text = (
			"RETAIL SHOP\n"
			+ "LEVEL %d  •  ₹%s/sec"
			% [
				business_levels[0],
				_money(business_income[0])
			]
		)

	else:

		retail_button.text = (
			"RETAIL SHOP\nLOCKED"
		)


	if unlocked_businesses[1]:

		carwash_button.text = (
			"CAR WASH\n"
			+ "LEVEL %d  •  ₹%s/sec"
			% [
				business_levels[1],
				_money(business_income[1])
			]
		)

	else:

		carwash_button.text = (
			"CAR WASH\n"
			+ "UNLOCK ₹%s"
			% _money(
				business_unlock_costs[1]
			)
		)


	if unlocked_businesses[2]:

		coffee_button.text = (
			"COFFEE SHOP\n"
			+ "LEVEL %d  •  ₹%s/sec"
			% [
				business_levels[2],
				_money(business_income[2])
			]
		)

	else:

		coffee_button.text = (
			"COFFEE SHOP\n"
			+ "UNLOCK ₹%s"
			% _money(
				business_unlock_costs[2]
			)
		)


	# =====================================================
	# MISSION
	# =====================================================

	if mission_index < mission_names.size():

		var progress := _mission_progress()

		var target: float = (
			mission_targets[mission_index]
		)

		mission_label.text = (
			"MISSION %d\n%s\nProgress: %s / %s\nReward: ₹%s"
			% [
				mission_index + 1,
				mission_names[mission_index],
				_money(progress),
				_money(target),
				_money(
					mission_rewards[mission_index]
				)
			]
		)

	else:

		mission_label.text = (
			"ALL MISSIONS COMPLETED!\n"
			+ "You are building a business empire."
		)


	# =====================================================
	# ACHIEVEMENTS
	# =====================================================

	achievement_label.text = (
		"%s First Revenue — ₹100 reward\n"
		+ "%s Rising Entrepreneur — ₹1K reward\n"
		+ "%s Business Owner — ₹2.5K reward\n"
		+ "%s Team Builder — ₹5K reward\n"
		+ "%s Entrepreneur — ₹10K reward"
		% [
			_achievement_mark(0),
			_achievement_mark(1),
			_achievement_mark(2),
			_achievement_mark(3),
			_achievement_mark(4)
		]
	)


	# =====================================================
	# STATS
	# =====================================================

	stats_label.text = (
		"Businesses: %d / %d\n"
		+ "Employees: %d\n"
		+ "Managers: %d\n"
		+ "Business upgrades: %d\n"
		+ "Missions completed: %d\n"
		+ "Total revenue: ₹%s\n"
		+ "Cash: ₹%s"
		% [
			_business_count(),
			business_names.size(),
			employee_count,
			manager_level,
			upgrade_level,
			missions_completed,
			_money(total_earned),
			_money(cash)
		]
	)


# =========================================================
# ACHIEVEMENT MARK
# =========================================================

func _achievement_mark(index: int) -> String:

	if achievement_earned[index]:

		return "[DONE]"

	return "[LOCKED]"


# =========================================================
# MONEY FORMAT
# =========================================================

func _money(value: float) -> String:

	if value >= 10000000.0:

		return "%.2fCr" % (
			value / 10000000.0
		)


	if value >= 100000.0:

		return "%.2fL" % (
			value / 100000.0
		)


	if value >= 1000.0:

		return "%.1fK" % (
			value / 1000.0
		)


	return "%.0f" % value


# =========================================================
# SAVE
# =========================================================

func _save_game() -> void:

	var data := {

		"cash": cash,

		"total_earned": total_earned,

		"selected_business": selected_business,

		"tap_value": tap_value,

		"upgrade_level": upgrade_level,

		"manager_level": manager_level,

		"employee_count": employee_count,

		"unlocked_businesses":
			unlocked_businesses,

		"business_levels":
			business_levels,

		"mission_index":
			mission_index,

		"missions_completed":
			missions_completed,

		"achievement_earned":
			achievement_earned,

		"last_save_time":
			Time.get_unix_time_from_system()
	}


	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)


	if file:

		file.store_string(
			JSON.stringify(data)
		)

		if status_label != null:

			status_label.text = (
				"Game saved successfully."
			)


# =========================================================
# LOAD
# =========================================================

func _load_game() -> void:

	if not FileAccess.file_exists(
		SAVE_PATH
	):

		return


	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)


	if file == null:

		return


	var parsed = JSON.parse_string(
		file.get_as_text()
	)


	if typeof(parsed) != TYPE_DICTIONARY:

		return


	cash = float(
		parsed.get(
			"cash",
			0.0
		)
	)


	total_earned = float(
		parsed.get(
			"total_earned",
			0.0
		)
	)


	selected_business = int(
		parsed.get(
			"selected_business",
			0
		)
	)


	tap_value = float(
		parsed.get(
			"tap_value",
			10.0
		)
	)


	upgrade_level = int(
		parsed.get(
			"upgrade_level",
			0
		)
	)


	manager_level = int(
		parsed.get(
			"manager_level",
			0
		)
	)


	employee_count = int(
		parsed.get(
			"employee_count",
			0
		)
	)


	var saved_businesses = parsed.get(
		"unlocked_businesses",
		[true, false, false]
	)


	var saved_levels = parsed.get(
		"business_levels",
		[1, 0, 0]
	)


	var saved_achievements = parsed.get(
		"achievement_earned",
		[false, false, false, false, false]
	)


	if saved_businesses is Array:

		unlocked_businesses = saved_businesses


	if saved_levels is Array:

		business_levels = saved_levels


	if saved_achievements is Array:

		achievement_earned = saved_achievements


	mission_index = int(
		parsed.get(
			"mission_index",
			0
		)
	)


	missions_completed = int(
		parsed.get(
			"missions_completed",
			0
		)
	)


	last_save_time = int(
		parsed.get(
			"last_save_time",
			Time.get_unix_time_from_system()
		)
	)


	# =====================================================
	# OFFLINE EARNINGS
	# =====================================================

	var now := int(
		Time.get_unix_time_from_system()
	)


	var elapsed := clamp(
		now - last_save_time,
		0,
		8 * 60 * 60
	)


	_recalculate_income()


	if passive_income > 0.0 and elapsed > 5:

		var offline := (
			passive_income *
			float(elapsed)
		)


		cash += offline

		total_earned += offline

		status_label.text = (
			"Welcome back!\nOffline earnings: ₹%s"
			% _money(offline)
		)


# =========================================================
# CLOSE
# =========================================================

func _notification(what: int) -> void:

	if what == NOTIFICATION_WM_CLOSE_REQUEST:

		_save_game()

		get_tree().quit()
