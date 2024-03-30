extends Control


@onready var username: LineEdit = $VBoxContainer/Username
@onready var pwd: LineEdit = $VBoxContainer/Pwd
@onready var email: LineEdit = $VBoxContainer/Email
@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var signup_request: HTTPRequest = $SignupRequest
@onready var login_request: HTTPRequest = $LoginRequest

@export var user_scene: PackedScene


func is_valid_email(s: String) -> bool:
	return s.match("*@*.*")


func clear_fields() -> void:
	username.clear()
	email.clear()
	pwd.clear()


func _on_signup_button_pressed() -> void:
	if not is_valid_email(email.text):
		message_label.set("theme_override_colors/font_color", Color.DARK_RED)
		message_label.text = 'please enter valid email.'
		return
	
	var body: String = JSON.stringify(
		{
			'username': username.text,
			'email': email.text,
			'password': pwd.text
		}
	)
	
	signup_request.request('http://127.0.0.1:8080/auth/',
		[], 
		HTTPClient.METHOD_POST, body)


func _on_login_button_pressed() -> void:
	if username.text.is_empty() or pwd.text.is_empty():
		message_label.set("theme_override_colors/font_color", Color.DARK_RED)
		message_label.text = 'please enter valid username/password.'
		return
	
	var headers: Array[String] = ["Content-Type: application/x-www-form-urlencoded", "Accept: application/json"]
	var form_data: String = "username={username}&password={password}"\
		.format({
			"username": username.text,
			"password": pwd.text})
	
	login_request.request("http://127.0.0.1:8080/auth/token", 
		headers, 
		HTTPClient.METHOD_POST, form_data)


func _on_signup_http_request_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	clear_fields()
	
	if response_code == 200:
		message_label.set("theme_override_colors/font_color", Color.WEB_GREEN)
		message_label.text = 'account created'


func _on_login_http_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	clear_fields()
	
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		UserData.TOKEN = json['access_token']
		get_tree().change_scene_to_packed(user_scene)
	else:
		message_label.text = 'access denied!'

