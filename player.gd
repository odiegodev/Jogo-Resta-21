class_name Player

var nickname: String
var hand: Array = []
var score: int = 0
# NOVO: controle dos poderes (cada um só pode ser usado 1 vez por partida)
var used_peek: bool = false
var used_discard: bool = false

func _init( nickname ) -> void:
	self.nickname = nickname
	self.hand = []
	self.score = 0
	
func take_card( deck ):
	self.hand.append( deck[0] )
	self.score += deck[0].score
	deck.remove_at( 0 )

func show_hand():
	var view_cards = ''
	for card in self.hand:
		view_cards += card.title + " | "
	return view_cards

# NOVO: tira a última carta da mão e desconta os pontos dela
func discard_last():
	var card = self.hand.pop_back()
	self.score -= card.score
	return card

func reset():
	self.hand = []
	self.score = 0
	self.used_peek = false      # NOVO
	self.used_discard = false   # NOVO
