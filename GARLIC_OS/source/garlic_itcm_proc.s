@;==============================================================================
@;
@;	"garlic_itcm_proc.s":	código de las rutinas de control de procesos (2.0)
@;						(ver "garlic_system.h" para descripción de funciones)
@;
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2
	
	.global _gp_WaitForVBlank
	@; rutina para pausar el procesador mientras no se produzca una interrupción
	@; de retrazado vertical (VBL); es un sustituto de la "swi #5", que evita
	@; la necesidad de cambiar a modo supervisor en los procesos GARLIC
_gp_WaitForVBlank:
	push {r0-r1, lr}
	ldr r0, =__irq_flags
.Lwait_espera:
	mcr p15, 0, lr, c7, c0, 4	@; HALT (suspender hasta nueva interrupción)
	ldr r1, [r0]			@; R1 = [__irq_flags]
	tst r1, #1				@; comprobar flag IRQ_VBL
	beq .Lwait_espera		@; repetir bucle mientras no exista IRQ_VBL
	bic r1, #1
	str r1, [r0]			@; poner a cero el flag IRQ_VBL
	pop {r0-r1, pc}


	.global _gp_IntrMain
	@; Manejador principal de interrupciones del sistema Garlic
_gp_IntrMain:
	mov	r12, #0x4000000
	add	r12, r12, #0x208	@; R12 = base registros de control de interrupciones	
	ldr	r2, [r12, #0x08]	@; R2 = REG_IE (máscara de bits con int. permitidas)
	ldr	r1, [r12, #0x0C]	@; R1 = REG_IF (máscara de bits con int. activas)
	and r1, r1, r2			@; filtrar int. activas con int. permitidas
	ldr	r2, =irqTable
.Lintr_find:				@; buscar manejadores de interrupciones específicos
	ldr r0, [r2, #4]		@; R0 = máscara de int. del manejador indexado
	cmp	r0, #0				@; si máscara = cero, fin de vector de manejadores
	beq	.Lintr_setflags		@; (abandonar bucle de búsqueda de manejador)
	ands r0, r0, r1			@; determinar si el manejador indexado atiende a una
	beq	.Lintr_cont1		@; de las interrupciones activas
	ldr	r3, [r2]			@; R3 = dirección de salto del manejador indexado
	cmp	r3, #0
	beq	.Lintr_ret			@; abandonar si dirección = 0
	mov r2, lr				@; guardar dirección de retorno
	blx	r3					@; invocar el manejador indexado
	mov lr, r2				@; recuperar dirección de retorno
	b .Lintr_ret			@; salir del bucle de búsqueda
.Lintr_cont1:	
	add	r2, r2, #8			@; pasar al siguiente índice del vector de
	b	.Lintr_find			@; manejadores de interrupciones específicas
.Lintr_ret:
	mov r1, r0				@; indica qué interrupción se ha servido
.Lintr_setflags:
	str	r1, [r12, #0x0C]	@; REG_IF = R1 (comunica interrupción servida)
	ldr	r0, =__irq_flags	@; R0 = dirección flags IRQ para gestión IntrWait
	ldr	r3, [r0]
	orr	r3, r3, r1			@; activar el flag correspondiente a la interrupción
	str	r3, [r0]			@; servida (todas si no se ha encontrado el maneja-
							@; dor correspondiente)
	mov	pc,lr				@; retornar al gestor de la excepción IRQ de la BIOS


	.global _gp_rsiVBL
	@; Manejador de interrupciones VBL (Vertical BLank) de Garlic:
	@; se encarga de actualizar los tics, intercambiar procesos, etc.
_gp_rsiVBL:
	push {r4-r7, lr}
	
	@; incrementar _gd_tickCount
		ldr r4, =_gd_tickCount
		ldr r5, [r4]
		add r5, r5, #1
		str r5, [r4]
	
	@; comprovar cua
		ldr r4, =_gd_nReady
		ldr r5, [r4]
		cmp r5, #0
		beq .L_gp_rsiVBL_final
	
	@; si hi ha coses, mirar si es procés SO
		ldr r6, =_gd_pidz
		ldr r7, [r6]
		cmp r7, #0
		beq .L_rsiVBL_guardar
	
	@; si no és procés SO, comprovem PID
		bic r6, r7, #0xF	@; _gd_pidz té el PID als 28 bits alts, i el zocalo als 4 baixos
		cmp r6, #0
		beq .L_rsiVBL_restaurar
	
	@; Guardar Contexte del procés actual
.L_rsiVBL_guardar:
		ldr r6, =_gd_pidz
		bl _gp_salvarProc
	
	@; Restaurar procés del seguent procés cua ready
.L_rsiVBL_restaurar:
		ldr r6, =_gd_pidz
		bl _gp_restaurarProc
	
.L_gp_rsiVBL_final:
	pop {r4-r7, pc}


	


	@; Rutina para salvar el estado del proceso interrumpido en la entrada
	@; correspondiente del vector _gd_pcbs
	@;Parámetros
	@; R4: dirección _gd_nReady
	@; R5: número de procesos en READY
	@; R6: dirección _gd_pidz
	@;Resultado
	@; R5: nuevo número de procesos en READY (+1)
_gp_salvarProc:
	push {r8-r11, lr}

	@;comentaris a aquesta alçada son el que se'ns demana al pdf
	@;incrementar el contador de procesos pendientes _gd_nReady,
		add r5, #1
		str r5, [r4]		@;guardar el valor incrementat
	
	
	@;guardar el número de zócalo del proceso a desbancar en la última posición de la cola de Ready,
		ldr r7, [r6]			@;r7 = pidz
		and r8, r7, #0b1111		@;r8 = zócalo en els ultims 4 bits
		sub r9, r5, #1			@;r9 = posició de la cua
		ldr r10, =_gd_qReady	@;r10 = cua ready
		strb r8, [r10, r9]		@;guardar a la cua posició calculada amb r9 el zócalo
	
	@;guardar el valor del R15 del proceso a desbancar en el campo PC del elemento _gd_pcbs[z],
	@;donde z es el número de zócalo del proceso a desbancar,
		ldr r9, =_gd_pcbs
		mov r10, #24			@;mida garlic_PCB
		mul r8, r10, r8			@;r8 = zocalo * mida garlic_PCB
		add r8, r9, r8			@;r8 = zocalo * mida garlic_PCB + base = _gd_pcbs[zocalo]
		
		add r9, r13, #60		@;r13 = SP_irq, r9 = R15 (PC) o SP_irq+60
		ldr r9, [r9]			@;r9 = valor PC
		str r9, [r8, #4]		@;guardar valor PC a r8= _gd_pcbs[zocalo], #4 perquè a l'struct es guarda el pc al segon lloc
	
	@;guardar el CPSR del proceso a desbancar en el campo Status del elemento _gd_pcbs[z],
		mrs r9, spsr			@;r9 = cpsr del proces (spsr perquè és el guardat)
		str r9, [r8, #12]		@;guardar el cpsr a _gd_pcbs[zocalo], #12 perquè a l'struct es guarda el cpsr al quart lloc
		
	@;guardar el SP_irq en un registro de trabajo libre (R8-R11),
		mov r8, r13				@;r8 = SP_irq (pag 16 taula surt r13 = SP_irq)
		
	@;cambiar al modo de ejecución del proceso interrumpido,
		mrs r9, cpsr
		orr r9, #0x1F			@;modo
		msr cpsr, r9			@;el guardem
	
	@;apilar el valor de los registros R0-R12 + R14 del proceso a desbancar en su propia pila,
		@;Utilitzarem la taula de la pàgina 64 per orientar-nos
		@;r8 utilitzarem com a punter per navegar amb la pila
		@;r9, r10, r11 per copiar els valors dels que volem guardar
		@;valors es tenen que carregar de registre més gran a petit (r14, r12, r11, ..., r1, r0)
		
		ldr r9, [r8, #12]		@;r9 = r11
		ldr r10, [r8, #56]		@;r10 = r12
		push {lr}
		stmdb r13!, {r9,r10}
		ldr r9, [r8, #0]		@;r9 = r8
		ldr r10, [r8, #4]		@;r10 = r9
		ldr r11, [r8, #8]		@;r11 = r10
		stmdb r13!, {r9-r11}
		ldr r9, [r8, #24]		@;r9 = r5
		ldr r10, [r8, #28]		@;r10 = r6
		ldr r11, [r8, #32]		@;r11 = r7
		stmdb r13!, {r9-r11}
		ldr r9, [r8, #48]		@;r9 = r2
		ldr r10, [r8, #52]		@;r10 = r3
		ldr r11, [r8, #20]		@;r11 = r4
		stmdb r13!, {r9-r11}
		ldr r9, [r8, #40]		@;r9 = r0
		ldr r10, [r8, #44]		@;r10 = r1
		stmdb r13!, {r9-r10}
		
		
	@;guardar el valor del registro R13 del proceso a desbancar en el campo SP del elemento _gd_pcbs[z],
		ldr r9, = _gd_pcbs
		mov r10, #24
		and r11, r7, #0b1111		 @;todo intentar cambiar registro usado para no recalcular esto
		mul r11, r10, r11
		add r11, r9
		str r13, [r11, #8]
		
	@;volver al modo de ejecución IRQ y retornar de _gp_salvarProc()
		mrs r9, CPSR			@;utilitzem igual que pag 74 de The Arm Instruction Set
		bic r9, #0x1F
		orr r9, #0x12			@; mode IRQ
		msr cpsr, r9

	pop {r8-r11, pc}


	@; Rutina para restaurar el estado del siguiente proceso en la cola de READY
	@;Parámetros
	@; R4: dirección _gd_nReady
	@; R5: número de procesos en READY
	@; R6: dirección _gd_pidz
_gp_restaurarProc:
	push {r8-r11, lr}

	@;decrementar el contador de procesos pendientes _gd_nReady,
		sub r8, r5, #1
		str r8, [r4]
	
	@;recuperar el número de zócalo del proceso a restaurar de la primera posición de la cola de Ready
		ldr r9, =_gd_qReady
		ldrb r10, [r9]		@;número zocalo del primer procés
		
	@;y desplazar el vector _gd_qReady[] para que la cola empiece por el zócalo del siguiente proceso a restaurar,
.L_gd_restaurarProc_while:
		cmp r8, #0							@;while (r8 !=0) {//queden procesos en cola a mover
		beq .L_gd_restaurarProc_while_FI
		ldrb r11, [r9, #1]					@;	zocalo[_gd_qReady] = zocalo[_gd_qReady +1];
		strb r11, [r9]
		add r9, #1							@;	_gd_qReady++;
		sub r8, #1							@;	r8--;
		b .L_gd_restaurarProc_while
.L_gd_restaurarProc_while_FI:				@;}


	@;construir el valor combinado PIDz para guardarlo en la variable global _gd_pidz, a partir del PID
	@;y número de zócalo del proceso a restaurar,
		ldr r8, =_gd_pcbs
		mov r9, #24							@;mida garlicPCB
		mul r9, r10							@;zócalo * mida garlicPCB
		add r8, r9							@;zócalo * mida garlicPCB + base
		ldr r9, [r8, #0]					@;r9 = PID 
		orr r9, r10, r9, lsl #4				@;PIDz = 28 bits PID + 4 bits zocalo -> orr + desplaçament
		str r9, [r6]
		
	@;recuperar el valor del R15 anterior del proceso a restaurar y copiarlo en la posición correspondiente de pila del proceso,
		ldr r9, [r8, #4]					@;_gd_pcbs[1]= PC = r15
		str r9, [r13, #60]					@;guardar-ho en el punter
		
	@;recuperar el CPSR del proceso a restaurar y copiarlo sobre el registro SPSR_irq,
		ldr r9, [r8, #12]
		msr spsr, r9
	
	@;guardar el puntero de la pila del modo IRQ en un registro de trabajo libre (R8-R11),
		mov r11, r13
	
	@;cambiar al modo de ejecución del proceso a restaurar,
		mrs r9, cpsr
		orr r9, #0x1F						@;modo
		msr cpsr, r9						@;el guardem
	
	@;recuperar el valor del registro R13 del proceso a restaurar,
		ldr r13, [r8, #8]
	@;desapilar el valor de los registros R0-R12 + R14 de la pila del proceso a restaurar, y copiarlos en la pila del modo IRQ,
		pop {r8}			@;r8 = r0 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #40]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {r8}			@;r8 = r1 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #44]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {r8}			@;r8 = r2 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #48]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {r8}			@;r8 = r3 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #52]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {r8}			@;r8 = r4 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #20]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {r8}			@;r8 = r5 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #24]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {r8}			@;r8 = r6 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #28]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {r8}			@;r8 = r7 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #32]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {r8}			@;r8 = r8 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #0]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {r8}			@;r8 = r9 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #4]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {r8}			@;r8 = r10 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #8]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {r8}			@;r8 = r11 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #12]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {r8}			@;r8 = r12 i incrementem després el punter 13 per passar al següent
		str r8, [r11, #56]	@;guardem a posició segons taula pg 64 manual fase 1
		pop {lr}			@;r8 = r14 i incrementem després el punter 13 per passar al següent
							@;ya hemos guardado r14 directamente
		
	@;volver al modo de ejecución IRQ y retornar de _gp_restaurarProc().
		mrs r9, cpsr			@;utilitzem igual que pag 74 de The Arm Instruction Set
		bic r9, #0x1F
		orr r9, #0x12			@; mode IRQ
		msr cpsr, r9

	pop {r8-r11, pc}



	.global _gp_numProc
	@;Resultado
	@; R0: número de procesos total
_gp_numProc:
	push {r1-r2, lr}
	mov r0, #1				@; contar siempre 1 proceso en RUN
	ldr r1, =_gd_nReady
	ldr r2, [r1]			@; R2 = número de procesos en cola de READY
	add r0, r2				@; añadir procesos en READY
	ldr r1, =_gd_nDelay
	ldr r2, [r1]			@; R2 = número de procesos en cola de DELAY
	add r0, r2				@; añadir procesos retardados
	pop {r1-r2, pc}


	.global _gp_crearProc
	@; prepara un proceso para ser ejecutado, creando su entorno de ejecución y
	@; colocándolo en la cola de READY
	@;Parámetros
	@; R0: intFunc funcion,
	@; R1: int zocalo,
	@; R2: char *nombre
	@; R3: int arg
	@;Resultado
	@; R0: 0 si no hay problema, >0 si no se puede crear el proceso
_gp_crearProc:
	push {r1-r6, lr}
	
	@;rechazar la llamada si zócalo = 0 (reservado para sistema operativo), o si el zócalo ya está ocupado
	@;por otro proceso, lo cual se verifica consultando el campo PID del elemento _gd_pcbs[z], teniendo en
	@;cuenta que un zócalo está libre si su PID es 0,
		cmp r1, #0						@;si zocalo sistema operativo
		moveq r0, #1					@;return 1
		beq .L_gp_crearProc_rechazar	@;saltar al final
		
		ldr r4, =_gd_pcbs
		mov r5, #24
		mul r5, r1, r5					@;zocalo * mida garlicPCB
		add r4, r5, r4					@;zocalo * mida garlicPCB + base
		ldr r5, [r4]					@;r5 = PID en _gd_pcbs[z]
		cmp r5, #0
		movne r0, #1					@;return 1
		bne .L_gp_crearProc_rechazar	@;saltar al final
	
	@;obtener un PID para el nuevo proceso, incrementando la variable
	@;global _gd_pidCount, y guardarlo en el campo PID del _gd_pcbs[z],
		ldr r5, =_gd_pidCount
		ldr r6, [r5]					@;carreguem el valor
		add r6, #1						@;l'incrementem
		str r6, [r5]					@;el guardem
		str r6, [r4, #0]				@;el guardem també a _gd_pcbs
		
	
	@;guardar la dirección de la rutina inicial del proceso (primer parámetro)
	@;en el campo PC del elemento _gd_pcbs[z], sumándole 4 (una
	@;instrucción) para compensar el decremento que sufrirá la primera vez
	@;que se restaure el proceso, debido al código de retorno de la BIOS IRQ
	@;exception handler (ver apartado 2.2),
		add r0, #4						@;incrementem 4 per compensar el decrement de restaurar
		str r0, [r4, #4]				@;el guardem a _gd_pcbs[z].PC
	
	@;guardar los cuatro primeros caracteres del nombre en clave del
	@;programa (tercer parámetro) en el campo keyName del elemento _gd_pcbs[z],
		ldr r5, [r2]
		str r5, [r4, #16]
	
	@;calcular la dirección base de la pila del proceso,
		ldr r5, =_gd_stacks
		mov r6, #512					@;mida _gd_stacks, pag 52 manual fase 1		@;todo cambiar a shiftear, potencia 2
		mul r6, r1, r6					@;r6 = zocalo*mida
		add r6, r6, r5					@;r6 = zocalo*mida + base
	
	@;guardar en la pila del proceso el valor inicial de los registros R0-R12 +
	@;R14, que será cero para todos excepto para R0, que tendrá que
	@;contener el valor del argumento (cuarto parámetro), y excepto R14,
	@;que deberá contener la dirección de retorno del proceso,
	@;concretamente, la dirección de la rutina _gp_terminarProc(), que se
	@;encargará de realizar las tareas de finalización del proceso,
		ldr r5, =_gp_terminarProc		@;r14 = _gp_terminarProc
		sub r6, #4
		str r5, [r6]
										@;todo meter en un loop
		mov r5, #0						@;preparem el 0
		sub r6, #4						@;passem al anterior
		str r5, [r6]					@;r12
		sub r6, #4						@;passem al anterior
		str r5, [r6]					@;r11
		sub r6, #4						@;passem al anterior
		str r5, [r6]					@;r10
		sub r6, #4						@;passem al anterior
		str r5, [r6]					@;r9
		sub r6, #4						@;passem al anterior
		str r5, [r6]					@;r8
		sub r6, #4						@;passem al anterior
		str r5, [r6]					@;r7
		sub r6, #4						@;passem al anterior
		str r5, [r6]					@;r6
		sub r6, #4						@;passem al anterior
		str r5, [r6]					@;r5
		sub r6, #4						@;passem al anterior
		str r5, [r6]					@;r4
		sub r6, #4						@;passem al anterior
		str r5, [r6]					@;r3
		sub r6, #4						@;passem al anterior
		str r5, [r6]					@;r2
		sub r6, #4						@;passem al anterior
		str r5, [r6]					@;r1
		sub r6, #4						@;passem al anterior
		str r3, [r6]					@;r0 guardem el quart paràmetre (r3)
		
	
	@;guardar el valor actual del registro R13 del proceso a crear en el campo SP del elemento _gd_pcbs[z],
		str r6, [r4, #8]
	
	@;guardar el valor inicial del registro CPSR en el campo Status del
	@;elemento _gd_pcbs[z], para que la ejecución del proceso sea en modo
	@;sistema, se permite la generación de interrupciones (flag I = 0), tipo
	@;de juego de instrucciones ARM (flag T = 0) y el resto de flags a cero,
		mov r6, #0b11111
		str r6, [r4, #12]
	
	@;inicializar otros campos del elemento _gd_pcbs[z], como el contador de tics de trabajo workTicks,
		str r5, [r4, #20]				@;inicialitzem amb valor 0
	
	@;guardar el número de zócalo en la última posición de la cola de Ready
	@;e incrementar en número de procesos pendientes en la variable _gd_nReady.
		ldr r4, =_gd_nReady
		ldr r5, [r4]					@;numero procesos
		ldr r6, =_gd_qReady
		strb r1, [r6, r5]				@;guardem zocalo a ultima posició
		add r5, #1						@;incrementem el número de processos
		str r5, [r4]					@;guardem el número
		
		mov r0, #0						@;finalitzem creació proces
.L_gp_crearProc_rechazar:
		

	pop {r1-r6, pc}


	@; Rutina para terminar un proceso de usuario:
	@; pone a 0 el campo PID del PCB del zócalo actual, para indicar que esa
	@; entrada del vector _gd_pcbs está libre; también pone a 0 el PID de la
	@; variable _gd_pidz (sin modificar el número de zócalo), para que el código
	@; de multiplexación de procesos no salve el estado del proceso terminado.
_gp_terminarProc:
	ldr r0, =_gd_pidz
	ldr r1, [r0]			@; R1 = valor actual de PID + zócalo
	and r1, r1, #0xf		@; R1 = zócalo del proceso desbancado
	str r1, [r0]			@; guardar zócalo con PID = 0, para no salvar estado			
	ldr r2, =_gd_pcbs
	mov r10, #24
	mul r11, r1, r10
	add r2, r11				@; R2 = dirección base _gd_pcbs[zocalo]
	mov r3, #0
	str r3, [r2]			@; pone a 0 el campo PID del PCB del proceso
	str r3, [r2, #20]		@; borrar porcentaje de USO de la CPU
	ldr r0, =_gd_sincMain
	ldr r2, [r0]			@; R2 = valor actual de la variable de sincronismo
	mov r3, #1
	mov r3, r3, lsl r1		@; R3 = máscara con bit correspondiente al zócalo
	orr r2, r3
	str r2, [r0]			@; actualizar variable de sincronismo
.LterminarProc_inf:
	bl _gp_WaitForVBlank	@; pausar procesador
	b .LterminarProc_inf	@; hasta asegurar el cambio de contexto

	
.end

