extends Control

const SAVE_PATH := "user://business_clicker_save_v2.json"

# =========================================================
# GAME SETTINGS
# =========================================================

const DAYS_PER_MONTH: int = 30

# Approximately 5 real seconds = 1 game day.
const REAL_SECONDS_PER_GAME_DAY: float = 5.0

const MAX_CLICK_VALUE: float = 10.0

# Rewarded boost multiplier.
const BOOST_MULTIPLIER: float = 10.0

# Boost duration in game days.
const BOOST_DURATION_DAYS: float = 3.0

# Company unlock requirement.
const COMPANY_UNLOCK_COST: float = 100000.0

# =========================================================
# GAME STATE
# =========================================================

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

# =========================================================
# MANAGEMENT
# =========================================================

var employee_count: int = 0
var manager_count: int = 0

# =========================================================
# BUSINESSES
# =========================================================

var selected_business: int = 0

var unlocked_businesses: Array = [
	true,
	false,
	false,
	false,
	false
]

var business_levels: Array = [
	1,
	0,
	0,
	0,
	0
]

var business_monthly_revenue: Array = [
	0.0,
	0.0,
	0.0,
	0.0,
	0.0
]

var business_monthly_expenses: Array = [
	0.0,
	0.0,
	0.0,
	0.0,
	0.0
]

var business_monthly_profit: Array = [
	0.0,
	0.0,
	0.0,
	0.0,
	0.0
]

# =========================================================
# COMPANY
# =========================================================

var company_unlocked: bool = false
var company_level: int = 0

var company_revenue: float = 0.0
var company_expenses: float = 0.0
var company_profit: float = 0.0

# =========================================================
# BUSINESS DATA
# =========================================================

var business_names: Array = [
	"Retail Shop",
	"Car Wash",
	"Coffee Shop",
	"Supermarket",
	"Restaurant"
]

var business_unlock_costs: Array = [
	0.0,
	2500.0,
	10000.0,
	50000.0,
	150000.0
]

# Base monthly revenue at level 1.
var business_base_revenue: Array = [
	1500.0,
	6000.0,
	15000.0,
	55000.0,
	150000.0
]

# Base monthly operating expenses at level 1.
var business_base_expenses: Array = [
	850.0,
	3600.0,
	9000.0,
	33000.0,
	90000.0
]

# Revenue growth per business level.
var business_level_multiplier: float = 1.55

# =========================================================
# UI
# =========================================================

var cash_label: Label
var click_label: Label
var time_label: Label
var boost_label: Label
var business_label: Label
var monthly_label: Label
var company_label: Label
var status_label: Label

var earn_button: Button
var click_upgrade_button: Button
var boost_button: Button

var employee_button: Button
var manager_button: Button

var retail_button: Button
var carwash_button: Button
var coffee_button: Button
var supermarket_button: Button
var restaurant_button: Button

var company_button: Button
var company_upgrade_button: Button

var mission_label: Label
var achievement_label: Label
var stats_label: Label

# =========================================================
# MISSIONS
# =========================================================

var mission_index: int = 0
var missions_completed: int = 0

var mission_names: Array = [
	"Earn your first $100",
	"Reach $2,500 total earnings",
	"Own 2 businesses",
	"Complete your first month",
	"Earn $100,000 total"
]

var mission_targets: Array = [
	100.0,
	2500.0,
	2.0,
	1.0,
	100000.0
]

var mission_rewards: Array = [
	100.0,
	500.0,
	2500.0,
	5000.0,
	25000.0
]

# =========================================================
# ACHIEVEMENTS
# =========================================================

var achievement_earned: Array = [
	false,
	false,
	false,
	false,
	false,
	false
]

var achievement_names: Array = [
	"First Dollar",
	"Serious Earner",
	"Business Owner",
	"Monthly Operator",
	"Company Founder",
	"Business Tycoon"
]

# =========================================================
# READY
# =========================================================

func _ready() -> void:

	_build_ui()

	_load_game()

	_recalculate_businesses()

	_refresh_ui()

# =========================================================
# GAME LOOP
# =========================================================

func _process(delta: float) -> void:

	day_timer += delta

	if day_timer >= REAL_SECONDS_PER_GAME_DAY:

		day_timer -= REAL_SECONDS_PER_GAME_DAY

		_advance_game_day()

	_refresh_ui()

	_check_achievements()

# =========================================================
# GAME DAY
# =========================================================

func _advance_game_day() -> void:

	game_day += 1

	if boost_active:

		boost_days_left -= 1.0

		if boost_days_left <= 0.0:

			boost_active = false
			boost_days_left = 0.0

			status_label.text = "Boost ended."

	# Month complete.
	if game_day > DAYS_PER_MONTH:

		game_day = 1

		game_month += 1

		total_months_completed += 1

		_process_monthly_businesses()

		status_label.text = (
			"Month %d completed. Business profit received."
			% (game_month - 1)
		)

	_save_game()

# =========================================================
# BUILD UI
# =========================================================

