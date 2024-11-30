extends Node2D

const CLOCK: float = 1

var time_counter: float = 0
var money_prev: float = 0

var money: float = 0

var cps: int = 0

var particles: int = 0

var pressed: bool = false  
var ach_pressed: bool = false
var quit_pressed: bool = false
var hovering: bool = false

enum Upgrades {KEYBOARD, KIDS, FEASTABLES, FORMATION, N_UPGRADES} 

const baseKeyboard: int = 1
const baseKids: int = 50
const baseFeastable: float = 1.10

const SIZE = 1000

var formation_level: int = 0
var population: PackedFloat64Array = PackedFloat64Array()

func _init():
	population.resize(SIZE)

var achievement_count: int = 0

var linear: PackedFloat64Array = PackedFloat64Array([50.0, 25_00.0, 50.0, 25000.0])
var multipliers: PackedFloat64Array = PackedFloat64Array([1.0, 1.0, 1.25, 100.0])
var level: PackedInt64Array = PackedInt64Array([0, 0, 0, 0])
var price: PackedFloat64Array = PackedFloat64Array([1_00.0, 10_00.0, 22_00.0, 50_000_00.0])
var pressedUpgrades: PackedByteArray = PackedByteArray([false, false, false, false])
var titles: PackedStringArray = PackedStringArray([
	"Un nouveau clavier",
	"Un enfant très pratique",
	"Du bon chocolat",
	"Formation cliquage",
	])
var descriptions: PackedStringArray = PackedStringArray([
	"Un nouveau clavier pour votre autre main, ou pied, ou nez si vous manquez de moyens d'appuyer sur cette satanée touche... Peu importe ! Vous trouverez bien quelque-chose !\n\n[b]Augmente de 1 centime chaque appui sur la touche espace[/b]",
	"Ne me demandez pas où vous avez acheté cet enfant, mais il fera très bien l'affaire lorsqu'il s'agit d'appuyer sur la touche d'un clavier !\n\n[b]Augmente de 1 le nombre d'enfants appuyant régulièrement sur la touche espace[/b]",
	"Selon les mots de Mr.Beast, le meilleur chocolat au monde ! Donnera certainement un coup de boost à vos fidèles travailleurs.\n\n[b]Augmente de 1 la productivité de chacun des enfants[/b]",
	"Former des enfants à l'art d'appuyer sur la touche espace, c'est tout un travail ! Rajoutez un niveau de formation pour automatiser le processus de recrutement ! (Finançable par le CPF)\n\n[b]Vos enfants / formateurs seront recrutés automatiquement par de nouveaux formateurs[/b]",
	])

const upgraded_kids_base_title = "Formateur niveau "
const upgraded_kids_base_description  = "Ce formateur embauchera des formateurs de niveau inférieur, ou des enfants si jamais il est de niveau 1. Deux trois tiktoks de motivation, et des promesses d'argent gratuit, et les enfants afflueront vers vous !\n\n [b]Vous avez "
var upgraded_kids_title: String = upgraded_kids_base_title
var upgraded_kids_description: String = upgraded_kids_base_description

func _ready() -> void:
	$MrBeastPopup.update(money)

func _process(delta: float) -> void:
	if hovering:
		handleHover()
	
	time_counter += delta
	if time_counter > CLOCK:
		updateChildrenNumber()
		updateMoneyChildren()
		time_counter = 0
		var rate: float = (money - money_prev)/CLOCK
		money_prev = money
		$MoneyRateLabel.text = toSciString(rate) + " €/s"
		updateMoneyLabel()
		$MrBeastPopup.update(money)
		$Achievements.update(money, cps/CLOCK, population[0], level[Upgrades.FEASTABLES], level[Upgrades.FORMATION])
		cps = 0
		achievement_count = $Achievements.count
		
func toSciString(number: float) -> String:
	var base: int
	var dec: int
	var exp: int
	if (number < 100000000):
		base = int(number / 100.)
		dec = int(number) % 100
		return "%d,%02d" % [base, dec]
	else:
		exp = log(number / 100.) / log(10)
		base = int(number / pow(10, exp + 2))
		dec = int(number / pow(10, exp)) - base * 100
		return "%d,%02d e%d" % [base, dec, exp]

