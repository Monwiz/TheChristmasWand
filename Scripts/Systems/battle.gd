extends Control

#input variables
var allies: Array[CharacterBody2D]
var enemies: Array[CharacterBody2D]
var battle_program: Dictionary
@onready var dialogue_box = get_parent().get_node("DialogueRelevant/DialogueBox")
var talking_dialogue: Dialogue
var failed_leaving_dialogue: Dialogue
var dialogue_before_death: Dialogue
var can_leave: bool
var leaving_chances: float

#battle variables
var strength_multiplyer = 1.0

#technical variables
var strategy: Array[Array] = [[]]
var character_turn: int = 0
var is_fighting: bool = false
var ended: bool = false
var returned
var current_battle_program: Array
var i_battle_program: int = 0
var i_current_program: int = 0
var i_current_actions: int = 0
var enemies_total_max_xp: int
var enemies_total_current_xp: int
var goals: Array[CharacterBody2D]
var i_goals: int
var is_ignoring_input: bool = false #workaround for selecting a goal
signal action_selected()
signal chose_goal(goal: CharacterBody2D)

signal finished(status: int)	#0 - scripted battle finishing
								#1 - winning
								#2 - leaving
signal lose()

func _ready() -> void:
	set_physics_process(false)

func start_fight(fight: Fight) -> void:
	for path in fight.allies_paths:
		allies.append($/root/Scene.get_node(path)) #I haven't found a way in Godot to always use absolute NodePaths
	for path in fight.enemies_paths:
		enemies.append($/root/Scene.get_node(path))
	battle_program = fight.battle_program.program
	talking_dialogue = fight.talking_dialogue
	failed_leaving_dialogue = fight.failed_leaving_dialogue
	dialogue_before_death = fight.dialogue_before_death
	can_leave = fight.can_leave
	leaving_chances = fight.leaving_chances
	
	for allie in allies:
		allie.process_mode = Node.PROCESS_MODE_DISABLED
		allie.get_node("HealthBar").visible = true
		var magic_bar = allie.get_node_or_null("MagicBar")
		if magic_bar:
			magic_bar.visible = true
		#save allies' positions
		#slowly move allies to their positions
	for enemy in enemies:
		enemies_total_max_xp += enemy.get_hp()
		enemy.get_node("HealthBar").visible = true
		#save enemies' positions
		#slowly move enemies to their positions
		
	#animation
	visible = true
	#Slowly stop the global music
	$Music.stream = fight.music
	$Music.play()
	
	current_battle_program = battle_program["1.0"]
	var element = current_battle_program[0]
	if element is Dialogue:
		i_current_program = 1
		dialogue_box.set_dialogue(element)
		await dialogue_box.finished
		
	chose_goal.connect(func(goal: CharacterBody2D): returned = goal)
	$Attack.grab_focus()
	allies[0].set_hover(true)
	set_physics_process(true)
	decide()

func end_fight():
	set_physics_process(false)
	for allie in allies:
		allie.process_mode = Node.PROCESS_MODE_INHERIT
		allie.get_node("HealthBar").visible = false
		var magic_bar = allie.get_node_or_null("MagicBar")
		if magic_bar:
			magic_bar.visible = false
		#move allies back to their previous positions
	for enemy in enemies:
		enemies_total_max_xp += enemy.get_hp()
		enemy.get_node("HealthBar").visible = false
		#move enemies back to their previous positions
	
	#animation
	visible = false
	$Music.stop() #Slowly stop the music
	#animation
	#Slowly return the global music