func _build_ui() -> void:

	# -------------------------------------------------------
	# BACKGROUND
	# -------------------------------------------------------

	var background := ColorRect.new()

	background.color = Color("#080c16")

	background.set_anchors_preset(
		Control.PRESET_FULL_RECT
	)

	add_child(background)

	# -------------------------------------------------------
	# SCROLL
	# -------------------------------------------------------

	var scroll := ScrollContainer.new()

	scroll.set_anchors_preset(
		Control.PRESET_FULL_RECT
	)

	scroll.horizontal_scroll_mode = (
		ScrollContainer.SCROLL_MODE_DISABLED
	)

	scroll.vertical_scroll_mode = (
		ScrollContainer.SCROLL_MODE_AUTO
	)

	add_child(scroll)

	# -------------------------------------------------------
	# MAIN
	# -------------------------------------------------------

	var main := VBoxContainer.new()

	main.custom_minimum_size = Vector2(
		672,
		2450
	)

	main.add_theme_constant_override(
		"separation",
		12
	)

	scroll.add_child(main)

	# =======================================================
	# TITLE
	# =======================================================

	var title := Label.new()

	title.text = "BUSINESS CLICKER"

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

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

	subtitle.text = "BUILD CAPITAL • OWN BUSINESSES • BUILD A COMPANY"

	subtitle.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	subtitle.add_theme_font_size_override(
		"font_size",
		14
	)

	main.add_child(subtitle)

	# =======================================================
	# CASH
	# =======================================================

	cash_label = Label.new()

	cash_label.text = "$0"

	cash_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	cash_label.add_theme_font_size_override(
		"font_size",
		50
	)

	cash_label.custom_minimum_size.y = 80

	main.add_child(cash_label)

	# =======================================================
	# CLICK VALUE
	# =======================================================

	click_label = Label.new()

	click_label.text = "Earning: $1 / click"

	click_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	click_label.add_theme_font_size_override(
		"font_size",
		21
	)

	main.add_child(click_label)

	# =======================================================
	# TIME
	# =======================================================

	time_label = Label.new()

	time_label.text = "Day 1 / 30 • Month 1"

	time_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	time_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main.add_child(time_label)

	# =======================================================
	# BOOST STATUS
	# =======================================================

	boost_label = Label.new()

	boost_label.text = "Boost: OFF"

	boost_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	boost_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main.add_child(boost_label)

	# =======================================================
	# EARN
	# =======================================================

	earn_button = Button.new()

	earn_button.text = "EARN\n+$1"

	earn_button.custom_minimum_size = Vector2(
		0,
		170
	)

	earn_button.pressed.connect(
		_on_earn_pressed
	)

	main.add_child(earn_button)

	# =======================================================
	# BOOST
	# =======================================================

	boost_button = Button.new()

	boost_button.text = "WATCH AD • 10X BOOST"

	boost_button.custom_minimum_size.y = 80

	boost_button.pressed.connect(
		_activate_boost
	)

	main.add_child(boost_button)

	# =======================================================
	# STATUS
	# =======================================================

	status_label = Label.new()

	status_label.text = "Start building your capital."

	status_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	status_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	status_label.custom_minimum_size.y = 50

	main.add_child(status_label)

	# =======================================================
	# CLICKER UPGRADE
	# =======================================================

	var click_title := Label.new()

	click_title.text = "CLICKER"

	click_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(click_title)

	click_upgrade_button = Button.new()

	click_upgrade_button.custom_minimum_size.y = 80

	click_upgrade_button.pressed.connect(
		_upgrade_click
	)

	main.add_child(click_upgrade_button)

	# =======================================================
	# MANAGEMENT
	# =======================================================

	var management_title := Label.new()

	management_title.text = "MANAGEMENT"

	management_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(management_title)

	employee_button = Button.new()

	employee_button.custom_minimum_size.y = 75

	employee_button.pressed.connect(
		_hire_employee
	)

	main.add_child(employee_button)

	manager_button = Button.new()

	manager_button.custom_minimum_size.y = 75

	manager_button.pressed.connect(
		_hire_manager
	)

	main.add_child(manager_button)

	# =======================================================
	# BUSINESSES
	# =======================================================

	var business_title := Label.new()

	business_title.text = "BUSINESSES"

	business_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(business_title)

	retail_button = Button.new()

	retail_button.custom_minimum_size.y = 80

	retail_button.pressed.connect(
		_select_retail
	)

	main.add_child(retail_button)

	carwash_button = Button.new()

	carwash_button.custom_minimum_size.y = 80

	carwash_button.pressed.connect(
		_select_carwash
	)

	main.add_child(carwash_button)

	coffee_button = Button.new()

	coffee_button.custom_minimum_size.y = 80

	coffee_button.pressed.connect(
		_select_coffee
	)

	main.add_child(coffee_button)

	supermarket_button = Button.new()

	supermarket_button.custom_minimum_size.y = 80

	supermarket_button.pressed.connect(
		_select_supermarket
	)

	main.add_child(supermarket_button)

	restaurant_button = Button.new()

	restaurant_button.custom_minimum_size.y = 80

	restaurant_button.pressed.connect(
		_select_restaurant
	)

	main.add_child(restaurant_button)

	# =======================================================
	# MONTHLY BUSINESS REPORT
	# =======================================================

	var monthly_title := Label.new()

	monthly_title.text = "MONTHLY BUSINESS REPORT"

	monthly_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(monthly_title)

	monthly_label = Label.new()

	monthly_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	monthly_label.custom_minimum_size.y = 190

	monthly_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main.add_child(monthly_label)

	# =======================================================
	# COMPANY
	# =======================================================

	var company_title := Label.new()

	company_title.text = "COMPANY"

	company_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(company_title)

	company_button = Button.new()

	company_button.custom_minimum_size.y = 85

	company_button.pressed.connect(
		_form_company
	)

	main.add_child(company_button)

	company_upgrade_button = Button.new()

	company_upgrade_button.custom_minimum_size.y = 80

	company_upgrade_button.pressed.connect(
		_upgrade_company
	)

	main.add_child(company_upgrade_button)

	company_label = Label.new()

	company_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	company_label.custom_minimum_size.y = 150

	company_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main.add_child(company_label)

	# =======================================================
	# MISSIONS
	# =======================================================

	var mission_title := Label.new()

	mission_title.text = "MISSIONS"

	mission_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(mission_title)

	mission_label = Label.new()

	mission_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	mission_label.custom_minimum_size.y = 140

	mission_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main.add_child(mission_label)

	# =======================================================
	# ACHIEVEMENTS
	# =======================================================

	var achievement_title := Label.new()

	achievement_title.text = "ACHIEVEMENTS"

	achievement_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(achievement_title)

	achievement_label = Label.new()

	achievement_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	achievement_label.custom_minimum_size.y = 180

	achievement_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main.add_child(achievement_label)

	# =======================================================
	# STATS
	# =======================================================

	var stats_title := Label.new()

	stats_title.text = "GAME STATS"

	stats_title.add_theme_font_size_override(
		"font_size",
		25
	)

	main.add_child(stats_title)

	stats_label = Label.new()

	stats_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	stats_label.custom_minimum_size.y = 180

	stats_label.add_theme_font_size_override(
		"font_size",
		18
	)

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

	# =======================================================
	# PREMIUM UI
	# =======================================================

	_apply_premium_ui()

