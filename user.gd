extends Control


@onready var info: RichTextLabel = $VBoxContainer/Info
@onready var details_request: HTTPRequest = $DetailsRequest


func _ready() -> void:
	var headers: Array[String] = ["Authorization: Bearer {token}".format({'token': UserData.TOKEN})]
	
	details_request.request("http://127.0.0.1:8080/users/", 
		headers, 
		HTTPClient.METHOD_GET, '')


func _on_details_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	info.text = str(json['id']) + \
		'\n' + json['email'] + \
		'\n' + json['username'] + \
		'\n' + json['hashed_password']
