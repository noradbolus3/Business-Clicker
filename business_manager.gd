extends RefCounted
class_name BusinessManager


# ============================================================
# BUSINESS CONSTANTS
# ============================================================

const BUSINESS_COUNT: int = 5

const BUSINESS_NAMES: Array = [
	"Retail Shop",
	"Car Wash",
	"Coffee Shop",
	"Supermarket",
	"Restaurant"
]

const BUSINESS_UNLOCK_COSTS: Array = [
	0.0,
	2500.0,
	10000.0,
	50000.0,
	150000.0
]

# Monthly revenue at Level 1.
const BUSINESS_BASE_REVENUE: Array = [
	1500.0,
	6000.0,
	15000.0,
	55000.0,
	150000.0
]

# Monthly operating expenses at Level 1.
const BUSINESS_BASE_EXPENSES: Array = [
	850.0,
	3600.0,
	9000.0,
	33000.0,
	90000.0
]

# Level 1 -> Level 2 upgrade starting costs.
const BUSINESS_UPGRADE_BASE_COST: Array = [
	500.0,
	2000.0,
	7500.0,
	30000.0,
	90000.0
]

const BUSINESS_LEVEL_MULTIPLIER: float = 1.55
const BUSINESS_EXPENSE_MULTIPLIER: float = 1.42
const BUSINESS_UPGRADE_COST_MULTIPLIER: float = 1.60

const EMPLOYEE_REVENUE_BONUS: float = 0.025
const MANAGER_EXPENSE_REDUCTION: float = 0.04
const MIN_MANAGER_EXPENSE_MULTIPLIER: float = 0.60

const TAX_RATE: float = 0.15


# ============================================================
# BUSINESS STATE
# ============================================================

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

var selected_business: int = 0

var company_multiplier: float = 1.0

var total_revenue: float = 0.0
var total_expenses: float = 0.0
var total_profit: float = 0.0


# ============================================================
# INITIALIZATION
# ============================================================

func _init() -> void:
	recalculate(0, 0, 1.0)


# ============================================================
# BUSINESS SELECTION
# ============================================================

func select_business(index: int) -> bool:
	if not is_valid_business(index):
		return false

	if not bool(unlocked_businesses[index]):
		return false

	selected_business = index

	return true


# ============================================================
# BUSINESS UNLOCK
# ============================================================

func unlock_business(index: int, cash: float) -> Dictionary:
	if not is_valid_business(index):
		return {
			"success": false,
			"cost": 0.0,
			"message": "Invalid business."
		}

	if bool(unlocked_businesses[index]):
		selected_business = index

		return {
			"success": true,
			"cost": 0.0,
			"message": "Business selected."
		}

	var cost: float = float(
		BUSINESS_UNLOCK_COSTS[index]
	)

	if cash < cost:
		return {
			"success": false,
			"cost": cost,
			"message": "Not enough cash."
		}

	unlocked_businesses[index] = true
	business_levels[index] = 1
	selected_business = index

	return {
		"success": true,
		"cost": cost,
		"message": "Business unlocked."
	}


# ============================================================
# BUSINESS UPGRADE
# ============================================================

func upgrade_business(index: int, cash: float) -> Dictionary:
	if not is_valid_business(index):
		return {
			"success": false,
			"cost": 0.0,
			"message": "Invalid business."
		}

	if not bool(unlocked_businesses[index]):
		return {
			"success": false,
			"cost": 0.0,
			"message": "Unlock this business first."
		}

	var cost: float = get_upgrade_cost(index)

	if cash < cost:
		return {
			"success": false,
			"cost": cost,
			"message": "Not enough cash."
		}

	business_levels[index] = int(
		business_levels[index]
	) + 1

	return {
		"success": true,
		"cost": cost,
		"message": "Business upgraded."
	}


func get_upgrade_cost(index: int) -> float:
	if not is_valid_business(index):
		return 0.0

	var level: int = int(
		business_levels[index]
	)

	if level < 1:
		level = 1

	var base_cost: float = float(
		BUSINESS_UPGRADE_BASE_COST[index]
	)

	return base_cost * pow(
		BUSINESS_UPGRADE_COST_MULTIPLIER,
		float(level - 1)
	)


# ============================================================
# BUSINESS INFORMATION
# ============================================================

func get_unlock_cost(index: int) -> float:
	if not is_valid_business(index):
		return 0.0

	return float(
		BUSINESS_UNLOCK_COSTS[index]
	)


func is_unlocked(index: int) -> bool:
	if not is_valid_business(index):
		return false

	return bool(
		unlocked_businesses[index]
	)


func get_level(index: int) -> int:
	if not is_valid_business(index):
		return 0

	return int(
		business_levels[index]
	)


func get_business_name(index: int) -> String:
	if not is_valid_business(index):
		return ""

	return str(
		BUSINESS_NAMES[index]
	)


func get_business_revenue(index: int) -> float:
	if not is_valid_business(index):
		return 0.0

	return float(
		business_monthly_revenue[index]
	)


func get_business_expenses(index: int) -> float:
	if not is_valid_business(index):
		return 0.0

	return float(
		business_monthly_expenses[index]
	)


