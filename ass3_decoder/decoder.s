.text

.include "abc_sorted.s"


.data
fmt:		.string "%c"

.global main
main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program


# ****************%********************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value    								 *
#0 B B B B B 00001000 00000001 01001000 ? 8 1 H				 *
#1 B B B B B 00001010 00000001 01010111 ? 10 1 W			 *				 
#2 B B B B B 00000111 00000001 01101100 ? 7 1 l			     *
#3 B B B B B 00000001 00000001 00100000 ? 1 1			 	 *
#4 B B B B B 00000101 00000010 01101100 ? 5 2 l				 *
#5 B B B B B 00000011 00000001 01101111 ? 3 1 o			 	 *
#6 B B B B B 00000000 00000001 00100001 ? 0 1 !				 *
#7 B B B B B 00000110 00000001 01100100 ? 6 1 d				 *
#8 B B B B B 00000100 00000001 01100101 ? 4 1 e				 *
#9 B B B B B 00000010 00000001 01110010 ? 2 1 r				 *
#10 B B B B B 00001001 00000001 01101111 ? 9 1 o             *
# ************************************************************
decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	%rdi, %rax

	#print several strings
    #register for arguments
    #%rdi -> first arguments
    #%rsi -> second
    #%rdx, %rcx, %r8, r9
    #more than that -> stack

	shl		$16, %rax		#index
	movl	%eax, %ecx		#move 4 bytes

	shl		$32, %rax		#amount
	movzbq	%al, %rdx		#move 1 byte (extend register with zero's, 0x0000000000..)

	shl		$8, %rax		#character
	movzbq	%al, %rsi		#move 1 byte (extend register with zero's)

	#rdi = "Character" FIRST AGRUMENT
	#rsi = "Amount" SECOND ARGUMENT
	#rdx = "Index" THIRD ARGUMENT

loop:
	cmp		$0, %rdx
	je		loop_end
	movq	$fmt, %rdi
	movq	$0, %rax
	call	printf
	dec		%rdx
	jmp		loop


loop_end:
	cmp		$0, %rcx 
	je		ending
	
	leaq	(MESSAGE)+%rcx(%rip), %rdi
	call	decode


ending:
	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret


