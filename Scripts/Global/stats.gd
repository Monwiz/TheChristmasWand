extends Node

const PLAYER_MAX_HP = 100
var player_hp = 100
var player_magic = 100
var player_fight_spells: Array[BattleSpell] = [preload("res://Assets/Resources/BattleSpells/kaboom.tres")]
var _new_position: Vector2

var inventory: Array[Item]
var interact_spells: Array

var menu #set by the menu
var team: int = 0 #1 - Jack Frost, 2 - Snow Queen, 4 - Jethro

func reset():
	player_hp = 100
	player_magic = 100
	player_fight_spells = []
	interact_spells = []
	inventory = []
	team = 0
	_new_position = Vector2.ZERO
	
func add_item(item: Item):
	if inventory.any(func(item1): return item1.name == item.name):
		if item.stackable:
			for item1 in inventory:
				if item1.name == item.name:
					item1.quantity += 1
					update_name_stackable(item1)
					return
		else:
			var i = 2
			while true:
				if inventory.all(func(item1): return item1.name != (item.name+" ("+str(i)+")")):
					item.name += " (" + str(i) + ")"
					break
				i += 1
	inventory.append(item)
		
func remove_item(item: Item, quantity: int = 1):
	if item.stackable:
		item.quantity -= quantity
		if item.quantity <= 0:
			inventory.erase(item)
		else:
			update_name_stackable(item)
	else:
		inventory.erase(item)

func update_name_stackable(item: Item):
	var name_split = item.name.split(" ")
	if name_split[-1].begins_with("["):
		name_split.remove_at(name_split.size()-1)
	if item.quantity != 1:
		name_split.append("["+str(item.quantity)+"]")
	item.name = " ".join(name_split)
		
func _ready() -> void:		#for testing purposes
	for n in 5:
		var stone = load("res://Assets/Resources/Items/stone.tres")
		add_item(stone)
		var boulder = load("res://Assets/Resources/Items/boulder.tres")
		add_item(boulder)
#	add_item(preload("res://Assets/Resources/Items/stone.tres"))
#	add_item(salad.duplicate())
func open_menu():
	menu.open()
func close_menu():
	menu.close()
#If you use this in your project, you can add the speed of fighting of an entity
#(and edit ../Systems/battle.gd), their strength
