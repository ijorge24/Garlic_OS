/*------------------------------------------------------------------------------

	"ORDI.c" : programa de prueba para el sistema operativo GARLIC 1.0;
	
	Ordena mitjançant insertion sort un conjunt de (arg+1)*10 nombres aleatoris
	amb un rang de [0,1000]

------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definición de las funciones API de GARLIC */

int _start(int arg)				
{
	unsigned int i=0,j=0,key=0;
	if (arg < 0) arg = 0;			
	else if (arg > 3) arg = 3;		
	arg=(arg+1)*10;
	int llista[40];
	GARLIC_printf("-- Programa ORDI  --\n");
	for (i=0;i<arg;i++)
	{
		GARLIC_divmod(GARLIC_random(), 1000, &j, &key);
		llista[i]=key;
		GARLIC_printf("%d\n", llista[i]);
	}
	GARLIC_printf("\n\n");
	for (i = 1; i < arg; i++)
    {
        key = llista[i];
        j = i - 1;
        while (j >= 0 && llista[j] > key)
        {
            llista[j + 1] = llista[j];
            j = j - 1;
        }
        llista[j + 1] = key;
    }
	for (i=0;i<arg;i++)
	{
		GARLIC_printf("%d\n", llista[i]);
	}
	return 0;
}
	