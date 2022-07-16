/*------------------------------------------------------------------------------

	"garlic_graf.c" : fase 2 / programador G

	Funciones de gestión de las ventanas de texto (gráficos), para GARLIC 2.0

------------------------------------------------------------------------------*/
#include <nds.h>

#include <garlic_system.h>	// definición de funciones y variables de sistema
#include <garlic_font.h>	// definición gráfica de caracteres

/* definiciones para realizar cálculos relativos a la posición de los caracteres
	dentro de las ventanas gráficas, que pueden ser 4 o 16 */
#define NVENT	16				// número de ventanas totales
#define PPART	4				// número de ventanas horizontales o verticales
								// (particiones de pantalla)
#define VCOLS	32				// columnas y filas de cualquier ventana
#define VFILS	24
#define PCOLS	VCOLS * PPART	// número de columnas totales (en pantalla)
#define PFILS	VFILS * PPART	// número de filas totales (en pantalla)


const unsigned int char_colors[] = {240, 96, 64};	// amarillo, verde, rojo
const char borrador[]="    ";
int bg2, bg3, bg2posicion;


/* _gg_generarMarco: dibuja el marco de la ventana que se indica por parámetro,
												con el color correspondiente */
void _gg_generarMarco(int v, int color)
{
	u16 * posicion = bgGetMapPtr(bg3);
	int p_fil = (v/PPART)*VFILS;			//posicion inicial de los punteros segun la ventana que nos pase
	int p_col = (v%PPART)*VCOLS;
	
	int i, baldosa;
	
	baldosa=103 + color * 128;
	posicion[p_fil*PCOLS+p_col]=baldosa ;
	baldosa=99 + color * 128;
	
	for (i=2; i<VCOLS; i++){
		p_col++;
		posicion[p_fil*PCOLS+p_col]=baldosa;
	}
	p_col++;
	baldosa=102 + color * 128;
	posicion[p_fil*PCOLS+p_col]=baldosa;
	baldosa=98 + color * 128;
	
	for (i=2; i<VFILS; i++){
		p_fil++;
		posicion[p_fil*PCOLS+p_col]=baldosa;
	}
	p_fil++;
	baldosa=101 + color * 128;
	posicion[p_fil*PCOLS+p_col]=baldosa;
	baldosa=97 + color * 128;
	
	for (i=2; i<VCOLS; i++){
		p_col--;
		posicion[p_fil*PCOLS+p_col]=baldosa;
	}
	p_col--;
	baldosa=100 + color * 128;
	posicion[p_fil*PCOLS+p_col]=baldosa;
	baldosa=96 + color * 128;
	
	for (i=2; i<VFILS; i++){
		p_fil--;
		posicion[p_fil*PCOLS+p_col]=baldosa;
	}
	
}	



/* _gg_iniGraf: inicializa el procesador gráfico A para GARLIC 2.0 */
/*	
	Resumen de tareas:
		1. modo 5, pantalla superior
		2. reservar banco mem A
		3. fondo 2 y 3 --> modo extended rotation
		4. fondo 3 + prioritario que fondo 2
		5. descomprimir fuente de letras en memoria de video
		6. copiar paleta colores memoria video
		7. marcos de ventanas en fondo 3
		8. reducir 50% fondos 2 y 3
*/
void _gg_iniGrafA()
{
	int i;
	
	videoSetMode(MODE_5_2D);
	vramSetBankA(VRAM_A_MAIN_BG_0x06000000);						//tamaño mapa baldosas: 128 baldosas *(8*8pixeles) * 2 bytes por baldosa* 4 colores = 65536 = 64KB
	bg2 = bgInit(2, BgType_ExRotation, BgSize_ER_1024x1024, 0, 4);	//tamano mapas= 128*96*2 = 24576 = 24KB = 4*2KB+ 1*16KB
	bg3 = bgInit(3, BgType_ExRotation, BgSize_ER_1024x1024, 0, 6);	//los fondos son simetricos cuadrados, asi que guardarlo en la posicion correspondiente a 128*128*2=32kB  
	bgSetPriority(bg2, 2);
	bgSetPriority(bg3, 1);
	decompress(garlic_fontTiles, bgGetGfxPtr(bg2), LZ77Vram);		
	dmaCopy(garlic_fontPal, BG_PALETTE, garlic_fontPalLen);
	bgUpdate();
	bg2posicion = (int) bgGetMapPtr(bg2);

		//iniciar baldosas de colores
	u16* baldosas = bgGetGfxPtr(bg2);
	for(int i=0; i<4096; i++)				// cargaremos halfwords, asi que trataremos los pixeles de 2 en 2
	{										// hay 3 posibilidades, primer pixel color, segundo pixel color o ambos con color
		if(baldosas[i]==0x00FF){			//cada mapa ocupa 8192 bytes, los tratamos de 2 en 2 y guardamos el valor de su color en la posición correspondiente
			baldosas[i+4096]=0x00F0;		//color amarillo:0xF0=240
			baldosas[i+4096*2]=0x0060;		//color verde:0x60=96
			baldosas[i+4096*3]=0x0040;		//color rojo:0x40=64
		}
		if(baldosas[i]==0xFF00){
			baldosas[i+4096]=0xF000;
			baldosas[i+4096*2]=0x6000;
			baldosas[i+4096*3]=0x4000;
		}
		if(baldosas[i]==0xFFFF){
			baldosas[i+4096]=0xF0F0;
			baldosas[i+4096*2]=0x6060;
			baldosas[i+4096*3]=0x4040;
		}
	}
	//iniciar baldosas de colores
	for(i=0; i<NVENT; i++)
		_gg_generarMarco(i, 3);
	bgSetScale(bg2, 1024, 1024); 
	bgSetScale(bg3, 1024, 1024);
	bgUpdate();

}



