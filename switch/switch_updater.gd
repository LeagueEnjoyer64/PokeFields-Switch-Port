extends Node
# Public update feed contains app files only. ROMs and account/settings data stay in user://.
const PORT_CODE: int = 470000
const PORT_VERSION: String = "47.0.0"
const ENGINE_ID: String = "0.3.9-pf-tls-awake-20261028"
const FEED: String = "https://github.com/LeagueEnjoyer64/PokeFields-Switch-Port/releases/latest/download/update.json"
const ASSET_PREFIX: String = "https://github.com/LeagueEnjoyer64/PokeFields-Switch-Port/releases/download/"
const TRUST_BUNDLE: String = "res://switch/update-ca-bundle.pem"
const INSTALL: String = "sdmc:/switch/PokeFields/"
var _busy: bool = false
var _dialog: ConfirmationDialog

func _ready() -> void:
	if OS.get_name() != "Switch":
		return
	await get_tree().create_timer(4.0).timeout
	check_for_updates()

func _http(url: String, destination: String = "", limit: int = 65536) -> Array:
	var ca: = X509Certificate.new()
	if ca.load(TRUST_BUNDLE) != OK:
		return []
	var request_node: = HTTPRequest.new()
	request_node.set_tls_options(TLSOptions.client(ca))
	request_node.use_threads = true
	request_node.timeout = 120.0 if not destination.is_empty() else 15.0
	request_node.body_size_limit = limit
	request_node.download_file = destination
	add_child(request_node)
	var error: = request_node.request(url, PackedStringArray(["User-Agent: PokeFields-Switch/" + PORT_VERSION]))
	if error != OK:
		request_node.queue_free()
		return []
	var result: Array = await request_node.request_completed
	request_node.queue_free()
	return result

func check_for_updates() -> void:
	if _busy:
		return
	_busy = true
	var result: Array = await _http(FEED)
	if result.size() != 4 or result[0] != HTTPRequest.RESULT_SUCCESS or result[1] != 200:
		_busy = false
		return
	var manifest: Variant = JSON.parse_string(result[3].get_string_from_utf8())
	if not manifest is Dictionary or int(manifest.get("schema", 0)) != 1 or int(manifest.get("code", 0)) <= PORT_CODE:
		_busy = false
		return
	if not _valid_asset(manifest.get("pck", {}), "PokeFields.pck"):
		_busy = false
		return
	var needs_engine: bool = str(manifest.get("engine_id", "")) != ENGINE_ID
	if needs_engine and not _valid_asset(manifest.get("nro", {}), "PokeFields.nro"):
		_busy = false
		return
	_dialog = ConfirmationDialog.new()
	_dialog.title = "PokeFields update"
	_dialog.dialog_text = "Version %s is available. Download it now?\nYour ROMs, settings and login data are kept.\nYou choose when to close the game and apply it." % str(manifest.get("version", "new"))
	_dialog.ok_button_text = "Download update"
	_dialog.cancel_button_text = "Later"
	_dialog.min_size = Vector2i(680, 240)
	add_child(_dialog)
	_dialog.confirmed.connect(_download.bind(manifest, needs_engine))
	_dialog.canceled.connect(func(): _busy = false; _dialog.queue_free())
	_dialog.popup_centered()

func _valid_asset(value: Variant, filename: String) -> bool:
	if not value is Dictionary:
		return false
	var url: String = str(value.get("url", ""))
	var digest: String = str(value.get("sha256", ""))
	if not url.begins_with(ASSET_PREFIX) or not url.ends_with("/" + filename):
		return false
	var remaining: String = url.trim_prefix(ASSET_PREFIX)
	if remaining.get_slice_count("/") != 2 or ".." in remaining or "?" in remaining or "#" in remaining:
		return false
	if digest.length() != 64 or not digest.is_valid_hex_number(false):
		return false
	return int(value.get("size", 0)) > 0 and int(value.get("size", 0)) <= 512 * 1024 * 1024

func _download(manifest: Dictionary, needs_engine: bool) -> void:
	_dialog.queue_free()
	var notice: = AcceptDialog.new()
	notice.title = "Downloading PokeFields update"
	notice.dialog_text = "Downloading and checking the update. Please keep the game open."
	notice.min_size = Vector2i(680, 220)
	notice.get_ok_button().hide()
	notice.exclusive = true
	add_child(notice)
	notice.popup_centered()
	var files: Array[String] = ["pck"]
	if needs_engine:
		files.push_front("nro")
	var ready: Array[String] = []
	for kind in files:
		var info: Dictionary = manifest[kind]
		var filename: String = "PokeFields." + kind
		var path: String = INSTALL + filename + ".download"
		var result: Array = await _http(str(info.url), path, int(info.size))
		var file: = FileAccess.open(path, FileAccess.READ)
		var size: int = file.get_length() if file != null else -1
		file = null
		var valid: bool = result.size() == 4 and result[0] == HTTPRequest.RESULT_SUCCESS and result[1] == 200
		if not valid or size != int(info.size) or FileAccess.get_sha256(path) != str(info.sha256):
			DirAccess.remove_absolute(path)
			for pending in ready:
				DirAccess.remove_absolute(pending)
			_fail(notice, "The download could not be verified. Your installed game is unchanged. Please try again later.")
			return
		ready.append(path)
	# A previous staged update belongs to an earlier transaction. Apply it first.
	for path in ready:
		if FileAccess.file_exists(path.trim_suffix(".download") + ".next"):
			for downloaded in ready:
				DirAccess.remove_absolute(downloaded)
			_fail(notice, "An update is already waiting. Close and reopen PokeFields before checking again.")
			return
	# Roll back this transaction if either rename fails; never leave only half queued.
	var staged: Array[String] = []
	for path in ready:
		var pending: String = path.trim_suffix(".download") + ".next"
		if DirAccess.rename_absolute(path, pending) != OK:
			for queued in staged:
				DirAccess.remove_absolute(queued)
			for downloaded in ready:
				DirAccess.remove_absolute(downloaded)
			_fail(notice, "Could not save the update. Check free SD card space and try again.")
			return
		staged.append(pending)
	notice.queue_free()
	var apply_dialog: = ConfirmationDialog.new()
	apply_dialog.title = "Update ready"
	apply_dialog.dialog_text = "The update is downloaded and verified.\nSave your progress before closing the game.\nReopen PokeFields from hbmenu to apply it."
	apply_dialog.ok_button_text = "Close game"
	apply_dialog.cancel_button_text = "Keep playing"
	apply_dialog.min_size = Vector2i(680, 240)
	add_child(apply_dialog)
	apply_dialog.confirmed.connect(get_tree().quit)
	apply_dialog.canceled.connect(func(): apply_dialog.queue_free(); _busy = false)
	apply_dialog.popup_centered()

func _fail(notice: AcceptDialog, message: String) -> void:
	notice.title = "Update not installed"
	notice.dialog_text = message
	notice.get_ok_button().show()
	_busy = false
