extends RefCounted
class_name UIManager


# ============================================================
# UI REFERENCES
# ============================================================

var root: Control

var cash_label: Label
var earnings_label: Label
var day_label: Label
var click_label: Label
var boost_label: Label
var status_label: Label

var staff_label: Label
var business_label: Label
var company_label: Label
var mission_label: Label
var achievement_label: Label
var monthly_label: Label
var stats_label: Label

var earn_button: Button
var click_upgrade_button: Button
var boost_button: Button
var employee_button: Button
var manager_button: Button

var business_buttons: Array[Button] = []
var business_upgrade_button: Button

var company_button: Button


# ============================================================
# BUILD
# ============================================================

func build(
	parent: Control,
	callbacks: Dictionary
) -> void:

	root = parent

	_create_ui(callbacks)


# ============================================================
# CREATE UI
# ============================================================

func _create_ui(callbacks: Dictionary) -> void:

	# --------------------------------------------------------
	# BACKGROUND
	# --------------------------------------------------------

	var background: ColorRect = ColorRect.new()

	background.color = Color("#080C16")

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	root.add_child(background)


	# --------------------------------------------------------
	# SCROLL
	# --------------------------------------------------------

	var scroll: ScrollContainer = ScrollContainer.new()

	scroll.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	scroll.offset_left = 12.0
	scroll.offset_top = 12.0
	scroll.offset_right = -12.0
	scroll.offset_bottom = -12.0

	scroll.horizontal_scroll_mode = (
		ScrollContainer.SCROLL_MODE_DISABLED
	)

	root.add_child(scroll)


	# --------------------------------------------------------
	# MAIN CONTAINER
	# --------------------------------------------------------

	var main_box: VBoxContainer = VBoxContainer.new()

	main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	main_box.add_theme_constant_override(
		"separation",
		10
	)

	scroll.add_child(main_box)


	# --------------------------------------------------------
	# TITLE
	# --------------------------------------------------------

	var title: Label = _make_label(
		"BUSINESS CLICKER",
		30
	)

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	main_box.add_child(title)


	var subtitle: Label = _make_label(
		"BUILD CAPITAL  •  OWN BUSINESSES  •  BUILD A COMPANY",
		13
	)

	subtitle.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	main_box.add_child(subtitle)


	# --------------------------------------------------------
	# MONEY
	# --------------------------------------------------------

	cash_label = _make_label(
		"CASH: $0",
		30
	)

	main_box.add_child(cash_label)


	earnings_label = _make_label(
		"TOTAL EARNED: $0",
		16
	)

	main_box.add_child(earnings_label)


	day_label = _make_label(
		"DAY 1  •  MONTH 1",
		16
	)

	day_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	main_box.add_child(day_label)


	status_label = _make_label(
		"Welcome. Start building your capital.",
		14
	)

	status_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	status_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	main_box.add_child(status_label)


	# --------------------------------------------------------
	# EARN
	# --------------------------------------------------------

	earn_button = _make_button(
		"EARN $1"
	)

	earn_button.custom_minimum_size.y = 72

	earn_button.pressed.connect(
		callbacks["earn"]
	)

	main_box.add_child(earn_button)


	# --------------------------------------------------------
	# CLICKER
	# --------------------------------------------------------

	_add_separator(main_box)

	var click_title: Label = _make_section_title(
		"CLICKER"
	)

	main_box.add_child(click_title)


	click_label = _make_label(
		"CLICK LEVEL 1  •  $1 / CLICK",
		16
	)

	main_box.add_child(click_label)


	click_upgrade_button = _make_button(
		"UPGRADE CLICK"
	)

	click_upgrade_button.pressed.connect(
		callbacks["upgrade_click"]
	)

	main_box.add_child(click_upgrade_button)


	# --------------------------------------------------------
	# BOOST
	# --------------------------------------------------------

	boost_label = _make_label(
		"BOOST: READY",
		15
	)

	boost_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	main_box.add_child(boost_label)


	boost_button = _make_button(
		"ACTIVATE 10X BOOST"
	)

	boost_button.pressed.connect(
		callbacks["boost"]
	)

	main_box.add_child(boost_button)


	# --------------------------------------------------------
	# STAFF
	# --------------------------------------------------------

	_add_separator(main_box)

	var staff_title: Label = _make_section_title(
		"STAFF"
	)

	main_box.add_child(staff_title)


	staff_label = _make_label(
		"Employees: 0  •  Managers: 0",
		15
	)

	main_box.add_child(staff_label)


	employee_button = _make_button(
		"HIRE EMPLOYEE"
	)

	employee_button.pressed.connect(
		callbacks["employee"]
	)

	main_box.add_child(employee_button)


	manager_button = _make_button(
		"HIRE MANAGER"
	)

	manager_button.pressed.connect(
		callbacks["manager"]
	)

	main_box.add_child(manager_button)


	# --------------------------------------------------------
	# BUSINESSES
	# --------------------------------------------------------

	_add_separator(main_box)

	var business_title: Label = _make_section_title(
		"BUSINESSES"
	)

	main_box.add_child(business_title)


	business_label = _make_label(
		"Businesses owned: 1 / 5",
		16
	)

	main_box.add_child(business_label)


	for index in range(5):

		var business_button: Button = _make_button(
			"BUSINESS %d" % (index + 1)
		)

		business_button.custom_minimum_size.y = 64

		business_button.pressed.connect(
			callbacks["business"].bind(index)
		)

		business_buttons.append(
			business_button
		)

		main_box.add_child(
			business_button
		)


	# --------------------------------------------------------
	# BUSINESS UPGRADE
	# --------------------------------------------------------

	business_upgrade_button = _make_button(
		"UPGRADE SELECTED BUSINESS"
	)

	business_upgrade_button.custom_minimum_size.y = 72

	business_upgrade_button.pressed.connect(
		callbacks["business_upgrade"]
	)

	main_box.add_child(
		business_upgrade_button
	)


	# --------------------------------------------------------
	# COMPANY
	# --------------------------------------------------------

	_add_separator(main_box)

	var company_title: Label = _make_section_title(
		"COMPANY"
	)

	main_box.add_child(company_title)


	company_label = _make_label(
		"Company: NOT FORMED",
		16
	)

	company_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	main_box.add_child(company_label)


	company_button = _make_button(
		"FORM COMPANY"
	)

	company_button.custom_minimum_size.y = 64

	company_button.pressed.connect(
		callbacks["company"]
	)

	main_box.add_child(company_button)


	# --------------------------------------------------------
	# MONTHLY REPORT
	# --------------------------------------------------------

	_add_separator(main_box)

	var monthly_title: Label = _make_section_title(
		"MONTHLY BUSINESS REPORT"
	)

	main_box.add_child(monthly_title)


	monthly_label = _make_label(
		"Revenue: $0\nExpenses: $0\nNet Profit: $0",
		15
	)

	monthly_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	main_box.add_child(monthly_label)


	# --------------------------------------------------------
	# MISSIONS
	# --------------------------------------------------------

	_add_separator(main_box)

	var mission_title: Label = _make_section_title(
		"MISSIONS"
	)

	main_box.add_child(mission_title)


	mission_label = _make_label(
		"No mission",
		15
	)

	mission_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	main_box.add_child(mission_label)


	# --------------------------------------------------------
	# ACHIEVEMENTS
	# --------------------------------------------------------

	var achievement_title: Label = _make_section_title(
		"ACHIEVEMENTS"
	)

	main_box.add_child(
		achievement_title
	)


	achievement_label = _make_label(
		"No achievements yet",
		14
	)

	achievement_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	main_box.add_child(
		achievement_label
	)


	# --------------------------------------------------------
	# STATS
	# --------------------------------------------------------

	_add_separator(main_box)

	var stats_title: Label = _make_section_title(
		"GAME STATS"
	)

	main_box.add_child(stats_title)


	stats_label = _make_label(
		"Cash: $0",
		14
	)

	stats_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	main_box.add_child(stats_label)


	# --------------------------------------------------------
	# END SPACE
	# --------------------------------------------------------

	var spacer: Control = Control.new()

	spacer.custom_minimum_size.y = 40

	main_box.add_child(spacer)


