/*------------------------------------------------------------------------------

	"HOLA.c" : primer programa de prueba para el sistema operativo GARLIC 1.0;
	
	Imprime el típico mensaje "Hello world!" por una ventana de GARLIC, un
	número aleatorio de veces, dentro de un rango entre 1 y 10 elevado al
	argumento ([0..3]), es decir, hasta 1, 10, 100 o 1000 iteraciones.

------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definición de las funciones API de GARLIC */
#include <stdio.h>


void fahrenheitACelsiusYKelvin(int fahrenheit) {
	int entero, decimal;
	fahrenheit = fahrenheit - 32;
	fahrenheit = fahrenheit << 14;
	entero = (fahrenheit * 5) / 9;		/*  mult.5  y div.9 equivale a div.1.8*/
    decimal = entero & 15;				/* and de los 4 ultimos bit para saber que valor decimal hemos obtenido*/
	switch (decimal){
		case 3:
			decimal=8889;
			break;
		case 13:
			decimal=8889;
			break;
		case 7:
			decimal=7778;
			break;
		case 9:
			decimal=7778;
			break;
		case 10:
			decimal=6667;
			break;
		case 6:
			decimal=6667;
			break;
		case 14: 
			decimal=5556;
			break;
		case 2: 
			decimal=5556;
			break;
		case 1: 
			decimal=4444;
			break;
		case 15: 
			decimal=4444;
			break;
		case 5:
			decimal=3333;
			break;
		case 11:
			decimal=3333;
			break;
		case 8:
			decimal=2222;			/*se repite en + y - */
			break;
		case 12:
			decimal=1111;
			break;
		case 4: 
			decimal=1111;
			break;
		default:
			decimal=0;
	}
	entero= entero >> 14;
	if (entero<0){
		entero = entero *-1;
		GARLIC_printf("\nCelsius: -%d.%d", entero, decimal);
		entero = entero *-1;
	}
	else	GARLIC_printf("\nCelsius: %d.%d", entero, decimal);
	entero= entero + 273;
	GARLIC_printf("\nKelvin: %d.%d\n", entero, decimal);
}

void celsiusAFahrenheit(int celsius) {
	int entero, decimal;
	celsius = celsius << 14;
	entero = (celsius * 9) / 5;		/* ya que 9/5= *1.8*/
	decimal = entero & 7;					/* and de los 3 ultimos bit para saber que valor decimal hemos obtenido*/
	switch (decimal){
		case 3: 
			decimal=8000;
			break;
		case 5:
			decimal=8000;
			break;
		case 6:
			decimal=6000;
			break;
		case 2:
			decimal=6000;
			break;
		case 1:
			decimal=4000;
			break;
		case 7:
			decimal=4000;
			break;
		case 4:
			decimal=2000;
			break;
		default:
			decimal=0;
	}
	entero= entero >> 14;
	entero = entero + 32;
	if (entero < 0){
		entero = entero *-1;
		GARLIC_printf("\nFahrenheit: -%d.%d", entero, decimal);
		entero = entero *-1;
	}
	else	GARLIC_printf("\nFahrenheit: %d.%d", entero, decimal);
	
	return;
}


int _start(int arg)				/* función de inicio : no se usa 'main' */
{
	char aux=' ';
	switch (arg){
		case 0: 
			arg=30;
			break;
		case 1:
			arg=-300;
			break;
		case 2:
			arg=-500;
			break;
		case 3:
			arg=0;
			break;
	}
	signed int celsius = arg, kelvin = arg, fahrenheit = arg;
	if (celsius<-273)	GARLIC_printf("\n%c%c%3TEMPERATURA PROPUESTA IMPOSIBLE EN CELSIUS\n",aux, aux);
	else{
		GARLIC_printf("\n%c%c%0",aux, aux);
		if (celsius<0){
			celsius = celsius * -1;
			GARLIC_printf("\npasar (-%d) Celsius a:", celsius);
			celsius = celsius * -1;
		}
		else{
			GARLIC_printf("\npasar (%d) Celsius a:", celsius);
		}
		celsiusAFahrenheit(celsius);
		kelvin = celsius + 273;
		GARLIC_printf("\nKelvin: %d", kelvin);
	}
	kelvin=arg;
	
	if (kelvin < 0)	GARLIC_printf("\n%c%c%3TEMPERATURA PROPUESTA IMPOSIBLE EN KELVIN",aux, aux);
	else{
		GARLIC_printf("\n%c%c%1",aux, aux);
		GARLIC_printf("\n\npasar (%d) Kelvin a:", kelvin);
		celsius = kelvin - 273;
		if(celsius < 0){
			celsius = celsius *-1;
			GARLIC_printf("\nCelsius -%d", celsius);
			celsius = celsius *-1;
		}
		else	GARLIC_printf("\nCelsius %d", celsius);
		celsiusAFahrenheit(celsius);
	}
	fahrenheit = arg;
	if (fahrenheit < -460)	GARLIC_printf("\n%c%c%3TEMPERATURA PROPUESTA IMPOSIBLE EN FAHRENHEIT",aux, aux);
	else{
		GARLIC_printf("\n%c%c%2",aux, aux);
		if (fahrenheit<0){
			fahrenheit = fahrenheit *-1;
			GARLIC_printf("\n\npasar (-%d) Fahrenheit a:", fahrenheit);
			fahrenheit = fahrenheit *-1;
		}
		else GARLIC_printf("\n\npasar (%d) Fahrenheit a:", fahrenheit);
		fahrenheitACelsiusYKelvin(fahrenheit);
	}
	return 0;
}