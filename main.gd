extends Control

const SAVE_PATH: String = "user://business_clicker_save_v2.json"

# =========================================================
# GAME SETTINGS
# =========================================================

const DAYS_PER_MONTH: int = 30

# 5 real seconds = 1 game day.
const REAL_SECONDS_PER_GAME_DAY: float = 5.0

# Clicker permanently stops at $10 per click.
const MAX_CLICK_VALUE: float = 10.0

# Rewarded-ad boost.
const BOOST_MULTIPLIER: float = 10.0
const BOOST_DURATION_DAYS: float = 3.0

# Company requirements.
const COMPANY_UNLOCK_COST: float = 100000.0
const COMPANY_REQUIRED_BUSINESSES: int = 2

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

# Monthly revenue at Level 1.
var business_base_revenue: Array = [
	1500.0,
	6000.0,
	15000.0,
	55000.0,
	150000.0
]

# Monthly operating expenses at Level 1.
var business_base_expenses: Array = [
	850.0,
	3600.0,
	9000.0,
	33000.0,
	90000.0
]

# Business upgrade starting costs.
var business_upgrade_base_cost: Array = [
	500.0,
	2000.0,
	7500.0,
	30000.0,
	90000.0
]

var business_level_multiplier: float = 1.55
var business_expense_multiplier: float = 1.42

# =========================================================
# CLICKER UPGRADE COSTS
# =========================================================

