extends CenterContainer

func activate(score):
	visible = true
	$"VBoxContainer/Final Score".text = String(int(score))
	
