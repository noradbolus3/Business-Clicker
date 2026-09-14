extends Control

const SAVE_PATH := "user://business_clicker_save.json"

# =========================================================
# GAME STATE
# =========================================================

var cash: float = 0.0
var total_earned: float = 0.0

var tap_value: float = 10.0
var passive_income: float = 0.0

var upgrade_level: int = 0
var manager_level: int = 0
var employee_count: int = 0

var selected_business: int = 0

var unlocked_businesses: Array = [true, false, false]
var business_levels: Array = [1, 0, 0]
var business_income: Array = [0.0, 0.0, 0.0]

var mission_index: int = 0
var missions_completed: int = 0

var achievement_earned: Array = [
	false,
	false,
	false,
	false,
	false
]

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
# UI REFERENCES
# =========================================================

var cash_label: Label
var income_label: Label
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
# READY
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
# UI BUILD
# =========================================================

func _build_ui() -> void:

	# -------------------------------------------------------
	# BACKGROUND
	# -------------------------------------------------------

	var background := ColorRect.new()

	background.color = Color("#090d18")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)

	add_child(background)

	# -------------------------------------------------------
	# SCROLL CONTAINER
	# -------------------------------------------------------

	var scroll := ScrollContainer.new()

	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)

	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

	add_child(scroll)

	# -------------------------------------------------------
	# MAIN CONTENT
	# -------------------------------------------------------

	var main := VBoxContainer.new()

	main.custom_minimum_size = Vector2(672, 1900)

	main.add_theme_constant_override(
		"separation",
		14
	)

	scroll.add_child(main)

	# =======================================================
	# TITLE
	# =======================================================

	var title := Label.new()

	title.text = "BUSINESS CLICKER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	title.add_theme_font_size_override(
		"font_size",
		32
	)

	title.custom_minimum_size.y = 55

	main.add_child(title)

	# =======================================================
	# SUBTITLE
	# =======================================================

	var subtitle := Label.new()

	subtitle.text = "START SMALL • BUILD BIG • OWN EVERYTHING"

	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	subtitle.add_theme_font_size_override(
		"font_size",
		15
	)

	main.add_child(subtitle)

	# =======================================================
	# CASH
	# =======================================================

	cash_label = Label.new()

	cash_label.text = "₹0"

	cash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	cash_label.add_theme_font_size_override(
		"font_size",
		48
	)

	cash_label.custom_minimum_size.y = 75

	main.add_child(cash_label)

	# =======================================================
	# INCOME
	# =======================================================

	income_label = Label.new()

	income_label.text = "Passive Income: ₹2/sec"

	income_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	income_label.add_theme_font_size_override(
		"font_size",
		19
	)

	main.add_child(income_label)

	# =======================================================
	# BUSINESS
	# =======================================================

	business_label = Label.new()

	business_label.text = "🏪 Retail Shop • Level 1"

	business_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	business_label.add_theme_font_size_override(
		"font_size",
		24
	)

	business_label.custom_minimum_size.y = 55

	main.add_child(business_label)

	# =======================================================
	# EARN BUTTON
	# =======================================================

	earn_button = Button.new()

	earn_button.text = "💰 EARN MONEY\n+₹10"

	earn_button.custom_minimum_size = Vector2(0, 180)

	earn_button.add_theme_font_size_override(
		"font_size",
		30
	)

	earn_button.pressed.connect(
		_on_earn_pressed
	)

	main.add_child(earn_button)

	# =======================================================
	# STATUS
	# =======================================================

	status_label = Label.new()

	status_label.text = "Your business journey starts here."

	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	status_label.add_theme_font_size_override(
		"font_size",
		17
	)

	status_label.custom_minimum_size.y = 45

	main.add_child(status_label)

	# =======================================================
	# UPGRADES TITLE
	# =======================================================

	var upgrade_title := Label.new()

	upgrade_title.text = "UPGRADES & MANAGEMENT"

	upgrade_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(upgrade_title)

	# =======================================================
	# UPGRADE
	# =======================================================

	upgrade_button = Button.new()

	upgrade_button.custom_minimum_size.y = 75

	upgrade_button.pressed.connect(
		_buy_upgrade
	)

	main.add_child(upgrade_button)

	# =======================================================
	# MANAGER
	# =======================================================

	manager_button = Button.new()

	manager_button.custom_minimum_size.y = 75

	manager_button.pressed.connect(
		_hire_manager
	)

	main.add_child(manager_button)

	# =======================================================
	# EMPLOYEE
	# =======================================================

	employee_button = Button.new()

	employee_button.custom_minimum_size.y = 75

	employee_button.pressed.connect(
		_hire_employee
	)

	main.add_child(employee_button)

	# =======================================================
	# BUSINESSES TITLE
	# =======================================================

	var businesses_title := Label.new()

	businesses_title.text = "BUSINESSES"

	businesses_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(businesses_title)

	# =======================================================
	# RETAIL
	# =======================================================

	retail_button = Button.new()

	retail_button.custom_minimum_size.y = 75

	retail_button.pressed.connect(
		_select_retail
	)

	main.add_child(retail_button)

	# =======================================================
	# CAR WASH
	# =======================================================

	carwash_button = Button.new()

	carwash_button.custom_minimum_size.y = 75

	carwash_button.pressed.connect(
		_select_carwash
	)

	main.add_child(carwash_button)

	# =======================================================
	# COFFEE SHOP
	# =======================================================

	coffee_button = Button.new()

	coffee_button.custom_minimum_size.y = 75

	coffee_button.pressed.connect(
		_select_coffee
	)

	main.add_child(coffee_button)

	# =======================================================
	# MISSIONS
	# =======================================================

	var missions_title := Label.new()

	missions_title.text = "MISSIONS"

	missions_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(missions_title)

	mission_label = Label.new()

	mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	mission_label.add_theme_font_size_override(
		"font_size",
		18
	)

	mission_label.custom_minimum_size.y = 130

	main.add_child(mission_label)

	# =======================================================
	# ACHIEVEMENTS
	# =======================================================

	var achievements_title := Label.new()

	achievements_title.text = "ACHIEVEMENTS"

	achievements_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(achievements_title)

	achievement_label = Label.new()

	achievement_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	achievement_label.add_theme_font_size_override(
		"font_size",
		18
	)

	achievement_label.custom_minimum_size.y = 150

	main.add_child(achievement_label)

	# =======================================================
	# COMPANY STATS
	# =======================================================

	var stats_title := Label.new()

	stats_title.text = "COMPANY STATS"

	stats_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(stats_title)

	stats_label = Label.new()

	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	stats_label.add_theme_font_size_override(
		"font_size",
		18
	)

	stats_label.custom_minimum_size.y = 130

	main.add_child(stats_label)

	# =======================================================
	# SAVE
	# =======================================================

	var save_button := Button.new()

	save_button.text = "SAVE GAME"

	save_button.custom_minimum_size.y = 65

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

	status_label.text = "Revenue received! +₹%s" % _money(tap_value)

	_refresh_ui()
	_check_achievements()