func handleHover() -> void:
	$Hover.size.y = 130 + $Hover/MarginContainer/VBoxContainer/Description.get_content_height()
	var mousePosition: Vector2 = get_viewport().get_mouse_position()
	if mousePosition.x < 960:
		$Hover.position = mousePosition + Vector2(50.0, -50.0)
	else:
		$Hover.position = mousePosition + Vector2(-$Hover.size.x - 50.0, -50.0)

func updateMoneyLabel() -> void:
	$MoneyLabel.text = toSciString(money) + " €"
	# $MoneyLabel.text = "%d,%02d €" % [int(money/100), int(money) % 100]
	
func updateMoney() -> void:
	money += (1 + level[Upgrades.KEYBOARD]) * baseKeyboard * pow(achievement_count + 1, pow(achievement_count + 1, achievement_count))
	updateMoneyLabel()

func updateChildrenNumber() -> void:
	for i in range(SIZE-1, 0, -1):
		population[i-1] = population[i-1] + population[i]
	upgraded_kids_title = upgraded_kids_base_title + str(formation_level)
	upgraded_kids_description = upgraded_kids_base_description + str(population[0]) + " enfants travaillant pour vous ![/b]"

func updateMoneyChildren() -> void:
	money += baseKids * population[0] * pow(baseFeastable, level[Upgrades.FEASTABLES]) / CLOCK

func launchParticles() -> void:
	if particles == 0:
		$Particles/GPUParticles2D.restart()
		$Particles/GPUParticles2D.emitting = true
	elif particles == 1:
		$Particles/GPUParticles2D2.restart()
		$Particles/GPUParticles2D2.emitting = true
	elif particles == 2:
		$Particles/GPUParticles2D3.restart()
		$Particles/GPUParticles2D3.emitting = true
	elif particles == 3:
		$Particles/GPUParticles2D4.restart()
		$Particles/GPUParticles2D4.emitting = true
	elif particles == 4:
		$Particles/GPUParticles2D5.restart()
		$Particles/GPUParticles2D5.emitting = true
	particles = (particles + 1)%5

func resetButtons() -> void:
	if ach_pressed:
		$KeysAnimations.queue("achievements_release")
		ach_pressed = false
	if quit_pressed:
		$KeysAnimations.queue("quit_release")
		quit_pressed = false

func buy(upgrade: Upgrades) -> void:
	if formation_level >= SIZE:
		return
	if money >= price[upgrade]:
		resetButtons()
		pressedUpgrades[upgrade] = true
		level[upgrade] += 1
		money -= price[upgrade]
		money_prev -= price[upgrade]
		updateMoneyLabel()
		
		price[upgrade] += linear[upgrade]
		price[upgrade] *= multipliers[upgrade]
		if upgrade == Upgrades.KEYBOARD:
			$KeysAnimations.play("keyboard_press")
			$Keys/Keyboard/Level.text = str(level[upgrade])
			$Keys/Keyboard/Price.text = toSciString(price[upgrade]) + " €"
		if upgrade == Upgrades.KIDS:
			population[formation_level] += 1
			if formation_level == 0:
				$KeysAnimations.play("kids_press")
			else:
				$KeysAnimations.play("kids_press_2")
			$Keys/Kids/Level.text = str(level[upgrade])
			$Keys/Kids/Price.text = toSciString(price[upgrade]) + " €"
		if upgrade == Upgrades.FEASTABLES:
			$KeysAnimations.play("feastables_press")
			$Keys/Feastables/Level.text = str(level[upgrade])
			$Keys/Feastables/Price.text = toSciString(price[upgrade]) + " €"
		if upgrade == Upgrades.FORMATION:
			formation_level += 1
			price[Upgrades.KIDS] = baseKids * pow(1000, formation_level)
			level[Upgrades.KIDS] = 0
			linear[Upgrades.KIDS] = 500 * linear[Upgrades.KIDS]
			multipliers[Upgrades.KIDS] = 1.1*multipliers[Upgrades.KIDS]
			$Keys/Kids/Level.text = str(level[Upgrades.KIDS])
			$Keys/Kids/Price.text = toSciString(price[Upgrades.KIDS]) + " €"
			$KeysAnimations.play("formation_press")
			$Keys/Formation/Level.text = str(level[upgrade])
			$Keys/Formation/Price.text = toSciString(price[upgrade]) + " €"
			$KeysAnimations.queue("kids_release_2")

