extends Resource
class_name Dialogue

@export var dialogue_line : Array = [["Name","Text"]]
#How to use and make dialogues
#To use, create a dialogue resource and fill the dialogue_line array.
#For a single line. Use an array using the following order; ["Name","Text"]
#For choices. Use a dictionary using the following order; {"Choice":Dialogue Resource}
#An example of a branching dialogue (In the dialogue line array (Shown in code form);
#[
#["Npc","This is a test dialogue."],
#{
#"Ignore":[["Player","..."],["Npc","Eh."]],  <-(Should be another dialogue resource but this is an example for this example)
#"Greet": [["Player","Hello.],["Npc","Hi."]
#}
#]
#
#The dialogue ends if there is no further items in the array
#For this example, the dialogue ends on when the Npc says "Eh." for the first choice and "Hi." for the second.
#
#After you make one, add the dialogue to the dialogue var of the npc you want it to add to.
#An example dialogue would be found in the Dialogue folder in the Assets folder.
#Note:This burns my brain to code.
