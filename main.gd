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

var unlocked_businesses: Array = [true, false, false]

var business_levels: Array = [1, 0, 0]
var business_income: Array = [0.0, 0.0, 0.0]

var last_save_time: int = 0


# =========================================================
# BUSINESS DATA
# =========================================================

var business_names: Array = [
	"Retail Shop",
	"Car Wash",
	"Coffee Shop"
]

var business_icons: Array = [
	"SHOP",
	"CAR WASH",
	"COFFEE"
]

var business_unlock_costs: Array = [
	0.0,
	10000.0,
	50000.0
]

var business_setup_costs: Array = [
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
# UI REFERENCES
# =========================================================

var cash_label: Label
var income_label: Label
var business_label: Label
var status_label: Label

var earn_button: Button

var upgrade_button: Button
var manager_button: Button

var retail_button: Button
var carwash_button: Button
var coffee_button: Button

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


	# -----------------------------------------------------
	# TITLE
	# -----------------------------------------------------

	var title := Label.new()

	title.text = "BUSINESS CLICKER"

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.add_theme_font_size_override(
		"font_size",
		30
	)

	main.add_child(title)


	var subtitle := Label.new()

	subtitle.text = "START SMALL. BUILD BIG."

	subtitle.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	subtitle.add_theme_font_size_override(
		"font_size",
		15
	)

	main.add_child(subtitle)


	# -----------------------------------------------------
	# CASH
	# -----------------------------------------------------

	cash_label = Label.new()

	cash_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	cash_label.add_theme_font_size_override(
		"font_size",
		48
	)

	main.add_child(cash_label)


	income_label = Label.new()

	income_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	income_label.add_theme_font_size_override(
		"font_size",
		19
	)

	main.add_child(income_label)


	# -----------------------------------------------------
	# CURRENT BUSINESS
	# -----------------------------------------------------

	business_label = Label.new()

	business_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	business_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	business_label.add_theme_font_size_override(
		"font_size",
		22
	)

	main.add_child(business_label)


	# -----------------------------------------------------
	# EARN BUTTON
	# -----------------------------------------------------

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


	# -----------------------------------------------------
	# STATUS
	# -----------------------------------------------------

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


	# -----------------------------------------------------
	# UPGRADES
	# -----------------------------------------------------

	var upgrades_title := Label.new()

	upgrades_title.text = "UPGRADES"

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


	# -----------------------------------------------------
	# BUSINESSES
	# -----------------------------------------------------

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
		func():
			_select_business(0)
	)

	main.add_child(retail_button)


	carwash_button = Button.new()

	carwash_button.custom_minimum_size.y = 75

	carwash_button.pressed.connect(
		func():
			_select_business(1)
	)

	main.add_child(carwash_button)


	coffee_button = Button.new()

	coffee_button.custom_minimum_size.y = 75

	coffee_button.pressed.connect(
		func():
			_select_business(2)
	)

	main.add_child(coffee_button)


	# -----------------------------------------------------
	# COMPANY STATS
	# -----------------------------------------------------

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


	# -----------------------------------------------------
	# SAVE
	# -----------------------------------------------------

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
		"Revenue received from your business."
	)

	_refresh_ui()


# =========================================================
# UPGRADE
# =========================================================

func _buy_upgrade() -> void:

	var cost := _upgrade_cost()

	if cash < cost:

		status_label.text = (
			"Not enough cash for this upgrade."
		)

		return


	cash -= cost

	upgrade_level += 1

	tap_value = (
		10.0 * pow(1.55, upgrade_level)
	)

	status_label.text = (
		"Business upgrade purchased!"
	)

	_refresh_ui()

	_save_game()


# =========================================================
# MANAGER
# =========================================================

func _hire_manager() -> void:

	var cost := _manager_cost()

	if cash < cost:

		status_label.text = (
			"Not enough cash to hire a manager."
		)

		return


	cash -= cost

	manager_level += 1

	status_label.text = (
		"Manager hired. Operations are becoming automated."
	)

	_recalculate_income()

	_refresh_ui()

	_save_game()


# =========================================================
# SELECT BUSINESS
# =========================================================

