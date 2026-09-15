extends RefCounted
class_name UIManager


var root: Control

var cash_label: Label
var earnings_label: Label
var day_label: Label
var click_label: Label
var boost_label: Label

var mission_label: Label
var achievement_label: Label

var business_label: Label
var company_label: Label
var staff_label: Label

var earn_button: Button
var click_upgrade_button: Button
var boost_button: Button

var employee_button: Button
var manager_button: Button

var business_buttons: Array[Button] = []
var company_button: Button

var status_label: Label


func build(
	parent: Control,
	callbacks: Dictionary
) -> void:

	root = parent

	_create_ui(callbacks)


func _create_ui(callbacks: Dictionary) -> void:

	var background: ColorRect = ColorRect.new()

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.color = Color(
		0.035,
		0.045,
		0.065,
		1.0
	)

	root.add_child(background)


	var scroll: ScrollContainer = ScrollContainer.new()

	scroll.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	scroll.offset_left = 16.0
	scroll.offset_top = 16.0
	scroll.offset_right = -16.0
	scroll.offset_bottom = -16.0

	root.add_child(scroll)


	var main_box: VBoxContainer = VBoxContainer.new()

	main_box.add_theme_constant_override(
		"separation",
		12
	)

	main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	scroll.add_child(main_box)


	var title: Label = Label.new()

	title.text = "BUSINESS CLICKER"

	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	title.add_theme_font_size_override(
		"font_size",
		28
	)

	main_box.add_child(title)


	var subtitle: Label = Label.new()

	subtitle.text = "Build income. Own businesses. Build your company."

	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	subtitle.add_theme_font_size_override(
		"font_size",
		14
	)

	main_box.add_child(subtitle)


	cash_label = _make_label(
		"CASH: $0",
		24
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

	day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	main_box.add_child(day_label)


	status_label = _make_label(
		"Welcome.",
		14
	)

	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	main_box.add_child(status_label)


	earn_button = _make_button(
		"EARN $1"
	)

	earn_button.pressed.connect(
		callbacks["earn"]
	)

	main_box.add_child(earn_button)


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


	boost_label = _make_label(
		"BOOST: READY",
		15
	)

	main_box.add_child(boost_label)


	boost_button = _make_button(
		"ACTIVATE 10X BOOST"
	)

	boost_button.pressed.connect(
		callbacks["boost"]
	)

	main_box.add_child(boost_button)


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


	_add_separator(main_box)


	var business_title: Label = _make_section_title(
		"BUSINESSES"
	)

	main_box.add_child(business_title)


	business_label = _make_label(
		"Businesses owned: 0 / 5",
		16
	)

	main_box.add_child(business_label)


	for index in range(5):

		var business_button: Button = _make_button(
			"BUSINESS %d" % (index + 1)
		)

		business_button.pressed.connect(
			callbacks["business"].bind(index)
		)

		business_buttons.append(
			business_button
		)

		main_box.add_child(
			business_button
		)


	_add_separator(main_box)


	var company_title: Label = _make_section_title(
		"COMPANY"
	)

	main_box.add_child(company_title)


	company_label = _make_label(
		"Company: NOT FORMED",
		16
	)

	main_box.add_child(company_label)


	company_button = _make_button(
		"FORM COMPANY"
	)

	company_button.pressed.connect(
		callbacks["company"]
	)

	main_box.add_child(company_button)


	_add_separator(main_box)


	var mission_title: Label = _make_section_title(
		"MISSION"
	)

	main_box.add_child(mission_title)


	mission_label = _make_label(
		"No mission",
		15
	)

	mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	main_box.add_child(mission_label)


	var achievement_title: Label = _make_section_title(
		"ACHIEVEMENTS"
	)

	main_box.add_child(
		achievement_title
	)


	achievement_label = _make_label(
		"No achievements yet",
		15
	)

	achievement_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	main_box.add_child(
		achievement_label
	)


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

	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	return label


func _make_section_title(
	text_value: String
) -> Label:

	var label: Label = Label.new()

	label.text = text_value

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	label.add_theme_font_size_override(
		"font_size",
		20
	)

	return label


func _make_button(
	text_value: String
) -> Button:

	var button: Button = Button.new()

	button.text = text_value

	button.custom_minimum_size = Vector2(
		0,
		52
	)

	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	button.add_theme_font_size_override(
		"font_size",
		16
	)

	return button


func _add_separator(
	parent: VBoxContainer
) -> void:

	var separator: HSeparator = HSeparator.new()

	parent.add_child(
		separator
	)


func refresh(
	state: GameState,
	businesses: BusinessManager,
	company: CompanyManager,
	progression: Progression
) -> void:

	if cash_label == null:
		return


	cash_label.text = "CASH: $%s" % _money(
		state.cash
	)


	earnings_label.text = "TOTAL EARNED: $%s" % _money(
		state.total_earned
	)


	day_label.text = "DAY %d  •  MONTH %d" % [
		state.game_day,
		state.game_month
	]


	earn_button.text = "EARN $%s" % _money(
		state.get_click_amount()
	)


	click_label.text = "CLICK LEVEL %d  •  $%s / CLICK" % [
		state.click_level,
		_money(state.click_value)
	]


	if state.click_value >= GameState.MAX_CLICK_VALUE:

		click_upgrade_button.text = "CLICK MAXED"

		click_upgrade_button.disabled = true

	else:

		var click_cost: float = _get_click_upgrade_cost(
			state.click_level
		)

		click_upgrade_button.text = "UPGRADE CLICK  •  $%s" % _money(
			click_cost
		)

		click_upgrade_button.disabled = (
			state.cash < click_cost
		)


	if state.boost_active:

		boost_label.text = "BOOST ACTIVE  •  %.1f DAYS LEFT" % (
			state.boost_days_left
		)

		boost_button.text = "BOOST ACTIVE"

		boost_button.disabled = true

	else:

		boost_label.text = "BOOST: READY"

		boost_button.text = "ACTIVATE 10X BOOST"

		boost_button.disabled = false


	staff_label.text = "Employees: %d  •  Managers: %d" % [
		state.employee_count,
		state.manager_count
	]


	var employee_cost: float = (
		1000.0 + float(state.employee_count) * 750.0
	)

	employee_button.text = "HIRE EMPLOYEE  •  $%s" % _money(
		employee_cost
	)

	employee_button.disabled = (
		state.cash < employee_cost
	)


	var manager_cost: float = (
		5000.0 + float(state.manager_count) * 3000.0
	)

	manager_button.text = "HIRE MANAGER  •  $%s" % _money(
		manager_cost
	)

	manager_button.disabled = (
		state.cash < manager_cost
	)


	var owned_count: int = businesses.get_owned_count()

	business_label.text = "Businesses owned: %d / 5" % owned_count


	for index in range(business_buttons.size()):

		var button: Button = business_buttons[index]

		if businesses.is_unlocked(index):

			var level: int = businesses.get_level(
				index
			)

			var revenue: float = businesses.get_business_revenue(
				index
			)

			var upgrade_cost: float = businesses.get_upgrade_cost(
				index
			)

			button.text = "%s  •  LV %d  •  $%s/mo  •  UPGRADE $%s" % [
				businesses.get_business_name(index),
				level,
				_money(revenue),
				_money(upgrade_cost)
			]

			button.disabled = (
				state.cash < upgrade_cost
			)

		else:

			var unlock_cost: float = businesses.get_unlock_cost(
				index
			)

			button.text = "%s  •  UNLOCK $%s" % [
				businesses.get_business_name(index),
				_money(unlock_cost)
			]

			button.disabled = (
				state.cash < unlock_cost
			)


	company_label.text = company.get_status_text()


	if company.is_active():

		var company_cost: float = company.get_upgrade_cost()

		company_button.text = "UPGRADE COMPANY  •  $%s" % _money(
			company_cost
		)

		company_button.disabled = (
			state.cash < company_cost
		)

	else:

		company_button.text = "FORM COMPANY  •  $100000"

		company_button.disabled = (
			owned_count < CompanyManager.COMPANY_REQUIRED_BUSINESSES
			or state.cash < CompanyManager.COMPANY_UNLOCK_COST
		)


	mission_label.text = progression.get_mission_text(
		state,
		businesses,
		company
	)


	achievement_label.text = progression.get_achievement_text(
		state,
		businesses,
		company
	)


func set_status(
	text_value: String
) -> void:

	if status_label == null:
		return

	status_label.text = text_value


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
