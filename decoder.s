.text

.include "final.s"

.global main

fmt:
    .string "%c"

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************

# %r14 = charachter
# %r13 = Amount
# %rbx = index
main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program



decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq 	%rdi, %rsi
	

	

decode_loop:
	movq 	(%rsi), %rax	#Let %rax contain all 64 bits of message

	movb	%al, %r14b		#Let %r14 contain the charachter (%al --> 0-7)
	shr		$8, %rax
	movb 	%al, %r13b		#Let %r13 contain the Amount of repetition (%ah --> 8-15)

	shr		$8, %rax
    shl     $32, %rax       # push unknown out
    shr     $32, %rax       # now rax contains only the 32-bit index
	mov		%rax, %rbx		#Save the index in register %rbx


print_loop:
	cmp		$0, %r13b		#Check if repeat count is equal to 0
	je		end_print		#if so jump to next memory block

	movq	$fmt, %rdi		#load fromat string into first argument
	movzbl	%r14b, %esi		#load the charachter into rsi
	movq	$0, %rax		#clear %rax
	call	printf

	dec 	%r13b			#decrease the repeater by 1, else infinte loop
	jmp		print_loop		#repeat the loop

# %rdx --> %rsi = new address for MESSAGE
end_print:
#Load next memory block
	cmp 	$0, %rbx
	je 		end_loop

	movq	%rbx, %rax		#move index toregister %rax
	imulq	$8, %rax, %rax	#Multiply the index by 8 and store it in %rbx
	movq	$MESSAGE, %rdx	#baser address of message
	addq	%rax, %rdx 		#base + (index * 8) into %rcx
	movq	%rdx, %rsi		#The new base is being put into rsi which now points to the next memory block
	
	
	jmp 	decode_loop

end_loop:
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret


