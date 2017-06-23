# Grupo: Estevan Silva e Adrian Kaminski
# Professor: Giovani Baratto
# Sobre o algoritmo: 
# - Divide um n�mero positivo de 32 bits por outro positivo de 32 bits.
# - � baseado no segundo algoritmo de divis�o do material dado pelo professor.
# - Para escolher o dividendo e divisor, modificar os resgistradores $t0 e $t1, respectivamente.

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

.macro sleep (%int)
	li $v0, 32
	add $a0, $zero, %int
	syscall
.end_macro

.text 

main:

# Divis�o requerida: 253893217 / 789
li $t0, 253893217 # Resto (ou dividendo)
li $t1, 789 # Divisor

li $s3, 0 # Quantidade de itera��es
jal encontra_quantidade_iteracoes
li $s4, 0 # Contador de itera��es
li $s7, 1 # M�scara de bits
jal cria_mascara_bits
li $s4, 0 # Reseta contador

printStr("Divisao: ")
printInt($t0)
printStr(" / ")
printInt($t1)
printStr("\n")

li $t4, 0 # RH_ext
jal desloca_resto_esquerda

passoBase: 
sub $t4, $t4, $t1 # RH_ext = RH_ext - Divisor
bltz $t4, passoMenor

passoMaior:
jal desloca_resto_esquerda
add $t0, $t0, 1 # Insere bit 1 em Resto
j verificaFim

passoMenor: 
add $t4, $t4, $t1 # RH_ext = RH_ext + Divisor; Restaura valor original
jal desloca_resto_esquerda

verificaFim:
add $s4, $s4, 1
blt $s4, $s3, passoBase

fim:
srl $t4, $t4, 1
jal corta_bits_excesso_resto
printStr("Quociente: ")
printInt($t0)
printStr("\n")
printStr("Resto: ")
printInt($t4)
li $v0, 10
syscall

# Procedimentos

desloca_resto_esquerda:
	sll $t0, $t0, 1 # Desloca resto para esquerda
	sll $t4, $t4, 1 # Desloca RH_ext para esquerda
	and $a1, $s7, $t0 # M�scara de 1 bit sobre o resto
	beqz $a1, desloca_fim  # Se for igual a zero, m�scara n�o agiu
	add $t4, $t4, 1 # Overflow � detectado pela m�scara: Insere bit 1 em RH_ext
desloca_fim:
	add $k0, $ra, $zero
	jal corta_bits_excesso_resto
	jr $k0

corta_bits_excesso_resto: 
# Usa a m�scara para retirar bits em excesso do resto
# A quantidade de bits do resto n�o pode ser maior que a quantidade de itera��es
	beq $s3, 31, corta_fim # N�o precisa cortar quando o n�mero usar 31 bits
	sub $s7, $s7, 1 # Cria um n�mero feito de bits 1
	and $t0, $s7, $t0
	add $s7, $s7, 1 # M�scara retorna ao valor original
corta_fim:
	jr $ra
	
cria_mascara_bits: # Desloca para esquerda pela quantidade de itera��es
	sll $s7, $s7, 1
	add $s4, $s4, 1
	blt $s4, $s3, cria_mascara_bits
	jr $ra
	
encontra_quantidade_iteracoes: 
# Seta as itera��es para a quantidade de bits usados no resto
# Encontra o primeiro bit 1 do resto e para o procedimento
	li $s3, 32 # N�mero de bits de um registrador
	li $a0, 2147483648 # Bit na posi��o 32 vale 1
loop_iteracoes:
	and $a1, $a0, $t0 # Usa a m�scara para ver se existe o 1 na posi��o
	bgt $a1, 0, iteracoes_fim
	sub $s3, $s3, 1 # Quantidade de itera��es atualizada
	srl $a0, $a0, 1 # Bit desce para a posi��o 30... 
	j loop_iteracoes
iteracoes_fim:
	jr $ra