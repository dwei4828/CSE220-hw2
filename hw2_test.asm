########### Run and assemble this file to run hw2.asm ###########
########### Change the file to test hw2.asm ###########
.data
 plaintext: .ascii "Hello Seawolves!"
 buf: .space 4
 ciphertext: .space 16
 key: .space 16
 origtext: .space 16

.text:
 la $a0, plaintext
 la $a1, key
 la $a2, ciphertext
 li $a3, 16
 jal encrypt

 la $a0, ciphertext
 la $a1, key
 li $a2, 16
 la $a3, origtext
 jal decrypt

 la $a0, origtext
 li $a1, 0
 li $a2, 16
 jal substr

 la $a0, origtext
 li $v0, 4
 syscall

 li $v0, 10
 syscall

.include "hw2.asm"