func _physics_process(delta: float) -> void:
	if goals:
		if Input.is_action_just_pressed("ui_up"):
			goals[i_goals].set_hover_selected(false)
			i_goals -= 1
			if i_goals == -1:
				i_goals = goals.size()-1
			goals[i_goals].set_hover_selected(true)
		elif Input.is_action_just_pressed("ui_down"):
			goals[i_goals].set_hover_selected(false)
			i_goals += 1
			if i_goals == goals.size():
				i_goals = 0
			goals[i_goals].set_hover_selected(true)
		elif not is_ignoring_input and Input.is_action_just_pressed("ui_accept"):
			goals[i_goals].set_hover_selected(false)
			chose_goal.emit(goals[i_goals])
			goals = []
			i_goals = 0
		elif Input.is_action_just_pressed("ui_cancel"):
			chose_goal.emit(null)
	else:
		if not is_fighting and Input.is_action_just_pressed("ui_cancel"):
			var choice = strategy[character_turn]
			if len(choice) > 1:
				dialogue_box.end_dialogue()
				#dialogue_box.returned.emit(null)
			else:
				if character_turn > 0:
					strategy.pop_back()
					allies[character_turn].set_hover(false)
					character_turn -= 1
					allies[character_turn].set_hover(true)
					decide()
				else:
					strategy = [[]]
	if ended and Input.is_action_just_pressed("ui_accept"):
		#animation
		visible = false
		set_physics_process(false)
		for allie in allies:
			allie.process_mode = Node.PROCESS_MODE_INHERIT
	is_ignoring_input = false
	if allies.all(func(allie): return allie.get_hp() <= 0):
		death()
	
func next_character() -> void:
	toggle_buttons(false)
	allies[character_turn].set_hover(false)
	returned = null
	character_turn += 1
	if character_turn < len(allies):
		allies[character_turn].set_hover(true)
		strategy.append([])
		decide()
	else:
		character_turn = 0
		fight()

func decide() -> void:
	var choice = strategy[character_turn]
	returned = null
	var allie = allies[character_turn]
	match len(choice):
		0: #The first choice: Attack, Spell, Item, Defend
			toggle_buttons(true)
			await action_selected
			toggle_buttons(false)
			decide()
		1: #The second choice
			var options: Dictionary
			match choice[0]:
				"Attack": #goal
					select_goal(enemies)
					await chose_goal
					if returned == null:
						strategy[character_turn].pop_back() #Back
						decide()
					else:
						strategy[character_turn].append(returned)
						next_character()
				"Spell": #spell
					if Stats.player_fight_spells.is_empty():
						var dialogue = Dialogue.new()
						dialogue.dialogue_line = [["[Battle]", allie.name + " haven't learned any battle spells yet"]]
						dialogue_box.set_dialogue(dialogue)
						await dialogue_box.finished
						
						strategy[character_turn].pop_back() #Back
						decide()
						return
						
					options["_"] = Dialogue.new()
					options["_"].dialogue_line = [null]
					for spell in Stats.player_fight_spells:
						var dialogue = Dialogue.new()
						dialogue.dialogue_line = [spell]
						options[spell.name] = dialogue
					var dialogue = Dialogue.new()
					dialogue.dialogue_line = [options]
					dialogue_box.set_dialogue(dialogue)
					
					await dialogue_box.finished
					if returned == null:
						strategy[character_turn].pop_back() #Back
						decide()
					else:
						strategy[character_turn].append(returned)
						decide()
				"Items": #item
					if Stats.inventory.is_empty():
						var dialogue = Dialogue.new()
						dialogue.dialogue_line = [["[Battle]", "You don't have any items"]]
						dialogue_box.set_dialogue(dialogue)
						await dialogue_box.finished
						
						strategy[character_turn].pop_back() #Back
						decide()
						return
						
					options["_"] = Dialogue.new()
					options["_"].dialogue_line = [null]
					for item in Stats.inventory:
						var dialogue = Dialogue.new()
						dialogue.dialogue_line = [item]
						options[item.name] = dialogue
					var dialogue = Dialogue.new()
					dialogue.dialogue_line = [options]
					dialogue_box.set_dialogue(dialogue)
					
					await dialogue_box.finished
					if returned == null:
						strategy[character_turn].pop_back()
						decide()
					elif not returned.type in [Item.Types.CONSUMABLE, Item.Types.ENEMY_DIRECTED]:
						match returned.type:
							Item.Types.TEACHABLE:
								dialogue = Dialogue.new()
								dialogue.dialogue_line = [["[Battle]", allie.name + " doesn't have time to study now"]]
								dialogue_box.set_dialogue(dialogue)
								await dialogue_box.finished
							Item.Types.CHECKABLE:
								returned.check()
								#await signal of returning
							Item.Types.SIMPLE:
								dialogue = Dialogue.new()
								dialogue.dialogue_line = [["[Battle]", "It doesn't seem like " + allie.name + " can do anything with " + returned.name]]
								dialogue_box.set_dialogue(dialogue)
								await dialogue_box.finished
						decide()
					else:
						strategy[character_turn].append(returned)
						decide()
						
				"Defense": #goal
					select_goal(allies)
					await chose_goal
					allie.set_hover(true)
					if returned == null:
						strategy[character_turn].pop_back() #Back
						decide()
					else:
						strategy[character_turn].append(returned)
						next_character()
		2: #The third choice
			var options: Dictionary
			match choice[0]:
				"Spell": #goal
					match choice[1].type:
						BattleSpell.Types.BATTLE_DIRECTED:
							strategy[character_turn].append(self)
							next_character()
							return
						BattleSpell.Types.USER_DIRECTED:
							strategy[character_turn].append(allie)
							next_character()
							return
						BattleSpell.Types.ALL_ALLIES_DIRECTED:
							strategy[character_turn].append(allies)
							next_character()
							return
						BattleSpell.Types.ALL_ENEMIES_DIRECTED:
							strategy[character_turn].append(enemies)
							next_character()
							return
						BattleSpell.Types.ALL_ENTITIES_DIRECTED:
							strategy[character_turn].append(allies+enemies)
							next_character()
							return
						BattleSpell.Types.ALLIE_DIRECTED:
							select_goal(allies)
						BattleSpell.Types.ENEMY_DIRECTED:
							select_goal(enemies)
						BattleSpell.Types.ENTITY_DIRECTED:
							select_goal(allies+enemies)
					await chose_goal
					allie.set_hover(true)
					if returned == null:
						strategy[character_turn].pop_back() #Back
						decide()
					else:
						strategy[character_turn].append(returned)
						next_character()
				"Items": #goal
					if choice[1].type == Item.Types.CONSUMABLE:
						select_goal(allies)
					else: #Item.Types.ENEMIES_DIRECTED
						select_goal(enemies)
						
					await chose_goal
					allie.set_hover(true)
					if returned == null:
						strategy[character_turn].pop_back() #Back
						decide()
					else:
						strategy[character_turn].append(returned)
						next_character()


