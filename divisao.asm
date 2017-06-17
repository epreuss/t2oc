.macro printStr (%string)
.data
	myStr: .asciiz %string
.text
	li $v0, 4
	la $a0, myStr
	syscall
.end_macro

.macro printInt (%int)
	li $v0, 1
	add $a0, $zero, %int
	syscall
.end_macro

.text 
# 253 893 217 / 789
#li $t0, 253893217
#li $t1, 789
li $t0, 700
li $t1, 7

printStr("Divisao: ")
printInt($t0)
printStr(" / ")
printInt($t1)
printStr("\n")

li $s0, 0 # Quociente
li $s1, 0 # Divisor
li $s2, 0 # Resto
li $s3, 33 # Quantidade de operações
li $s4, 0 # Contador de operações

add $s1, $t1, $zero # Inicializa Divisor
sll $s1, $s1, 4
add $s2, $t0, $zero # Inicializa Resto

passo1: 
sub $s2, $s2, $s1 # Resto = Resto - Divisor
bltz $s2, passo2B

passo2A:
sll $s0, $s0, 1 # Quociente desloca 1 para esquerda
add $s0, $s0, 1 # Seta bit da direita com 1
j passo3

passo2B: 
add $s2, $s2, $s1 # Restaura valor original
sll $s0, $s0, 1 # Quociente desloca 1 para esquerda e seta bit da direita com 0
j passo3

passo3:
srl $s1, $s1, 1 # Divisor desloca 1 para direita 

verificaFim:
beq $s1, 0, fim
add $s4, $s4, 1
blt $s4, $s3, passo1

fim:
printStr("Quociente: ")
printInt($s0)
printStr("\n")
printStr("Divisor: ")
printInt($s1)
printStr("\n")
printStr("Resto: ")
printInt($s2)
