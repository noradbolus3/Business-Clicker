extends RefCounted
class_name Progression


# ============================================================
# MISSIONS
# ============================================================

const MISSION_NAMES: Array = [
	"Earn your first $100",
	"Reach $2,500 total earnings",
	"Own 2 businesses",
	"Complete your first month",
	"Earn $100,000 total"
]

const MISSION_TARGETS: Array = [
	100.0,
	2500.0,
	2.0,
	1.0,
	100000.0
]

const MISSION_REWARDS: Array = [
	100.0,
	500.0,
	2500.0,
	5000.0,
	25000.0
]


# ============================================================
# ACHIEVEMENTS
# ============================================================

const ACHIEVEMENT_NAMES: Array = [
	"First Dollar",
	"Serious Earner",
	"Business Owner",
	"Monthly Operator",
	"Company Founder",
	"Business Tycoon"
]

const ACHIEVEMENT_REWARDS: Array = [
	25.0,
	250.0,
	1000.0,
	2500.0,
	10000.0,
	50000.0
]


# ============================================================
# STATE
# ============================================================

var mission_index: int = 0
var missions_completed: int = 0

var achievement_earned: Array = [
	false,
	false,
	false,
	false,
	false,
	false
]


# ============================================================
# CURRENT MISSION
# ============================================================

func get_current_mission_name() -> String:

	if mission_index >= MISSION_NAMES.size():
		return "All missions completed."

	return str(
		MISSION_NAMES[mission_index]
	)


func get_current_mission_target() -> float:

	if mission_index >= MISSION_TARGETS.size():
		return 0.0

	return float(
		MISSION_TARGETS[mission_index]
	)


func get_current_mission_reward() -> float:

	if mission_index >= MISSION_REWARDS.size():
		return 0.0

	return float(
		MISSION_REWARDS[mission_index]
	)


# ============================================================
# MISSION PROGRESS
# ============================================================

func get_mission_progress(
	total_earned: float,
	owned_businesses: int,
	months_completed: int
) -> float:

	if mission_index >= MISSION_NAMES.size():
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
				owned_businesses
			)

		3:
			return float(
				months_completed
			)

		4:
			return min(
				total_earned,
				100000.0
			)

	return 0.0


# ============================================================
# MISSION CHECK
# ============================================================

func check_mission(
	state: GameState,
	businesses: BusinessManager,
	company: CompanyManager
) -> float:

	if mission_index >= MISSION_NAMES.size():
		return 0.0

	var total_earned: float = state.total_earned
	var owned_businesses: int = businesses.get_owned_count()
	var months_completed: int = state.total_months_completed

	var completed: bool = false

	match mission_index:

		0:
			completed = total_earned >= 100.0

		1:
			completed = total_earned >= 2500.0

		2:
			completed = owned_businesses >= 2

		3:
			completed = months_completed >= 1

		4:
			completed = total_earned >= 100000.0

	if not completed:
		return 0.0

	var reward: float = float(
		MISSION_REWARDS[mission_index]
	)

	missions_completed += 1
	mission_index += 1

	return reward


# ============================================================
# ACHIEVEMENT CHECK
# ============================================================

func check_achievements(
	state: GameState,
	businesses: BusinessManager,
	company: CompanyManager
) -> float:

	var total_reward: float = 0.0

	var total_earned: float = state.total_earned
	var owned_businesses: int = businesses.get_owned_count()
	var months_completed: int = state.total_months_completed
	var company_active: bool = company.is_active()


	# --------------------------------------------------------
	# First Dollar
	# --------------------------------------------------------

	if not bool(achievement_earned[0]):

		if total_earned >= 1.0:

			achievement_earned[0] = true
			total_reward += float(
				ACHIEVEMENT_REWARDS[0]
			)


	# --------------------------------------------------------
	# Serious Earner
	# --------------------------------------------------------

	if not bool(achievement_earned[1]):

		if total_earned >= 2500.0:

			achievement_earned[1] = true
			total_reward += float(
				ACHIEVEMENT_REWARDS[1]
			)


	# --------------------------------------------------------
	# Business Owner
	# --------------------------------------------------------

	if not bool(achievement_earned[2]):

		if owned_businesses >= 2:

			achievement_earned[2] = true
			total_reward += float(
				ACHIEVEMENT_REWARDS[2]
			)


	# --------------------------------------------------------
	# Monthly Operator
	# --------------------------------------------------------

	if not bool(achievement_earned[3]):

		if months_completed >= 1:

			achievement_earned[3] = true
			total_reward += float(
				ACHIEVEMENT_REWARDS[3]
			)


	# --------------------------------------------------------
	# Company Founder
	# --------------------------------------------------------

	if not bool(achievement_earned[4]):

		if company_active:

			achievement_earned[4] = true
			total_reward += float(
				ACHIEVEMENT_REWARDS[4]
			)


	# --------------------------------------------------------
	# Business Tycoon
	# --------------------------------------------------------

	if not bool(achievement_earned[5]):

		if total_earned >= 1000000.0:

			achievement_earned[5] = true
			total_reward += float(
				ACHIEVEMENT_REWARDS[5]
			)

	return total_reward