func fight() -> void:
	is_fighting = true
	await allies_turn()		#avoid multithread, idk why is this a thing in godot
	await enemies_turn()
	await preparing_next_turns()
	decide()

func allies_turn():
	for allie_choice in strategy:
		var dialogue = Dialogue.new()
		var allie = allies[character_turn]
		match allie_choice[0]:
			"Attack":
				allie.attack(allie_choice[1], strength_multiplyer)
				
				dialogue.dialogue_line = [["[Battle]", allie.name+" attacked "+allie_choice[1].name+"."]]
				dialogue_box.set_dialogue(dialogue)
				#animation
			"Spell":
				allie_choice[1].use_on(allie_choice[2])
				
				var line_end: String
				match allie_choice[1].type:
					BattleSpell.Types.ALLIE_DIRECTED, BattleSpell.Types.ENEMY_DIRECTED, BattleSpell.Types.ENTITY_DIRECTED:
						line_end = " on " + allie_choice[2].name
					BattleSpell.Types.ALL_ALLIES_DIRECTED:
						line_end = " on his team"
					BattleSpell.Types.ALL_ENEMIES_DIRECTED:
						line_end = " on the enemies"
					BattleSpell.Types.ALL_ENTITIES_DIRECTED:
						line_end = " on everybody"
					#BattleSpell.Types.BATTLE_DIRECTED and BattleSpell.Types.USER_DIRECTED have the line end empty
					
				dialogue.dialogue_line = [["[Battle]", allie.name+" uses the spell \""+allie_choice[1].name+"\""+line_end+"!"]]
				dialogue_box.set_dialogue(dialogue)
				#animation
			"Items":
				allie_choice[1].use_on(allie_choice[2])
				
				var line_end = " on "+allie_choice[2].name if (allie != allie_choice[2]) else ""
				dialogue.dialogue_line = [["[Battle]", allie.name+" uses "+allie_choice[1].name+line_end+"."]]
				dialogue_box.set_dialogue(dialogue)
				#animation
			"Defense":
				allie_choice[1].set_defense(allie.get_defense_ability() * randf_range(0.4,1.25))
				
				var line_end = " "+allie_choice[1].name if (allie != allie_choice[1]) else ""
				dialogue.dialogue_line = [["[Battle]", allie.name+" is defending"+line_end+"."]]
					
				dialogue_box.set_dialogue(dialogue)
				#animation
				
		await await_dialogue_or_animation()
		dialogue_box.end_dialogue()
		character_turn += 1
		
		for enemy in enemies: #updating the enemies battle program
			enemies_total_current_xp += enemy.get_hp()
		var hp_collection = battle_program.keys()
		if i_battle_program+1 < hp_collection.size():
			if float(hp_collection[i_battle_program+1]) > enemies_total_current_xp / enemies_total_max_xp:
				i_battle_program += 1
				current_battle_program = battle_program.values()[i_battle_program]
				
				var element = current_battle_program[i_current_program] 
				if element is Dialogue:
					i_current_program += 1
					dialogue_box.set_dialogue(element)
					await dialogue_box.finished
		
	character_turn = 0
	