# =========================================================
# PREMIUM UI
# =========================================================

func _apply_premium_ui() -> void:

	if cash_label != null:

		cash_label.add_theme_color_override(
			"font_color",
			Color("#f5c542")
		)

	if click_label != null:

		click_label.add_theme_color_override(
			"font_color",
			Color("#55d98b")
		)

	if boost_label != null:

		boost_label.add_theme_color_override(
			"font_color",
			Color("#f5c542")
		)

	if time_label != null:

		time_label.add_theme_color_override(
			"font_color",
			Color("#9aa7bd")
		)

	if business_label != null:

		business_label.add_theme_color_override(
			"font_color",
			Color("#ffffff")
		)

	if monthly_label != null:

		monthly_label.add_theme_color_override(
			"font_color",
			Color("#55d98b")
		)

	if company_label != null:

		company_label.add_theme_color_override(
			"font_color",
			Color("#ffffff")
		)

	if status_label != null:

		status_label.add_theme_color_override(
			"font_color",
			Color("#9aa7bd")
		)

	# -------------------------------------------------------
	# EARN BUTTON
	# -------------------------------------------------------

	_style_earn_button(earn_button)

	# -------------------------------------------------------
	# BOOST
	# -------------------------------------------------------

	_style_boost_button(boost_button)

	# -------------------------------------------------------
	# NORMAL BUTTONS
	# -------------------------------------------------------

	_style_button(click_upgrade_button)

	_style_button(employee_button)
	_style_button(manager_button)

	_style_button(retail_button)
	_style_button(carwash_button)
	_style_button(coffee_button)
	_style_button(supermarket_button)
	_style_button(restaurant_button)

	_style_button(company_button)
	_style_button(company_upgrade_button)


func _style_earn_button(button: Button) -> void:

	if button == null:
		return

	var normal := StyleBoxFlat.new()

	normal.bg_color = Color("#18243a")

	normal.corner_radius_top_left = 24
	normal.corner_radius_top_right = 24
	normal.corner_radius_bottom_left = 24
	normal.corner_radius_bottom_right = 24

	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2

	normal.border_color = Color("#f5c542")

	var hover := normal.duplicate()

	hover.bg_color = Color("#243654")

	var pressed := normal.duplicate()

	pressed.bg_color = Color("#101a2b")

	button.add_theme_stylebox_override(
		"normal",
		normal
	)

	button.add_theme_stylebox_override(
		"hover",
		hover
	)

	button.add_theme_stylebox_override(
		"pressed",
		pressed
	)

	button.add_theme_color_override(
		"font_color",
		Color("#ffffff")
	)

	button.add_theme_color_override(
		"font_hover_color",
		Color("#f5c542")
	)

	button.add_theme_font_size_override(
		"font_size",
		30
	)


