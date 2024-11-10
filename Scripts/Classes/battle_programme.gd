extends Resource
class_name BattleProgram

@export var program: Dictionary
#How to use and make battle programs
#To use, create a BattleProgram resource and fill the program dictionary where:
#	the key is named after the reached enemies' hp ratio (the sum of the current HPs to sum of the max HPs ratio as a String)
#	the value is an array with what should be used after reaching, add following:
#		For a dialogue. Use a Dialogue resource
#		For an enemy action selection. Players are choosed automatically. The choosed enemy is the current enemy.
#			Use an array and make arrays for every enemy: [[Enemy1Action1, Enemy1Action2], [Enemy2Action1]]
#			Add actions into these arrays:
#				For attacking: "Attack"
# 				For using a spell: a Spell resource
#				For using an item: an Item resource
#				For skipping due to preparing an attack: "Prepare"
#				For skipping: "Skip"
#Example: { #HPs when the programs are being used
#			"1.0":	[ #Program
#						Dialogue["Player","Nice to meet you"],
#						[	#Turns for each enemy (There's only one enemy)
#						 		#(Player attacks, the first enemy prepares (no other enemies), Player attacks, the first enemy attacks)
#							["Prepare", "Attack"] #Actions for each turn
#						] #is being looped
#					],
#			"0.25":	[
#						Dialogue["NPC","Nah I'd win"],
#						[
#							[FoodItem]
#						],
#						Dialogue["NPC","Say goodbye"],
#						[ #is being looped
#							["Attack"]
#						]
#					]
#		  }
