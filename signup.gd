extends Control


@onready var username: LineEdit = $VBoxContainer/HBoxContainer/Username
@onready var pwd: LineEdit = $VBoxContainer/HBoxContainer2/Pwd
@onready var email: LineEdit = $VBoxContainer/HBoxContainer3/Email
@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var http_request: HTTPRequest = $HTTPRequest


func _on_http_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	username.text = ''
	email.text = ''
	pwd.text = ''
	
	var data = body.get_string_from_utf8()
	message_label.text = data


func is_valid_email(email: String) -> bool:
	return email.match("*@*.*")


func _on_button_pressed() -> void:
	if not is_valid_email(email.text):
		message_label.text = 'please enter valid email.'
		return
	
	var body = JSON.new().stringify(
		{
			'username': username.text,
			'email': email.text,
			'password': pwd.text
		}
	)
	
	http_request.request('http://127.0.0.1:8080/auth/', [], HTTPClient.METHOD_POST, body)


func _on_login_button_pressed() -> void:
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Accept: application/json"]
	
	var form_data = "username={username}&password={password}".format({
		"username": username.text,
		"password": pwd.text})
	http_request.request("http://127.0.0.1:8080/auth/token/", headers, 
		HTTPClient.METHOD_POST, form_data)