# ============================================================
# LABEL
# ============================================================

func _make_label(
	text_value: String,
	font_size: int
) -> Label:

	var label: Label = Label.new()

	label.text = text_value

	label.add_theme_font_size_override(
		"font_size",
		font_size
	)

	label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	return label


# ============================================================
# SECTION TITLE
# ============================================================

func _make_section_title(
	text_value: String
) -> Label:

	var label: Label = Label.new()

	label.text = text_value

	label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	label.add_theme_font_size_override(
		"font_size",
		21
	)

	label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	return label


# ============================================================
# BUTTON
# ============================================================

func _make_button(
	text_value: String
) -> Button:

	var button: Button = Button.new()

	button.text = text_value

	button.custom_minimum_size = Vector2(
		0,
		54
	)

	button.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	button.add_theme_font_size_override(
		"font_size",
		15
	)

	return button


# ============================================================
# SEPARATOR
# ============================================================

func _add_separator(
	parent: VBoxContainer
) -> void:

	var separator: HSeparator = HSeparator.new()

	parent.add_child(
		separator
	)


# ============================================================
# REFRESH
# ============================================================

func refresh(
	state: GameState,
	businesses: BusinessManager,
	company: CompanyManager,
	progression: Progression
) -> void:

	if cash_label == null:
		return


	# --------------------------------------------------------
	# MONEY
	# --------------------------------------------------------

	cash_label.text = "CASH: $%s" % _money(
		state.cash
	)

	earnings_label.text = "TOTAL EARNED: $%s" % _money(
		state.total_earned
	)


	# --------------------------------------------------------
	# TIME
	# --------------------------------------------------------

	day_label.text = "DAY %d / %d  •  MONTH %d" % [
		state.game_day,
		GameState.DAYS_PER_MONTH,
		state.game_month
	]


	# --------------------------------------------------------
	# EARN
	# --------------------------------------------------------

	earn_button.text = "EARN  +$%s" % _money(
		state.get_click_amount()
	)


	# --------------------------------------------------------
	# CLICKER
	# --------------------------------------------------------

	click_label.text = "CLICK LEVEL %d  •  $%s / CLICK" % [
		state.click_level,
		_money(state.click_value)
	]


	if state.click_value >= GameState.MAX_CLICK_VALUE:

		click_upgrade_button.text = (
			"CLICKER MAXED  •  $10 / CLICK"
		)

		click_upgrade_button.disabled = true

	else:

		var click_cost: float = _get_click_upgrade_cost(
			state.click_level
		)

		click_upgrade_button.text = (
			"UPGRADE CLICK  •  COST $%s"
			% _money(click_cost)
		)

		click_upgrade_button.disabled = (
			state.cash < click_cost
		)


	# --------------------------------------------------------
	# BOOST
	# --------------------------------------------------------

	if state.boost_active:

		boost_label.text = (
			"10X BOOST ACTIVE  •  %.1f DAYS LEFT"
			% state.boost_days_left
		)

		boost_button.text = "10X BOOST ACTIVE"

		boost_button.disabled = true

	else:

		boost_label.text = (
			"BOOST READY  •  10X FOR 3 DAYS"
		)

		boost_button.text = "ACTIVATE 10X BOOST"

		boost_button.disabled = false


	# --------------------------------------------------------
	# STAFF
	# --------------------------------------------------------

	staff_label.text = "Employees: %d  •  Managers: %d" % [
		state.employee_count,
		state.manager_count
	]


	var employee_cost: float = (
		1000.0 +
		float(state.employee_count) * 750.0
	)

	employee_button.text = (
		"HIRE EMPLOYEE  •  $%s"
		% _money(employee_cost)
	)

	employee_button.disabled = (
		state.cash < employee_cost
	)


	var manager_cost: float = (
		5000.0 +
		float(state.manager_count) * 3000.0
	)

	manager_button.text = (
		"HIRE MANAGER  •  $%s"
		% _money(manager_cost)
	)

	manager_button.disabled = (
		state.cash < manager_cost
	)


	# --------------------------------------------------------
	# BUSINESSES
	# --------------------------------------------------------

	var owned_count: int = businesses.get_owned_count()

	business_label.text = "BUSINESSES OWNED: %d / %d" % [
		owned_count,
		BusinessManager.BUSINESS_COUNT
	]


	for index in range(
		business_buttons.size()
	):

		var button: Button = business_buttons[index]

		if not businesses.is_valid_business(index):

			button.text = "INVALID BUSINESS"
			button.disabled = true

			continue


		if businesses.is_unlocked(index):

			var level: int = businesses.get_level(
				index
			)

			var revenue: float = businesses.get_business_revenue(
				index
			)

			var profit: float = businesses.get_business_profit(
				index
			)

			var selected_text: String = ""

			if businesses.selected_business == index:

				selected_text = "  [SELECTED]"


			button.text = (
				"%s%s\nLV %d  •  Revenue $%s/mo\nProfit $%s/mo"
				% [
					businesses.get_business_name(index),
					selected_text,
					level,
					_money(revenue),
					_money(profit)
				]
			)

			button.disabled = false

		else:

			var unlock_cost: float = businesses.get_unlock_cost(
				index
			)

			button.text = (
				"%s\nLOCKED  •  UNLOCK $%s"
				% [
					businesses.get_business_name(index),
					_money(unlock_cost)
				]
			)

			button.disabled = (
				state.cash < unlock_cost
			)


	# --------------------------------------------------------
	# BUSINESS UPGRADE
	# --------------------------------------------------------

	var selected_business: int = (
		businesses.selected_business
	)

	if not businesses.is_valid_business(
		selected_business
	):

		business_upgrade_button.text = (
			"SELECT A BUSINESS"
		)

		business_upgrade_button.disabled = true

	elif not businesses.is_unlocked(
		selected_business
	):

		business_upgrade_button.text = (
			"SELECT AN UNLOCKED BUSINESS"
		)

		business_upgrade_button.disabled = true

	else:

		var selected_name: String = (
			businesses.get_business_name(
				selected_business
			)
		)

		var selected_level: int = (
			businesses.get_level(
				selected_business
			)
		)

		var upgrade_cost: float = (
			businesses.get_upgrade_cost(
				selected_business
			)
		)

		business_upgrade_button.text = (
			"UPGRADE %s  •  LV %d  •  COST $%s"
			% [
				selected_name,
				selected_level,
				_money(upgrade_cost)
			]
		)

		business_upgrade_button.disabled = (
			state.cash < upgrade_cost
		)


	# --------------------------------------------------------
	# COMPANY
	# --------------------------------------------------------

	company_label.text = company.get_status_text()


	if company.is_active():

		var company_cost: float = (
			company.get_upgrade_cost()
		)

		company_button.text = (
			"UPGRADE COMPANY  •  $%s"
			% _money(company_cost)
		)

		company_button.disabled = (
			state.cash < company_cost
		)

	else:

		company_button.text = (
			"FORM COMPANY  •  $100000"
		)

		var can_form: bool = true

		if owned_count < CompanyManager.COMPANY_REQUIRED_BUSINESSES:

			can_form = false

		if state.cash < CompanyManager.COMPANY_UNLOCK_COST:

			can_form = false

		company_button.disabled = not can_form


	# --------------------------------------------------------
	# MONTHLY REPORT
	# --------------------------------------------------------

	monthly_label.text = (
		"Monthly Revenue: $%s\n"
		+ "Operating Expenses + Tax: $%s\n"
		+ "NET MONTHLY PROFIT: $%s"
	) % [
		_money(businesses.get_total_revenue()),
		_money(businesses.get_total_expenses()),
		_money(businesses.get_total_profit())
	]


	# --------------------------------------------------------
	# MISSION
	# --------------------------------------------------------

	mission_label.text = progression.get_mission_text(
		state,
		businesses,
		company
	)


	# --------------------------------------------------------
	# ACHIEVEMENTS
	# --------------------------------------------------------

	achievement_label.text = progression.get_achievement_text(
		state,
		businesses,
		company
	)


	# --------------------------------------------------------
	# STATS
	# --------------------------------------------------------

	var company_status: String = "NOT FORMED"

	if company.is_active():

		company_status = "ACTIVE"


	stats_label.text = (
		"Cash: $%s\n"
		+ "Total Earnings: $%s\n"
		+ "Businesses: %d / %d\n"
		+ "Employees: %d\n"
		+ "Managers: %d\n"
		+ "Months Completed: %d\n"
		+ "Click Value: $%s\n"
		+ "Company: %s"
	) % [
		_money(state.cash),
		_money(state.total_earned),
		owned_count,
		BusinessManager.BUSINESS_COUNT,
		state.employee_count,
		state.manager_count,
		state.total_months_completed,
		_money(state.click_value),
		company_status
	]


# ============================================================
# STATUS
# ============================================================

func set_status(
	text_value: String
) -> void:

	if status_label == null:
		return

	status_label.text = text_value


# ============================================================
# CLICK UPGRADE COST
# ============================================================

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


# ============================================================
# MONEY FORMAT
# ============================================================

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
