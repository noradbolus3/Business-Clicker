extends RefCounted
class_name CompanyManager

const COMPANY_UNLOCK_COST: float = 100000.0
const COMPANY_REQUIRED_BUSINESSES: int = 2

var company_unlocked: bool = false
var company_level: int = 0


func can_form_company(
	owned_businesses: int,
	cash: float
) -> Dictionary:

	if company_unlocked:
		return {
			"success": false,
			"cost": 0.0,
			"message": "Company already exists."
		}

	if owned_businesses < COMPANY_REQUIRED_BUSINESSES:
		return {
			"success": false,
			"cost": COMPANY_UNLOCK_COST,
			"message": "Own at least 2 businesses first."
		}

	if cash < COMPANY_UNLOCK_COST:
		return {
			"success": false,
			"cost": COMPANY_UNLOCK_COST,
			"message": "Not enough cash."
		}

	return {
		"success": true,
		"cost": COMPANY_UNLOCK_COST,
		"message": "Company can be formed."
	}


func form_company(
	owned_businesses: int,
	cash: float
) -> Dictionary:

	var check: Dictionary = can_form_company(
		owned_businesses,
		cash
	)

	if not bool(check["success"]):
		return check

	company_unlocked = true
	company_level = 1

	return {
		"success": true,
		"cost": COMPANY_UNLOCK_COST,
		"message": "Company founded."
	}


func can_upgrade_company(cash: float) -> Dictionary:

	if not company_unlocked:
		return {
			"success": false,
			"cost": 0.0,
			"message": "Form your company first."
		}

	var cost: float = get_upgrade_cost()

	if cash < cost:
		return {
			"success": false,
			"cost": cost,
			"message": "Not enough cash."
		}

	return {
		"success": true,
		"cost": cost,
		"message": "Company can be upgraded."
	}


func upgrade_company(cash: float) -> Dictionary:

	var check: Dictionary = can_upgrade_company(
		cash
	)

	if not bool(check["success"]):
		return check

	company_level += 1

	return {
		"success": true,
		"cost": float(check["cost"]),
		"message": "Company upgraded."
	}


func get_upgrade_cost() -> float:

	if company_level < 1:
		return COMPANY_UNLOCK_COST

	return 25000.0 * pow(
		1.75,
		float(company_level - 1)
	)


func get_revenue_multiplier() -> float:

	if not company_unlocked:
		return 1.0

	if company_level <= 1:
		return 1.0

	return 1.0 + (
		float(company_level - 1) *
		0.10
	)


func get_monthly_multiplier() -> float:
	return get_revenue_multiplier()


func get_level() -> int:
	return company_level


func is_active() -> bool:
	return company_unlocked


func get_status_text() -> String:

	if not company_unlocked:
		return "Company: NOT FORMED"

	return "Company: ACTIVE  •  Level %d" % company_level


func get_save_data() -> Dictionary:
	return {
		"company_unlocked": company_unlocked,
		"company_level": company_level
	}


func load_save_data(data: Dictionary) -> void:

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

	if not company_unlocked:
		company_level = 0
		return

	if company_level < 1:
		company_level = 1
