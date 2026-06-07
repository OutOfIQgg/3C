/* 3C >> Circle Chasing Circle (prototype build) 
* This game was built on the GNU Assembler.
* It is a mere experiment for my Assembly knowledge, expect errors and some random things that are inoptimal
* I'll try to make the game in another way that's low-level (e.g., DRM KMS GEM, Cocoa or similar for MacOS, etc...)
*/

.section .data
	window_title:
		.asciz "Circle Chasing Circle"
	
	back_color:
		.byte 0, 0, 0, 255
	
	cir_pos_x:
		.float 400.0
	
	cir_pos_y:
		.float 300.0
	
	cir_rad:
		.float 30.0
	
	cir_speed:
		.float 7.5
	
	cir_vel_x:
		.float 0.0
	
	cir_vel_y:
		.float 0.0
	
	cir_points:
		.int 0
	
	cir_points_str:
		.asciz "Points: %d"
	
	cir_points_buf:
		.space 64
	
	white:
		.byte 255, 255, 255, 255
	
	dot_points:
		.int 10
	
	dot_rad:
		.float 2.0

	dots:
	.float 200.0, 200.0		# dot 0: x = 0, y = 4
	.float 600.0, 200.0		# dot 1: x = 8, y = 12
	.float 200.0, 400.0		# dot 2: x = 16, y = 20
	.float 600.0, 400.0		# dot 3: x = 24, y = 28
	.float 400.0, 300.0		# dot 4: x = 32, y = 36
	.float 0.0, 0.0			# dot 5: x = 40, y = 44
	.float 0.0, 0.0			# dot 6: x = 48, y = 52
	.float 0.0, 0.0			# dot 7: x = 56, y = 60
	.float 0.0, 0.0			# dot 8: x = 64, y = 68
	.float 0.0, 0.0			# dot 9: x = 72, y = 76

.section .text
	.global main

#.equiv _rip, (%rip)

.equiv _win_wid, 800
.equiv _win_hei, 600
.equiv _dots, 10

main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	pushq %rbx
	subq $8, %rsp

	# WindowInit
	movl $_win_wid, %edi
	movl $_win_hei, %esi
	leaq window_title(%rip), %rdx
	call InitWindow@PLT

	movl $60, %edi
	call SetTargetFPS

	# loop
.Lwindow_loop:
	call WindowShouldClose@PLT
	testb %al, %al
	jnz .Lcleanup

	# Point number display (snprintf) (Spoiler: it FAILED and we used TextFormat [provided by raylib])

	#leaq cir_points_buf(%rip), %rdi
	#movl $64, %esi
	#leaq cir_points_str(%rip), %rdx
	#movl cir_points(%rip), %r8d
	#xorq %rax, %rax
	#call snprintf@PLT

	# Dot logic

	leaq dots(%rip), %rbx

	# for (int i = 0; i <= 10; i++)
	movl $0, %r12d
	.LgenDots_str:

	cmp $_dots, %r12d
	jge .LgenDots_end

	movss (%rbx), %xmm0				# xmm0 = dot[i];
	movss 4(%rbx), %xmm1			# xmm1 = dot[i+1]
	movss dot_rad(%rip), %xmm2		# xmm2 = 2.0

	movss cir_pos_x(%rip), %xmm3	# xmm3 = cir.pos.x
	movss cir_pos_y(%rip), %xmm4	# xmm4 = cir.pos.y
	movss cir_rad(%rip), %xmm5		# xmm5 = cir.rad = 30.0

	# dx & dy
	subss %xmm0, %xmm3				# xmm3(200) -= xmm0(200) = 0
	subss %xmm1, %xmm4				# xmm4(200) -= xmm1(400) = 200

	# dx^2 & dy^2
	mulss %xmm3, %xmm3				# xmm3(0) *= xmm3(0) = 0
	mulss %xmm4, %xmm4				# xmm4(200) *= xmm4(200) = 40,000

	# dist^2
	addss %xmm3, %xmm4				# xmm4(40,000) += xmm3(0) = 40,000

	# rad_sum
	addss %xmm2, %xmm5				# xmm5(30) += xmm2(2) = 32

	# rad_sum^2
	mulss %xmm5, %xmm5				# xmm5(32) *= xmm5(32) = 1024

	## if xmm5(1024) <= xmm4(40,000)
	ucomiss %xmm4, %xmm5
	jbe .Lcond_1_not		# This fires when there's no collision
	## else

	# RNG for X
	movl $20, %edi
	movl $780, %esi
	call GetRandomValue@PLT

	cvtsi2ss %eax, %xmm0
	movss %xmm0, (%rbx)

	# RNG for Y
	movl $20, %edi
	movl $580, %esi
	call GetRandomValue@PLT

	cvtsi2ss %eax, %xmm0
	movss %xmm0, 4(%rbx)

	movl cir_points(%rip), %r13d
	addl dot_points(%rip), %r13d
	movl %r13d, cir_points(%rip)

	.Lcond_1_not:
	addq $8, %rbx

	inc %r12d
	
	jmp .LgenDots_str

	.LgenDots_end:

	# old logic (for one dot)
	/*
	movss dots(%rip), %xmm0			# exm = 350
	movss dots+4(%rip), %xmm1		# exm = 540
	movss dot_rad(%rip), %xmm2		# 2.0
	
	movss cir_pos_x(%rip), %xmm3	# 200
	movss cir_pos_y(%rip), %xmm4	# 200
	movss cir_rad(%rip), %xmm5		# 30

	# dx & dy
	subss %xmm0, %xmm3				# xmm3 = xmm3(200) - xmm0(350) = -150
	subss %xmm1, %xmm4				# xmm4 = xmm4(200) - xmm1(540) = -340

	# dx^2 & dy^2
	mulss %xmm3, %xmm3				# xmm3 = xmm3(-150)^2 = 22,500
	mulss %xmm4, %xmm4				# xmm4 = xmm4(-340)^2 = 115,600

	# dist^2
	addss %xmm3, %xmm4				# xmm4 = xmm4(115,600) + xmm3(22,500) = 138,100

	# rad_sum
	addss %xmm2, %xmm5				# xmm5 = xmm5(30) + xmm2(2) = 32

	# rad_sum^2
	mulss %xmm5, %xmm5				# xmm5 = xmm5(32)^2 = 1024

	# if xmm5 > xmm4
	ucomiss %xmm4, %xmm5
	jb .Lcond_1_not

	# RNG for X
	movl $20, %edi
	movl $_win_wid, %esi
	call GetRandomValue@PLT

	cvtsi2ss %eax, %xmm0
	movss %xmm0, dots(%rip)

	#RNG for Y
	movl $20, %edi
	movl $_win_hei, %esi
	call GetRandomValue@PLT

	cvtsi2ss %eax, %xmm0
	movss %xmm0, dots+4(%rip)

	.Lcond_1_not:
	*/

	# Player logic

	# Movement

	# A -- left
	movl $65, %edi
	call IsKeyDown@PLT
	movzbl %al, %r13d				# T or F (int)

	# D -- right
	movl $68, %edi
	call IsKeyDown@PLT
	movzbl %al, %r14d				# T or F (int)

	# (A - D) * speed
	sub %r13d, %r14d
	movss cir_speed(%rip), %xmm2
	cvtsi2ss %r14d, %xmm1
	mulss %xmm1, %xmm2
	movss %xmm2, cir_vel_x(%rip)

	# cir_pos_x += cir_vel_x > cir_pos_x = cir_pos_x + cir_vel_x
	movss cir_vel_x(%rip), %xmm1
	movss cir_pos_x(%rip), %xmm2
	addss %xmm1, %xmm2
	movss %xmm2, cir_pos_x(%rip)

	# W -- Up
	movl $87, %edi
	call IsKeyDown@PLT
	movzbl %al, %r12d				# T or F (int)

	# S -- Down
	movl $83, %edi
	call IsKeyDown@PLT
	movzbl %al, %ebx				# T or F (int)

	# (S - W) * speed
	sub %r12d, %ebx
	movss cir_speed(%rip), %xmm2
	cvtsi2ss %ebx, %xmm1
	mulss %xmm1, %xmm2
	movss %xmm2, cir_vel_y(%rip)

	# cir_pos_y += cir_vel_y > cir_pos_y = cir_pos_y + cir_vel_y
	movss cir_vel_y(%rip), %xmm1
	movss cir_pos_y(%rip), %xmm2
	addss %xmm1, %xmm2
	movss %xmm2, cir_pos_y(%rip)

	#andq $-16, %rsp

	call BeginDrawing@PLT

	movl back_color(%rip), %edi
	call ClearBackground@PLT

	# Make Vector2 for circle && radius
	movss cir_pos_x(%rip), %xmm0
	movss cir_pos_y(%rip), %xmm1
	unpcklps %xmm1, %xmm0

	movss cir_rad(%rip), %xmm1
	movl white(%rip), %edi
	call DrawCircleV@PLT
	

	# Dots

	leaq dots(%rip), %rbx

	# Use RBX as dots[]
	movq $0, %r12

	.LdrawDots_str:

	cmp $_dots, %r12
	jge .LdrawDots_end

	movss (%rbx), %xmm0
	movss 4(%rbx), %xmm1
	addq $8, %rbx
	unpcklps %xmm1, %xmm0

	movss dot_rad(%rip), %xmm1
	movl white(%rip), %edi
	call DrawCircleV@PLT

	inc %r12

	jmp .LdrawDots_str

	.LdrawDots_end:

	movl $10, %edi
	movl $10, %esi
	call DrawFPS@PLT

	leaq cir_points_str(%rip), %rdi
	movl cir_points(%rip), %esi
	call TextFormat@PLT

	movq %rax, %rdi
	movl $10, %esi
	movl $30, %edx
	movl $26, %ecx
	movl white(%rip), %r8d
	call DrawText@PLT

	call EndDrawing@PLT

	jmp .Lwindow_loop

.Lcleanup:
	call CloseWindow@PLT
	xorl %eax, %eax

	popq %rbx
	popq %r15
	popq %r14
	popq %r13
	popq %r12

	leave
	ret
