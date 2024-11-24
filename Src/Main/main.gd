extends Node2D

const CLOCK: float = 1

var time_counter: float = 0
var money_prev: int = 0

var money: int = 0

var particles: int = 0

var pressed: bool = false  
var ach_pressed: bool = false
var quit_pressed: bool = false
var hovering: bool = false

enum Upgrades {KEYBOARD, KIDS, FEASTABLES, N_UPGRADES} 

var basePerClic: int = 1.0

enum Children {PRODUCTION, NUMBER}
var children: PackedFloat64Array = PackedFloat64Array([50, 0])

var linear: PackedFloat64Array = PackedFloat64Array([0.5, 0.25, 0.5, 25.0])
var multipliers: PackedFloat64Array = PackedFloat64Array([1.0, 2.0, 2.0, 100.0])
var level: PackedInt64Array = PackedInt64Array([0, 0, 0])
var price: PackedFloat64Array = PackedFloat64Array([1.0, 10.0, 22.0])
var pressedUpgrades: PackedByteArray = PackedByteArray([false, false, false])
var titles: PackedStringArray = PackedStringArray([
	"Un nouveau clavier",
	"Un enfant très pratique",
	"Du bon chocolat"
	])
var descriptions: PackedStringArray = PackedStringArray([
	"Un nouveau clavier pour votre autre main, ou pied, ou nez si vous manquez de moyens d'appuyer sur cette satanée touche... Peu importe ! Vous trouverez bien quelque-chose !\n\n[b]Augmente de 1 centime chaque appui sur la touche espace[/b]",
	"Ne me demandez pas où vous avez acheté cet enfant, mais il fera très bien l'affaire lorsqu'il s'agit d'appuyer sur la touche d'un clavier !\n\n[b]Augmente de 1 le nombre d'enfants appuyant régulièrement sur la touche espace[/b]",
	"Selon les mots de Mr.Beast, le meilleur chocolat au monde ! Donnera certainement un coup de boost à vos fidèles travailleurs\n\n[b]Augmente de 1 la productivité de chacun des enfants[/b]",])

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
		var rate: int = (money - money_prev)/CLOCK
		money_prev = money
		$MoneyRateLabel.text = "%d,%02d €/s  " % [rate/100, rate % 100]
		updateMoneyLabel()
		$MrBeastPopup.update(money)
	
func handleHover() -> void:
	$Hover.size.y = 130 + $Hover/MarginContainer/VBoxContainer/Description.get_content_height()
	var mousePosition: Vector2 = get_viewport().get_mouse_position()
	if mousePosition.x < 960:
		$Hover.position = mousePosition + Vector2(50.0, -50.0)
	else:
		$Hover.position = mousePosition + Vector2(-$Hover.size.x - 50.0, -50.0)

func updateMoneyLabel() -> void:
	$MoneyLabel.text = "%d,%02d €" % [money / 100, money % 100]
	
func updateMoney() -> void:
	money += (1 + level[Upgrades.KEYBOARD]) * basePerClic
	updateMoneyLabel()

func updateChildrenNumber() -> void:
	children[Children.NUMBER] = level[Upgrades.KIDS]

func updateMoneyChildren() -> void:
	money += children[Children.PRODUCTION] * children[Children.NUMBER] / CLOCK 

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
	if money >= 100*price[upgrade]:
		resetButtons()
		pressedUpgrades[upgrade] = true
		level[upgrade] += 1
		money -= 100*price[upgrade]
		money_prev -= 100*price[upgrade]
		updateMoneyLabel()
		price[upgrade] += linear[upgrade]
		price[upgrade] *= multipliers[upgrade]
		if upgrade == Upgrades.KEYBOARD:
			$KeysAnimations.play("keyboard_press")
			$Keys/Keyboard/Level.text = str(level[upgrade])
			$Keys/Keyboard/Price.text = "%d,%02d €" % [int(price[upgrade]), int(100*price[upgrade]) % 100]
		if upgrade == Upgrades.KIDS:
			$KeysAnimations.play("kids_press")
			$Keys/Kids/Level.text = str(level[upgrade])
			$Keys/Kids/Price.text = "%d,%02d €" % [int(price[upgrade]), int(100*price[upgrade]) % 100]
		if upgrade == Upgrades.FEASTABLES:
			$KeysAnimations.play("feastables_press")
			$Keys/Feastables/Level.text = str(level[upgrade])
			$Keys/Feastables/Price.text = "%d,%02d €" % [int(price[upgrade]), int(100*price[upgrade]) % 100]

func showHover(upgrade: Upgrades) -> void:
	$Hover/MarginContainer/VBoxContainer/Title.text = titles[upgrade]
	$Hover/MarginContainer/VBoxContainer/Description.text = descriptions[upgrade]
	hovering = true
	handleHover()
	$Hover.visible = true
	
func hideHover() -> void:
	$Hover.visible = false
	hovering = false

func _input(event) -> void:
	if event is InputEventKey and event.keycode == KEY_SPACE:
		if event.is_pressed() and not pressed:
			_on_space_down()
		elif event.is_released():
			_on_space_up() 


func _on_space_down() -> void:
	if not pressed:
		pressed = true
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


func _on_quit_down() -> void:
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

func _on_keyboard_up() -> void:
	if pressedUpgrades[Upgrades.KEYBOARD]:
		pressedUpgrades[Upgrades.KEYBOARD] = false
		$KeysAnimations.play("keyboard_release")
func _on_kids_up() -> void:
	if pressedUpgrades[Upgrades.KIDS]:
		pressedUpgrades[Upgrades.KIDS] = false
		$KeysAnimations.play("kids_release")
func _on_feastables_up() -> void:
	if pressedUpgrades[Upgrades.FEASTABLES]:
		pressedUpgrades[Upgrades.FEASTABLES] = false
		$KeysAnimations.play("feastables_release")
	
func _on_keyboard_mouse_entered() -> void:
	showHover(Upgrades.KEYBOARD)
func _on_kids_mouse_entered() -> void:
	showHover(Upgrades.KIDS)
func _on_feastables_mouse_entered() -> void:
	showHover(Upgrades.FEASTABLES)

func _on_keyboard_mouse_exited() -> void:
	hideHover()
func _on_kids_mouse_exited() -> void:
	hideHover()
func _on_feastables_mouse_exited() -> void:
	hideHover()