/* _gg_procesarFormato: copia los caracteres del string de formato sobre el
					  string resultante, pero identifica las marcas de formato
					  precedidas por '%' e inserta la representación ASCII de
					  los valores indicados por parámetro.
	Parámetros:
		formato	->	string con marcas de formato (ver descripción _gg_escribir);
		val1, val2	->	valores a transcribir, sean número de código ASCII (%c),
					un número natural (%d, %x) o un puntero a string (%s);
		resultado	->	mensaje resultante.
	Observación:
		Se supone que el string resultante tiene reservado espacio de memoria
		suficiente para albergar todo el mensaje, incluyendo los caracteres
		literales del formato y la transcripción a código ASCII de los valores.
*/
void _gg_procesarFormato(char *formato, unsigned int val1, unsigned int val2,
																char *resultado)
{
	
	int i=0, j=0, k=0, t=0;					//'i' se desplazará por formato, 'k' por resultado y 't' para seleccionar val1 o val2
	
	char texto[VCOLS*3];
	char *txt;
	
	while (i< (VCOLS*3) && formato[i]!='\0'){
		if(formato[i]=='%'&& t<2){
		
			switch(formato[i+1]){
				case 'c':
					if (t==0){
						txt=(char*)val1;
						resultado[k]=(char)val1;
						t++;
						k++;
					}
					else if (t==1){
						resultado[k]=(char)val2;
						t++;
						k++;
					}
					i= i+2; 
					break;
				case 'd':
					
					if (t==0){
						_gs_num2str_dec(texto, 11, val1); // tamaño: 2^32 = 10 cifras + '\0'=11
						t++;
					}
					else if (t==1){
						_gs_num2str_dec(texto, 11, val2); 
						t++;
					}
					j=0;
					while ( texto[j]!='\0'){
						if (texto[j]!=' '){
							resultado[k]=texto[j];
							k++;
						}
						j++;
					}
					i= i+2; 
					break;
				case 'x':
					if (t==0){
						_gs_num2str_hex(texto, 9, val1); //tamaño: 2^32 = 8 cifras + '\0'= 9
						t++;
					}
					else if (t==1){
						_gs_num2str_hex(texto, 9, val2);
						t++;
					}
					j=0;
					while ( texto[j]!='\0'){
						if (texto[j]!=' '){
							resultado[k]=texto[j];
							k++;
						}
						j++;
					}
					i= i+2; 
					break;
				case 's':
					if (t==0){
						txt=(char*)val1;
						t++;
					}
					else if (t==1){
						txt=(char*)val2;
						t++;
					}
					for (j=0; txt[j] != '\0'; j++){
						resultado[k]=txt[j];
						k++;
					}
					i= i+2; 
					break;
				case '%':
						resultado[k]=formato[j];
						k++;
						i++;
				default:
					resultado[k]=formato[j];
					k++;
					i++;
			}
		}
		else{
			resultado[k]=formato[i];
			i++; k++;
		}
	}
	resultado[k]='\0';
	return;
}


