extends Panel

var trophy = preload("res://Res/Sprites/Main/achievement.svg")

var opened: bool = false

enum Ach {MONEY, CPS, KIDS, FEASTABLES, FORMATIONS}

var titles: PackedStringArray = PackedStringArray([
	"Plus riche que Mr.Beast",
	"Clavier maltraité",
	"Vous êtes allés les chercher où ?",
	"Epidémie diabétique",
	"Université cliquage",
	])
var descriptions: PackedStringArray = PackedStringArray([
	"Vous avez dépassé 500 millions d'euros, la fortune estimée de Mr.Beast.",
	"Vous avez appuyé sur la touche espace 10 fois en une seconde, 10 fois... Calmez-vous par pitié.",
	"8 milliards d'enfants sous vos ordres, c'est plus que la population terrestre... Etrange...",
	"Vous avez distribué 100 tonnes de feastables.",
	"Vous avez débloqué les 3 premiers niveaux de formations, bravo !",
	])

var completed: PackedByteArray = PackedByteArray([
	false,
	false,
	false,
	false,
	false,
])

var count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open() -> void:
	opened = true
	$AchievementsAnimations.play("open")

func _on_quit_pressed() -> void:
	opened = false
	$AchievementsAnimations.play("close")

func update(money: float, cps: int, kids: float, feastables: int, formations: int) -> void:
	if money > 500_000_000_00 and not completed[Ach.MONEY]:
		get_parent().get_node("AchievementPopup/AchievementPopupAnimations").play("show")
		completed[Ach.MONEY] = true
		count += 1
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Money/MarginContainer/HBoxContainer/Logo.texture = trophy
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Money/MarginContainer/HBoxContainer/VBoxContainer/Title.text = titles[Ach.MONEY]
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Money/MarginContainer/HBoxContainer/VBoxContainer/Description.text = descriptions[Ach.MONEY]
	if cps >= 10 and not completed[Ach.CPS]:
		get_parent().get_node("AchievementPopup/AchievementPopupAnimations").play("show")
		completed[Ach.CPS] = true
		count += 1
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/SpamClick/MarginContainer/HBoxContainer/Logo.texture = trophy
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/SpamClick/MarginContainer/HBoxContainer/VBoxContainer/Title.text = titles[Ach.CPS]
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/SpamClick/MarginContainer/HBoxContainer/VBoxContainer/Description.text = descriptions[Ach.CPS]
	if kids >= 8_000_000_000 and not completed[Ach.KIDS]:
		get_parent().get_node("AchievementPopup/AchievementPopupAnimations").play("show")
		completed[Ach.KIDS] = true
		count += 1
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Kids/MarginContainer/HBoxContainer/Logo.texture = trophy
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Kids/MarginContainer/HBoxContainer/VBoxContainer/Title.text = titles[Ach.KIDS]
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Kids/MarginContainer/HBoxContainer/VBoxContainer/Description.text = descriptions[Ach.KIDS]
	if feastables >= 100 and not completed[Ach.FEASTABLES]:
		get_parent().get_node("AchievementPopup/AchievementPopupAnimations").play("show")
		completed[Ach.FEASTABLES] = true
		count += 1
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Feastables/MarginContainer/HBoxContainer/Logo.texture = trophy
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Feastables/MarginContainer/HBoxContainer/VBoxContainer/Title.text = titles[Ach.FEASTABLES]
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Feastables/MarginContainer/HBoxContainer/VBoxContainer/Description.text = descriptions[Ach.FEASTABLES]
	if formations >= 3 and not completed[Ach.FORMATIONS]:
		get_parent().get_node("AchievementPopup/AchievementPopupAnimations").play("show")
		completed[Ach.FORMATIONS] = true
		count += 1
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Formations/MarginContainer/HBoxContainer/Logo.texture = trophy
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Formations/MarginContainer/HBoxContainer/VBoxContainer/Title.text = titles[Ach.FORMATIONS]
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Formations/MarginContainer/HBoxContainer/VBoxContainer/Description.text = descriptions[Ach.FORMATIONS]
	$MarginContainer/VBoxContainer/HBoxContainer/Count.text = str(count) + "/5"
