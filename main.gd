extends Node2D

@onready var board = get_node("board")
@onready var labelResult = get_node("labelResult")
# NOVO: referências dos botões (para poder travar/destravar)
@onready var btnPull = get_node("btnPull")
@onready var btnKeep = get_node("btnKeep")
@onready var btnPeek = get_node("btnPeek")
@onready var btnDiscard = get_node("btnDiscard")

var turn_player : bool = true
var p1 : Player
var p2 : Player
var deck

# NOVO: variáveis das novidades
var game_over : bool = false        # true quando a partida acabou
var keeps_in_a_row : int = 0        # 2 "Manter" seguidos = fim da partida
var wins_p1 : int = 0               # placar de vitórias (não zera no Reiniciar)
var wins_p2 : int = 0
var last_action : String = "nenhuma ainda"   # histórico da última jogada
var peek_text : String = ""         # carta espiada (vazio = nenhuma)


func generate_deck():
	var naipes = ["Copas", "Espadas", "Ouro", "Paus"]
	var cards = []
	
	# for iterador in objeto_iterado
	for naipe in naipes:
		for num in range(1, 14):
			cards.append( Card.new( num, naipe ) )
	return cards

func _ready():
	p1 = Player.new("A")
	p2 = Player.new("B")
	start_game()

# NOVO: junta o que antes estava no _ready e no reset
func start_game():
	deck = generate_deck()
	deck.shuffle()   # NOVO: embaralha
	p1.reset()
	p2.reset()
	turn_player = true
	game_over = false
	keeps_in_a_row = 0
	last_action = "nenhuma ainda"
	peek_text = ""
	labelResult.text = ''
	update_board()

func current_player():
	return p1 if turn_player else p2

# NOVO: texto que mostra se os poderes do jogador ainda estão livres
func powers_text( p ):
	var t = "Espiar " + ("usado" if p.used_peek else "livre")
	t += ", Descartar " + ("usado" if p.used_discard else "livre")
	return t

func update_board():
	var cur = current_player()
	board.text = "Vez do jogador A" if turn_player else "Vez do jogador B"
	board.text += " | Jogador A: "+ str(p1.score) +" | Jogador B: "+ str(p2.score) +"\n"
	board.text += "Placar de vitórias -> A: " + str(wins_p1) + " | B: " + str(wins_p2) + "\n"   # NOVO
	board.text += "Mão A: " + p1.show_hand() + '\n'
	board.text += "Mão B: " + p2.show_hand() + '\n'
	board.text += "Poderes -> A: " + powers_text(p1) + " | B: " + powers_text(p2) + "\n"      # NOVO
	board.text += "Última jogada: " + last_action + "\n"                                        # NOVO
	if peek_text != "":
		board.text += "Próxima carta do baralho (espiada): " + peek_text + "\n"               # NOVO
	
	# NOVO: trava os botões que não podem ser usados agora
	btnPull.disabled = game_over
	btnKeep.disabled = game_over
	btnPeek.disabled = game_over or cur.used_peek
	btnDiscard.disabled = game_over or cur.used_discard or cur.hand.size() == 0

# NOVO: termina a partida e atualiza o placar (winner: 1 = A, 2 = B, 0 = empate)
func finish( winner ):
	game_over = true
	if winner == 1:
		labelResult.text = 'P1 venceu'
		wins_p1 += 1
	elif winner == 2:
		labelResult.text = 'P2 venceu'
		wins_p2 += 1
	else:
		labelResult.text = 'Empate'

func _on_btn_pull_button_up() -> void:
	if game_over or deck.size() == 0:
		return
	var cur = current_player()
	var card = deck[0]
	cur.take_card( deck )
	last_action = "Jogador " + cur.nickname + " puxou " + card.title   # NOVO
	peek_text = ""   # NOVO: a carta espiada acabou de sair do baralho
	keeps_in_a_row = 0
	turn_player = not turn_player
	
	if( p1.score == 21 or p2.score > 21 ):
		finish(1)
	elif( p2.score == 21 or p1.score > 21 ):
		finish(2)
	update_board()

func _on_btn_keep_button_up() -> void:
	if game_over:
		return
	last_action = "Jogador " + current_player().nickname + " manteve"   # NOVO
	turn_player = not turn_player
	keeps_in_a_row += 1
	
	# NOVO: dois "Manter" seguidos terminam o jogo; vence quem está mais perto de 21
	if keeps_in_a_row >= 2:
		if p1.score > p2.score:
			finish(1)
		elif p2.score > p1.score:
			finish(2)
		else:
			finish(0)
	update_board()

func _on_btn_reset_button_up() -> void:
	start_game()

# ---------- NOVO PODER 1: ESPIAR ----------
# Mostra qual é a próxima carta do baralho. Só 1 vez por partida por jogador.
# Não gasta a vez, mas a carta aparece para os dois jogadores!
func _on_btn_peek_button_up() -> void:
	if game_over or deck.size() == 0:
		return
	var cur = current_player()
	if cur.used_peek:
		return
	cur.used_peek = true
	peek_text = deck[0].title
	last_action = "Jogador " + cur.nickname + " espiou a próxima carta"
	update_board()

# ---------- NOVO PODER 2: DESCARTAR ----------
# Joga fora a última carta da sua mão (perde os pontos dela).
# Só 1 vez por partida por jogador e GASTA a vez.
func _on_btn_discard_button_up() -> void:
	if game_over:
		return
	var cur = current_player()
	if cur.used_discard or cur.hand.size() == 0:
		return
	cur.used_discard = true
	var card = cur.discard_last()
	last_action = "Jogador " + cur.nickname + " descartou " + card.title
	keeps_in_a_row = 0
	turn_player = not turn_player
	update_board()
