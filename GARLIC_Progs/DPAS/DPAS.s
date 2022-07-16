	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"DPAS.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"\012Any: %d \012\000"
	.align	2
.LC1:
	.ascii	"Mes: %d \012\000"
	.align	2
.LC2:
	.ascii	"Dia: %d \012\000"
	.text
	.align	2
	.global	calculaData
	.syntax unified
	.arm
	.fpu softvfp
	.type	calculaData, %function
calculaData:
	@ args = 0, pretend = 0, frame = 80
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #84
	str	r0, [sp, #4]
	ldr	r0, [sp, #4]
	add	r3, sp, #68
	add	r2, sp, #20
	mov	r1, #19
	bl	GARLIC_divmod
	ldr	r0, [sp, #4]
	add	r3, sp, #60
	add	r2, sp, #64
	mov	r1, #100
	bl	GARLIC_divmod
	ldr	r0, [sp, #64]
	add	r3, sp, #52
	add	r2, sp, #56
	mov	r1, #4
	bl	GARLIC_divmod
	ldr	r3, [sp, #64]
	add	r3, r3, #8
	str	r3, [sp, #76]
	add	r3, sp, #20
	add	r2, sp, #48
	mov	r1, #25
	ldr	r0, [sp, #76]
	bl	GARLIC_divmod
	ldr	r2, [sp, #64]
	ldr	r3, [sp, #48]
	sub	r3, r2, r3
	add	r3, r3, #1
	str	r3, [sp, #76]
	add	r3, sp, #20
	add	r2, sp, #44
	mov	r1, #3
	ldr	r0, [sp, #76]
	bl	GARLIC_divmod
	ldr	r2, [sp, #68]
	mov	r3, r2
	lsl	r3, r3, #3
	add	r3, r3, r2
	lsl	r3, r3, #1
	add	r2, r3, r2
	ldr	r3, [sp, #64]
	add	r2, r2, r3
	ldr	r3, [sp, #56]
	sub	r2, r2, r3
	ldr	r3, [sp, #44]
	sub	r3, r2, r3
	add	r3, r3, #15
	str	r3, [sp, #76]
	add	r3, sp, #40
	add	r2, sp, #20
	mov	r1, #30
	ldr	r0, [sp, #76]
	bl	GARLIC_divmod
	ldr	r0, [sp, #60]
	add	r3, sp, #32
	add	r2, sp, #36
	mov	r1, #4
	bl	GARLIC_divmod
	ldr	r2, [sp, #52]
	ldr	r3, [sp, #36]
	add	r3, r2, r3
	add	r3, r3, #16
	lsl	r2, r3, #1
	ldr	r3, [sp, #40]
	sub	r2, r2, r3
	ldr	r3, [sp, #32]
	sub	r3, r2, r3
	str	r3, [sp, #76]
	add	r3, sp, #28
	add	r2, sp, #20
	mov	r1, #7
	ldr	r0, [sp, #76]
	bl	GARLIC_divmod
	ldr	r2, [sp, #40]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #1
	add	r2, r3, r2
	ldr	r3, [sp, #28]
	mov	r1, #22
	mul	r3, r1, r3
	add	r2, r2, r3
	ldr	r3, [sp, #68]
	add	r3, r2, r3
	str	r3, [sp, #76]
	add	r3, sp, #20
	add	r2, sp, #24
	ldr	r1, .L2
	ldr	r0, [sp, #76]
	bl	GARLIC_divmod
	ldr	r2, [sp, #40]
	ldr	r3, [sp, #28]
	add	r1, r2, r3
	ldr	r2, [sp, #24]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	sub	r3, r1, r3
	add	r3, r3, #114
	str	r3, [sp, #72]
	add	r3, sp, #12
	add	r2, sp, #16
	mov	r1, #31
	ldr	r0, [sp, #72]
	bl	GARLIC_divmod
	ldr	r3, [sp, #12]
	add	r3, r3, #1
	str	r3, [sp, #12]
	ldr	r1, [sp, #4]
	ldr	r0, .L2+4
	bl	GARLIC_printf
	ldr	r3, [sp, #16]
	mov	r1, r3
	ldr	r0, .L2+8
	bl	GARLIC_printf
	ldr	r3, [sp, #12]
	mov	r1, r3
	ldr	r0, .L2+12
	bl	GARLIC_printf
	nop
	add	sp, sp, #84
	@ sp needed
	ldr	pc, [sp], #4
.L3:
	.align	2
.L2:
	.word	451
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.size	calculaData, .-calculaData
	.section	.rodata
	.align	2
.LC3:
	.ascii	"\012JOC DE PROVES\000"
	.align	2
.LC4:
	.ascii	"\012Data m\351s aviat\000"
	.align	2
.LC5:
	.ascii	"\012Any: 1818 Mes 3 Dia 22\000"
	.align	2
.LC6:
	.ascii	"\012Data m\351s tard\000"
	.align	2
.LC7:
	.ascii	"\012Any: 2038 Mes 4 Dia 25\000"
	.align	2
.LC8:
	.ascii	"\012Dates conegudes\000"
	.align	2
.LC9:
	.ascii	"\012Any: 2000 Mes 4 Dia 23\000"
	.align	2
.LC10:
	.ascii	"\012Any: 2003 Mes 4 Dia 20\000"
	.align	2
.LC11:
	.ascii	"\012Any: 2006 Mes 4 Dia 16\000"
	.align	2
.LC12:
	.ascii	"\012Any: 2009 Mes 4 Dia 12\000"
	.align	2
.LC13:
	.ascii	"\012Any: 2012 Mes 4 Dia 8\000"
	.align	2
.LC14:
	.ascii	"\012Any: 2015 Mes 4 Dia 5\000"
	.align	2
.LC15:
	.ascii	"\012Any: 2016 Mes 3 Dia 27\000"
	.align	2
.LC16:
	.ascii	"\012Any: 2018 Mes 4 Dia 1\000"
	.align	2
.LC17:
	.ascii	"\012Any: 2021 Mes 4 Dia 4\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #28
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	cmp	r3, #0
	bge	.L5
	mov	r3, #0
	str	r3, [sp, #4]
	b	.L6
.L5:
	ldr	r3, [sp, #4]
	cmp	r3, #3
	ble	.L6
	mov	r3, #3
	str	r3, [sp, #4]
.L6:
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	add	r3, sp, #12
	add	r2, sp, #16
	mov	r1, #200
	bl	GARLIC_divmod
	ldr	r3, [sp, #4]
	mov	r2, #200
	mul	r3, r2, r3
	mov	r2, r3
	ldr	r3, [sp, #12]
	add	r3, r2, r3
	add	r3, r3, #1568
	add	r3, r3, #15
	str	r3, [sp, #12]
	mov	r3, #0
	str	r3, [sp, #20]
	b	.L7
.L8:
	ldr	r2, [sp, #12]
	ldr	r3, [sp, #20]
	add	r3, r2, r3
	mov	r0, r3
	bl	calculaData
	ldr	r3, [sp, #20]
	add	r3, r3, #1
	str	r3, [sp, #20]
.L7:
	ldr	r3, [sp, #20]
	cmp	r3, #9
	bls	.L8
	ldr	r3, [sp, #4]
	cmp	r3, #3
	bne	.L9
	ldr	r0, .L11
	bl	GARLIC_printf
	ldr	r0, .L11+4
	bl	GARLIC_printf
	ldr	r0, .L11+8
	bl	GARLIC_printf
	ldr	r0, .L11+12
	bl	calculaData
	ldr	r0, .L11+16
	bl	GARLIC_printf
	ldr	r0, .L11+20
	bl	GARLIC_printf
	ldr	r0, .L11+24
	bl	calculaData
	ldr	r0, .L11+28
	bl	GARLIC_printf
	ldr	r0, .L11+32
	bl	GARLIC_printf
	mov	r0, #2000
	bl	calculaData
	ldr	r0, .L11+36
	bl	GARLIC_printf
	ldr	r0, .L11+40
	bl	calculaData
	ldr	r0, .L11+44
	bl	GARLIC_printf
	ldr	r0, .L11+48
	bl	calculaData
	ldr	r0, .L11+52
	bl	GARLIC_printf
	ldr	r0, .L11+56
	bl	calculaData
	ldr	r0, .L11+60
	bl	GARLIC_printf
	ldr	r0, .L11+64
	bl	calculaData
	ldr	r0, .L11+68
	bl	GARLIC_printf
	ldr	r0, .L11+72
	bl	calculaData
	ldr	r0, .L11+76
	bl	GARLIC_printf
	mov	r0, #2016
	bl	calculaData
	ldr	r0, .L11+80
	bl	GARLIC_printf
	ldr	r0, .L11+84
	bl	calculaData
	ldr	r0, .L11+88
	bl	GARLIC_printf
	ldr	r0, .L11+92
	bl	calculaData
.L9:
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #28
	@ sp needed
	ldr	pc, [sp], #4
.L12:
	.align	2
.L11:
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.word	1818
	.word	.LC6
	.word	.LC7
	.word	2038
	.word	.LC8
	.word	.LC9
	.word	.LC10
	.word	2003
	.word	.LC11
	.word	2006
	.word	.LC12
	.word	2009
	.word	.LC13
	.word	2012
	.word	.LC14
	.word	2015
	.word	.LC15
	.word	.LC16
	.word	2018
	.word	.LC17
	.word	2021
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
