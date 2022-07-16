@;==============================================================================
@;
@;	"garlic_itcm_mem.s":	código de rutinas de soporte a la carga de
@;							programas en memoria (version 1.0)
@; programador M: alberto.flores@estudiants.urv.cat 
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2


	.global _gm_reubicar
	@; rutina para interpretar los 'relocs' de un fichero ELF y ajustar las
	@; direcciones de memoria correspondientes a las referencias de tipo
	@; R_ARM_ABS32, restando la dirección de inicio de segmento y sumando
	@; la dirección de destino en la memoria;
	@;Parámetros:
	@; R0: dirección inicial del buffer de fichero (char *fileBuf)
	@; R1: dirección de inicio de segmento (unsigned int pAddr)
	@; R2: dirección de destino en la memoria (unsigned int *dest)
	@;Resultado:
	@; cambio de las direcciones de memoria que se tienen que ajustar
_gm_reubicar:
	push {r0-r12,lr}
	ldr r3,[r0,#32]  			@;Agafem el valor corresponent a e_shoff (desplaçament taula de seccions)
	ldrh r4,[r0,#46] 			@;Agafem el valor de e_shentsize (mida de cada entrada secció)
	ldrh r5,[r0,#48] 			@;Agafem el valor de e_shnum (num entrades seccions)
	add r6, r0, r3   			@;posicionament a la taula de seccions
	mov r7, r0					@;Guardem la direcció inicial del buffer
	mov r8,r1					@;Guardem el valor de l'inici del segment
	mov r9,r2					@;Guardem el valor del destí de memoria
	mov r10, #0       			@;valor per recorrer la taula de seccions
.L_Recorrer_Seccions:
	mul r3,r4,r10				@;Calcular offset
	add r3,r6					@;Sumem l'offset a la taula de secció
	ldr r0, [r3,#4]				@;Carreguem el tipus de secció
	cmp r0,#0x09				@;Comparem si es el tipus 9 (SHT_REL)
	bne .L_No_SHT_REL			@;Sino es tipus SHT_REL pasem a la seguent secció
	ldr r11,[r3,#16]			@;Guardem el valor de sh_offset (desplaçament dels relocs)
	add r11,r7					@;Ens situem als relocs
	ldr r0,[r3,#20]				@;Extreim el valor de sh_size (tamany secció dins el fitxer)
	ldr r1,[r3,#36]				@;Extreim el valor de sh_entsize (tamany de cada reubicador)
	mov r12,r3					@;Guardem el valor de l'offset de la taula
	ldr r2, =quo				@;Carregam parametre per a divisió
	ldr r3, =res				@;Carregam parametre per a divisió
	bl _ga_divmod				@;Realitzem la divió per saber quants reubicadors hi ha
	ldr r2, [r2]				@;Obtenim el quocient de la divisió
	mov r3,r12					@;Tornam a obtenir el valor de l'offset de la taula
	mov r0, #0					@;Contador de reubicadors
.L_Recorrer_Seccio:
	
	ldr r12,[r11,#4]			@;Carreguem el r_info (tipus de reubicador)
	and r12,#0xFF				@;Extraem els 8 darrers bits (on es troba el tipus de reubicador)
	cmp r12,#0x2				@;Analitzem si es del tipus REL (valor 2)
	bne .L_No_REL				@;Sino ho es pasem al seguent reubicador
	ldr r3,[r11]				@;Carreguem el r_offset del reubicador a tractar
	add r3,r9					@;Sumem direcció destí de memoria
	sub r3,r8					@;Restem direcció d'inici de segment
	ldr r12,[r3]				@;Obtenim el valor a reubicar de la direcció destí actualitzada
	sub r12,r8					@;Restem la direcció d'inici del segment
	add r12,r9					@;Sumem la direcció de destí de memoria
	str r12,[r3]				@;Guardem la nova direcció ja reubicada
.L_No_REL:
	add r11,r1					@;Seguent reubicador
	add r0,#1					@;Pasam al seguent reubicador, es fa al final perque el primer no ho analitza
	cmp r0,r2					@;Comparem si s'han analitzat tots els reubicadors
	blt .L_Recorrer_Seccio
.L_No_SHT_REL:
	add r10,#1					@;Sumem 1 per comparar si s'han analitzat totes les seccions
	cmp r10,r5					@;Comparem per veure si s'han comprovat totes les seccions
	blt .L_Recorrer_Seccions	@;Mentre sigui menor anar analitzant
	

	pop {r0-r12,pc}


.end