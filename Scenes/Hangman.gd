extends TextureRect

var secret
var display
var alphabet
var num_missed
var game_over


func setup_game():
	secret  = "godot"
	display = "_____"
	alphabet = "abcdefghijklm\nnopqrstuvwxyz"
	num_missed = 0
	game_over = false
	$GameOver.text = ""
	$AgainButton.visible = false
	$Word.text = display
	$Alphabet.text = alphabet


func _ready():
	setup_game()


func _on_AgainButton_pressed():
	setup_game()


func _input(event):
	# See if event is a keyboard press
	if event.is_pressed() and not game_over:
		# Get key that player pressed
		var key = event.as_text().to_lower()
		#
		# NOTE: We shouldn't assume that 'key' is a single character!
		# It might be something like 'escape', 'space', or 'inputeventmousebutton'.
		# However, those strings won't be found in 'alphabet', so the code won't
		# try to interpret them as a guess. (It will treat them as a guess that 
		# has already been made and is being ignored.)
		#
		# See if letter has been guessed already
		var guessed = alphabet.find(key) == -1
		if not guessed:
			# Remove letter from available alphabet
			alphabet = alphabet.replace(key, " ")
			$Alphabet.text = alphabet
			# See if guessed letter is in secret word
			var found = false
			var i = secret.find(key)
			while i > -1:
				found = true
				# Show guessed letter in the displayed word
				display = display.left(i) + key + display.right(i + 1)
				$Word.text = display
				# See if there's another instance of this lettter
				i = secret.findn(key, i + 2)
				
			#If player guessed correctly
			if found:
				# See if word is completely guessed
				if display.find("_") == -1:
					game_over = true
					$GameOver.text = "You Win!"
					$AgainButton.visible = true
			else:
				# Update image state if guess was wrong
				num_missed = num_missed + 1
				if num_missed < 7:
					$Image.play(String(num_missed))
				else:
					game_over = true
					$Image.play("lose")
					$GameOver.text = "You Lose!"
					$AgainButton.visible = true
	