func showHover(upgrade: Upgrades) -> void:
	if upgrade == Upgrades.KIDS and formation_level > 0:
		$Hover/MarginContainer/VBoxContainer/Title.text = upgraded_kids_title
		$Hover/MarginContainer/VBoxContainer/Description.text = upgraded_kids_description
	else:
		$Hover/MarginContainer/VBoxContainer/Title.text = titles[upgrade]
		$Hover/MarginContainer/VBoxContainer/Description.text = descriptions[upgrade]
	hovering = true
	handleHover()
	$Hover.visible = true
	
func hideHover() -> void:
	$Hover.visible = false
	hovering = false

func _input(event) -> void:
	if event is InputEventKey and event.keycode == KEY_SPACE and not $Achievements.opened:
		if event.is_pressed() and not pressed:
			_on_space_down()
		elif event.is_released():
			_on_space_up() 


func _on_space_down() -> void:
	if not pressed:
		pressed = true
		cps += 1
		$KeysAnimations.play("press")
		resetButtons()
		updateMoney()
		launchParticles()


func _on_space_up() -> void:
	pressed = false
	$KeysAnimations.play("release")


func _on_achievements_down() -> void:
	if not ach_pressed:
		resetButtons()
		ach_pressed = true
		$KeysAnimations.queue("achievements_press")

func _on_achievements_up() -> void:
	if ach_pressed:
		ach_pressed = false
		$KeysAnimations.queue("achievements_release")
		$Achievements.open()

func _on_quit_down() -> void:
	get_tree().quit()
	if not quit_pressed:
		resetButtons()
		quit_pressed = true
		$KeysAnimations.queue("quit_press")


func _on_keyboard_down() -> void:
	buy(Upgrades.KEYBOARD)
func _on_kids_down() -> void:
	buy(Upgrades.KIDS)
func _on_feastables_down() -> void:
	buy(Upgrades.FEASTABLES)
func _on_formation_down() -> void:
	buy(Upgrades.FORMATION)

func _on_keyboard_up() -> void:
	if pressedUpgrades[Upgrades.KEYBOARD]:
		pressedUpgrades[Upgrades.KEYBOARD] = false
		$KeysAnimations.play("keyboard_release")
func _on_kids_up() -> void:
	if pressedUpgrades[Upgrades.KIDS]:
		pressedUpgrades[Upgrades.KIDS] = false
		if formation_level == 0:
			$KeysAnimations.play("kids_release")
		else:
			$KeysAnimations.play("kids_release_2")
func _on_feastables_up() -> void:
	if pressedUpgrades[Upgrades.FEASTABLES]:
		pressedUpgrades[Upgrades.FEASTABLES] = false
		$KeysAnimations.play("feastables_release")
func _on_formation_up() -> void:
	if pressedUpgrades[Upgrades.FORMATION]:
		pressedUpgrades[Upgrades.FORMATION] = false
		$KeysAnimations.play("formation_release")
	
func _on_keyboard_mouse_entered() -> void:
	showHover(Upgrades.KEYBOARD)
func _on_kids_mouse_entered() -> void:
	showHover(Upgrades.KIDS)
func _on_feastables_mouse_entered() -> void:
	showHover(Upgrades.FEASTABLES)
func _on_formation_mouse_entered() -> void:
	showHover(Upgrades.FORMATION)

func _on_keyboard_mouse_exited() -> void:
	hideHover()
func _on_kids_mouse_exited() -> void:
	hideHover()
func _on_feastables_mouse_exited() -> void:
	hideHover()
func _on_formation_mouse_exited() -> void:
	hideHover()
