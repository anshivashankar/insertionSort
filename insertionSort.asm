.globl main

.data
space: .asciiz " "
openBracket: .asciiz "["
closeBracket: .asciiz " ]\n"
size: .word 16
initialSize: .asciiz "Initial array is:\n" #printf("Initial array is:\n");
endPrint: .asciiz "Insertion sort is finished!\n" #printf("Insertion sort is finished!\n");
           .align 5  # in our example, names start on a 32-byte boundary
#           char * data[] = {"Joe", "Jenny", "Jill", "John", "Jeff", "Joyce",
#		"Jerry", "Janice", "Jake", "Jonna", "Jack", "Jocelyn",
#		"Jessie", "Jess", "Janet", "Jane"};
dataName:
	.asciiz "Joe"
           .align 5
           .asciiz "Jenny"
           .align 5
           .asciiz "Jill"
           .align 5
           .asciiz "John"
           .align 5
           .asciiz "Jeff"
           .align 5
           .asciiz "Joyce"
           .align 5
           .asciiz "Jerry"
           .align 5
           .asciiz "Janice"
           .align 5
           .asciiz "Jake"
           .align 5
           .asciiz "Jonna"
           .align 5
           .asciiz "Jack"
           .align 5
           .asciiz "Jocelyn"
           .align 5
           .asciiz "Jessie"
           .align 5
           .asciiz "Jess"
           .align 5
           .asciiz "Janet"
           .align 5
           .asciiz "Jane"

          .align 2  # addresses should start on a word boundary
dataAddr: .space 64 # 16 pointers to strings: 16*4 = 64

.text

main:    
	li $v0, 4
	la $a0, initialSize 	#printf("Initial array is:\n");
	syscall
	
	li $t1, 0 # i
	la $t4, dataName
	la $t5, dataAddr
	mainLoop:
		beq $t1, 16, mainLoopEnd
		mul $t2, $t1, 32 
		mul $t3, $t1, 4
		addu $t2, $t2, $t4	# dataName[i]
		addu $t3, $t3, $t5	# dataAddr[i]
		sw $t2, ($t3)		# dataAddr[i] = dataName[i]
		addi $t1, $t1, 1
		j mainLoop
	mainLoopEnd:
	move $s2, $t5		 # so that dataAddr is contained in a saved address
	move $a0, $s2
	lw $a1, size
	jal pa 			# print_array(data, size);
	
	move $a0, $s2
	lw $a1, size
	jal insertSort		 #insertSort(data, size);
	
	li $v0, 4
	la $a0, endPrint
	syscall 		#printf("Insertion sort is finished!\n");
	
	move $a0, $s2
	lw $a1, size
	jal pa	 	#print_array(data, size);
 	
	li $v0, 10
	syscall 	#exit(0);


insertSort:
	subi $sp, $sp, 36
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $t5, 24($sp)
	sw $t6, 28($sp)
	sw $t7, 32($sp)
	
	move $t0, $a0 		# dataAddr
	move $t1, $a1 		# size
	li $t2, 1 		# i = 1
	insertLoop:
	bge $t2, $t1, insertLoopEnd	#for (i = 1; i < length;)
	la $t7, ($t0)		# addr of dataAddr
	mul $t3, $t2, 4 	# 4*i
	addu $t3, $t3, $t7 	# addr+ 4*i = addr of a[i]
	lw $t3, ($t3)		#value = a[i];
	subi $t4, $t2, 1 	# j = i-1
	
	insertLoop2:
	blt $t4, $zero, insertLoop2End # if j < 0, break loop
	move $a0, $t3 		# arg1 str_lt (*value)
	mul $t5, $t4, 4		# j*4
	addu $t5, $t5, $t7  	# $t5 = a[j]
	
	lw $a1, ($t5) 		# arg2 str_lt (a[j])
	
	jal str_lt		# str_lt(value, a[j]) 
	
	beq $v0, $zero, insertLoop2End	# if str_lt(value, a[j]) = 0 break loop

	mul $t6, $t4, 4		
	addu $t6, $t6, $t7	# $t7 has contents of dataAddr
	lw $t6, ($t6) 		# a[j]
	
	move $t7, $t0		# $t7 is now pointer to dataAddr
	addi $s3, $t4, 1
	mul $s3, $s3, 4
	addu $s3, $s3, $t7 	# a[j+1]
	sw $t6, ($s3) 		#a[j+1] = a[j]
	
	subi $t4, $t4, 1	# j--;
	j insertLoop2		#}
	
	insertLoop2End:		
	addi $t4, $t4, 1	# j++;
	mul $t5, $t4, 4
	addu $t5, $t5, $t0
	sw $t3, ($t5)		# a[j+1] = value
	
	
	addi $t2, $t2, 1	# i++;
	j insertLoop		#}
	insertLoopEnd:
	
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t4, 20($sp)
	lw $t5, 24($sp)
	lw $t6, 28($sp)
	lw $t7, 32($sp)
	addi $sp, $sp, 36
	jr $ra
	
#takes in char *x, char *y, will be in $a0, $a1, respectively
# outputs an int, will be in $v0
str_lt:
	subi $sp, $sp, 36
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $t5, 24($sp)
	sw $t6, 28($sp)
	sw $t7, 32($sp)
	
	move $t0, $a0 			# $t0 is char *x
	move $t1, $a1 			# $t1 is char *y
	
str_loop:
	lb $t3, ($t0) 			# *x
	lb $t4, ($t1) 			# *y
	
	beq $t3, $zero, str_loop_end 	# if *x == '\0' then don't loop
	beq $t4, $zero, str_loop_end 	# if *y == '\0' then don't loop
	
	blt $t3, $t4, str_loop_end_1 	# if *x < *y return 1
	blt $t4, $t3, str_loop_end_0 	# if *y < *x return 0
	
	addi $t0, $t0, 1		# x++
	addi $t1, $t1, 1		# y++
	j str_loop
	
str_loop_end:
	beq $t4, $zero, str_loop_end_0 # if *y == '\0'
	j str_loop_end_1 		#else
str_loop_end_1:
	li $v0, 1 			#return 1
	j str_loop_end_all
str_loop_end_0:
	li $v0, 0 			#return 0
	j str_loop_end_all
str_loop_end_all:
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t4, 20($sp)
	lw $t5, 24($sp)
	lw $t6, 28($sp)
	lw $t7, 32($sp)
	addi $sp, $sp, 36
	jr $ra
pa:
	subi $sp, $sp, 20
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	move $t0, $a0 		# $t0 = array pointer
	li $t2, 0 		# i = 0
	
	li $v0, 4
	la $a0, openBracket 	# printf("[")
	syscall
	
pa_loop:
	beq $t2, $a1, pa_end
	
	li $v0, 4
	la $a0, space 		# printf(" ")
	syscall
	
	mul $t1, $t2, 4		# 4*i
	
	addu $t3, $t1, $t0 	
	lw $a0, ($t3)		# printf("%s", a[i])
	li $v0, 4
	syscall
	
	addi $t2, $t2, 1 	# i++
	j pa_loop
	
pa_end:

	li $v0, 4
	la $a0, closeBracket 	# printf(" ]\n)
	syscall
	
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)	
	addi $sp, $sp, 20
	
	jr $ra