# =========================================================
# UPGRADE
# =========================================================

func _buy_upgrade() -> void:

	var cost := _upgrade_cost()

	if cash < cost:

		status_label.text = "Need ₹%s for upgrade." % _money(cost)

		return

	cash -= cost

	upgrade_level += 1

	tap_value = 10.0 * pow(1.55, upgrade_level)

	business_levels[selected_business] += 1

	status_label.text = "%s upgraded to Level %d!" % [
		business_names[selected_business],
		business_levels[selected_business]
	]

	_recalculate_income()
	_refresh_ui()
	_save_game()

# =========================================================
# MANAGER
# =========================================================

func _hire_manager() -> void:

	var cost := _manager_cost()

	if cash < cost:

		status_label.text = "Need ₹%s for manager." % _money(cost)

		return

	cash -= cost

	manager_level += 1

	status_label.text = "Manager hired!"

	_recalculate_income()
	_refresh_ui()
	_save_game()

# =========================================================
# EMPLOYEE
# =========================================================

func _hire_employee() -> void:

	var cost := _employee_cost()

	if cash < cost:

		status_label.text = "Need ₹%s to hire employee." % _money(cost)

		return

	cash -= cost

	employee_count += 1

	status_label.text = "Employee hired!"

	_recalculate_income()
	_refresh_ui()
	_save_game()
	_check_achievements()

# =========================================================
# COSTS
# =========================================================

func _upgrade_cost() -> float:

	return 100.0 * pow(1.7, upgrade_level)

func _manager_cost() -> float:

	return 750.0 * pow(1.85, manager_level)

func _employee_cost() -> float:

	return 500.0 * pow(1.45, employee_count)

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

		var cost: float = business_unlock_costs[index]

		if cash < cost:

			status_label.text = "Need ₹%s to unlock %s." % [
				_money(cost),
				business_names[index]
			]

			return

		cash -= cost

		unlocked_businesses[index] = true
		business_levels[index] = 1
		selected_business = index

		status_label.text = "%s joined your company!" % business_names[index]

		_recalculate_income()
		_refresh_ui()
		_save_game()
		_check_achievements()

		return

	selected_business = index

	status_label.text = "Operating %s." % business_names[index]

	_refresh_ui()

