class_name Save_System extends Node

signal save_requested
signal load_requested

@export var encryption_key : String = "abcdefg1234567"
@export var use_encryption : bool = false

var base_folder = "user://saves"
var default_file_path : String:
	get: return "%s/save_file.tres" % [base_folder]
var save_object: Save_File = Save_File.new()

func save_entity(id: String, what: Variant):
	save_object.dictionary[id] = what

func load_entity(id: String) -> Variant:
	return save_object.dictionary.get(id)

func save(file_path : String = default_file_path) -> Error:
	DirAccess.make_dir_recursive_absolute(base_folder)
	save_requested.emit()
	var successful: Error = ResourceSaver.save(save_object, file_path)
	assert(successful == OK)
	if use_encryption:
		_encrypt_file(file_path)
		DirAccess.remove_absolute(file_path)
	return successful

func load_savefile(file_path : String = default_file_path):
	if use_encryption:
		_decrypt_file(file_path)
	save_object = ResourceLoader.load(file_path, "", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
	load_requested.emit()
	if use_encryption:
		DirAccess.remove_absolute(file_path)

func _encrypt_file(filepath: String):
	var encrypted_filepath = _get_encrypted_file_name(filepath)
	var cleartext_file : FileAccess = FileAccess.open(filepath, FileAccess.READ)
	var encrypted_file: FileAccess = FileAccess.open_encrypted_with_pass(encrypted_filepath, FileAccess.WRITE, encryption_key)
	encrypted_file.store_string(cleartext_file.get_as_text())
	
	cleartext_file.close()
	encrypted_file.close()

func _decrypt_file(filepath: String):
	var encrypted_filepath = _get_encrypted_file_name(filepath)
	var cleartext_file : FileAccess = FileAccess.open(filepath, FileAccess.WRITE)
	var encrypted_file: FileAccess = FileAccess.open_encrypted_with_pass(encrypted_filepath, FileAccess.READ, encryption_key)
	cleartext_file.store_string(encrypted_file.get_as_text())
	
	cleartext_file.close()
	encrypted_file.close()

func _get_encrypted_file_name(cleartext_filepath: String) -> String:
	var filename_with_extension = cleartext_filepath.split("/")
	filename_with_extension = filename_with_extension[filename_with_extension.size() - 1] as String
	var prefix = cleartext_filepath.replace(filename_with_extension, "")
	var filename_without_extension = filename_with_extension.split(".")[0]
	var extension = filename_with_extension.replace(filename_without_extension, "")
	# TODO: also encrypt save name
	var encrypted_filepath = prefix + filename_without_extension + ".crypt" + extension
	return encrypted_filepath

# Ref: https://forum.godotengine.org/t/how-to-load-and-save-things-with-godot-a-complete-tutorial-about-serialization/44515
#region ##################### Save / load INI ############################
var save_path_ini := "user://player_data.ini"

func save_ini() -> void:
	var config_file := ConfigFile.new()
	var object: Label = Label.new()

	config_file.set_value("<Section_name>", "text", object.text)
	
	var error := config_file.save(save_path_ini)
	if error:
		print("An error happened while saving data: ", error)

func load_ini() -> void:
	var config_file := ConfigFile.new()
	var error := config_file.load(save_path_ini)

	if error:
		print("An error happened while loading data: ", error)
		return

	var object = Label.new()
	object.text = config_file.get_value("<Section_name>", "text", "1")
#endregion
