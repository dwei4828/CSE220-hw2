########### Enter Full Name ############
########### Enter NETID ################
########### Enter SBUID ################

###################################
##### DO NOT ADD A DATA SECTION ###
###################################

.text
.globl substr
substr:
    li $t0, 0
    move $t1, $a0
findLen:
    lbu $t2, 0($t1)
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    bnez $t2, findLen
    addi $t0, $t0, -1
    
check:
    bgt $a1, $t0, error  #if $a1 < length
    bgt $a2, $t0, error  
    bltz $a1, error
    bltz $a2, error  
    sub $t9, $a2, $a1
    move $t1, $a0
    move $t2, $a0
    add $t1, $a1, $t1
    
replaceLoop:
    lbu $t3, 0($t1)
    sb $t3, 0($t2)
    addi $t9, $t9, -1
    addi $t1, $t1, 1
    addi $t2, $t2, 1
    beqz $t9, success
    j replaceLoop
    
error: 
    li $v0, -1
    jr $ra
    
success:
    li $t4, 0
    sb $t4, 0($t2)
    li $v0, 0 
    jr $ra
    
.globl encrypt_block
encrypt_block:
    addi $sp, $sp, -24
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    lbu $t0, 0($a0)
    lbu $t1, 0($a1)
    xor $t2, $t0, $t1
    lbu $t0, 1($a0)
    lbu $t1, 1($a1)
    xor $t3, $t0, $t1
    lbu $t0, 2($a0)
    lbu $t1, 2($a1)
    xor $t4, $t0, $t1
    lbu $t0, 3($a0)
    lbu $t1, 3($a1)
    xor $t5, $t0, $t1
    add $t6, $0, $t2
    sll $t6, $t6, 8
    add $t6, $t6, $t3
    sll $t6, $t6, 8
    add $t6, $t6, $t4
    sll $t6, $t6, 8
    add $t6, $t6, $t5
    move $v0, $t6
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    addi $sp, $sp, 24
    j done
.globl add_block
add_block:
    addi $sp, $sp, -32
    sw $a0, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)
    sw $t5, 24($sp)
    sw $t6, 28($sp)
    li $t0, 4
    mul $t1, $a1, $t0
    li $t2, 255
    move $t3, $a0
    add $t3, $t3, $t1
    move $t5, $a2
    li $t6, 4 #counter
loopCode:
    and $t4, $t5, $t2
    sb $t4, 0($t3)
    addi $t3, $t3, 1
    srl $t5, $t5, 8
    addi $t6, $t6, -1
    beqz $t6, loopCodeDone
    j loopCode
loopCodeDone:
    lw $a0, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    lw $t5, 24($sp)
    lw $t6, 28($sp)
    addi $sp, $sp, 32
    j done
.globl gen_key
gen_key: 
    addi $sp, $sp, -32
    sw $a0, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)
    sw $t5, 24($sp)
    sw $t6, 28($sp)
    li $t0, 4
    mul $t1, $a1, $t0
    move $t2, $a0
    li $t3, 4 #counter
    add $a0, $a0, $t1
    move $t5, $a0
    move $t6, $a1
loopForKey:
    li $a1, 127
    li $v0, 42
    syscall
    move $t4, $a0
    sb $t4, 0($t5)
    addi $t5, $t5, 1
    addi $t3, $t3, -1
    beqz $t3, loopKeyDone
    j loopForKey
loopKeyDone:
    lw $a0, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    lw $t5, 24($sp)
    lw $t6, 28($sp)
    addi $sp, $sp, 32
    jr $ra
.globl encrypt
encrypt:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $a0, 12($sp) #plain
    sw $a1, 8($sp) #key
    sw $a2, 4($sp) #cipher
    sw $a3, 0($sp) #length
    li $t0, 4
    div $a3, $t0
    mfhi $t1
    mflo $t2
    beqz $t1, generateKey
    addi $t2, $t2, 1    #t2 to quotient + 1
    mul $t3, $t2, $t0   
    add $t4, $t3, $t0   #expected length
    sub $t7, $t4, $a3   #get the difference of the length and expected length
    move $t5, $a0 #address of plain
    add $t5, $t5, $a3 #move to end of plain