func get_business_profit(index: int) -> float:
	if not is_valid_business(index):
		return 0.0

	return float(
		business_monthly_profit[index]
	)


# ============================================================
# BUSINESS RECALCULATION
# ============================================================

func recalculate(
	employee_count: int,
	manager_count: int,
	company_revenue_multiplier: float = 1.0
) -> void:

	company_multiplier = max(
		1.0,
		company_revenue_multiplier
	)

	total_revenue = 0.0
	total_expenses = 0.0
	total_profit = 0.0

	var employee_multiplier: float = (
		1.0 +
		float(employee_count) * EMPLOYEE_REVENUE_BONUS
	)

	var manager_multiplier: float = max(
		MIN_MANAGER_EXPENSE_MULTIPLIER,
		1.0 -
		float(manager_count) * MANAGER_EXPENSE_REDUCTION
	)

	for i in range(BUSINESS_COUNT):

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
			float(BUSINESS_BASE_REVENUE[i]) *
			pow(
				BUSINESS_LEVEL_MULTIPLIER,
				float(level - 1)
			)
		)

		var operating_expenses: float = (
			float(BUSINESS_BASE_EXPENSES[i]) *
			pow(
				BUSINESS_EXPENSE_MULTIPLIER,
				float(level - 1)
			)
		)

		# Employees increase operational capacity.
		revenue *= employee_multiplier

		# Managers reduce operating expenses.
		operating_expenses *= manager_multiplier

		# Company improves portfolio performance.
		revenue *= company_multiplier

		var profit_before_tax: float = (
			revenue -
			operating_expenses
		)

		if profit_before_tax < 0.0:
			profit_before_tax = 0.0

		var tax: float = (
			profit_before_tax *
			TAX_RATE
		)

		var net_profit: float = (
			profit_before_tax -
			tax
		)

		business_monthly_revenue[i] = revenue

		business_monthly_expenses[i] = (
			operating_expenses +
			tax
		)

		business_monthly_profit[i] = net_profit

		total_revenue += revenue

		total_expenses += (
			operating_expenses +
			tax
		)

		total_profit += net_profit


# ============================================================
# TOTALS
# ============================================================

func get_owned_count() -> int:
	var count: int = 0

	for unlocked in unlocked_businesses:
		if bool(unlocked):
			count += 1

	return count


func get_total_revenue() -> float:
	return total_revenue


func get_total_expenses() -> float:
	return total_expenses


func get_total_profit() -> float:
	return total_profit


# ============================================================
# COMPANY MULTIPLIER
# ============================================================

func set_company_multiplier(multiplier: float) -> void:
	company_multiplier = max(
		1.0,
		multiplier
	)


# ============================================================
# VALIDATION
# ============================================================

func is_valid_business(index: int) -> bool:
	return index >= 0 and index < BUSINESS_COUNT


# ============================================================
# SAVE
# ============================================================

func get_save_data() -> Dictionary:
	return {
		"selected_business": selected_business,
		"unlocked_businesses": unlocked_businesses.duplicate(),
		"business_levels": business_levels.duplicate(),
		"business_monthly_revenue": business_monthly_revenue.duplicate(),
		"business_monthly_expenses": business_monthly_expenses.duplicate(),
		"business_monthly_profit": business_monthly_profit.duplicate()
	}


# ============================================================
# LOAD
# ============================================================

func load_save_data(data: Dictionary) -> void:

	selected_business = int(
		data.get(
			"selected_business",
			0
		)
	)

	if not is_valid_business(selected_business):
		selected_business = 0

	var saved_unlocks: Variant = data.get(
		"unlocked_businesses",
		[true, false, false, false, false]
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

	# Retail Shop always exists.
	unlocked_businesses[0] = true

	var saved_levels: Variant = data.get(
		"business_levels",
		[1, 0, 0, 0, 0]
	)

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

	for i in range(BUSINESS_COUNT):

		if bool(unlocked_businesses[i]):

			if int(business_levels[i]) < 1:
				business_levels[i] = 1

		else:

			business_levels[i] = 0

	# --------------------------------------------------------
	# RESTORE CALCULATED VALUES
	# --------------------------------------------------------

	var saved_revenue: Variant = data.get(
		"business_monthly_revenue",
		[]
	)

	if saved_revenue is Array:
		var revenue_array: Array = saved_revenue

		for i in range(
			min(
				revenue_array.size(),
				business_monthly_revenue.size()
			)
		):
			business_monthly_revenue[i] = float(
				revenue_array[i]
			)

	var saved_expenses: Variant = data.get(
		"business_monthly_expenses",
		[]
	)

	if saved_expenses is Array:
		var expense_array: Array = saved_expenses

		for i in range(
			min(
				expense_array.size(),
				business_monthly_expenses.size()
			)
		):
			business_monthly_expenses[i] = float(
				expense_array[i]
			)

	var saved_profit: Variant = data.get(
		"business_monthly_profit",
		[]
	)

	if saved_profit is Array:
		var profit_array: Array = saved_profit

		for i in range(
			min(
				profit_array.size(),
				business_monthly_profit.size()
			)
		):
			business_monthly_profit[i] = float(
				profit_array[i]
			)
