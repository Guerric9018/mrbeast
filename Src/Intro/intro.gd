extends Node2D

var listening: bool = false
var advancement: int = 0

var story: Dictionary = {
	0: {
		"name": "Mr.Beast",
		"content": "Bonjour à tous, j'éspère que vous allez bien !"
	},
	1: {
		"name": "Mr.Beast",
		"content": "On se retrouve aujourd'hui pour une vidéo assez spéciale..."
	},
	2: {
		"name": "Mr.Beast",
		"content": "Je veux que vous gagniez gros alors je lance un nouveau concept encore jamais vu !"
	},
	3: {
		"name": "Mr.Beast",
		"content": "A chaque fois que vous appuyez sur la barre espace, je vous donnerai 1 centime !"
	},
	4: {
		"name": "Mr.Beast",
		"content": "Bonne chance !"
	},
	"length": 5
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("fade_in")
	while $AnimationPlayer.is_playing():
		await get_tree().create_timer(0.1).timeout
	displayText(story[0]["name"], story[0]["content"])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func close() -> void:
	advancement += 1
	$AnimationPlayer.play("bubble_disappear")
	await get_tree().create_timer(1).timeout
	$AnimationPlayer.play("fade_out")
	while $AnimationPlayer.is_playing():
		await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Src/Main/main.tscn"   )

func displayText(name: String, content: String) -> void:
	listening = false
	
	$AnimationPlayer.play("bubble_appear")
	$Bubble/Text/Name.text = name
	$AnimationPlayer.queue("mrbeast_talking")
	
	var length: int = content.length()
	
	for i: int in range(length):
		$Bubble/Text/Content.text = content.substr(0, i + 1)
		if content[i] == " ":
			$BeastSound.pitch_scale = 0.5 + randf() * (2.0 - 0.5)
			$BeastSound.play()
		await get_tree().create_timer(0.05).timeout
	
	$AnimationPlayer.play("mrbeast_silent")
	
	listening = true
	advancement += 1

func _input(event) -> void:
	if listening and advancement == story["length"]:
		close()
	elif not listening or advancement >= story["length"]:
		return
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			displayText(story[advancement]["name"], story[advancement]["content"])
	elif event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			displayText(story[advancement]["name"], story[advancement]["content"])
