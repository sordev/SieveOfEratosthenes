# Sieve of Eratosthenes
# test
# version updates
# 1st version had 3 loops, per instruction I've looped 3 times, 1st loop to loop through numbers, 2nd to create multiplies, 3rd to compare multiplies to numbers
# 2nd I've removed multiply loop instead used modulo so it should be at least one loop cheaper,
# 3rd I've removed counting instead of counting i've divided input by 2 and reduced division by eliminated numbers
# also instead of adding all numbers changed step by 2 starting from 3 so array size can be twice as smaller
# and added bunch of optimization, sadly still very slow 
# has debug to show numbers

.data
	numbers: .space 131072
	welcome_text:  .asciiz "Please enter the maximum value to be tested for prime numbers: "
	result_text_prefix: .asciiz "In the range of 1-"
	result_text_suffix: .asciiz ", the number of primes is: "
	not_found_text: .asciiz "No primes found"
	cant_text: .asciiz "Can't compute number higher than 32768"
	space: .asciiz " "
	#enter: .asciiz "\n"
	#first_loop: .asciiz "\n1st Loop: "
	#second_loop: .asciiz "\n 2nd Loop: "
	#third_loop: .asciiz "\n  3rd Loop: "
	#eliminated: .asciiz "\n   Eliminated: "
	
.text
	# show welcome
	la $a0, welcome_text 
	li $v0, 4
	syscall
	
	# get user input
	li $v0, 5
	syscall
	move $s0, $v0
	
	# index
	li $t0, 0
	# number, start from 2
	li $t1, 3
	
	# if lower than 2 just exit
	add $t2, $t1, -1
	blt $s0, $t2, not_found
	
	# higher than 32768 exit
	bge $s0, 32768, cant_result
	
	# even numbers
	li $t2,2
	div $s1,$s0,$t2
	mflo $s1

fill_numbers:
	# instead of modulo stepping 2 steps
	# if t2%2 then don't add to array
	#li $t2,2
	#div $t1,$t2
	#mfhi $t3
	#beqz $t3, fill_numbers_increase
			
	bgt $t1, $s0, loop_numbers_init
	sw $t1, numbers($t0)
	#increase index
	addi $t0, $t0, 4
	addi $t1, $t1, 2
	j fill_numbers
	
	#j fill_numbers_increase

#fill_numbers_increase:
	#increase number
	#addi $t1, $t1, 2
	#j fill_numbers
	
loop_numbers_init:
	# index
	li $t0, 0
	j loop_numbers
	
loop_numbers:
	# load current number into t1
	lw $t1, numbers($t0)
	
	beqz $t1, print_result
	# found a better way to count, divide input by 2 and reduce by eliminted
	#beqz $t1, count_numbers_init
	# debug
	#beqz $t1, print_numbers_init
	bltz $t1, loop_numbers_increase_index
	
	j loop_multi_init

loop_numbers_increase_index:
	#increase index
	addi $t0, $t0, 4
	j loop_numbers
	
loop_multi_init:
	# index, start from next word
	addi $t2, $t0, 4
	j loop_multi

loop_multi:
	lw $t3, numbers($t2)
	
	bltz $t3, loop_multi_increase_index
	
	beqz $t3, loop_numbers_increase_index
	
	mul $t5, $t1, $t1
	# if square is lower than current skip
	blt $t3, $t5, loop_multi_increase_index
	# if square is higher than given number skip
	bgt $t5, $s0, loop_numbers_increase_index
	
	# t3%t1 
	div $t3,$t1
	mfhi $t4
	beqz $t4, eliminate
	
	j loop_multi_increase_index

loop_multi_increase_index:
	#increase index
	addi $t2, $t2, 4
	j loop_multi

eliminate:
	# mark -1 to eliminate
	li $t5, -1,
	sw $t5, numbers($t2)
	
	# decrease odd numbers
	addi $s1, $s1, -1
	j loop_multi_increase_index
	
count_numbers_init:
	# index
	li $t0, 0
	# start with 1 since 2 is already included
	li $t1, 1 
	j count_numbers_loop
	
count_numbers_loop:
	lw $t2, numbers($t0)
	beqz $t2, print_result
	
	bltz $t2, count_numbers_increase_index
	addi $t1, $t1, 1
	j count_numbers_increase_index
	
count_numbers_increase_index:
	#increase index
	addi $t0, $t0, 4
	j count_numbers_loop	
	

print_numbers_init:
	# index
	li $t0, 0
	j print_numbers
	
print_numbers:
	lw $a0, numbers($t0)
	beqz $a0, count_numbers_init
	#increase index
	addi $t0, $t0, 4
	
	li $v0, 1
	syscall
	
	la $a0, space
	li $v0, 4
	syscall
	
	j print_numbers

print_result:
	la $a0, result_text_prefix
	li $v0, 4
	syscall
		
	li $v0, 1
	move $a0, $s0
	syscall
		
	la $a0, result_text_suffix
	li $v0, 4
	syscall
	
	# old way to count
	#li $v0, 1
	#move $a0, $t1
	#syscall
	
	la $a0, space
	li $v0, 4
	syscall
	
	li $v0, 1
	move $a0, $s1
	syscall
	j exit

cant_result:
	la $a0, cant_text
	li $v0, 4
	syscall
	j exit

not_found:
	la $a0, not_found_text
	li $v0, 4
	syscall
	j exit

exit:
	li $v0, 10
	syscall
	
