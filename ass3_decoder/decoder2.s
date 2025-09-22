
.data
.include "helloWorld.s"
fmt:		.string "%c\n"

.text
.global main

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
decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
	subq	$24, %rsp

	movq	%rdi, -24(%rbp)	#save %rdi in -24(%rbp)
	movq	(%rdi), %rax

	#print several strings
    #register for arguments
    #%rdi -> first arguments
    #%rsi -> second
    #%rdx, %rcx, %r8, r9
    #more than that -> stack

#| 0000 0001 	0010 0011	0100 0101 	0110 0111 	| ------> EAX
#|							0100 0101 	0110 0111 	| ------> AX
#|										0110 0111 	| ------> AL
#|    						0100 0101				| ------> AH


	movzbq	%al, %rsi		#rsi = character
	shr		$8, %rax
	movzbq	%al, %rdx		#rdx = amount
	shr		$16, %rax
	movl	%eax, %ecx		#ecx = index

	# Store them on stack
    movl    %ecx, -4(%rbp)   # store index (4 bytes)
    movq    %rdx, -8(%rbp)   # store amount (8 bytes)
    movq    %rsi, -16(%rbp)  # store character (8 bytes)

loop:
    cmpq    $0, -8(%rbp)     # compare amount with 0
    jbe     loop_end

    movq    $fmt, %rdi
    movq    -16(%rbp), %rsi  # load character from stack
    xorq    %rax, %rax
    call    printf

    decq    -8(%rbp)         # decrement amount on stack
    jmp     loop

loop_end:
	cmpl	$0, -4(%rbp)
	jbe		ending

	movl 	-4(%rbp), %r8d
	movq	-24(%rbp), %rdi
	imul	$8, %r8d
	leaq 	(%rdi,%rax,1), %rdi
	call	decode


ending:
	movq    %rbp, %rsp
    popq    %rbp
    ret



main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	leaq	MESSAGE(%rip), %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