func enemies_turn():
	while character_turn < len(enemies):
		var element = current_battle_program[i_current_program][character_turn][i_current_actions]
		var enemy = enemies[character_turn]
		var dialogue = Dialogue.new()
		if element is BattleSpell:
				var line_end: String
				match element.type:
					BattleSpell.Types.ALLIE_DIRECTED:
						element.use_on(enemy)
					BattleSpell.Types.ENEMY_DIRECTED:
						var goal = allies.pick_random()
						element.use_on(goal)
						line_end = " on " + goal.name
					BattleSpell.Types.ENTITY_DIRECTED:
						var goal = (allies+enemies).pick_random()
						element.use_on(goal)
						line_end = " on " + goal.name
					BattleSpell.Types.ALL_ALLIES_DIRECTED:
						element.use_on(enemies)
						line_end = " on his team"
					BattleSpell.Types.ALL_ENEMIES_DIRECTED:
						element.use_on(allies)
						line_end = " on the enemies"
					BattleSpell.Types.ALL_ENTITIES_DIRECTED:
						element.use_on(enemies+allies)
						line_end = " on everybody"
					#BattleSpell.Types.BATTLE_DIRECTED and BattleSpell.Types.USER_DIRECTED have the line end empty
					
				dialogue.dialogue_line = [["[Battle]", enemy.name+" uses the spell "+element.name+line_end+"!"]]
				dialogue_box.set_dialogue(dialogue)
				#animation
				await await_dialogue_or_animation()
		elif element is Item:
			if element.type == Item.Types.CONSUMABLE:
				element.use_on(enemy)
				
				dialogue.dialogue_line = [["[Battle]", enemy.name+" uses "+element.name+"."]]
				dialogue_box.set_dialogue(dialogue)
				#animation
				await await_dialogue_or_animation()
			elif element.type == Item.Types.ENEMY_DIRECTED:
				var goal = allies.pick_random()
				element.use_on(goal)
				
				dialogue.dialogue_line = [["[Battle]", enemy.name+" uses "+element.name+" on "+goal.name+"."]]
				dialogue_box.set_dialogue(dialogue)
				#animation
				await await_dialogue_or_animation()
			else:
				assert("The item in the battle program is neither CONSUMABLE or ENEMY_DIRECTED")
			#dialogue box message for a short time
		else: match element:
			"Attack":
				var goal = allies.pick_random()
				enemy.attack(goal)
				
				dialogue.dialogue_line = [["[Battle]", enemy.name+" attacked "+goal.name+"."]]
				dialogue_box.set_dialogue(dialogue)
				#animation
				await await_dialogue_or_animation()
			"Prepare":
				dialogue.dialogue_line = [["[Battle]", enemy.name+" is preparing an attack."]]
				dialogue_box.set_dialogue(dialogue)
				#animation
				await await_dialogue_or_animation()
			"Skip":
				pass
		
		dialogue_box.end_dialogue()
		character_turn += 1
	character_turn = 0
	
