# Trabalho 2 de Organiza��o de Computadores com Giovani Baratto
# Alunos: Estevan Silva e Adrian Kaminski
# Frisando que o resultado mostra em $t8!

# Sobre o algoritmo: O resultado final da soma em ponto flutuante com precis�o simples 
# usando somente registradores de ponto inteiro e suas intru��es � colocado em $t8.
# Para analisar o resultado, olhar o valor em hexadecimal mostrado na tabela
# de registradores.

# Avalia��o: O resultado encontra da soma pedida � foi 0x517ce8d4, sendo que
# a ferramenta Floating Point Representation mostra 0x517ce8d5. H� um pequeno
# erro da soma no �ltimo bit da fra��o.

.text   

# 6,789 * 10^10 = 0x517ce8f3 = 1367140595 (representa��o em decimal)
# -1,2354 * 10^5 = 0xc7f14a00 = 3354479104 (representa��o em decimal)
# Resultado esperado:
# Em Decimal: 67889876460
# Em Bin�rio: 0 10100010 11111001110100011010101
# Em Hexadecimal: 0x517ce8d5

li $s0, 1367140595 # A
li $s1, 3354479104 # B

srl $s2, $s0, 31 # $s2 = Sinal de A
sll $t0, $s0, 1
srl $s3, $t0, 24 # $s3 = Expoente de A
sll $t0, $s0, 9
srl $s4, $t0, 9 # $s4 = Fra��o de A

srl $s5, $s1, 31 # $s5 = Sinal de B
sll $t0, $s1, 1
srl $s6, $t0, 24 # #s6 = Expoente de B 
sll $t0, $s1, 9
srl $s7, $t0, 9 # $s7 = Fra��o de B

sub $t7, $s3, $s6 # $t7 = DEP (diferen�a entre expoentes)

############### Adicionar GAS, usado para melhor precis�o na soma
sll $s4, $s4, 3 # Fra��o de A com GAS
sll $s7, $s7, 3 # Fra��o de B com GAS
bgtz $t7, DEP_maior_zero
# <= 0
beqz $t7, ajuste_expoente_pronto

############### Deslocar fra��o e expoente de A
DEP_menor_zero: # < 0

# fazer
j ajuste_expoente_pronto

############### Deslocar fra��o e expoente de B
DEP_maior_zero: # > 0
srlv $s7, $s7, $t7 # Desloca para a direita a fra��o de B
add $s6, $s6, $t7  # Adiciona DEP ao expoente de B
j ajuste_expoente_pronto

###################### Colocar parte inteira no significando
ajuste_expoente_pronto: 
add $a0, $s4, $zero
jal encontra_mascara_parte_inteira # Argumento: $a0, Retorno: $v0
or $k0, $v0, $s4 # $k0 = Significando de A

add $a0, $s7, $zero
jal encontra_mascara_parte_inteira # Argumento: $a0, Retorno: $v0
or $k1, $v0, $s7 # $k1 = Significando de B

beqz $s5, B_positivo # Verifica sinal de B

########### Se sinal de B � negativo, atualizar o significando de B
B_negativo: # Complementar significando e somar 1
li $t0, 4294967295
xor  $k1, $k1, $t0 # Complementa com XOR
add $k1, $k1, 1 # Soma 1
j significandos_prontos

########### 
B_positivo:
# fazer

##################### Passos finais para criar o resultado
significandos_prontos: # Somar significandos
add $t0, $k0, $k1 # $t0 = Soma

############################### Normalizar soma
jal encontra_valor_deslocamento # Argumento: $t0, Retorno: $a1

srl $t0, $t0, 3 # Retira GAS
sllv $t0, $t0, $a1 # Normaliza com o deslocamento necess�rio
sub $s3, $s3, $a1 # Maior expoente recebe a subtra��o

add $t8, $s3, $zero # $t8 = Resultado; Recebe o expoente do maior n�mero
sll $t8, $t8, 23 # Posiciona expoente na posi��o correta do vetor de bits

li $t1, 8388607 # M�scara para retirar o 1 normalizado do final
and $t0, $t0, $t1 # A soma agora est� em forma de fra��o

or $t8, $t8, $t0 # Junta expoente com a fra��o

end:
li $v0, 10
syscall

############################## Procedimentos

encontra_mascara_parte_inteira:
li $v0, 2147483648 # M�scara com 1 na posi��o 32
mascara_loop:
and $t0, $a0, $v0 # Verifica se encontrou o primeiro bit 1 de $a0
srl $v0, $v0, 1 # Avan�a m�scara
beqz $t0, mascara_loop

sll $v0, $v0, 2 # Volta 2 passos para entregar
jr $ra

encontra_valor_deslocamento: # Usado para normalizar o significando
li $a0, 2147483648 # M�scara com 1 na posi��o 32
li $a1, -1 # Contador
desloc_loop:
and $a2, $t0, $a0 # Verifica se encontrou o primeiro bit 1 de $t0
add $a1, $a1, 1 # Aumenta contador
srl $a0, $a0, 1 # Avan�a m�scara
beqz $a2, desloc_loop

sub $a1, $a1, 5 # Ajuste do contador
jr $ra