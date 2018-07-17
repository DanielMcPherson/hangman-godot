extends TextureRect

var secret      # Word player is trying to guess
var display     # Partially completed word displayed on screen
var alphabet    # Letters the player can guess from
var num_missed  # Number of wrong guesses the player has made
var game_over   # Whether the game has ended yet

# Secret words to select from
var words = ["godot", "game", "script"]
# Strings displayed to the user
var user_strings

# Set up a new game
func setup_game():
	# Choose a random word
	secret  = words[randi() % words.size()]
	# Make sure it's all lower case
	secret = secret.to_lower()
	# Create word display of all underscores
	display = ""
	for i in range(secret.length()):
		# Allow spaces in secret word, don't convert to underscore
		if secret[i] == " ":
			display = display + " "
		else:
			display = display + "_"
	# Available alphabet for guesses
	alphabet = user_strings["alphabet"]
	#Initialize variables and display
	num_missed = 0
	game_over = false
	$GameOver.text = ""
	$AgainButton.visible = false
	$Word.text = display
	$Alphabet.text = alphabet
	$Image.play("0")


func _ready():
	randomize();
	words = get_from_json("words.json")
	user_strings = get_from_json("user_strings.json")
	$AgainButton/AgainText.text = user_strings["again"]
	setup_game()


func _on_AgainButton_pressed():
	setup_game()


# Called when there is user input
func _input(event):
	# See if event is a keyboard press
	if event.is_pressed() and not game_over:
		# Get key that player pressed
		var key = event.as_text().to_lower()
		# NOTE: We shouldn't assume that 'key' is a single character!
		# It might be something like 'escape', 'space', or 'inputeventmousebutton'.
		# However, those strings won't be found in 'alphabet', so the code won't
		# try to interpret them as a guess. (It will treat them as a guess that 
		# has already been made and is being ignored.)
		
		# See if letter has been guessed already
		var guessed = alphabet.find(key) == -1
		if not guessed:
			# Remove letter from available alphabet
			alphabet = alphabet.replace(key, " ")
			$Alphabet.text = alphabet
			
			# See if guessed letter is in the secret word
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
					$GameOver.text = user_strings["you win"]
					$AgainButton.visible = true
			else:
				# Update image state if guess was wrong
				num_missed = num_missed + 1
				if num_missed < 6:
					$Image.play(String(num_missed))
				else:
					game_over = true
					$Image.play("lose")
					$GameOver.text = user_strings["you lose"]
					$Word.text = secret
					$AgainButton.visible = true


func get_from_json(filename):
	var file = File.new()
	file.open(filename, File.READ)
	var text = file.get_as_text()
	var data = parse_json(text)
	file.close()
	return data
