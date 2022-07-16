/*------------------------------------------------------------------------------

	"dpas.c" : primer programa de prueba para el sistema operativo GARLIC 1.0;
	
	Imprime el típico mensaje "Hello world!" por una ventana de GARLIC, un
	número aleatorio de veces, dentro de un rango entre 1 y 10 elevado al
	argumento ([0..3]), es decir, hasta 1, 10, 100 o 1000 iteraciones.

------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definición de las funciones API de GARLIC */


void calculaData(int any){
	unsigned int a, b, c, d, e, f, g, h, i, k, l, m, n, extra, suma, mes, dia;
	GARLIC_divmod(any, 19, &extra, &a);	// a = any % 19
	GARLIC_divmod(any, 100, &b, &c);		// b = any / 100; c = any % 100
	GARLIC_divmod(b, 4, &d, &e);			// d = b / 4; e = b % 4
	suma = b + 8;
	GARLIC_divmod(suma, 25, &f, &extra);	// f = (b + 28) / 25
	suma = b - f + 1;
	GARLIC_divmod(suma, 3, &g, &extra);	// g = (b - f + 1) / 3
	suma = 19*a + b - d - g + 15;
	GARLIC_divmod(suma, 30, &extra, &h); 	// h = (19a + b - d - g + 15) % 30
	GARLIC_divmod(c, 4, &i, &k);			// i = c / 4; k = c % 4
	suma = 32 + 2*e + 2*i - h - k;
	GARLIC_divmod(suma, 7, &extra, &l);	// l = (32 + 2e + 2i - h - k) % 7
	suma = a + 11*h + 22*l;
	GARLIC_divmod(suma, 451, &m, &extra);	// m = (a + 11h + 22l) / 451
	n = h + l - 7*m + 114;
	GARLIC_divmod(n, 31, &mes, &dia);		// mes = n / 31
	dia++;									// dia = n % 31 + 1
	//GARLIC_printf("%d: Data Pasqua: %d/%d/%d \n", GARLIC_pid(), dia, mes, any);
	// imprimir com a forma de dalt sempre posa a mes -> 3
	GARLIC_printf("\nAny: %d \n", any);
	GARLIC_printf("Mes: %d \n", mes);
	GARLIC_printf("Dia: %d \n", dia);
}



int _start(int arg)				/* función de inicio : no se usa 'main' */
{
	unsigned int j, extra, any;
	
	if (arg < 0) arg = 0;			// limitar valor máximo y 
	else if (arg > 3) arg = 3;		// valor mínimo del argumento
	
									// esccribir mensaje inicial
	
	
	
	GARLIC_divmod(GARLIC_random(), 200, &extra, &any);
	any = any + 1583 + 200*arg;					// any aleatori entre 1583 i 2382 en franges de 200 segons arg
	for (j = 0; j < 10; j++){					// i els 10 consecutius
		calculaData(any + j);
	}
	
	if ( arg == 3){								// si arg = 3 també fem joc de proves
		GARLIC_printf("\nJOC DE PROVES");
		GARLIC_printf("\nData més aviat");
		GARLIC_printf("\nAny: 1818 Mes 3 Dia 22");
		calculaData(1818);
		GARLIC_printf("\nData més tard");
		GARLIC_printf("\nAny: 2038 Mes 4 Dia 25");
		calculaData(2038);
		GARLIC_printf("\nDates conegudes");
		GARLIC_printf("\nAny: 2000 Mes 4 Dia 23");
		calculaData(2000);
		GARLIC_printf("\nAny: 2003 Mes 4 Dia 20");
		calculaData(2003);
		GARLIC_printf("\nAny: 2006 Mes 4 Dia 16");
		calculaData(2006);
		GARLIC_printf("\nAny: 2009 Mes 4 Dia 12");
		calculaData(2009);
		GARLIC_printf("\nAny: 2012 Mes 4 Dia 8");
		calculaData(2012);
		GARLIC_printf("\nAny: 2015 Mes 4 Dia 5");
		calculaData(2015);
		GARLIC_printf("\nAny: 2016 Mes 3 Dia 27");
		calculaData(2016);
		GARLIC_printf("\nAny: 2018 Mes 4 Dia 1");
		calculaData(2018);
		GARLIC_printf("\nAny: 2021 Mes 4 Dia 4");
		calculaData(2021);
		
		
	
	}

	return 0;
}