func preparing_next_turns():
	if i_current_actions+1 < current_battle_program[i_current_program].size():
		i_current_actions += 1
	elif i_current_program+1 < current_battle_program.size():
		i_current_program += 1
		var element = current_battle_program[i_current_program] 
		if element is Dialogue:
			dialogue_box.set_dialogue(element)
			await dialogue_box.finished
	else:
		i_current_actions = 0 #repeat the last battle program actions
		
	for allie in allies:
		allie.set_defense(1)
	is_fighting = false
	strategy = [[]]
	allies[0].set_hover(true)

func death():
	lose.emit()
	queue_free()

func select_goal(entities: Array[CharacterBody2D]):
	allies[0].set_hover_selected(true)
	goals = entities
	is_ignoring_input = true

func set_returned(val):
	returned = val


func set_strength_multiplyer(val: float):
	strength_multiplyer = val


func toggle_buttons(val: bool):
	if val:
		$Attack.focus_mode = FocusMode.FOCUS_ALL
		$Spell.focus_mode = FocusMode.FOCUS_ALL
		$Items.focus_mode = FocusMode.FOCUS_ALL
		$Defense.focus_mode = FocusMode.FOCUS_ALL
		$Talk.focus_mode = FocusMode.FOCUS_ALL
		$Leave.focus_mode = FocusMode.FOCUS_ALL
		$Attack.grab_focus()
	else:
		$Attack.focus_mode = FocusMode.FOCUS_NONE
		$Spell.focus_mode = FocusMode.FOCUS_NONE
		$Items.focus_mode = FocusMode.FOCUS_NONE
		$Defense.focus_mode = FocusMode.FOCUS_NONE
		$Talk.focus_mode = FocusMode.FOCUS_NONE
		$Leave.focus_mode = FocusMode.FOCUS_NONE

func _on_attack_pressed() -> void:
	strategy[character_turn].append("Attack")
	action_selected.emit()

func _on_spell_pressed() -> void:
	strategy[character_turn].append("Spell")
	action_selected.emit()

func _on_items_pressed() -> void:
	strategy[character_turn].append("Items")
	action_selected.emit()

func _on_defense_pressed() -> void:
	strategy[character_turn].append("Defense")
	action_selected.emit()


func _on_talk_pressed() -> void:
	toggle_buttons(false)
	dialogue_box.set_dialogue(talking_dialogue)
	
	await dialogue_box.finished
	action_selected.emit()

func _on_leave_pressed() -> void:
	toggle_buttons(false)
	if can_leave:
		if randf_range(0, 1) > leaving_chances:
			#animation
			var dialogue = Dialogue.new()
			var last_allie = allies.pop_back().name
			var allies_line: String
			if len(allies) == 0:
				allies_line = last_allie
			else:
				allies_line = ", ".join(allies) + " and " + last_allie
			dialogue.dialogue_line = [["[Battle]", allies_line+" escaped"]]
			await dialogue_box.finished
			
			end_fight()
			return
			
	dialogue_box.set_dialogue(failed_leaving_dialogue)
	set_physics_process(false)
	await dialogue_box.finished
	set_physics_process(true)
	
	if can_leave: #Skip the turn
		is_fighting = true
		enemies_turn()
		preparing_next_turns()
		decide()
	else:
		toggle_buttons(true)


signal signal_dialogue_or_animation()	#wait for one of the two signals
func await_dialogue_or_animation():#anim: AnimationPlayer):
	var finished: int
	dialogue_box.finished.connect(signal_dialogue_or_animation.emit)
	var timer = get_tree().create_timer(3).timeout
	timer.connect(signal_dialogue_or_animation.emit) #replace with anim.animation_finished
	
	await signal_dialogue_or_animation
	dialogue_box.finished.disconnect(signal_dialogue_or_animation.emit)
	timer.disconnect(signal_dialogue_or_animation.emit)
	return