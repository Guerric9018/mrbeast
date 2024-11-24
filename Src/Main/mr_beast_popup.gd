extends VBoxContainer

var advancement: int = 0

const messages: Dictionary = {
	0: {
		"amount": 0,
		"message": "C'est parti ! Détruisez votre clavier et vous serez riche !"
	},
	1: {
		"amount": 1_00,
		"message": "J'offre une feastable au premier qui atteint les 100 € !"
	},
	2: {
		"amount": 20_00,
		"message": "Plus besoin de travailler, tout ce que vous avez à faire, c'est d'appuyer sur cette touche espace !"
	},
	3: {
		"amount": 100_00,
		"message": "Bravo à toi pour avoir été le premier à atteindre 100 € !"
	},
	4: {
		"amount": 200_00,
		"message": "J'ai cru entendre que manger des feastable vous rendra plus productif..."
	},
	5: {
		"amount": 500_00,
		"message": "N'oubliez pas de regarder ma dernière vidéo où je fais exploser une base militaire en Afghanistan !"
	},
	6: {
		"amount": 1_000_00,
		"message": "Dites combien vous avez gagné avec #MrBeastSpaceContest"
	},
	7: {
		"amount": 10_000_00,
		"message": "Vous avez entendu parler de ces histoire de traffic d'enfants ? Effrayant..."
	},
	8: {
		"amount": 123_516_00,
		"message": "Ca commence à faire un gros trou dans mon porte-feuille..."
	},
	9: {
		"amount": 894_777_00,
		"message": "COMMENT ON ARRÊTE CA ?"
	},
	10: {
		"amount": 7_740_199_00,
		"message": "JE SUIS DEJA ASSEZ ENDETTE STOOOOOP !"
	},
	11: {
		"amount": 55_429_232_00,
		"message": "..."
	},
	"length": 12
}

func showPopup(message: String) -> void:
	$PopupAnimations.play("show")
	
	$PopupAnimations.queue("talk")
	
	var length: int = message.length()
	for i: int in range(length):
		$MessagePanel/Message.text = message.substr(0, i + 1)
		if message[i] == " ":
			$Beast.pitch_scale = 0.5 + randf() * (2.0 - 0.5)
			$Beast.play()
		await get_tree().create_timer(0.05).timeout
	
	$PopupAnimations.play("silent")
	await get_tree().create_timer(5).timeout
	$PopupAnimations.play("hide")

func update(amount: int) -> void:
	if advancement < messages["length"] and messages[advancement]["amount"] <= amount:
		showPopup(messages[advancement]["message"])
		advancement += 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