func _style_boost_button(button: Button) -> void:

	if button == null:
		return

	var normal := StyleBoxFlat.new()

	normal.bg_color = Color("#172d25")

	normal.corner_radius_top_left = 18
	normal.corner_radius_top_right = 18
	normal.corner_radius_bottom_left = 18
	normal.corner_radius_bottom_right = 18

	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2

	normal.border_color = Color("#55d98b")

	var hover := normal.duplicate()

	hover.bg_color = Color("#214534")

	var pressed := normal.duplicate()

	pressed.bg_color = Color("#102219")

	button.add_theme_stylebox_override(
		"normal",
		normal
	)

	button.add_theme_stylebox_override(
		"hover",
		hover
	)

	button.add_theme_stylebox_override(
		"pressed",
		pressed
	)

	button.add_theme_color_override(
		"font_color",
		Color("#ffffff")
	)

	button.add_theme_color_override(
		"font_hover_color",
		Color("#55d98b")
	)

	button.add_theme_font_size_override(
		"font_size",
		19
	)


func _style_button(button: Button) -> void:

	if button == null:
		return

	var normal := StyleBoxFlat.new()

	normal.bg_color = Color("#121b2d")

	normal.corner_radius_top_left = 16
	normal.corner_radius_top_right = 16
	normal.corner_radius_bottom_left = 16
	normal.corner_radius_bottom_right = 16

	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1

	normal.border_color = Color("#2c3b56")

	var hover := normal.duplicate()

	hover.bg_color = Color("#1b2942")

	var pressed := normal.duplicate()

	pressed.bg_color = Color("#0d1524")

	button.add_theme_stylebox_override(
		"normal",
		normal
	)

	button.add_theme_stylebox_override(
		"hover",
		hover
	)

	button.add_theme_stylebox_override(
		"pressed",
		pressed
	)

	button.add_theme_color_override(
		"font_color",
		Color("#ffffff")
	)

	button.add_theme_color_override(
		"font_hover_color",
		Color("#f5c542")
	)

	button.add_theme_font_size_override(
		"font_size",
		17
	)

# =========================================================
# EARN
# =========================================================

func _on_earn_pressed() -> void:

	var amount := click_value

	if boost_active:

		amount *= BOOST_MULTIPLIER

	cash += amount
	total_earned += amount

	status_label.text = (
		"Revenue received: +$%s"
		% _money(amount)
	)

	_check_achievements()

# =========================================================
# CLICK UPGRADE
# =========================================================

func _upgrade_click() -> void:

	if click_value >= MAX_CLICK_VALUE:

		status_label.text = (
			"Click income reached the $10 maximum. "
			"Use Boost or build a business."
		)

		return

	var cost := _click_upgrade_cost()

	if cash < cost:

		status_label.text = (
			"Need $%s for click upgrade."
			% _money(cost)
		)

		return

	cash -= cost

	click_level += 1

	click_value = min(
		MAX_CLICK_VALUE,
		float(click_level)
	)

	status_label.text = (
		"Click power increased to $%s."
		% _money(click_value)
	)

	_refresh_ui()

	_save_game()


func _click_upgrade_cost() -> float:

	if click_value >= MAX_CLICK_VALUE:

		return 0.0

	return 25.0 * pow(
		1.65,
		float(click_level - 1)
	)

# =========================================================
# BOOST
# =========================================================

func _activate_boost() -> void:

	if boost_active:

		status_label.text = (
			"10x Boost already active."
		)

		return

	# -------------------------------------------------------
	# TEMPORARY TEST REWARD
	#
	# Later this function will be connected to a real
	# rewarded-ad callback.
	# -------------------------------------------------------

	boost_active = true

	boost_days_left = BOOST_DURATION_DAYS

	status_label.text = (
		"10x BOOST ACTIVATED!"
	)

	_refresh_ui()

# =========================================================
# EMPLOYEE
# =========================================================

func _hire_employee() -> void:

	var cost := _employee_cost()

	if cash < cost:

		status_label.text = (
			"Need $%s to hire an employee."
			% _money(cost)
		)

		return

	cash -= cost

	employee_count += 1

	status_label.text = (
		"Employee hired. Team size: %d"
		% employee_count
	)

	_recalculate_businesses()

	_refresh_ui()

	_save_game()

	_check_achievements()


func _employee_cost() -> float:

	return 500.0 * pow(
		1.45,
		float(employee_count)
	)

# =========================================================
# MANAGER
# =========================================================

func _hire_manager() -> void:

	var cost := _manager_cost()

	if cash < cost:

		status_label.text = (
			"Need $%s for manager."
			% _money(cost)
		)

		return

	cash -= cost

	manager_count += 1

	status_label.text = (
		"Manager hired. Managers: %d"
		% manager_count
	)

	_recalculate_businesses()

	_refresh_ui()

	_save_game()


