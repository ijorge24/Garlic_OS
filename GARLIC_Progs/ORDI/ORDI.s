	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"ORDI.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"-- Programa ORDI  --\012\000"
	.align	2
.LC1:
	.ascii	"%d\012\000"
	.align	2
.LC2:
	.ascii	"\012\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 184
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #188
	str	r0, [sp, #4]
	mov	r3, #0
	str	r3, [sp, #180]
	mov	r3, #0
	str	r3, [sp, #176]
	mov	r3, #0
	str	r3, [sp, #172]
	ldr	r3, [sp, #4]
	cmp	r3, #0
	bge	.L2
	mov	r3, #0
	str	r3, [sp, #4]
	b	.L3
.L2:
	ldr	r3, [sp, #4]
	cmp	r3, #3
	ble	.L3
	mov	r3, #3
	str	r3, [sp, #4]
.L3:
	ldr	r3, [sp, #4]
	add	r2, r3, #1
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #1
	str	r3, [sp, #4]
	ldr	r0, .L13
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [sp, #180]
	b	.L4
.L5:
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	add	r3, sp, #172
	add	r2, sp, #176
	mov	r1, #1000
	bl	GARLIC_divmod
	ldr	r3, [sp, #172]
	mov	r2, r3
	ldr	r3, [sp, #180]
	lsl	r3, r3, #2
	add	r1, sp, #184
	add	r3, r1, r3
	str	r2, [r3, #-172]
	ldr	r3, [sp, #180]
	lsl	r3, r3, #2
	add	r2, sp, #184
	add	r3, r2, r3
	ldr	r3, [r3, #-172]
	mov	r1, r3
	ldr	r0, .L13+4
	bl	GARLIC_printf
	ldr	r3, [sp, #180]
	add	r3, r3, #1
	str	r3, [sp, #180]
.L4:
	ldr	r3, [sp, #4]
	ldr	r2, [sp, #180]
	cmp	r2, r3
	bcc	.L5
	ldr	r0, .L13+8
	bl	GARLIC_printf
	mov	r3, #1
	str	r3, [sp, #180]
	b	.L6
.L9:
	ldr	r3, [sp, #180]
	lsl	r3, r3, #2
	add	r2, sp, #184
	add	r3, r2, r3
	ldr	r3, [r3, #-172]
	str	r3, [sp, #172]
	ldr	r3, [sp, #180]
	sub	r3, r3, #1
	str	r3, [sp, #176]
	b	.L7
.L8:
	ldr	r3, [sp, #176]
	add	r1, r3, #1
	ldr	r3, [sp, #176]
	lsl	r3, r3, #2
	add	r2, sp, #184
	add	r3, r2, r3
	ldr	r2, [r3, #-172]
	lsl	r3, r1, #2
	add	r1, sp, #184
	add	r3, r1, r3
	str	r2, [r3, #-172]
	ldr	r3, [sp, #176]
	sub	r3, r3, #1
	str	r3, [sp, #176]
.L7:
	ldr	r3, [sp, #176]
	lsl	r3, r3, #2
	add	r2, sp, #184
	add	r3, r2, r3
	ldr	r3, [r3, #-172]
	mov	r2, r3
	ldr	r3, [sp, #172]
	cmp	r2, r3
	bhi	.L8
	ldr	r3, [sp, #176]
	add	r3, r3, #1
	ldr	r2, [sp, #172]
	lsl	r3, r3, #2
	add	r1, sp, #184
	add	r3, r1, r3
	str	r2, [r3, #-172]
	ldr	r3, [sp, #180]
	add	r3, r3, #1
	str	r3, [sp, #180]
.L6:
	ldr	r3, [sp, #4]
	ldr	r2, [sp, #180]
	cmp	r2, r3
	bcc	.L9
	mov	r3, #0
	str	r3, [sp, #180]
	b	.L10
.L11:
	ldr	r3, [sp, #180]
	lsl	r3, r3, #2
	add	r2, sp, #184
	add	r3, r2, r3
	ldr	r3, [r3, #-172]
	mov	r1, r3
	ldr	r0, .L13+4
	bl	GARLIC_printf
	ldr	r3, [sp, #180]
	add	r3, r3, #1
	str	r3, [sp, #180]
.L10:
	ldr	r3, [sp, #4]
	ldr	r2, [sp, #180]
	cmp	r2, r3
	bcc	.L11
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #188
	@ sp needed
	ldr	pc, [sp], #4
.L14:
	.align	2
.L13:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