# ============================================================
# MISSION DISPLAY
# ============================================================

func get_mission_text(
	state: GameState,
	businesses: BusinessManager,
	company: CompanyManager
) -> String:

	if mission_index >= MISSION_NAMES.size():

		return "ALL MISSIONS COMPLETED\nStarter campaign completed."

	var progress: float = get_mission_progress(
		state.total_earned,
		businesses.get_owned_count(),
		state.total_months_completed
	)

	var target: float = get_current_mission_target()
	var reward: float = get_current_mission_reward()


	if mission_index == 2:

		return "MISSION 3\nOwn 2 businesses\n\nProgress: %d / 2 businesses\nReward: $%s" % [
			businesses.get_owned_count(),
			_money(reward)
		]


	if mission_index == 3:

		return "MISSION 4\nComplete your first month\n\nProgress: %d / 1 month\nReward: $%s" % [
			state.total_months_completed,
			_money(reward)
		]


	return "MISSION %d\n%s\n\nProgress: $%s / $%s\nReward: $%s" % [
		mission_index + 1,
		get_current_mission_name(),
		_money(progress),
		_money(target),
		_money(reward)
	]


# ============================================================
# ACHIEVEMENT DISPLAY
# ============================================================

func get_achievement_text(
	state: GameState,
	businesses: BusinessManager,
	company: CompanyManager
) -> String:

	var text: String = ""

	for i in range(
		ACHIEVEMENT_NAMES.size()
	):

		var mark: String = "[LOCKED]"

		if bool(achievement_earned[i]):
			mark = "[DONE]"

		text += "%s  %s  •  $%s\n" % [
			mark,
			ACHIEVEMENT_NAMES[i],
			_money(
				ACHIEVEMENT_REWARDS[i]
			)
		]

	return text


# ============================================================
# ACHIEVEMENT HELPERS
# ============================================================

func get_achievement_name(
	index: int
) -> String:

	if index < 0:
		return ""

	if index >= ACHIEVEMENT_NAMES.size():
		return ""

	return str(
		ACHIEVEMENT_NAMES[index]
	)


func get_achievement_reward(
	index: int
) -> float:

	if index < 0:
		return 0.0

	if index >= ACHIEVEMENT_REWARDS.size():
		return 0.0

	return float(
		ACHIEVEMENT_REWARDS[index]
	)


func is_achievement_earned(
	index: int
) -> bool:

	if index < 0:
		return false

	if index >= achievement_earned.size():
		return false

	return bool(
		achievement_earned[index]
	)


# ============================================================
# SAVE DATA
# ============================================================

func get_save_data() -> Dictionary:

	return {
		"mission_index": mission_index,
		"missions_completed": missions_completed,
		"achievement_earned": achievement_earned.duplicate()
	}


# ============================================================
# LOAD DATA
# ============================================================

func load_save_data(
	data: Dictionary
) -> void:

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

	if mission_index > MISSION_NAMES.size():
		mission_index = MISSION_NAMES.size()

	if missions_completed < 0:
		missions_completed = 0

	var saved_achievements: Variant = data.get(
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

		var achievement_array: Array = saved_achievements

		for i in range(
			min(
				achievement_array.size(),
				achievement_earned.size()
			)
		):

			achievement_earned[i] = bool(
				achievement_array[i]
			)


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