func _manager_cost() -> float:

	return 2500.0 * pow(
		1.65,
		float(manager_count)
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


func _select_supermarket() -> void:

	_select_business(3)


func _select_restaurant() -> void:

	_select_business(4)

# =========================================================
# BUSINESS
# =========================================================

func _select_business(index: int) -> void:

	if index < 0:
		return

	if index >= business_names.size():
		return

	# -------------------------------------------------------
	# UNLOCK
	# -------------------------------------------------------

	if not unlocked_businesses[index]:

		var cost: float = business_unlock_costs[index]

		if cash < cost:

			status_label.text = (
				"Need $%s to unlock %s."
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
			"%s is now part of your business portfolio!"
			% business_names[index]
		)

		_recalculate_businesses()

		_refresh_ui()

		_save_game()

		_check_achievements()

		return

	# -------------------------------------------------------
	# SELECT
	# -------------------------------------------------------

	selected_business = index

	status_label.text = (
		"Operating %s."
		% business_names[index]
	)

	_refresh_ui()

# =========================================================
# BUSINESS UPGRADE
# =========================================================

func _upgrade_selected_business() -> void:

	if selected_business < 0:
		return

	var cost := _business_upgrade_cost(
		selected_business
	)

	if cash < cost:

		status_label.text = (
			"Need $%s to upgrade %s."
			% [
				_money(cost),
				business_names[selected_business]
			]
		)

		return

	cash -= cost

	business_levels[selected_business] += 1

	_recalculate_businesses()

	status_label.text = (
		"%s upgraded to Level %d."
		% [
			business_names[selected_business],
			business_levels[selected_business]
		]
	)

	_refresh_ui()

	_save_game()


func _business_upgrade_cost(index: int) -> float:

	if index < 0 or index >= business_names.size():
		return 0.0

	var level: int = business_levels[index]

	if level <= 0:
		level = 1

	return (
		business_unlock_costs[index] *
		0.45 *
		pow(
			1.6,
			float(level - 1)
		)
	)

# =========================================================
# BUSINESS ECONOMY
# =========================================================

func _recalculate_businesses() -> void:

	company_revenue = 0.0
	company_expenses = 0.0
	company_profit = 0.0

	for i in range(business_names.size()):

		if not unlocked_businesses[i]:

			business_monthly_revenue[i] = 0.0
			business_monthly_expenses[i] = 0.0
			business_monthly_profit[i] = 0.0

			continue

		var level: int = business_levels[i]

		if level < 1:
			level = 1

		var revenue := (
			business_base_revenue[i] *
			pow(
				business_level_multiplier,
				float(level - 1)
			)
		)

		var expenses := (
			business_base_expenses[i] *
			pow(
				1.48,
				float(level - 1)
			)
		)

		# Employees improve revenue.
		revenue *= (
			1.0 +
			float(employee_count) * 0.025
		)

		# Managers reduce operating inefficiency.
		expenses *= max(
			0.60,
			1.0 -
			float(manager_count) * 0.04
		)

		var profit_before_tax := (
			revenue -
			expenses
		)

		if profit_before_tax < 0.0:

			profit_before_tax = 0.0

		var tax := (
			profit_before_tax *
			0.15
		)

		var net_profit := (
			profit_before_tax -
			tax
		)

		business_monthly_revenue[i] = revenue
		business_monthly_expenses[i] = (
			expenses +
			tax
		)

		business_monthly_profit[i] = net_profit

		company_revenue += revenue
		company_expenses += expenses + tax
		company_profit += net_profit

# =========================================================
# MONTHLY PROCESS
# =========================================================

func _process_monthly_businesses() -> void:

	_recalculate_businesses()

	if company_profit <= 0.0:

		status_label.text = (
			"Month closed. Your businesses made no net profit."
		)

		return

	cash += company_profit

	total_earned += company_profit

	status_label.text = (
		"Monthly profit received: +$%s"
		% _money(company_profit)
	)

	_check_achievements()

# =========================================================
# COMPANY FORMATION
# =========================================================

func _form_company() -> void:

	if company_unlocked:

		status_label.text = (
			"Company already exists."
		)

		return

	if cash < COMPANY_UNLOCK_COST:

		status_label.text = (
			"Need $%s to form your company."
			% _money(COMPANY_UNLOCK_COST)
		)

		return

	var owned := _owned_business_count()

	if owned < 2:

		status_label.text = (
			"Own at least 2 businesses before forming a company."
		)

		return

	cash -= COMPANY_UNLOCK_COST

	company_unlocked = true

	company_level = 1

	status_label.text = (
		"COMPANY FOUNDED! You are now a corporate owner."
	)

	_refresh_ui()

	_save_game()

	_check_achievements()

# =========================================================
# COMPANY UPGRADE
# =========================================================

func _upgrade_company() -> void:

	if not company_unlocked:

		status_label.text = (
			"Form your company first."
		)

		return

	var cost := _company_upgrade_cost()

	if cash < cost:

		status_label.text = (
			"Need $%s for company upgrade."
			% _money(cost)
		)

		return

	cash -= cost

	company_level += 1

	_recalculate_businesses()

	status_label.text = (
		"Company upgraded to Level %d."
		% company_level
	)

	_refresh_ui()

	_save_game()


func _company_upgrade_cost() -> float:

	return (
		25000.0 *
		pow(
			1.75,
			float(company_level - 1)
		)
	)

# =========================================================
# OWNED BUSINESSES
# =========================================================

func _owned_business_count() -> int:

	var count := 0

	for unlocked in unlocked_businesses:

		if unlocked:
			count += 1

	return count

# =========================================================
# REFRESH UI
# =========================================================

func _refresh_ui() -> void:

	if cash_label == null:
		return

	cash_label.text = (
		"$%s"
		% _money(cash)
	)

	var boosted_click := click_value

	if boost_active:

		boosted_click *= BOOST_MULTIPLIER

	click_label.text = (
		"Per Click: $%s"
		% _money(boosted_click)
	)

	time_label.text = (
		"Day %d / %d • Month %d"
		% [
			game_day,
			DAYS_PER_MONTH,
			game_month
		]
	)

	if boost_active:

		boost_label.text = (
			"10X BOOST ACTIVE • %s GAME DAYS LEFT"
			% _money(boost_days_left)
		)

	else:

		boost_label.text = (
			"BOOST OFF • WATCH AD FOR 10X"
		)

	earn_button.text = (
		"EARN MONEY\n+$%s"
		% _money(boosted_click)
	)

	# -------------------------------------------------------
	# CLICK UPGRADE
	# -------------------------------------------------------

	if click_value >= MAX_CLICK_VALUE:

		click_upgrade_button.text = (
			"CLICK LEVEL MAXED\n$10 / CLICK\nBUILD A BUSINESS NEXT"
		)

	else:

		click_upgrade_button.text = (
			"UPGRADE CLICK\n$%s → $%s\nCOST: $%s"
			% [
				_money(click_value),
				_money(
					min(
						MAX_CLICK_VALUE,
						click_value + 1.0
					)
				),
				_money(
					_click_upgrade_cost()
				)
			]
		)

	# -------------------------------------------------------
	# MANAGEMENT
	# -------------------------------------------------------

	employee_button.text = (
		"HIRE EMPLOYEE\nCost: $%s\nEmployees: %d"
		% [
			_money(_employee_cost()),
			employee_count
		]
	)

	manager_button.text = (
		"HIRE MANAGER\nCost: $%s\nManagers: %d"
		% [
			_money(_manager_cost()),
			manager_count
		]
	)

	# -------------------------------------------------------
	# BUSINESSES
	# -------------------------------------------------------

	retail_button.text = _business_button_text(0)
	carwash_button.text = _business_button_text(1)
	coffee_button.text = _business_button_text(2)
	supermarket_button.text = _business_button_text(3)
	restaurant_button.text = _business_button_text(4)

	# -------------------------------------------------------
	# MONTHLY REPORT
	# -------------------------------------------------------

	_recalculate_businesses()

	monthly_label.text = (
		"PORTFOLIO\n"
		"Monthly Revenue: $%s\n"
		"Operating Expenses + Tax: $%s\n"
		"NET MONTHLY PROFIT: $%s"
		% [
			_money(company_revenue),
			_money(company_expenses),
			_money(company_profit)
		]
	)

	# -------------------------------------------------------
	# COMPANY
	# -------------------------------------------------------

	if not company_unlocked:

		company_button.text = (
			"FORM COMPANY\n"
			"Cost: $%s\n"
			"Requires 2 Businesses"
			% _money(COMPANY_UNLOCK_COST)
		)

		company_upgrade_button.text = (
			"COMPANY LOCKED"
		)

		company_label.text = (
			"Build your business portfolio first.\n"
			"Own at least 2 businesses and have $100,000 "
			"to form your company."
		)

	else:

		company_button.text = (
			"COMPANY ACTIVE\n"
			"Level %d"
			% company_level
		)

		company_upgrade_button.text = (
			"UPGRADE COMPANY\n"
			"Cost: $%s\n"
			"Next Level: %d"
			% [
				_money(_company_upgrade_cost()),
				company_level + 1
			]
		)

		company_label.text = (
			"Company Level: %d\n"
			"Monthly Revenue: $%s\n"
			"Monthly Expenses: $%s\n"
			"Monthly Net Profit: $%s"
			% [
				company_level,
				_money(company_revenue),
				_money(company_expenses),
				_money(company_profit)
			]
		)

	# -------------------------------------------------------
	# MISSION
	# -------------------------------------------------------

	if mission_index < mission_names.size():

		var progress := mission_progress()

		mission_label.text = (
			"MISSION %d\n%s\n\n"
			"Progress: %s / %s\n"
			"Reward: $%s"
			% [
				mission_index + 1,
				mission_names[mission_index],
				_money(progress),
				_money(mission_targets[mission_index]),
				_money(mission_rewards[mission_index])
			]
		)

	else:

		mission_label.text = (
			"ALL MISSIONS COMPLETED\n"
			"You have completed the starter campaign."
		)

	# -------------------------------------------------------
	# ACHIEVEMENTS
	# -------------------------------------------------------

	var achievement_text := ""

	for i in range(achievement_names.size()):

		var mark := "[DONE]" if achievement_earned[i] else "[LOCKED]"

		achievement_text += (
			"%s  %s\n"
			% [
				mark,
				achievement_names[i]
			]
		)

	achievement_label.text = achievement_text

	# -------------------------------------------------------
	# STATS
	# -------------------------------------------------------

	stats_label.text = (
		"Cash: $%s\n"
		"Total Earnings: $%s\n"
		"Businesses: %d / %d\n"
		"Employees: %d\n"
		"Managers: %d\n"
		"Months Completed: %d\n"
		"Company: %s"
		% [
			_money(cash),
			_money(total_earned),
			_owned_business_count(),
			business_names.size(),
			employee_count,
			manager_count,
			total_months_completed,
			"ACTIVE" if company_unlocked else "NOT FORMED"
		]
	)

# =========================================================
# BUSINESS BUTTON TEXT
# =========================================================

func _business_button_text(index: int) -> String:

	if unlocked_businesses[index]:

		var selected := ""

		if selected_business == index:

			selected = " • SELECTED"

		return (
			"%s%s\n"
			"Level %d\n"
			"Monthly Profit: $%s\n"
			"OPERATE / SELECT"
			% [
				business_names[index],
				selected,
				business_levels[index],
				_money(
					business_monthly_profit[index]
				)
			]
		)

	return (
		"LOCKED: %s\n"
		"Unlock Cost: $%s"
		% [
			business_names[index],
			_money(
				business_unlock_costs[index]
			)
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
			return min(
				total_earned,
				100.0
			)

		1:
			return min(
				total_earned,
				2500.0
			)

		2:
			return float(
				_owned_business_count()
			)

		3:
			return float(
				total_months_completed
			)

		4:
			return min(
				total_earned,
				100000.0
			)

	return 0.0

# =========================================================
# ACHIEVEMENTS
# =========================================================

func _check_achievements() -> void:

	# -------------------------------------------------------
	# First Dollar
	# -------------------------------------------------------

	if not achievement_earned[0]:

		if total_earned >= 1.0:

			achievement_earned[0] = true

			cash += 25.0

			status_label.text = (
				"Achievement: First Dollar! +$25"
			)

	# -------------------------------------------------------
	# Serious Earner
	# -------------------------------------------------------

	if not achievement_earned[1]:

		if total_earned >= 2500.0:

			achievement_earned[1] = true

			cash += 250.0

			status_label.text = (
				"Achievement: Serious Earner! +$250"
			)

	# -------------------------------------------------------
	# Business Owner
	# -------------------------------------------------------

	if not achievement_earned[2]:

		if _owned_business_count() >= 2:

			achievement_earned[2] = true

			cash += 1000.0

			status_label.text = (
				"Achievement: Business Owner! +$1,000"
			)

	# -------------------------------------------------------
	# Monthly Operator
	# -------------------------------------------------------

	if not achievement_earned[3]:

		if total_months_completed >= 1:

			achievement_earned[3] = true

			cash += 2500.0

			status_label.text = (
				"Achievement: Monthly Operator! +$2,500"
			)

	# -------------------------------------------------------
	# Company Founder
	# -------------------------------------------------------

	if not achievement_earned[4]:

		if company_unlocked:

			achievement_earned[4] = true

			cash += 10000.0

			status_label.text = (
				"Achievement: Company Founder! +$10,000"
			)

	# -------------------------------------------------------
	# Business Tycoon
	# -------------------------------------------------------

	if not achievement_earned[5]:

		if total_earned >= 1000000.0:

			achievement_earned[5] = true

			cash += 50000.0

			status_label.text = (
				"Achievement: Business Tycoon! +$50,000"
			)

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
			completed = total_earned >= 100.0

		1:
			completed = total_earned >= 2500.0

		2:
			completed = _owned_business_count() >= 2

		3:
			completed = total_months_completed >= 1

		4:
			completed = total_earned >= 100000.0

	if completed:

		var reward := mission_rewards[mission_index]

		cash += reward

		missions_completed += 1

		status_label.text = (
			"Mission complete! +$%s"
			% _money(reward)
		)

		mission_index += 1

		_save_game()

# =========================================================
# MONEY FORMAT
# =========================================================

func _money(value: float) -> String:

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

		return "%.0f" % (
			value
		)

	return "%.0f" % value

# =========================================================
# SAVE
# =========================================================

func _save_game() -> void:

	var data := {
		"cash": cash,
		"total_earned": total_earned,

		"click_value": click_value,
		"click_level": click_level,

		"game_day": game_day,
		"game_month": game_month,

		"boost_active": boost_active,
		"boost_days_left": boost_days_left,

		"total_months_completed": total_months_completed,

		"employee_count": employee_count,
		"manager_count": manager_count,

		"selected_business": selected_business,

		"unlocked_businesses": unlocked_businesses,
		"business_levels": business_levels,

		"business_monthly_revenue":
			business_monthly_revenue,

		"business_monthly_expenses":
			business_monthly_expenses,

		"business_monthly_profit":
			business_monthly_profit,

		"company_unlocked": company_unlocked,
		"company_level": company_level,

		"mission_index": mission_index,
		"missions_completed": missions_completed,

		"achievement_earned": achievement_earned,

		"last_save_time":
			Time.get_unix_time_from_system()
	}

	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)

	if file == null:

		return

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

	# -------------------------------------------------------
	# BASIC
	# -------------------------------------------------------

	cash = float(
		data.get(
			"cash",
			0.0
		)
	)

	total_earned = float(
		data.get(
			"total_earned",
			0.0
		)
	)

	click_value = float(
		data.get(
			"click_value",
			1.0
		)
	)

	click_level = int(
		data.get(
			"click_level",
			1
		)
	)

	click_value = min(
		click_value,
		MAX_CLICK_VALUE
	)

	# -------------------------------------------------------
	# TIME
	# -------------------------------------------------------

	game_day = int(
		data.get(
			"game_day",
			1
		)
	)

	game_month = int(
		data.get(
			"game_month",
			1
		)
	)

	if game_day < 1:
		game_day = 1

	if game_day > DAYS_PER_MONTH:
		game_day = 1

	total_months_completed = int(
		data.get(
			"total_months_completed",
			0
		)
	)

	# -------------------------------------------------------
	# BOOST
	# -------------------------------------------------------

	boost_active = bool(
		data.get(
			"boost_active",
			false
		)
	)

	boost_days_left = float(
		data.get(
			"boost_days_left",
			0.0
		)
	)

	if boost_days_left <= 0.0:

		boost_active = false
		boost_days_left = 0.0

	# -------------------------------------------------------
	# MANAGEMENT
	# -------------------------------------------------------

	employee_count = int(
		data.get(
			"employee_count",
			0
		)
	)

	manager_count = int(
		data.get(
			"manager_count",
			0
		)
	)

	# -------------------------------------------------------
	# SELECTED BUSINESS
	# -------------------------------------------------------

	selected_business = int(
		data.get(
			"selected_business",
			0
		)
	)

	if selected_business < 0:

		selected_business = 0

	if selected_business >= business_names.size():

		selected_business = 0

	# -------------------------------------------------------
	# BUSINESSES
	# -------------------------------------------------------

	var saved_unlocks = data.get(
		"unlocked_businesses",
		[true, false, false, false, false]
	)

	var saved_levels = data.get(
		"business_levels",
		[1, 0, 0, 0, 0]
	)

	var saved_revenue = data.get(
		"business_monthly_revenue",
		[0.0, 0.0, 0.0, 0.0, 0.0]
	)

	var saved_expenses = data.get(
		"business_monthly_expenses",
		[0.0, 0.0, 0.0, 0.0, 0.0]
	)

	var saved_profit = data.get(
		"business_monthly_profit",
		[0.0, 0.0, 0.0, 0.0, 0.0]
	)

	if saved_unlocks is Array:

		for i in range(
			min(
				saved_unlocks.size(),
				unlocked_businesses.size()
			)
		):

			unlocked_businesses[i] = (
				bool(saved_unlocks[i])
			)

	# Retail must always exist.
	unlocked_businesses[0] = true

	if saved_levels is Array:

		for i in range(
			min(
				saved_levels.size(),
				business_levels.size()
			)
		):

			business_levels[i] = (
				int(saved_levels[i])
			)

	if saved_revenue is Array:

		for i in range(
			min(
				saved_revenue.size(),
				business_monthly_revenue.size()
			)
		):

			business_monthly_revenue[i] = (
				float(saved_revenue[i])
			)

	if saved_expenses is Array:

		for i in range(
			min(
				saved_expenses.size(),
				business_monthly_expenses.size()
			)
		):

			business_monthly_expenses[i] = (
				float(saved_expenses[i])
			)

	if saved_profit is Array:

		for i in range(
			min(
				saved_profit.size(),
				business_monthly_profit.size()
			)
		):

			business_monthly_profit[i] = (
				float(saved_profit[i])
			)

	# -------------------------------------------------------
	# COMPANY
	# -------------------------------------------------------

	company_unlocked = bool(
		data.get(
			"company_unlocked",
			false
		)
	)

	company_level = int(
		data.get(
			"company_level",
			0
		)
	)

	# -------------------------------------------------------
	# MISSIONS
	# -------------------------------------------------------

	mission_index = int(
		data.get(
			"mission_index",
			0
		)
	)

	missions_completed = int(
		data.get(
			"missions_completed",
			0
		)
	)

	if mission_index < 0:

		mission_index = 0

	if mission_index > mission_names.size():

		mission_index = mission_names.size()

	# -------------------------------------------------------
	# ACHIEVEMENTS
	# -------------------------------------------------------

	var saved_achievements = data.get(
		"achievement_earned",
		[
			false,
			false,
			false,
			false,
			false,
			false
		]
	)

	if saved_achievements is Array:

		for i in range(
			min(
				saved_achievements.size(),
				achievement_earned.size()
			)
		):

			achievement_earned[i] = (
				bool(saved_achievements[i])
			)
