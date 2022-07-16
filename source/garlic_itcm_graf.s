@;==============================================================================
@;
@;	"garlic_itcm_graf.s":	código de rutinas de soporte a la gestión de
@;							ventanas gráficas (versión 2.0)
@;
@;==============================================================================

NVENT	= 16				@; número de ventanas totales
PPART	= 4					@; número de ventanas horizontales o verticales
							@; (particiones de pantalla)
L2_PPART = 2				@; log base 2 de PPART

VCOLS	= 32				@; columnas y filas de cualquier ventana
VFILS	= 24
PCOLS	= VCOLS * PPART		@; número de columnas totales (en pantalla)
PFILS	= VFILS * PPART		@; número de filas totales (en pantalla)

WBUFS_LEN = 68				@; longitud de cada buffer de ventana (64+4)


.section .itcm,"ax",%progbits

	.arm
	.align 2

	.global _gg_escribirLinea
	@; Rutina para escribir toda una linea de caracteres almacenada en el
	@; buffer de la ventana especificada;
	@;Parámetros:
	@;	R0: ventana a actualizar (int v)
	@;	R1: fila actual (int f)
	@;	R2: número de caracteres a escribir (int n)
_gg_escribirLinea:
push {r0-r6, lr}
	mov r6,r0	
	mov r4, r1					 @; trasladamos a r4 la fila actual----------------------------
	mov r5, r2					 @; trasladamos a r5 el numero de caracteres a escribir--------
	
	mov r1, #PPART
	ldr r2, =quo
	ldr r3, =res
	bl _ga_divmod				 @; obtenemos posición inicial de cada ventana 
	mov r0,r6
	ldr r2, [r2]	
	ldr r3, [r3]
	mov r6, #VCOLS
	mul r3, r6					 @;columna inicial
	mov r6, #VFILS
	mul r2, r6					 @;fila inicial
	add r2, r4
	mov r6, #PCOLS
	mul r2, r6					 @;fila * nº columnas
	add r3, r2
	lsl r3, #1					@;(py*nºcolumnas+px) * 2		 
	ldr r1, = bg2posicion		 @;cargamos la base del fondo
	ldr r1, [r1]
	add r1, r3					 @;direccion= base +(py*nºcolumnas+px) * 2 ---------------------
	ldr r2, =_gd_wbfs			@;cargamos vector _gd_wbfs[].
	mov r6, #WBUFS_LEN
	mul r0, r6					@;accedemos a la tabla de caracteres(4+32) del _gd_wbfs en la ventana correspondiente
	add r0, #4
	add r0, r2					@; base_vector + (ventana * WBUFS_LEN) + 4 --------------------
	mov r2, #0					@;contador
	mov r5, r5, lsl #1
	
	.Lbucle:
	ldrh r3, [r0, r2]			@; ahora es pchars es halfword
	sub r3, #32					@; pasar de ASCII al código de baldosas
	strh r3, [r1, r2]			@; actualizar info baldosa
	add r2, #2
	cmp r2, r5					
	blt .Lbucle

	pop {r0-r6, pc}


	.global _gg_desplazar
	@; Rutina para desplazar una posición hacia arriba todas las filas de la
	@; ventana (v), y borrar el contenido de la última fila
	@;Parámetros:
	@;	R0: ventana a desplazar (int v)