# $1 -> $2 -> ... -> $10.
var click_upgrade_costs: Array = [
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

# =========================================================
# UI REFERENCES
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

var business_upgrade_button: Button

var company_button: Button
var company_upgrade_button: Button

var mission_label: Label
var achievement_label: Label
var stats_label: Label

var save_button: Button

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

var achievement_names: Array = [
	"First Dollar",
	"Serious Earner",
	"Business Owner",
	"Monthly Operator",
	"Company Founder",
	"Business Tycoon"
]

var achievement_earned: Array = [
	false,
	false,
	false,
	false,
	false,
	false
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

			status_label.text = "10X Boost ended."

	# -------------------------------------------------------
	# MONTH END
	# -------------------------------------------------------

	if game_day > DAYS_PER_MONTH:

		game_day = 1
		game_month += 1
		total_months_completed += 1

		_process_monthly_businesses()

	_save_game()

# =========================================================
# BUILD UI
# =========================================================

func _build_ui() -> void:

	# -------------------------------------------------------
	# BACKGROUND
	# -------------------------------------------------------

	var background: ColorRect = ColorRect.new()

	background.color = Color("#080c16")

	background.set_anchors_preset(
		Control.PRESET_FULL_RECT
	)

	add_child(background)

	# -------------------------------------------------------
	# SCROLL
	# -------------------------------------------------------

	var scroll: ScrollContainer = ScrollContainer.new()

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
	# MAIN CONTENT
	# -------------------------------------------------------

	var main: VBoxContainer = VBoxContainer.new()

	main.custom_minimum_size = Vector2(672, 2850)

	main.add_theme_constant_override(
		"separation",
		12
	)

	scroll.add_child(main)

	# =======================================================
	# TITLE
	# =======================================================

	var title: Label = Label.new()

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

	var subtitle: Label = Label.new()

	subtitle.text = (
		"BUILD CAPITAL  •  OWN BUSINESSES  •  BUILD A COMPANY"
	)

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

	click_label.text = "Per Click: $1"

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

	time_label.text = "Day 1 / 30  •  Month 1"

	time_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	time_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main.add_child(time_label)

	# =======================================================
	# BOOST
	# =======================================================

	boost_label = Label.new()

	boost_label.text = "BOOST OFF  •  WATCH AD FOR 10X"

	boost_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	boost_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main.add_child(boost_label)

	# =======================================================
	# EARN BUTTON
	# =======================================================

	earn_button = Button.new()

	earn_button.text = "EARN MONEY\n+$1"

	earn_button.custom_minimum_size = Vector2(0, 170)

	earn_button.pressed.connect(
		_on_earn_pressed
	)

	main.add_child(earn_button)

	# =======================================================
	# BOOST BUTTON
	# =======================================================

	boost_button = Button.new()

	boost_button.text = "WATCH AD  •  10X BOOST"

	boost_button.custom_minimum_size.y = 80

	boost_button.pressed.connect(
		_activate_boost
	)

	main.add_child(boost_button)

	# =======================================================
	# STATUS
	# =======================================================

	status_label = Label.new()

	status_label.text = (
		"Start building your capital."
	)

	status_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	status_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	status_label.custom_minimum_size.y = 50

	main.add_child(status_label)

	# =======================================================
	# CLICKER
	# =======================================================

	var click_title: Label = Label.new()

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

	var management_title: Label = Label.new()

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

	var business_title: Label = Label.new()

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
	# SELECTED BUSINESS UPGRADE
	# =======================================================

	business_upgrade_button = Button.new()

	business_upgrade_button.custom_minimum_size.y = 85

	business_upgrade_button.pressed.connect(
		_upgrade_selected_business
	)

	main.add_child(business_upgrade_button)

	# =======================================================
	# MONTHLY REPORT
	# =======================================================

	var monthly_title: Label = Label.new()

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

	var company_title: Label = Label.new()

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

	company_label.custom_minimum_size.y = 160

	company_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main.add_child(company_label)

	# =======================================================
	# MISSIONS
	# =======================================================

	var mission_title: Label = Label.new()

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

	var achievement_title: Label = Label.new()

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

	var stats_title: Label = Label.new()

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

	stats_label.custom_minimum_size.y = 190

	stats_label.add_theme_font_size_override(
		"font_size",
		18
	)

	main.add_child(stats_label)

	# =======================================================
	# SAVE
	# =======================================================

	save_button = Button.new()

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

	_style_earn_button(earn_button)
	_style_boost_button(boost_button)

	_style_button(click_upgrade_button)
	_style_button(employee_button)
	_style_button(manager_button)

	_style_button(retail_button)
	_style_button(carwash_button)
	_style_button(coffee_button)
	_style_button(supermarket_button)
	_style_button(restaurant_button)

	_style_button(business_upgrade_button)

	_style_button(company_button)
	_style_button(company_upgrade_button)
	_style_button(save_button)

# =========================================================
# EARN BUTTON STYLE
# =========================================================

func _style_earn_button(button: Button) -> void:

	if button == null:
		return

	var normal: StyleBoxFlat = StyleBoxFlat.new()

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

	var hover: StyleBoxFlat = normal.duplicate()

	hover.bg_color = Color("#243654")

	var pressed: StyleBoxFlat = normal.duplicate()

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

# =========================================================
# BOOST BUTTON STYLE
# =========================================================

func _style_boost_button(button: Button) -> void:

	if button == null:
		return

	var normal: StyleBoxFlat = StyleBoxFlat.new()

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

	var hover: StyleBoxFlat = normal.duplicate()

	hover.bg_color = Color("#214534")

	var pressed: StyleBoxFlat = normal.duplicate()

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

# =========================================================
# NORMAL BUTTON STYLE
# =========================================================

func _style_button(button: Button) -> void:

	if button == null:
		return

	var normal: StyleBoxFlat = StyleBoxFlat.new()

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

	var hover: StyleBoxFlat = normal.duplicate()

	hover.bg_color = Color("#1b2942")

	var pressed: StyleBoxFlat = normal.duplicate()

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

	var amount: float = click_value

	if boost_active:
		amount *= BOOST_MULTIPLIER

	cash += amount
	total_earned += amount

	status_label.text = (
		"Revenue received: +$%s"
		% _money(amount)
	)

	_check_achievements()
	_refresh_ui()

# =========================================================
# CLICKER UPGRADE
# =========================================================

func _upgrade_click() -> void:

	if click_value >= MAX_CLICK_VALUE:

		status_label.text = (
			"Clicker MAXED at $10 per click. "
			"Build businesses and use 10X Boost."
		)

		return

	var cost: float = _click_upgrade_cost()

	if cash < cost:

		status_label.text = (
			"Need $%s for the next click upgrade."
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
		"Click power increased to $%s per click."
		% _money(click_value)
	)

	_refresh_ui()
	_save_game()


func _click_upgrade_cost() -> float:

	if click_value >= MAX_CLICK_VALUE:
		return 0.0

	var index: int = click_level - 1

	if index < 0:
		index = 0

	if index >= click_upgrade_costs.size():
		return 1200.0

	return float(click_upgrade_costs[index])

# =========================================================
# BOOST
# =========================================================

func _activate_boost() -> void:

	if boost_active:

		status_label.text = "10X Boost is already active."

		return

	# -------------------------------------------------------
	# TEST MODE
	#
	# This will later be replaced by a real rewarded-ad
	# callback from AdMob.
	# -------------------------------------------------------

	boost_active = true
	boost_days_left = BOOST_DURATION_DAYS

	status_label.text = (
		"10X BOOST ACTIVATED! Every click pays 10X."
	)

	_refresh_ui()

# =========================================================
# EMPLOYEE
# =========================================================

func _hire_employee() -> void:

	var cost: float = _employee_cost()

	if cash < cost:

		status_label.text = (
			"Need $%s to hire an employee."
			% _money(cost)
		)

		return

	cash -= cost
	employee_count += 1

	status_label.text = (
		"Employee hired. Team size: %d."
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

	var cost: float = _manager_cost()

	if cash < cost:

		status_label.text = (
			"Need $%s to hire a manager."
			% _money(cost)
		)

		return

	cash -= cost
	manager_count += 1

	status_label.text = (
		"Manager hired. Managers: %d."
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
# BUSINESS SELECT / UNLOCK
# =========================================================

func _select_business(index: int) -> void:

	if index < 0:
		return

	if index >= business_names.size():
		return

	# -------------------------------------------------------
	# UNLOCK
	# -------------------------------------------------------

	if not bool(unlocked_businesses[index]):

		var cost: float = float(
			business_unlock_costs[index]
		)

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
			"%s joined your business portfolio!"
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

	if selected_business >= business_names.size():
		return

	if not bool(unlocked_businesses[selected_business]):

		status_label.text = (
			"Unlock this business first."
		)

		return

	var cost: float = _business_upgrade_cost(
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

	if index < 0:
		return 0.0

	if index >= business_names.size():
		return 0.0

	var level: int = int(
		business_levels[index]
	)

	if level < 1:
		level = 1

	var base_cost: float = float(
		business_upgrade_base_cost[index]
	)

	return base_cost * pow(
		1.60,
		float(level - 1)
	)

# =========================================================
# BUSINESS ECONOMY
# =========================================================

func _recalculate_businesses() -> void:

	company_revenue = 0.0
	company_expenses = 0.0
	company_profit = 0.0

	var company_multiplier: float = 1.0

	if company_unlocked and company_level > 0:

		company_multiplier += (
			float(company_level - 1) * 0.10
		)

	for i in range(business_names.size()):

		if not bool(unlocked_businesses[i]):

			business_monthly_revenue[i] = 0.0
			business_monthly_expenses[i] = 0.0
			business_monthly_profit[i] = 0.0

			continue

		var level: int = int(
			business_levels[i]
		)

		if level < 1:
			level = 1

		var revenue: float = (
			float(business_base_revenue[i]) *
			pow(
				business_level_multiplier,
				float(level - 1)
			)
		)

		var expenses: float = (
			float(business_base_expenses[i]) *
			pow(
				business_expense_multiplier,
				float(level - 1)
			)
		)

		# Employees increase operational capacity.
		revenue *= (
			1.0 +
			float(employee_count) * 0.025
		)

		# Managers reduce operating expenses.
		expenses *= max(
			0.60,
			1.0 -
			float(manager_count) * 0.04
		)

		# Company improves portfolio performance.
		revenue *= company_multiplier

		var profit_before_tax: float = (
			revenue -
			expenses
		)

		if profit_before_tax < 0.0:
			profit_before_tax = 0.0

		var tax: float = (
			profit_before_tax * 0.15
		)

		var net_profit: float = (
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
		company_expenses += (
			expenses +
			tax
		)

		company_profit += net_profit

# =========================================================
# MONTHLY BUSINESS PROCESS
# =========================================================

func _process_monthly_businesses() -> void:

	_recalculate_businesses()

	if company_profit <= 0.0:

		status_label.text = (
			"Month closed. No net business profit this month."
		)

		return

	cash += company_profit
	total_earned += company_profit

	status_label.text = (
		"Month %d closed. Profit received: +$%s"
		% [
			game_month - 1,
			_money(company_profit)
		]
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

	var owned: int = _owned_business_count()

	if owned < COMPANY_REQUIRED_BUSINESSES:

		status_label.text = (
			"Own at least %d businesses first."
			% COMPANY_REQUIRED_BUSINESSES
		)

		return

	if cash < COMPANY_UNLOCK_COST:

		status_label.text = (
			"Need $%s to form your company."
			% _money(COMPANY_UNLOCK_COST)
		)

		return

	cash -= COMPANY_UNLOCK_COST

	company_unlocked = true
	company_level = 1

	_recalculate_businesses()

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

	var cost: float = _company_upgrade_cost()

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

	if company_level < 1:
		return COMPANY_UNLOCK_COST

	return 25000.0 * pow(
		1.75,
		float(company_level - 1)
	)

# =========================================================
# OWNED BUSINESSES
# =========================================================

func _owned_business_count() -> int:

	var count: int = 0

	for unlocked in unlocked_businesses:

		if bool(unlocked):
			count += 1

	return count

# =========================================================
# REFRESH UI
# =========================================================

func _refresh_ui() -> void:

	if cash_label == null:
		return

	# -------------------------------------------------------
	# CASH
	# -------------------------------------------------------

	cash_label.text = (
		"$%s"
		% _money(cash)
	)

	# -------------------------------------------------------
	# CLICK
	# -------------------------------------------------------

	var displayed_click: float = click_value

	if boost_active:
		displayed_click *= BOOST_MULTIPLIER

	click_label.text = (
		"Per Click: $%s"
		% _money(displayed_click)
	)

	# -------------------------------------------------------
	# TIME
	# -------------------------------------------------------

	time_label.text = (
		"Day %d / %d  •  Month %d"
		% [
			game_day,
			DAYS_PER_MONTH,
			game_month
		]
	)

	# -------------------------------------------------------
	# BOOST
	# -------------------------------------------------------

	if boost_active:

		boost_label.text = (
			"10X BOOST ACTIVE  •  %s GAME DAYS LEFT"
			% _money(boost_days_left)
		)

	else:

		boost_label.text = (
			"BOOST OFF  •  WATCH AD FOR 10X"
		)

	# -------------------------------------------------------
	# EARN BUTTON
	# -------------------------------------------------------

	earn_button.text = (
		"EARN MONEY\n+$%s"
		% _money(displayed_click)
	)

	# -------------------------------------------------------
	# CLICK UPGRADE
	# -------------------------------------------------------

	if click_value >= MAX_CLICK_VALUE:

		click_upgrade_button.text = (
			"CLICKER MAXED\n"
			"$10 / CLICK\n"
			"BUILD A BUSINESS NEXT"
		)

	else:

		var next_click: float = min(
			MAX_CLICK_VALUE,
			click_value + 1.0
		)

		click_upgrade_button.text = (
			"UPGRADE CLICK\n"
			"$%s  ->  $%s PER CLICK\n"
			"COST: $%s"
			% [
				_money(click_value),
				_money(next_click),
				_money(_click_upgrade_cost())
			]
		)

	# -------------------------------------------------------
	# MANAGEMENT
	# -------------------------------------------------------

	employee_button.text = (
		"HIRE EMPLOYEE\n"
		"Cost: $%s\n"
		"Employees: %d"
		% [
			_money(_employee_cost()),
			employee_count
		]
	)

	manager_button.text = (
		"HIRE MANAGER\n"
		"Cost: $%s\n"
		"Managers: %d"
		% [
			_money(_manager_cost()),
			manager_count
		]
	)

	# -------------------------------------------------------
	# BUSINESS BUTTONS
	# -------------------------------------------------------

	retail_button.text = _business_button_text(0)
	carwash_button.text = _business_button_text(1)
	coffee_button.text = _business_button_text(2)
	supermarket_button.text = _business_button_text(3)
	restaurant_button.text = _business_button_text(4)

	# -------------------------------------------------------
	# SELECTED BUSINESS UPGRADE
	# -------------------------------------------------------

	if unlocked_businesses[selected_business]:

		business_upgrade_button.text = (
			"UPGRADE %s\n"
			"Current Level: %d\n"
			"Cost: $%s"
			% [
				business_names[selected_business],
				business_levels[selected_business],
				_money(
					_business_upgrade_cost(
						selected_business
					)
				)
			]
		)

	else:

		business_upgrade_button.text = (
			"SELECT AN UNLOCKED BUSINESS TO UPGRADE"
		)

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
			"Requires %d Businesses"
			% [
				_money(COMPANY_UNLOCK_COST),
				COMPANY_REQUIRED_BUSINESSES
			]
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

		var progress: float = mission_progress()

		mission_label.text = (
			"MISSION %d\n"
			"%s\n\n"
			"Progress: $%s / $%s\n"
			"Reward: $%s"
			% [
				mission_index + 1,
				mission_names[mission_index],
				_money(progress),
				_money(mission_targets[mission_index]),
				_money(mission_rewards[mission_index])
			]
		)

		# Special mission formatting.
		if mission_index == 2:

			mission_label.text = (
				"MISSION 3\n"
				"Own 2 businesses\n\n"
				"Progress: %d / 2 businesses\n"
				"Reward: $%s"
				% [
					_owned_business_count(),
					_money(mission_rewards[mission_index])
				]
			)

		if mission_index == 3:

			mission_label.text = (
				"MISSION 4\n"
				"Complete your first month\n\n"
				"Progress: %d / 1 month\n"
				"Reward: $%s"
				% [
					total_months_completed,
					_money(mission_rewards[mission_index])
				]
			)

	else:

		mission_label.text = (
			"ALL MISSIONS COMPLETED\n"
			"Starter campaign completed."
		)

	# -------------------------------------------------------
	# ACHIEVEMENTS
	# -------------------------------------------------------

	var achievement_text: String = ""

	for i in range(achievement_names.size()):

		var mark: String = "[DONE]"

		if not bool(achievement_earned[i]):
			mark = "[LOCKED]"

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

	var company_status: String = "ACTIVE"

	if not company_unlocked:
		company_status = "NOT FORMED"

	stats_label.text = (
		"Cash: $%s\n"
		"Total Earnings: $%s\n"
		"Businesses: %d / %d\n"
		"Employees: %d\n"
		"Managers: %d\n"
		"Months Completed: %d\n"
		"Click Value: $%s\n"
		"Company: %s"
		% [
			_money(cash),
			_money(total_earned),
			_owned_business_count(),
			business_names.size(),
			employee_count,
			manager_count,
			total_months_completed,
			_money(click_value),
			company_status
		]
	)

# =========================================================
# BUSINESS BUTTON TEXT
# =========================================================

func _business_button_text(index: int) -> String:

	if bool(unlocked_businesses[index]):

		var selected_text: String = ""

		if selected_business == index:
			selected_text = "  [SELECTED]"

		return (
			"%s%s\n"
			"Level %d\n"
			"Monthly Profit: $%s\n"
			"SELECT / OPERATE"
			% [
				business_names[index],
				selected_text,
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

	if status_label == null:
		return

	# -------------------------------------------------------
	# FIRST DOLLAR
	# -------------------------------------------------------

	if not bool(achievement_earned[0]):

		if total_earned >= 1.0:

			achievement_earned[0] = true
			cash += 25.0

			status_label.text = (
				"Achievement unlocked: First Dollar! +$25"
			)

	# -------------------------------------------------------
	# SERIOUS EARNER
	# -------------------------------------------------------

	if not bool(achievement_earned[1]):

		if total_earned >= 2500.0:

			achievement_earned[1] = true
			cash += 250.0

			status_label.text = (
				"Achievement unlocked: Serious Earner! +$250"
			)

	# -------------------------------------------------------
	# BUSINESS OWNER
	# -------------------------------------------------------

	if not bool(achievement_earned[2]):

		if _owned_business_count() >= 2:

			achievement_earned[2] = true
			cash += 1000.0

			status_label.text = (
				"Achievement unlocked: Business Owner! +$1,000"
			)

	# -------------------------------------------------------
	# MONTHLY OPERATOR
	# -------------------------------------------------------

	if not bool(achievement_earned[3]):

		if total_months_completed >= 1:

			achievement_earned[3] = true
			cash += 2500.0

			status_label.text = (
				"Achievement unlocked: Monthly Operator! +$2,500"
			)

	# -------------------------------------------------------
	# COMPANY FOUNDER
	# -------------------------------------------------------

	if not bool(achievement_earned[4]):

		if company_unlocked:

			achievement_earned[4] = true
			cash += 10000.0

			status_label.text = (
				"Achievement unlocked: Company Founder! +$10,000"
			)

	# -------------------------------------------------------
	# BUSINESS TYCOON
	# -------------------------------------------------------

	if not bool(achievement_earned[5]):

		if total_earned >= 1000000.0:

			achievement_earned[5] = true
			cash += 50000.0

			status_label.text = (
				"Achievement unlocked: Business Tycoon! +$50,000"
			)

	_check_missions()

# =========================================================
# MISSIONS
# =========================================================

func _check_missions() -> void:

	if mission_index >= mission_names.size():
		return

	var completed: bool = false

	match mission_index:

		0:
			completed = total_earned >= 100.0

		1:
			completed = total_earned >= 2500.0

		2:
			completed = (
				_owned_business_count() >= 2
			)

		3:
			completed = (
				total_months_completed >= 1
			)

		4:
			completed = total_earned >= 100000.0

	if completed:

		var reward: float = float(
			mission_rewards[mission_index]
		)

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

		return "%.0f" % value

	return "%.0f" % value

# =========================================================
# SAVE
# =========================================================

func _save_game() -> void:

	var data: Dictionary = {
		"cash": cash,
		"total_earned": total_earned,

		"click_value": click_value,
		"click_level": click_level,

		"game_day": game_day,
		"game_month": game_month,

		"boost_active": boost_active,
		"boost_days_left": boost_days_left,

		"total_months_completed":
			total_months_completed,

		"employee_count":
			employee_count,

		"manager_count":
			manager_count,

		"selected_business":
			selected_business,

		"unlocked_businesses":
			unlocked_businesses,

		"business_levels":
			business_levels,

		"business_monthly_revenue":
			business_monthly_revenue,

		"business_monthly_expenses":
			business_monthly_expenses,

		"business_monthly_profit":
			business_monthly_profit,

		"company_unlocked":
			company_unlocked,

		"company_level":
			company_level,

		"mission_index":
			mission_index,

		"missions_completed":
			missions_completed,

		"achievement_earned":
			achievement_earned,

		"last_save_time":
			Time.get_unix_time_from_system()
	}

	var file: FileAccess = FileAccess.open(
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

	var file: FileAccess = FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	if file == null:
		return

	var text: String = file.get_as_text()

	file.close()

	var json: JSON = JSON.new()

	if json.parse(text) != OK:
		return

	var data: Variant = json.data

	if typeof(data) != TYPE_DICTIONARY:
		return

	var saved: Dictionary = data

	# -------------------------------------------------------
	# BASIC
	# -------------------------------------------------------

	cash = float(
		saved.get(
			"cash",
			0.0
		)
	)

	total_earned = float(
		saved.get(
			"total_earned",
			0.0
		)
	)

	click_value = float(
		saved.get(
			"click_value",
			1.0
		)
	)

	click_level = int(
		saved.get(
			"click_level",
			1
		)
	)

	if click_value < 1.0:
		click_value = 1.0

	if click_value > MAX_CLICK_VALUE:
		click_value = MAX_CLICK_VALUE

	if click_level < 1:
		click_level = 1

	if click_level > 10:
		click_level = 10

	# -------------------------------------------------------
	# TIME
	# -------------------------------------------------------

	game_day = int(
		saved.get(
			"game_day",
			1
		)
	)

	game_month = int(
		saved.get(
			"game_month",
			1
		)
	)

	total_months_completed = int(
		saved.get(
			"total_months_completed",
			0
		)
	)

	if game_day < 1:
		game_day = 1

	if game_day > DAYS_PER_MONTH:
		game_day = 1

	if game_month < 1:
		game_month = 1

	if total_months_completed < 0:
		total_months_completed = 0

	# -------------------------------------------------------
	# BOOST
	# -------------------------------------------------------

	boost_active = bool(
		saved.get(
			"boost_active",
			false
		)
	)

	boost_days_left = float(
		saved.get(
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
		saved.get(
			"employee_count",
			0
		)
	)

	manager_count = int(
		saved.get(
			"manager_count",
			0
		)
	)

	if employee_count < 0:
		employee_count = 0

	if manager_count < 0:
		manager_count = 0

	# -------------------------------------------------------
	# SELECTED BUSINESS
	# -------------------------------------------------------

	selected_business = int(
		saved.get(
			"selected_business",
			0
		)
	)

	if selected_business < 0:
		selected_business = 0

	if selected_business >= business_names.size():
		selected_business = 0

	# -------------------------------------------------------
	# BUSINESS ARRAYS
	# -------------------------------------------------------

	var saved_unlocks: Variant = saved.get(
		"unlocked_businesses",
		[true, false, false, false, false]
	)

	var saved_levels: Variant = saved.get(
		"business_levels",
		[1, 0, 0, 0, 0]
	)

	if saved_unlocks is Array:

		var unlock_array: Array = saved_unlocks

		for i in range(
			min(
				unlock_array.size(),
				unlocked_businesses.size()
			)
		):

			unlocked_businesses[i] = bool(
				unlock_array[i]
			)

	# Retail always exists.
	unlocked_businesses[0] = true

	if saved_levels is Array:

		var level_array: Array = saved_levels

		for i in range(
			min(
				level_array.size(),
				business_levels.size()
			)
		):

			business_levels[i] = int(
				level_array[i]
			)

	# Ensure valid levels.
	for i in range(business_levels.size()):

		if bool(unlocked_businesses[i]):

			if int(business_levels[i]) < 1:
				business_levels[i] = 1

		else:

			business_levels[i] = 0

	# -------------------------------------------------------
	# COMPANY
	# -------------------------------------------------------

	company_unlocked = bool(
		saved.get(
			"company_unlocked",
			false
		)
	)

	company_level = int(
		saved.get(
			"company_level",
			0
		)
	)

	if not company_unlocked:

		company_level = 0

	else:

		if company_level < 1:
			company_level = 1

	# -------------------------------------------------------
	# MISSIONS
	# -------------------------------------------------------

	mission_index = int(
		saved.get(
			"mission_index",
			0
		)
	)

	missions_completed = int(
		saved.get(
			"missions_completed",
			0
		)
	)

	if mission_index < 0:
		mission_index = 0

	if mission_index > mission_names.size():
		mission_index = mission_names.size()

	if missions_completed < 0:
		missions_completed = 0

	# -------------------------------------------------------
	# ACHIEVEMENTS
	# -------------------------------------------------------

	var saved_achievements: Variant = saved.get(
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

		var achievement_array: Array = (
			saved_achievements
		)

		for i in range(
			min(
				achievement_array.size(),
				achievement_earned.size()
			)
		):

			achievement_earned[i] = bool(
				achievement_array[i]
			)

	# -------------------------------------------------------
	# RESET RUNTIME TIMER
	# -------------------------------------------------------

	day_timer = 0.0

	_recalculate_businesses()
