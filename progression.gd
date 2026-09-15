extends RefCounted
class_name Progression

# =========================================================
# MISSIONS
# =========================================================

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

# =========================================================
# ACHIEVEMENTS
# =========================================================

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

# =========================================================
# STATE
# =========================================================

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


# =========================================================
# MISSION PROGRESS
# =========================================================

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


func check_mission(
	total_earned: float,
	owned_businesses: int,
	months_completed: int
) -> Dictionary:

	if mission_index >= MISSION_NAMES.size():
		return {
			"completed": false,
			"reward": 0.0,
			"mission_index": mission_index
		}

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
		return {
			"completed": false,
			"reward": 0.0,
			"mission_index": mission_index
		}

	var completed_index: int = mission_index
	var reward: float = float(
		MISSION_REWARDS[completed_index]
	)

	missions_completed += 1
	mission_index += 1

	return {
		"completed": true,
		"reward": reward,
		"mission_index": completed_index,
		"next_mission": mission_index
	}


# =========================================================
# ACHIEVEMENTS
# =========================================================

func check_achievements(
	total_earned: float,
	owned_businesses: int,
	months_completed: int,
	company_active: bool
) -> Array:

	var unlocked: Array = []

	# First Dollar
	if (
		not bool(achievement_earned[0])
		and total_earned >= 1.0
	):
		achievement_earned[0] = true
		unlocked.append(0)

	# Serious Earner
	if (
		not bool(achievement_earned[1])
		and total_earned >= 2500.0
	):
		achievement_earned[1] = true
		unlocked.append(1)

	# Business Owner
	if (
		not bool(achievement_earned[2])
		and owned_businesses >= 2
	):
		achievement_earned[2] = true
		unlocked.append(2)

	# Monthly Operator
	if (
		not bool(achievement_earned[3])
		and months_completed >= 1
	):
		achievement_earned[3] = true
		unlocked.append(3)

	# Company Founder
	if (
		not bool(achievement_earned[4])
		and company_active
	):
		achievement_earned[4] = true
		unlocked.append(4)

	# Business Tycoon
	if (
		not bool(achievement_earned[5])
		and total_earned >= 1000000.0
	):
		achievement_earned[5] = true
		unlocked.append(5)

	return unlocked


func get_achievement_name(index: int) -> String:

	if index < 0 or index >= ACHIEVEMENT_NAMES.size():
		return ""

	return str(
		ACHIEVEMENT_NAMES[index]
	)


func get_achievement_reward(index: int) -> float:

	if index < 0 or index >= ACHIEVEMENT_REWARDS.size():
		return 0.0

	return float(
		ACHIEVEMENT_REWARDS[index]
	)


func is_achievement_earned(index: int) -> bool:

	if index < 0 or index >= achievement_earned.size():
		return false

	return bool(
		achievement_earned[index]
	)


# =========================================================
# DISPLAY
# =========================================================

func get_mission_text(
	total_earned: float,
	owned_businesses: int,
	months_completed: int
) -> String:

	if mission_index >= MISSION_NAMES.size():

		return (
			"ALL MISSIONS COMPLETED\n"
			"Starter campaign completed."
		)

	var progress: float = get_mission_progress(
		total_earned,
		owned_businesses,
		months_completed
	)

	var target: float = get_current_mission_target()
	var reward: float = get_current_mission_reward()

	if mission_index == 2:

		return (
			"MISSION 3\n"
			"Own 2 businesses\n\n"
			"Progress: %d / 2 businesses\n"
			"Reward: $%s"
			% [
				owned_businesses,
				_money(reward)
			]
		)

	if mission_index == 3:

		return (
			"MISSION 4\n"
			"Complete your first month\n\n"
			"Progress: %d / 1 month\n"
			"Reward: $%s"
			% [
				months_completed,
				_money(reward)
			]
		)

	return (
		"MISSION %d\n"
		"%s\n\n"
		"Progress: $%s / $%s\n"
		"Reward: $%s"
		% [
			mission_index + 1,
			get_current_mission_name(),
			_money(progress),
			_money(target),
			_money(reward)
		]
	)


func get_achievement_text() -> String:

	var text: String = ""

	for i in range(ACHIEVEMENT_NAMES.size()):

		var mark: String = "[LOCKED]"

		if bool(achievement_earned[i]):
			mark = "[DONE]"

		text += (
			"%s  %s\n"
			% [
				mark,
				ACHIEVEMENT_NAMES[i]
			]
		)

	return text


# =========================================================
# SAVE / LOAD
# =========================================================

func get_save_data() -> Dictionary:

	return {
		"mission_index": mission_index,
		"missions_completed": missions_completed,
		"achievement_earned": achievement_earned.duplicate()
	}


func load_save_data(data: Dictionary) -> void:

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
