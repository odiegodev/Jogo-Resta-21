class_name Card

var value : int
var house : String

var title : String
var score : int

# Construtor
func _init(value, house):
	self.value = value
	self.house = house
	
	if(value > 1 and value < 11):
		self.score = value
		self.title = str(value) + ' de ' + house 
	elif( value == 1 ):
		self.score = 11
		self.title = 'Às de ' + house
	else:
		self.score = 10
		if(value == 11):
			self.title = 'Valete de ' + house
		elif(value == 12):
			self.title = 'Rainha de ' + house
		elif(value == 13):
			self.title = 'Rei de ' + house
