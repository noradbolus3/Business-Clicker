extends RefCounted
class_name SaveManager


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

	file.store_string(
		JSON.stringify(data)
	)

	file.close()

	return true


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


func has_save(
	save_path: String
) -> bool:

	return FileAccess.file_exists(
		save_path
	)


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