func _select_business(index: int) -> void:

	if not unlocked_businesses[index]:

		var cost: float = (
			business_unlock_costs[index]
		)

		if cash < cost:

			status_label.text = (
				"You need ₹%s to unlock %s."
				% [
					_money(cost),
					business_names[index]
				]
			)

			return


		cash -= cost

		unlocked_businesses[index] = true

		business_levels[index] = 1

		status_label.text = (
			"%s is now part of your company!"
			% business_names[index]
		)

		_recalculate_income()

		_refresh_ui()

		_save_game()

		return


	selected_business = index

	status_label.text = (
		"Now operating: %s"
		% business_names[index]
	)

	_refresh_ui()


# =========================================================
# COSTS
# =========================================================

func _upgrade_cost() -> float:

	return (
		100.0 *
		pow(1.7, upgrade_level)
	)


func _manager_cost() -> float:

	return (
		750.0 *
		pow(1.85, manager_level)
	)


# =========================================================
# INCOME CALCULATION
# =========================================================

func _recalculate_income() -> void:

	passive_income = 0.0

	for i in range(business_names.size()):

		if unlocked_businesses[i]:

			var level: int = (
				business_levels[i]
			)

			var income: float = (
				business_base_income[i]
				* level
			)

			business_income[i] = income

			passive_income += income


	# Managers multiply operational income

	if manager_level > 0:

		passive_income *= (
			1.0 +
			(manager_level * 0.25)
		)


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
		"Company income: ₹%s / sec"
		% _money(passive_income)
	)


	business_label.text = (
		"CURRENT BUSINESS\n%s\nLevel %d"
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
		"UPGRADE BUSINESS\n"
		+ "Level %d  •  Cost ₹%s"
		% [
			upgrade_level + 1,
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


	# Retail

	if unlocked_businesses[0]:

		retail_button.text = (
			"SHOP\n"
			+ "Level %d  •  ₹%s/sec"
			% [
				business_levels[0],
				_money(business_income[0])
			]
		)

	else:

		retail_button.text = (
			"SHOP\nSTARTING BUSINESS"
		)


	# Car Wash

	if unlocked_businesses[1]:

		carwash_button.text = (
			"CAR WASH\n"
			+ "Level %d  •  ₹%s/sec"
			% [
				business_levels[1],
				_money(business_income[1])
			]
		)

	else:

		carwash_button.text = (
			"LOCKED: CAR WASH\n"
			+ "Unlock: ₹%s"
			% _money(business_unlock_costs[1])
		)


	# Coffee Shop

	if unlocked_businesses[2]:

		coffee_button.text = (
			"COFFEE SHOP\n"
			+ "Level %d  •  ₹%s/sec"
			% [
				business_levels[2],
				_money(business_income[2])
			]
		)

	else:

		coffee_button.text = (
			"LOCKED: COFFEE SHOP\n"
			+ "Unlock: ₹%s"
			% _money(business_unlock_costs[2])
		)


	# Stats

	var business_count := 0

	for unlocked in unlocked_businesses:

		if unlocked:
			business_count += 1


	stats_label.text = (
		"Businesses owned: %d / %d\n"
		+ "Total revenue: ₹%s\n"
		+ "Managers: %d\n"
		+ "Business upgrades: %d\n"
		+ "Net cash: ₹%s"
		% [
			business_count,
			business_names.size(),
			_money(total_earned),
			manager_level,
			upgrade_level,
			_money(cash)
		]
	)


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

		"passive_income": passive_income,

		"upgrade_level": upgrade_level,

		"manager_level": manager_level,

		"unlocked_businesses":
			unlocked_businesses,

		"business_levels":
			business_levels,

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
		parsed.get("cash", 0.0)
	)


	total_earned = float(
		parsed.get("total_earned", 0.0)
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


	var saved_businesses = parsed.get(
		"unlocked_businesses",
		[true, false, false]
	)


	var saved_levels = parsed.get(
		"business_levels",
		[1, 0, 0]
	)


	if saved_businesses is Array:

		unlocked_businesses = saved_businesses


	if saved_levels is Array:

		business_levels = saved_levels


	last_save_time = int(
		parsed.get(
			"last_save_time",
			Time.get_unix_time_from_system()
		)
	)


	# -----------------------------------------------------
	# OFFLINE EARNINGS
	# -----------------------------------------------------

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
			"Welcome back! Offline earnings: ₹%s"
			% _money(offline)
		)


# =========================================================
# AUTO SAVE ON CLOSE
# =========================================================

func _notification(what: int) -> void:

	if what == NOTIFICATION_WM_CLOSE_REQUEST:

		_save_game()

		get_tree().quit()
