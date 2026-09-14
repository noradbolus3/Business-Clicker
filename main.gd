extends Control

const SAVE_PATH := "user://business_clicker_save.json"

var cash: float = 0.0
var total_earned: float = 0.0
var tap_value: float = 10.0
var passive_income: float = 0.0

var upgrade_level: int = 0
var manager_level: int = 0
var last_save_time: int = 0

var cash_label: Label
var rate_label: Label
var tap_button: Button
var tap_upgrade_button: Button
var manager_button: Button
var business_label: Label
var status_label: Label


func _ready() -> void:
	_build_ui()
	_load_game()
	_refresh_ui()


func _process(delta: float) -> void:
	if passive_income > 0.0:
		cash += passive_income * delta
		total_earned += passive_income * delta
		_refresh_ui()


func _build_ui() -> void:

	var background := ColorRect.new()
	background.color = Color("#090d18")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)


	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_bottom", 34)

	add_child(margin)


	var main := VBoxContainer.new()
	main.add_theme_constant_override("separation", 18)
	margin.add_child(main)


	var title := Label.new()
	title.text = "BUSINESS CLICKER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	main.add_child(title)


	cash_label = Label.new()
	cash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cash_label.add_theme_font_size_override("font_size", 46)
	main.add_child(cash_label)


	rate_label = Label.new()
	rate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rate_label.add_theme_font_size_override("font_size", 20)
	main.add_child(rate_label)


	var spacer := Control.new()
	spacer.custom_minimum_size.y = 22
	main.add_child(spacer)


	tap_button = Button.new()
	tap_button.text = "EARN CASH\n+₹10"

	tap_button.custom_minimum_size = Vector2(0, 230)

	tap_button.add_theme_font_size_override("font_size", 34)

	tap_button.pressed.connect(_on_tap)

	main.add_child(tap_button)


	status_label = Label.new()
	status_label.text = "Start building your first business."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	main.add_child(status_label)


	var upgrades_title := Label.new()
	upgrades_title.text = "UPGRADES"
	upgrades_title.add_theme_font_size_override("font_size", 24)

	main.add_child(upgrades_title)


	tap_upgrade_button = Button.new()
	tap_upgrade_button.custom_minimum_size.y = 72

	tap_upgrade_button.pressed.connect(_buy_tap_upgrade)

	main.add_child(tap_upgrade_button)


	manager_button = Button.new()
	manager_button.custom_minimum_size.y = 72

	manager_button.pressed.connect(_buy_manager)

	main.add_child(manager_button)


	business_label = Label.new()
	business_label.add_theme_font_size_override("font_size", 22)
	business_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	main.add_child(business_label)


	var save_button := Button.new()
	save_button.text = "SAVE GAME"
	save_button.custom_minimum_size.y = 62

	save_button.pressed.connect(_save_game)

	main.add_child(save_button)


func _on_tap() -> void:

	cash += tap_value
	total_earned += tap_value

	status_label.text = "Revenue received. Keep growing!"

	_refresh_ui()


func _buy_tap_upgrade() -> void:

	var cost := _tap_upgrade_cost()

	if cash < cost:
		status_label.text = "Not enough cash."
		return

	cash -= cost

	upgrade_level += 1

	tap_value = 10.0 * pow(1.55, upgrade_level)

	status_label.text = "Tap power upgraded!"

	_refresh_ui()

	_save_game()


func _buy_manager() -> void:

	var cost := _manager_cost()

	if cash < cost:
		status_label.text = "Not enough cash for a manager."
		return

	cash -= cost

	manager_level += 1

	passive_income += 2.0 * pow(1.65, manager_level - 1)

	status_label.text = "Manager hired!"

	_refresh_ui()

	_save_game()


func _tap_upgrade_cost() -> float:

	return 100.0 * pow(1.7, upgrade_level)


func _manager_cost() -> float:

	return 750.0 * pow(1.85, manager_level)


func _refresh_ui() -> void:

	cash_label.text = "₹%s" % _money(cash)

	rate_label.text = "Passive income: ₹%s / sec" % _money(passive_income)

	tap_button.text = "EARN CASH\n+₹%s" % _money(tap_value)


	tap_upgrade_button.text = (
		"UPGRADE TAP  •  Lv.%d\nCost: ₹%s"
		% [
			upgrade_level + 1,
			_money(_tap_upgrade_cost())
		]
	)


	manager_button.text = (
		"HIRE MANAGER  •  Lv.%d\nCost: ₹%s  •  +₹%s/sec"
		% [
			manager_level + 1,
			_money(_manager_cost()),
			_money(2.0 * pow(1.65, manager_level))
		]
	)


	business_label.text = (
		"🏪 Current business: Starter Shop\n"
		+ "📈 Total revenue: ₹%s\n"
		+ "👔 Managers: %d"
		% [
			_money(total_earned),
			manager_level
		]
	)


func _money(value: float) -> String:

	if value >= 10000000.0:
		return "%.2fCr" % (value / 10000000.0)

	if value >= 100000.0:
		return "%.2fL" % (value / 100000.0)

	if value >= 1000.0:
		return "%.1fK" % (value / 1000.0)

	return "%.0f" % value


func _save_game() -> void:

	var data := {
		"cash": cash,
		"total_earned": total_earned,
		"tap_value": tap_value,
		"passive_income": passive_income,
		"upgrade_level": upgrade_level,
		"manager_level": manager_level,
		"last_save_time": Time.get_unix_time_from_system()
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file:
		file.store_string(JSON.stringify(data))
		status_label.text = "Game saved."


func _load_game() -> void:

	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		return

	var parsed = JSON.parse_string(file.get_as_text())

	if typeof(parsed) != TYPE_DICTIONARY:
		return

	cash = float(parsed.get("cash", 0.0))
	total_earned = float(parsed.get("total_earned", 0.0))
	tap_value = float(parsed.get("tap_value", 10.0))
	passive_income = float(parsed.get("passive_income", 0.0))

	upgrade_level = int(parsed.get("upgrade_level", 0))
	manager_level = int(parsed.get("manager_level", 0))

	last_save_time = int(
		parsed.get(
			"last_save_time",
			Time.get_unix_time_from_system()
		)
	)

	var now := int(Time.get_unix_time_from_system())

	var elapsed := clamp(
		now - last_save_time,
		0,
		8 * 60 * 60
	)

	if passive_income > 0.0 and elapsed > 5:

		var offline := passive_income * float(elapsed)

		cash += offline
		total_earned += offline

		status_label.text = (
			"Welcome back! Offline earnings: ₹%s"
			% _money(offline)
		)


func _notification(what: int) -> void:

	if what == NOTIFICATION_WM_CLOSE_REQUEST:

		_save_game()

		get_tree().quit()