# =========================================================
# INCOME
# =========================================================

func _recalculate_income() -> void:

	passive_income = 0.0

	for i in range(business_names.size()):

		if unlocked_businesses[i]:

			var level: int = business_levels[i]

			var income: float = (
				business_base_income[i] *
				float(level)
			)

			business_income[i] = income

			passive_income += income

	if manager_level > 0:

		passive_income *= (
			1.0 +
			float(manager_level) * 0.25
		)

	# Employees improve operations slightly.
	if employee_count > 0:

		passive_income *= (
			1.0 +
			float(employee_count) * 0.05
		)

# =========================================================
# REFRESH UI
# =========================================================

func _refresh_ui() -> void:

	if cash_label == null:
		return

	cash_label.text = "₹%s" % _money(cash)

	income_label.text = (
		"Passive Income: ₹%s / sec"
		% _money(passive_income)
	)

	business_label.text = (
		"🏢 %s • Level %d"
		% [
			business_names[selected_business],
			business_levels[selected_business]
		]
	)

	earn_button.text = (
		"💰 EARN MONEY\n+₹%s"
		% _money(tap_value)
	)

	upgrade_button.text = (
		"⬆️ Upgrade Business\nCost: ₹%s\nLevel: %d"
		% [
			_money(_upgrade_cost()),
			upgrade_level
		]
	)

	manager_button.text = (
		"👔 Hire Manager\nCost: ₹%s\nManagers: %d"
		% [
			_money(_manager_cost()),
			manager_level
		]
	)

	employee_button.text = (
		"👷 Hire Employee\nCost: ₹%s\nEmployees: %d"
		% [
			_money(_employee_cost()),
			employee_count
		]
	)

	# -------------------------------------------------------
	# BUSINESS BUTTONS
	# -------------------------------------------------------

	retail_button.text = _business_button_text(0)
	carwash_button.text = _business_button_text(1)
	coffee_button.text = _business_button_text(2)

	# -------------------------------------------------------
	# MISSION
	# -------------------------------------------------------

	if mission_index < mission_names.size():

		mission_label.text = (
			"🎯 %s\n\nTarget: %s\nReward: ₹%s"
			% [
				mission_names[mission_index],
				_money(mission_progress()),
				_money(mission_rewards[mission_index])
			]
		)

	else:

		mission_label.text = "🎯 All missions completed!"

	# -------------------------------------------------------
	# ACHIEVEMENTS
	# -------------------------------------------------------

	var achievements_text := ""

	var achievement_names: Array = [
		"First Revenue",
		"Rising Entrepreneur",
		"Business Owner",
		"Team Builder",
		"Entrepreneur"
	]

	for i in range(achievement_names.size()):

		var mark := "🏆" if achievement_earned[i] else "🔒"

		achievements_text += (
			"%s %s\n"
			% [
				mark,
				achievement_names[i]
			]
		)

	achievement_label.text = achievements_text

	# -------------------------------------------------------
	# STATS
	# -------------------------------------------------------

	var owned := 0

	for unlocked in unlocked_businesses:

		if unlocked:
			owned += 1

	var owned_count := 0

for unlocked in unlocked_businesses:

	if unlocked:
		owned_count += 1

stats_label.text = "💵 Cash: ₹%s\n📈 Total Revenue: ₹%s\n🏢 Businesses: %d / %d\n👔 Managers: %d\n👷 Employees: %d\n⬆️ Upgrade Level: %d" % [
	_money(cash),
	_money(total_earned),
	owned_count,
	business_names.size(),
	manager_level,
	employee_count,
	upgrade_level
]
	

# =========================================================
# BUSINESS BUTTON TEXT
# =========================================================

func _business_button_text(index: int) -> String:

	if unlocked_businesses[index]:

		return (
			"🏢 %s\nLevel %d • ₹%s/sec\nOPERATE"
			% [
				business_names[index],
				business_levels[index],
				_money(business_income[index])
			]
		)

	return (
		"🔒 %s\nUnlock Cost: ₹%s"
		% [
			business_names[index],
			_money(business_unlock_costs[index])
		]
	)

# =========================================================
# MISSION PROGRESS
# =========================================================

func mission_progress() -> float:

	if mission_index >= mission_names.size():

		return 0.0

	match mission_index:

		0:
			return min(total_earned, 1000.0)

		1:
			return min(total_earned, 10000.0)

		2:
			var owned := 0

			for unlocked in unlocked_businesses:

				if unlocked:
					owned += 1

			return float(owned)

		3:
			return float(employee_count)

		4:
			return min(total_earned, 100000.0)

	return 0.0