_gg_desplazar:
	push {r0-r6, lr}
	mov r1, #PPART
	ldr r2, =quo
	ldr r3, =res
	bl _ga_divmod			 @; obtenemos posición inicial de cada ventana 
	ldr r2, [r2]	
	ldr r3, [r3]
	mov r6, #VCOLS
	mul r3, r6				 @;columna inicial
	mov r6, #VFILS
	mul r2, r6				 @;fila inicial
	mov r6, #PCOLS
	mul r2, r6				 @;fila * nº columnas
	add r3, r2
	lsl r3, #1				@;(py*nºcolumnas+px) * 2		 
	ldr r1, =bg2posicion		 @;cargamos la base del fondo
	ldr r1, [r1]
	add r1, r3					 @;direccion= base +(py*nºcolumnas+px) * 2 ---------------------
	mov r0, r1					 @;copiamos en r0 la dirección 
	mov r2, #PCOLS				 
	lsl r2, #1					 @;tamaño de una fila ya q las baldosas tiene 2 bytes
	add r0, r2					 @;accedemos a la dirección de la siguiente fila------------
	mov r3, #0					 @;contador
	
	.Lbucle2:
	mov r4, #0					 @;contador
	
	.Lbucle1:
	lsl r4, #1
	ldrh r5, [r0, r4]	 		@;cargamos info de la siguiente fila
	strh r5, [r1, r4]	 		@;guardamos info en la fila anterior
	lsr r4, #1

	
	add r4, #1				
	cmp r4, #VCOLS				 @;miramos si ha llegado al final					
	blt .Lbucle1
	
	add r0, r2					 @;pasamos a la siguiente fila
	add r1, r2					 
	add r3, #1					 @;sumamos al contador
	cmp r3, #VFILS
	blt .Lbucle2
	mov r5, #0					 @;guardamos en r5 el valor 0 que corresponde a hueco en blanco en las baldosas
	mov r4, #0					 @;contador a 0
	
	.LultimaFila:
	lsl r4, #1
	strh r5, [r1, r4]			 @;guardamos info en la fila anterior
	lsr r4, #1
	add r4, #1
	cmp r4, #VCOLS				 @;miramos si ha llegado al final					
	blt .LultimaFila
	
	pop {r0-r6, pc}
	
	
	.global _gg_escribirLineaTabla
	@; escribe los campos básicos de una linea de la tabla correspondiente al
	@; zócalo indicado por parámetro con el color especificado; los campos
	@; son: número de zócalo, PID, keyName y dirección inicial
	@;Parámetros:
	@;	R0 (z)		->	número de zócalo
	@;	R1 (color)	->	número de color (de 0 a 3)
