extends Control


@onready var username: LineEdit = $VBoxContainer/HBoxContainer/Username
@onready var pwd: LineEdit = $VBoxContainer/HBoxContainer2/Pwd
@onready var email: LineEdit = $VBoxContainer/HBoxContainer3/Email
@onready var message_label: Label = $VBoxContainer/MessageLabel


func is_valid_email(s: String) -> bool:
	return s.match("*@*.*")


func _on_button_pressed() -> void:
	if not is_valid_email(email.text):
		message_label.text = 'please enter valid email.'
		return
	
	var body: String = JSON.stringify(
		{
			'username': username.text,
			'email': email.text,
			'password': pwd.text
		}
	)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_signup_http_request_completed)

	
	http_request.request('http://127.0.0.1:8080/auth/',
		[], 
		HTTPClient.METHOD_POST, body)


func _on_login_button_pressed() -> void:
	if username.text.is_empty() or pwd.text.is_empty():
		message_label.text = 'please enter valid username/password.'
		return
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Accept: application/json"]
	var form_data = "username={username}&password={password}"\
		.format({
			"username": username.text,
			"password": pwd.text})

	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_login_http_request_completed)
	
	http_request.request("http://127.0.0.1:8080/auth/token", 
		headers, 
		HTTPClient.METHOD_POST, form_data)


func _on_signup_http_request_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	username.text = ''
	email.text = ''
	pwd.text = ''
	
	if response_code == 200:
		message_label.text = 'account created'


func _on_login_http_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	username.text = ''
	email.text = ''
	pwd.text = ''
	
	if response_code == 200:
		var data: String = body.get_string_from_utf8()
		var thingy = JSON.parse_string(data)
		message_label.text = thingy['access_token']
	else:
		message_label.text = 'access denied!'