/* _gg_escribir: escribe una cadena de caracteres en la ventana indicada;
	Parámetros:
		formato	->	cadena de formato, terminada con centinela '\0';
					admite '\n' (salto de línea), '\t' (tabulador, 4 espacios)
					y códigos entre 32 y 159 (los 32 últimos son caracteres
					gráficos), además de marcas de format %c, %d, %h y %s (max.
					2 marcas por cadena) y de las marcas de cambio de color 
					actual %0 (blanco), %1 (amarillo), %2 (verde) y %3 (rojo)
		val1	->	valor a sustituir en la primera marca de formato, si existe
		val2	->	valor a sustituir en la segunda marca de formato, si existe
					- los valores pueden ser un código ASCII (%c), un valor
					  natural de 32 bits (%d, %x) o un puntero a string (%s)
		ventana	->	número de ventana (de 0 a 3)
*/

void _gg_escribir(char *formato, unsigned int val1, unsigned int val2, int ventana)
{
	/*
	z=90
	1º convertir valores en baldos para que se vea
	2º leer pControl de _gd_wbfs[ventana] (.space 4 * (4 + 32)) para obtener fila y caracteres de la pChars[]: vector de lo que sale por pantalla
		16 bits altos: número de línea (0-23)
		16 bits bajos: caracteres pendientes (0-32)
	3º caracteres mens definitivo añadirlo en ASCII final del buffer: pChars[]
	4º \t= 4 espacios, caracter= añadir codigo ASCII, \n salto de linea + swiWaitForVBlank() y _gg_escribirLinea
	5º +1 linea si línea anterior=23 = _gg_desplazar()
	6º seguir hasta final texto actualizando pControl
	
	*/
	int fila_texto, num_char, i=0, j=0, color;			//'i' es el puntero que se desplaza por texto 

	char texto[3*VCOLS+1]="";
	_gg_procesarFormato(formato, val1, val2, texto);
	color = _gd_wbfs[ventana].pControl >> 28; 					//los 4 bits de mayor peso corresponden a el color 
	fila_texto=(_gd_wbfs[ventana].pControl & 0x0FFF0000) >> 16;	//los 12 bits intermedios ahora corresponden a la fila
	fila_texto = fila_texto & 0x0FFF;
	num_char=  _gd_wbfs[ventana].pControl & 0xFFFF;		// nos indica cuantos caracteres se han quedado pendientes de escribir en la línea
	
	while ((i<VCOLS*3)&&texto[i]!='\0'){
	

		if(texto[i]== '%'){		//selección color
			switch(texto[i+1]){
				case '0':
					color = 0;
					break;
				case '1':
					color = 1;
					break;
				case '2':
					color = 2;
					break;
				case '3':
					color = 3;
					break;
				default: 
					i=i-2;
			}
			i=i+2;
		}
		if(num_char==VCOLS){
			_gp_WaitForVBlank();			
			if(fila_texto==VFILS){
				_gg_desplazar(ventana);
				fila_texto--;
			}
			_gg_escribirLinea(ventana, fila_texto, num_char);
			fila_texto++;
			num_char=0;
			_gd_wbfs[ventana].pChars[num_char]=' ';
		}
		else{
			if (texto[i]=='\n'){
				_gp_WaitForVBlank();					
				if(fila_texto==VFILS){
					_gg_desplazar(ventana);
					fila_texto--;
				}
				_gg_escribirLinea(ventana, fila_texto, num_char);
				fila_texto++;
				num_char=0;
				_gd_wbfs[ventana].pChars[num_char]=' ';
				i++;
			}
			else{
				if(texto[i]=='\t'){
					j=num_char%4;
					while((j<4) && (num_char<VCOLS)){
						_gd_wbfs[ventana].pChars[num_char]=' ';
						num_char++;
						j++;
					}
					i++;
				}
				else if(texto[i] != '\n' && num_char < VCOLS)
				{
					_gd_wbfs[ventana].pChars[num_char]=texto[i] + (128*color);
					i++;
					num_char++;
				}
			}
		}
	_gd_wbfs[ventana].pControl=(color<<28)+((fila_texto & 0x0FFF)<<16)+num_char;
	}
}