_gg_escribirLineaTabla:
	push {r0-r8, lr}
	ldr r6, =_gd_pcbs			@;r6 cargamos vector
	mov r3, r1					@;r3: color
	mov r7, r0					@;r7: numero de zocalo
	mov r5, #24 				@;r5: estructura de formada por 6 variables donde cada por ocupa 4(word) * 6: 4*6 = 24
	mul r4, r5, r0				@;Desplazamiento en _gd_pcbs correspondiente al zócalo actual
	add r4, r6					@;r4: nos posicionamos en la primera posición de memoria perteneciente al zocalo actual
	
	@;primera columna: numero de zócalo
	mov r2, r7					@;r2: numero de zocalo
	sub sp, #4					@;pasaremos por referencia un registro, reservamos el espacio tamaño char
	mov r0, sp					@;r0: valor por referencia para _gs_num2str_dec
	mov r1, #3					@;r1: espacio necesario para el valor a devolver, numero del 0-15, 2 cifras mas '\0'
	bl _gs_num2str_dec			@;(r0=char * numstr, r1= unsigned int length, r2= unsigned int num)
	mov r0, sp					@;r0: valor por referencia para _gs_escribirStringSub
	add r1, r7, #4				@;r1: posición de la fila correspondiente a cada zócalo empezando por la 4 fila
	mov r2, #1					@;r2: columna Z
	bl _gs_escribirStringSub	@; (r0: char *string,r1= int fil,r2= int col,r3= int color);
	add sp, #4					@; terminamos de reservar espacio
	
	@; segunda columna: PID
	cmp r7, #0					@; comprobamos si estamos en primer zocalo, el cual siempre mostrará línea de ejecución
	beq .Lsalto
	ldr r8, [r4]				@;r8: cargamos primera posicion correspondiente a PID
	cmp r8, #0					@; si es 0 se borra
	beq .Lborrar
	
	.Lsalto:
	sub sp, #4					@; crea espacio en la pila para el string
	mov r0, sp					@;pasaremos por referencia un registro, reservamos el espacio tamaño char
	mov r1, #4					@;r1: espacio necesario para el valor a devolver, numero del PID 3 cifras(max 999) mas '\0'
	mov r2, r7					@;r2: numero de zocalo
	bl _gs_num2str_dec			@;(r0=char * numstr, r1= unsigned int length, r2= unsigned int num)
	mov r0, sp					@;r0: valor por referencia para _gs_escribirStringSub
	add r1, r7, #4				@;r1: posición de la fila correspondiente a cada zócalo empezando por la 4 fila
	mov r2, #5					@;r2: columna PID
	bl _gs_escribirStringSub	@; (r0: char *string,r1= int fil,r2= int col,r3= int color);
	add sp, #4					@; terminamos de reservar espacio		
	
	@; tercera columna: keyname
	sub sp, #4					@; crea espacio en la pila para el string
	mov r0, sp					@;r0: valor por referencia para _gs_escribirStringSub
	ldr r8, [r4, #16]			@;r8: cargamos 5º valor vector correspondiente a keyname
	str r8, [r0]
	add r1, r7, #4				@;r1: posición de la fila correspondiente a cada zócalo empezando por la 4 fila
	mov r2, #9					@;r2: columna keyname
	bl _gs_escribirStringSub	@; (r0: char *string,r1= int fil,r2= int col,r3= int color);
	add sp, #4					@;terminamos de reservar espacio
	b .Lfin

	@;borrar si proceso acabado
	.Lborrar:
	ldr r0, =borrador			@;r0 cargamos matriz 3 posiciones vacias
	add r1, r7, #4				@;r1: posición de la fila correspondiente a cada zócalo empezando por la 4 fila
	mov r2, #4					@;r2: columna PID
	bl _gs_escribirStringSub	@; (r0: char *string,r1= int fil,r2= int col,r3= int color);
	ldr r0, =borrador			@;r0 cargamos matriz 3 posiciones vacias
	mov r2, #9					@;r2: columna keyname
	bl _gs_escribirStringSub	@; (r0: char *string,r1= int fil,r2= int col,r3= int color);
	mov r2, #14					@;borramos la primer parte del PC
	bl _gs_escribirStringSub	@; (r0: char *string,r1= int fil,r2= int col,r3= int color);
	mov r2, #18					@; borramos la segunda parte del PC
	bl _gs_escribirStringSub	@; (r0: char *string,r1= int fil,r2= int col,r3= int color);
	.Lfin:
	
	
	
	pop {r0-r8, pc}


	.global _gg_escribirCar
	@; escribe un carácter (baldosa) en la posición de la ventana indicada,
	@; con un color concreto;
	@;Parámetros:
	@;	R0 (vx)		->	coordenada x de ventana (0..31)
	@;	R1 (vy)		->	coordenada y de ventana (0..23)
	@;	R2 (car)	->	código del caràcter, como número de baldosa (0..127)
	@;	R3 (color)	->	número de color del texto (de 0 a 3)
	@; pila (vent)	->	número de ventana (de 0 a 15)
_gg_escribirCar:
	push {r0-r6, lr}
	
	ldr r4, [sp, #32]			@;cargamos 8º registro de la pila: 4*(7+sp)
	mov r6, r0					@;r6 cordenada de x
	mov r0, r4					@;r0 ventana actual
	mov r5, r3, lsl #7			@;color ya tratado * 128
	add r4, r5, r2				@;r4 baldosa + color adecuado
	mov	r2, #4096				
	mov r5, r1					@;r5 cordenada de y
	cmp r5, r2
	bls .Lajuste
	sub r5, r1, r2				@;r5 cordenada de y
	.Lajuste:
	mov r1, #PPART
	ldr r2, =quo
	ldr r3, =res
	bl _ga_divmod				 @; obtenemos posición inicial de cada ventana 
	ldr r2, [r2]	
	ldr r3, [r3]
	mov r1, #VCOLS
	mul r3, r1					 @;columna inicial
	add r3, r6
	mov r1, #VFILS
	mul r2, r1					 @;fila inicial
	add r2, r5
	mov r1, #PCOLS
	mul r2, r1
	add r3, r2
	lsl r3, #1					@;r3 (py*nºcolumnas+px) * 2
	ldr r1, = bg2posicion		@;cargamos la base del fondo
	ldr r1, [r1]
	add r1, r3					@;r1 direccion = base +(py*nºcolumnas+px) * 2
	strh r4, [r1]				@;guardamos en la posición calculada el valor de la baldosa coloreada
	
	pop {r0-r6, pc}

	.global _gg_escribirMat
	@; escribe una matriz de 8x8 carácteres a partir de una posición de la
	@; ventana indicada, con un color concreto;
	@;Parámetros:
	@;	R0 (vx)		->	coordenada x inicial de ventana (0..31)
	@;	R1 (vy)		->	coordenada y inicial de ventana (0..23)
	@;	R2 (m)		->	puntero a matriz 8x8 de códigos ASCII (dirección)
	@;	R3 (color)	->	número de color del texto (de 0 a 3)
	@; pila	(vent)	->	número de ventana (de 0 a 15)
_gg_escribirMat:
	push {r0-r7, lr}
	
	ldr r4, [sp, #36]			@;cargamos tras los 8º registros apilados: 4*(7(r0-r7)+lr)
	
	mov r6, r0					@;r6 cordenada de x
	mov r0, r4					@;r0 ventana actual
	mov r4, r3, lsl #7			@;r4 color ya tratado * 128
	mov r7, r2					@;r7 puntero a matriz				
	mov	r2, #4096				
	mov r5, r1					@;r5 cordenada de y
	cmp r5, r2
	bls .Lajuste2
	sub r5, r1, r2				@;r5 cordenada de y
	.Lajuste2:
	
	mov r1, #PPART
	ldr r2, =quo
	ldr r3, =res
	bl _ga_divmod				 @; obtenemos posición inicial de cada ventana 
	ldr r2, [r2]	
	ldr r3, [r3]
	mov r1, #VCOLS
	mul r3, r1					 @;columna inicial
	add r3, r6
	mov r1, #VFILS
	mul r2, r1					 @;fila inicial
	add r2, r5
	mov r1, #PCOLS
	mul r2, r1
	add r3, r2
	lsl r3, #1					@;r3 (py*nºcolumnas+px) * 2
	ldr r1, = bg2posicion		@;cargamos la base del fondo:  libre: r2, r5, r6
	ldr r1, [r1]
	add r1, r3					@;r1 direccion = base +(py*nºcolumnas+px) * 2
	
	mov r6, #0					@;r5 contador matriz 8x8
	.LbucleCol:
	mov r5, #0					@;r6 contador columnas matriz				
	cmp r6, #0					@;no aplicamos el cambio de fila si es la primera vez
	beq .LbucleFila
	mov r2, #PCOLS				
	mov r2, r2, lsl #1			@;añadimos una fila
	add r1, r2	
	.LbucleFila:
	ldrb r2, [r7, r6]			@;r2 caracter ASCII posicion matriz
	cmp r2, #0
	beq .Lsaltar
	sub r2, #32					@; selección de ASCII a baldosa
	.Lsaltar:
	add r2, r4					@; añadir color
	mov r5, r5, lsl #1
	strh r2, [r1, r5]			@; guardamos baldosa en la posición correspondiente
	mov r5, r5, lsr #1
	
	add r6, #1
	add r5, #1
	cmp r6, #64					@; contadores++
	beq .Lend
	cmp r5, #8
	blt .LbucleFila
	b .LbucleCol
	.Lend:
	pop {r0-r7, pc}



	.global _gg_rsiTIMER2
	@; Rutina de Servicio de Interrupción (RSI) para actualizar la representa-
	@; ción del PC actual.
_gg_rsiTIMER2:
	push {r0-r8, lr}
	ldr r7, =_gd_pcbs			@;r7: cargamos vector
	mov r3, #0					@;r3: color
	mov r5, #24 				@;r5: estructura de formada por 6 variables donde cada por ocupa 4(word) * 6: 4*6 = 24
	mov r6, #0					@;r6: contador zócalos
	
	
	add r8, r7					@;r8: info PC vector pcbs
	.Lrepet:
	
	sub sp, #4					@; crea espacio en la pila para el string
	mov r0, sp					@;pasaremos por referencia un registro, reservamos el espacio tamaño char
	mov r1, #9					@;r1: espacio necesario para el valor a devolver, maximo cifrax hexa de un int= 8 + '\0'
	ldr r2, [r8]				@;r2: Valor PC gd_pcbs
	bl _gs_num2str_dec			@;(r0=char * numstr, r1= unsigned int length, r2= unsigned int num)
	mov r0, sp					@;r0: valor por referencia para _gs_escribirStringSub
	add r1, r6, #4				@;r1: posición de la fila correspondiente a cada zócalo empezando por la 4 fila
	mov r2, #14					@;r2: columna PCactual
	bl _gs_escribirStringSub	@; (r0: char *string,r1= int fil,r2= int col,r3= int color);
	add sp, #4					@; terminamos de reservar espacio
	
	.Lvacio:
	add r6, #1
	cmp r6, #16
	beq .Lacabar
	mul r4, r5, r6				@;Desplazamiento en _gd_pcbs correspondiente al zócalo actual
	add r4, r7					@;r4: nos posicionamos en la primera posición de memoria perteneciente al zocalo actual
	ldr r8, [r4]				@;r8: extraemos el valor del pid del zocalo
	cmp r8, #0					
	beq .Lvacio
	b .Lrepet
	.Lacabar:
	
	
	pop {r0-r8, pc}


.end