# =========================================================
# ACHIEVEMENTS
# =========================================================

func _check_achievements() -> void:

	# First Revenue
	if not achievement_earned[0] and total_earned >= 1.0:

		achievement_earned[0] = true
		cash += 100.0
		status_label.text = "🏆 First Revenue! +₹100"

	# Rising Entrepreneur
	if not achievement_earned[1] and total_earned >= 1000.0:

		achievement_earned[1] = true
		cash += 1000.0
		status_label.text = "🏆 Rising Entrepreneur! +₹1,000"

	# Business Owner
	var owned := 0

	for unlocked in unlocked_businesses:

		if unlocked:
			owned += 1

	if not achievement_earned[2] and owned >= 2:

		achievement_earned[2] = true
		cash += 2500.0
		status_label.text = "🏆 Business Owner! +₹2,500"

	# Team Builder
	if not achievement_earned[3] and employee_count >= 5:

		achievement_earned[3] = true
		cash += 5000.0
		status_label.text = "🏆 Team Builder! +₹5,000"

	# Entrepreneur
	if not achievement_earned[4] and total_earned >= 10000.0:

		achievement_earned[4] = true
		cash += 10000.0
		status_label.text = "🏆 Entrepreneur! +₹10,000"

	_check_missions()

# =========================================================
# MISSIONS
# =========================================================

func _check_missions() -> void:

	if mission_index >= mission_names.size():

		return

	var completed := false

	match mission_index:

		0:
			completed = total_earned >= 1000.0

		1:
			completed = total_earned >= 10000.0

		2:
			var owned := 0

			for unlocked in unlocked_businesses:

				if unlocked:
					owned += 1

			completed = owned >= 2

		3:
			completed = employee_count >= 5

		4:
			completed = total_earned >= 100000.0

	if completed:

		cash += mission_rewards[mission_index]

		missions_completed += 1

		status_label.text = (
			"🎯 Mission complete! +₹%s"
			% _money(mission_rewards[mission_index])
		)

		mission_index += 1

		_save_game()

# =========================================================
# MONEY FORMAT
# =========================================================

func _money(value: float) -> String:

	if value >= 1000000000.0:

		return "%.2fB" % (value / 1000000000.0)

	if value >= 1000000.0:

		return "%.2fM" % (value / 1000000.0)

	if value >= 1000.0:

		return "%.0f" % value

	return "%.0f" % value

# =========================================================
# SAVE
# =========================================================

func _save_game() -> void:

	var data := {
		"cash": cash,
		"total_earned": total_earned,
		"tap_value": tap_value,
		"upgrade_level": upgrade_level,
		"manager_level": manager_level,
		"employee_count": employee_count,
		"selected_business": selected_business,
		"unlocked_businesses": unlocked_businesses,
		"business_levels": business_levels,
		"mission_index": mission_index,
		"missions_completed": missions_completed,
		"achievement_earned": achievement_earned,
		"last_save_time": Time.get_unix_time_from_system()
	}

	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)

	if file:

		file.store_string(
			JSON.stringify(data)
		)

		file.close()

# =========================================================
# LOAD
# =========================================================

func _load_game() -> void:

	if not FileAccess.file_exists(SAVE_PATH):

		return

	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	if file == null:

		return

	var text := file.get_as_text()

	file.close()

	var json := JSON.new()

	if json.parse(text) != OK:

		return

	var data = json.data

	if typeof(data) != TYPE_DICTIONARY:

		return

	cash = float(data.get("cash", 0.0))
	total_earned = float(data.get("total_earned", 0.0))

	tap_value = float(data.get("tap_value", 10.0))

	upgrade_level = int(data.get("upgrade_level", 0))
	manager_level = int(data.get("manager_level", 0))
	employee_count = int(data.get("employee_count", 0))

	selected_business = int(
		data.get("selected_business", 0)
	)

	var saved_unlocks = data.get(
		"unlocked_businesses",
		[true, false, false]
	)

	var saved_levels = data.get(
		"business_levels",
		[1, 0, 0]
	)

	var saved_achievements = data.get(
		"achievement_earned",
		[false, false, false, false, false]
	)

	if saved_unlocks is Array:
		unlocked_businesses = saved_unlocks

	if saved_levels is Array:
		business_levels = saved_levels

	if saved_achievements is Array:
		achievement_earned = saved_achievements

	mission_index = int(
		data.get("mission_index", 0)
	)

	missions_completed = int(
		data.get("missions_completed", 0)
	)