fillInLoop:
    li $a1, 127
    li $v0, 42
    syscall
    move $t6, $a0
    sb $t6, 0($t5)
    addi $t5, $t5, 1
    addi $t7, $t7, -1
    beqz $t7, generateKey
    j fillInLoop
    
generateKey:
    li $t1, 0 #counter
genKeyLoop:
    lw $a0, 8($sp) #change $a0 to key address
    move $a1, $t1 #set a1 to counter
    jal gen_key
    addi $t1, $t1, 1
    beq $t1, $t2, encryptBlock
    j genKeyLoop
    
encryptBlock:    
    lw $t9, 8($sp)#$t9 to key address
    lw $t8, 12($sp)#set $t8 to plaintext address
    li $t1, 0 #set counter to 0
    move $t7, $a2 #set t7 to cipher address
encryptLoop:
    move $a0, $t8
    move $a1, $t9
    jal encrypt_block
    move $a0, $t7 #set a0 to cipher address
    move $a1, $t1 #a1 to counter
    move $a2, $v0 #a2 to encrypted code
    jal add_block
    addi $t1, $t1, 1
    addi $t9, $t9, 4
    addi $t8, $t8, 4
    beq $t1, $t2, finishEncrypt
    j encryptLoop
finishEncrypt:
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra
    
.globl decrypt_block
decrypt_block:
    addi $sp, $sp, -32
    sw $a1, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)
    sw $t5, 24($sp)
    sw $t6, 28($sp)
    lbu $t0, 0($a1)
    lbu $t1, 1($a1)
    lbu $t2, 2($a1)
    lbu $t3, 3($a1)
    sb $t3, 0($a1)
    sb $t2, 1($a1)
    sb $t1, 2($a1)
    sb $t0, 3($a1)
    lbu $t0, 0($a0)
    lbu $t1, 0($a1)
    xor $t2, $t0, $t1
    lbu $t0, 1($a0)
    lbu $t1, 1($a1)
    xor $t3, $t0, $t1
    lbu $t0, 2($a0)
    lbu $t1, 2($a1)
    xor $t4, $t0, $t1
    lbu $t0, 3($a0)
    lbu $t1, 3($a1)
    xor $t5, $t0, $t1
    add $t6, $0, $t2
    sll $t6, $t6, 8
    add $t6, $t6, $t3
    sll $t6, $t6, 8
    add $t6, $t6, $t4
    sll $t6, $t6, 8
    add $t6, $t6, $t5
    move $v0, $t6
    
    lbu $t0, 0($a1)
    lbu $t1, 1($a1)
    lbu $t2, 2($a1)
    lbu $t3, 3($a1)
    sb $t3, 0($a1)
    sb $t2, 1($a1)
    sb $t1, 2($a1)
    sb $t0, 3($a1)
    
    lw $a1, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    lw $t5, 24($sp)
    lw $t6, 28($sp)
    addi $sp, $sp, 32
    jr $ra

.globl decrypt
decrypt:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $t0, 4
    div $a2, $t0
    mflo $t1
    li $t3, 0
    move $t8, $a0
    move $t9, $a1
decLoop:
    move $a0, $t8
    move $a1, $t9
    jal decrypt_block
    move $t2, $v0
    move $a2, $t2
    move $a1, $t3
    move $a0, $a3
    jal add_block
    addi $t3, $t3, 1
    addi $t1, $t1, -1
    addi $t8, $t8, 4
    addi $t9, $t9, 4
    beqz $t1, decryptDone
    j decLoop
decryptDone:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
done:
 jr $ra
   
