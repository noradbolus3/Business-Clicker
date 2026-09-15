extends RefCounted
class_name SaveManager


# ============================================================
# SAVE GAME
# ============================================================

func save_game(
	save_path: String,
	data: Dictionary
) -> bool:

	var file: FileAccess = FileAccess.open(
		save_path,
		FileAccess.WRITE
	)

	if file == null:
		return false

	var json_text: String = JSON.stringify(
		data
	)

	file.store_string(
		json_text
	)

	file.close()

	return true


# ============================================================
# LOAD GAME
# ============================================================

func load_game(
	save_path: String
) -> Dictionary:

	if not FileAccess.file_exists(
		save_path
	):
		return {}

	var file: FileAccess = FileAccess.open(
		save_path,
		FileAccess.READ
	)

	if file == null:
		return {}

	var text: String = file.get_as_text()

	file.close()

	if text.is_empty():
		return {}

	var json: JSON = JSON.new()

	var parse_result: Error = json.parse(
		text
	)

	if parse_result != OK:
		return {}

	if typeof(json.data) != TYPE_DICTIONARY:
		return {}

	return json.data as Dictionary


# ============================================================
# CHECK SAVE
# ============================================================

func has_save(
	save_path: String
) -> bool:

	return FileAccess.file_exists(
		save_path
	)


# ============================================================
# DELETE SAVE
# ============================================================

func delete_save(
	save_path: String
) -> bool:

	if not FileAccess.file_exists(
		save_path
	):
		return true

	return DirAccess.remove_absolute(
		save_path
	) == OK
