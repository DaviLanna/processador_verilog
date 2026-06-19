# -----------------------------------------------------------------------------
# Arquivo: programa_teste.s
# Descricao: Programa de teste para o processador RV32I monociclo.
# Objetivo: usar todas as 30 instrucoes obrigatorias do enunciado.
# Observacao: nao usa pseudo-instrucoes.
# -----------------------------------------------------------------------------

# Inicializacao de valores basicos
addi x1,  x0, 5          # x1  = 5
addi x2,  x0, 10         # x2  = 10
addi x12, x0, -1         # x12 = -1, usado em SRA/SRAI
addi x13, x0, 1          # x13 = 1, usado como quantidade de shift

# U-Type
lui  x14, 0x12345        # x14 = 0x12345000

# R-Type: 10 instrucoes
add  x3,  x1, x2         # x3  = 15
sub  x4,  x2, x1         # x4  = 5
sll  x5,  x1, x13        # x5  = 5 << 1 = 10
slt  x6,  x1, x2         # x6  = 1, pois 5 < 10 com sinal
sltu x7,  x1, x2         # x7  = 1, pois 5 < 10 sem sinal
xor  x8,  x1, x2         # x8  = 15
srl  x9,  x2, x13        # x9  = 10 >> 1 = 5
sra  x10, x12, x13       # x10 = -1 >> 1 = -1
or   x11, x1, x2         # x11 = 15
and  x14, x1, x2         # x14 = 0

# I-Type aritmetico/logico: 9 instrucoes
slti  x15, x1, 6         # x15 = 1
sltiu x15, x1, 6         # x15 = 1
xori  x15, x1, 3         # x15 = 6
ori   x15, x1, 2         # x15 = 7
andi  x15, x2, 6         # x15 = 2
slli  x5,  x1, 2         # x5  = 20
srli  x9,  x2, 1         # x9  = 5
srai  x10, x12, 1        # x10 = -1

# Memoria: SW e LW
sw   x3, 0(x0)           # memoria[0] = 15
lw   x15, 0(x0)          # x15 = 15

# Branches: os desvios devem ser tomados e pular as instrucoes de erro
beq  x1, x4, beq_ok      # 5 == 5, deve desviar
addi x15, x0, 111        # erro se executar
beq_ok:

bne  x1, x2, bne_ok      # 5 != 10, deve desviar
addi x15, x0, 112        # erro se executar
bne_ok:

blt  x1, x2, blt_ok      # 5 < 10, deve desviar
addi x15, x0, 113        # erro se executar
blt_ok:

bge  x2, x1, bge_ok      # 10 >= 5, deve desviar
addi x15, x0, 114        # erro se executar
bge_ok:

bltu x1, x2, bltu_ok     # 5 < 10, deve desviar
addi x15, x0, 115        # erro se executar
bltu_ok:

bgeu x2, x1, bgeu_ok     # 10 >= 5, deve desviar
addi x15, x0, 116        # erro se executar
bgeu_ok:

# Saltos: JAL e JALR
jal  x15, subrotina      # x15 recebe PC+4 e salta para subrotina
retorno:
addi x14, x0, 30         # marcador final de sucesso: x14 = 30
jal  x0, fim             # pula para o loop final

subrotina:
addi x13, x13, 1         # x13 = 2, prova que a subrotina executou
jalr x0, 0(x15)          # volta para o endereco salvo em x15

fim:
jal  x0, fim             # loop infinito para nao ler lixo da memoria