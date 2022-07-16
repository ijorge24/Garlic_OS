	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"CTEM.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"\012Celsius: -%d.%d\000"
	.align	2
.LC1:
	.ascii	"\012Celsius: %d.%d\000"
	.align	2
.LC2:
	.ascii	"\012Kelvin: %d.%d\012\000"
	.text
	.align	2
	.global	fahrenheitACelsiusYKelvin
	.syntax unified
	.arm
	.fpu softvfp
	.type	fahrenheitACelsiusYKelvin, %function
fahrenheitACelsiusYKelvin:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #20
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	sub	r3, r3, #32
	str	r3, [sp, #4]
	ldr	r3, [sp, #4]
	lsl	r3, r3, #14
	str	r3, [sp, #4]
	ldr	r2, [sp, #4]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	ldr	r2, .L22
	smull	r1, r2, r3, r2
	asr	r2, r2, #1
	asr	r3, r3, #31
	sub	r3, r2, r3
	str	r3, [sp, #12]
	ldr	r3, [sp, #12]
	and	r3, r3, #15
	str	r3, [sp, #8]
	ldr	r3, [sp, #8]
	sub	r3, r3, #1
	cmp	r3, #14
	ldrls	pc, [pc, r3, asl #2]
	b	.L2
.L4:
	.word	.L3
	.word	.L5
	.word	.L6
	.word	.L7
	.word	.L8
	.word	.L9
	.word	.L10
	.word	.L11
	.word	.L12
	.word	.L13
	.word	.L14
	.word	.L15
	.word	.L16
	.word	.L17
	.word	.L18
.L6:
	ldr	r3, .L22+4
	str	r3, [sp, #8]
	b	.L19
.L16:
	ldr	r3, .L22+4
	str	r3, [sp, #8]
	b	.L19
.L10:
	ldr	r3, .L22+8
	str	r3, [sp, #8]
	b	.L19
.L12:
	ldr	r3, .L22+8
	str	r3, [sp, #8]
	b	.L19
.L13:
	ldr	r3, .L22+12
	str	r3, [sp, #8]
	b	.L19
.L9:
	ldr	r3, .L22+12
	str	r3, [sp, #8]
	b	.L19
.L17:
	ldr	r3, .L22+16
	str	r3, [sp, #8]
	b	.L19
.L5:
	ldr	r3, .L22+16
	str	r3, [sp, #8]
	b	.L19
.L3:
	ldr	r3, .L22+20
	str	r3, [sp, #8]
	b	.L19
.L18:
	ldr	r3, .L22+20
	str	r3, [sp, #8]
	b	.L19
.L8:
	ldr	r3, .L22+24
	str	r3, [sp, #8]
	b	.L19
.L14:
	ldr	r3, .L22+24
	str	r3, [sp, #8]
	b	.L19
.L11:
	ldr	r3, .L22+28
	str	r3, [sp, #8]
	b	.L19
.L15:
	ldr	r3, .L22+32
	str	r3, [sp, #8]
	b	.L19
.L7:
	ldr	r3, .L22+32
	str	r3, [sp, #8]
	b	.L19
.L2:
	mov	r3, #0
	str	r3, [sp, #8]
.L19:
	ldr	r3, [sp, #12]
	asr	r3, r3, #14
	str	r3, [sp, #12]
	ldr	r3, [sp, #12]
	cmp	r3, #0
	bge	.L20
	ldr	r3, [sp, #12]
	rsb	r3, r3, #0
	str	r3, [sp, #12]
	ldr	r2, [sp, #8]
	ldr	r1, [sp, #12]
	ldr	r0, .L22+36
	bl	GARLIC_printf
	ldr	r3, [sp, #12]
	rsb	r3, r3, #0
	str	r3, [sp, #12]
	b	.L21
.L20:
	ldr	r2, [sp, #8]
	ldr	r1, [sp, #12]
	ldr	r0, .L22+40
	bl	GARLIC_printf
.L21:
	ldr	r3, [sp, #12]
	add	r3, r3, #272
	add	r3, r3, #1
	str	r3, [sp, #12]
	ldr	r2, [sp, #8]
	ldr	r1, [sp, #12]
	ldr	r0, .L22+44
	bl	GARLIC_printf
	nop
	add	sp, sp, #20
	@ sp needed
	ldr	pc, [sp], #4
.L23:
	.align	2
.L22:
	.word	954437177
	.word	8889
	.word	7778
	.word	6667
	.word	5556
	.word	4444
	.word	3333
	.word	2222
	.word	1111
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.size	fahrenheitACelsiusYKelvin, .-fahrenheitACelsiusYKelvin
	.section	.rodata
	.align	2
.LC3:
	.ascii	"\012Fahrenheit: -%d.%d\000"
	.align	2
.LC4:
	.ascii	"\012Fahrenheit: %d.%d\000"
	.text
	.align	2
	.global	celsiusAFahrenheit
	.syntax unified
	.arm
	.fpu softvfp
	.type	celsiusAFahrenheit, %function
celsiusAFahrenheit:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #20
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	lsl	r3, r3, #14
	str	r3, [sp, #4]
	ldr	r2, [sp, #4]
	mov	r3, r2
	lsl	r3, r3, #3
	add	r3, r3, r2
	ldr	r2, .L38
	smull	r1, r2, r3, r2
	asr	r2, r2, #1
	asr	r3, r3, #31
	sub	r3, r2, r3
	str	r3, [sp, #8]
	ldr	r3, [sp, #8]
	and	r3, r3, #7
	str	r3, [sp, #12]
	ldr	r3, [sp, #12]
	sub	r3, r3, #1
	cmp	r3, #6
	ldrls	pc, [pc, r3, asl #2]
	b	.L25
.L27:
	.word	.L26
	.word	.L28
	.word	.L29
	.word	.L30
	.word	.L31
	.word	.L32
	.word	.L33
.L29:
	mov	r3, #8000
	str	r3, [sp, #12]
	b	.L34
.L31:
	mov	r3, #8000
	str	r3, [sp, #12]
	b	.L34
.L32:
	ldr	r3, .L38+4
	str	r3, [sp, #12]
	b	.L34
.L28:
	ldr	r3, .L38+4
	str	r3, [sp, #12]
	b	.L34
.L26:
	mov	r3, #4000
	str	r3, [sp, #12]
	b	.L34
.L33:
	mov	r3, #4000
	str	r3, [sp, #12]
	b	.L34
.L30:
	mov	r3, #2000
	str	r3, [sp, #12]
	b	.L34
.L25:
	mov	r3, #0
	str	r3, [sp, #12]
.L34:
	ldr	r3, [sp, #8]
	asr	r3, r3, #14
	str	r3, [sp, #8]
	ldr	r3, [sp, #8]
	add	r3, r3, #32
	str	r3, [sp, #8]
	ldr	r3, [sp, #8]
	cmp	r3, #0
	bge	.L35
	ldr	r3, [sp, #8]
	rsb	r3, r3, #0
	str	r3, [sp, #8]
	ldr	r2, [sp, #12]
	ldr	r1, [sp, #8]
	ldr	r0, .L38+8
	bl	GARLIC_printf
	ldr	r3, [sp, #8]
	rsb	r3, r3, #0
	str	r3, [sp, #8]
	b	.L24
.L35:
	ldr	r2, [sp, #12]
	ldr	r1, [sp, #8]
	ldr	r0, .L38+12
	bl	GARLIC_printf
	nop
.L24:
	add	sp, sp, #20
	@ sp needed
	ldr	pc, [sp], #4
.L39:
	.align	2
.L38:
	.word	1717986919
	.word	6000
	.word	.LC3
	.word	.LC4
	.size	celsiusAFahrenheit, .-celsiusAFahrenheit
	.section	.rodata
	.align	2
.LC5:
	.ascii	"\012%c%c%3TEMPERATURA PROPUESTA IMPOSIBLE EN CELSIU"
	.ascii	"S\012\000"
	.align	2
.LC6:
	.ascii	"\012%c%c%0\000"
	.align	2
.LC7:
	.ascii	"\012pasar (-%d) Celsius a:\000"
	.align	2
.LC8:
	.ascii	"\012pasar (%d) Celsius a:\000"
	.align	2
.LC9:
	.ascii	"\012Kelvin: %d\000"
	.align	2
.LC10:
	.ascii	"\012%c%c%3TEMPERATURA PROPUESTA IMPOSIBLE EN KELVIN"
	.ascii	"\000"
	.align	2
.LC11:
	.ascii	"\012%c%c%1\000"
	.align	2
.LC12:
	.ascii	"\012\012pasar (%d) Kelvin a:\000"
	.align	2
.LC13:
	.ascii	"\012Celsius -%d\000"
	.align	2
.LC14:
	.ascii	"\012Celsius %d\000"
	.align	2
.LC15:
	.ascii	"\012%c%c%3TEMPERATURA PROPUESTA IMPOSIBLE EN FAHREN"
	.ascii	"HEIT\000"
	.align	2
.LC16:
	.ascii	"\012%c%c%2\000"
	.align	2
.LC17:
	.ascii	"\012\012pasar (-%d) Fahrenheit a:\000"
	.align	2
.LC18:
	.ascii	"\012\012pasar (%d) Fahrenheit a:\000"
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
	mov	r3, #32
	strb	r3, [sp, #15]
	ldr	r3, [sp, #4]
	cmp	r3, #3
	ldrls	pc, [pc, r3, asl #2]
	b	.L41
.L43:
	.word	.L42
	.word	.L44
	.word	.L45
	.word	.L46
.L42:
	mov	r3, #30
	str	r3, [sp, #4]
	b	.L41
.L44:
	ldr	r3, .L60
	str	r3, [sp, #4]
	b	.L41
.L45:
	ldr	r3, .L60+4
	str	r3, [sp, #4]
	b	.L41
.L46:
	mov	r3, #0
	str	r3, [sp, #4]
	nop
.L41:
	ldr	r3, [sp, #4]
	str	r3, [sp, #20]
	ldr	r3, [sp, #4]
	str	r3, [sp, #8]
	ldr	r3, [sp, #4]
	str	r3, [sp, #16]
	ldr	r3, [sp, #20]
	mvn	r2, #272
	cmp	r3, r2
	bge	.L47
	ldrb	r3, [sp, #15]	@ zero_extendqisi2
	ldrb	r2, [sp, #15]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r0, .L60+8
	bl	GARLIC_printf
	b	.L48
.L47:
	ldrb	r3, [sp, #15]	@ zero_extendqisi2
	ldrb	r2, [sp, #15]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r0, .L60+12
	bl	GARLIC_printf
	ldr	r3, [sp, #20]
	cmp	r3, #0
	bge	.L49
	ldr	r3, [sp, #20]
	rsb	r3, r3, #0
	str	r3, [sp, #20]
	ldr	r1, [sp, #20]
	ldr	r0, .L60+16
	bl	GARLIC_printf
	ldr	r3, [sp, #20]
	rsb	r3, r3, #0
	str	r3, [sp, #20]
	b	.L50
.L49:
	ldr	r1, [sp, #20]
	ldr	r0, .L60+20
	bl	GARLIC_printf
.L50:
	ldr	r0, [sp, #20]
	bl	celsiusAFahrenheit
	ldr	r3, [sp, #20]
	add	r3, r3, #272
	add	r3, r3, #1
	str	r3, [sp, #8]
	ldr	r1, [sp, #8]
	ldr	r0, .L60+24
	bl	GARLIC_printf
.L48:
	ldr	r3, [sp, #4]
	str	r3, [sp, #8]
	ldr	r3, [sp, #8]
	cmp	r3, #0
	bge	.L51
	ldrb	r3, [sp, #15]	@ zero_extendqisi2
	ldrb	r2, [sp, #15]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r0, .L60+28
	bl	GARLIC_printf
	b	.L52
.L51:
	ldrb	r3, [sp, #15]	@ zero_extendqisi2
	ldrb	r2, [sp, #15]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r0, .L60+32
	bl	GARLIC_printf
	ldr	r1, [sp, #8]
	ldr	r0, .L60+36
	bl	GARLIC_printf
	ldr	r3, [sp, #8]
	sub	r3, r3, #272
	sub	r3, r3, #1
	str	r3, [sp, #20]
	ldr	r3, [sp, #20]
	cmp	r3, #0
	bge	.L53
	ldr	r3, [sp, #20]
	rsb	r3, r3, #0
	str	r3, [sp, #20]
	ldr	r1, [sp, #20]
	ldr	r0, .L60+40
	bl	GARLIC_printf
	ldr	r3, [sp, #20]
	rsb	r3, r3, #0
	str	r3, [sp, #20]
	b	.L54
.L53:
	ldr	r1, [sp, #20]
	ldr	r0, .L60+44
	bl	GARLIC_printf
.L54:
	ldr	r0, [sp, #20]
	bl	celsiusAFahrenheit
.L52:
	ldr	r3, [sp, #4]
	str	r3, [sp, #16]
	ldr	r3, [sp, #16]
	cmn	r3, #460
	bge	.L55
	ldrb	r3, [sp, #15]	@ zero_extendqisi2
	ldrb	r2, [sp, #15]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r0, .L60+48
	bl	GARLIC_printf
	b	.L56
.L55:
	ldrb	r3, [sp, #15]	@ zero_extendqisi2
	ldrb	r2, [sp, #15]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r0, .L60+52
	bl	GARLIC_printf
	ldr	r3, [sp, #16]
	cmp	r3, #0
	bge	.L57
	ldr	r3, [sp, #16]
	rsb	r3, r3, #0
	str	r3, [sp, #16]
	ldr	r1, [sp, #16]
	ldr	r0, .L60+56
	bl	GARLIC_printf
	ldr	r3, [sp, #16]
	rsb	r3, r3, #0
	str	r3, [sp, #16]
	b	.L58
.L57:
	ldr	r1, [sp, #16]
	ldr	r0, .L60+60
	bl	GARLIC_printf
.L58:
	ldr	r0, [sp, #16]
	bl	fahrenheitACelsiusYKelvin
.L56:
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #28
	@ sp needed
	ldr	pc, [sp], #4
.L61:
	.align	2
.L60:
	.word	-300
	.word	-500
	.word	.LC5
	.word	.LC6
	.word	.LC7
	.word	.LC8
	.word	.LC9
	.word	.LC10
	.word	.LC11
	.word	.LC12
	.word	.LC13
	.word	.LC14
	.word	.LC15
	.word	.LC16
	.word	.LC17
	.word	.LC18
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
