/*------------------------------------------------------------------------------

	"garlic_mem.c" : fase 1 / programador M: alberto.flores@estudiants.urv.cat

	Funciones de carga de un fichero ejecutable en formato ELF, para GARLIC 1.0

------------------------------------------------------------------------------*/
#include <nds.h>
#include <filesystem.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
#include <garlic_system.h>				// definición de funciones y variables de sistema

#define INI_MEM 0x01002000				// dirección inicial de memoria para programas 
#define END_MEM 0x01008000				/*direcció maxima memoria itcm*/
#define EI_NIDENT 16
int mem_ini=INI_MEM;					/*variable global direcció de memoria inicial*/
int mem_max=END_MEM;					/*variable global de direcció maxima itcm*/
typedef unsigned int Elf32_Addr;		/*unsigned program adress*/
typedef unsigned short Elf32_Half;		/*unsigned halfword field*/
typedef unsigned int Elf32_Off; 		/*Unsigned file offset*/
typedef unsigned int Elf32_Word;		/*Field or <unsigned large integer*/

/*encapçalat ELF*/
typedef struct{
	unsigned char e_ident[EI_NIDENT]; 	/*0-15*/
	Elf32_Half e_type;					/*16-17*/
	Elf32_Half e_machine;				/*18-19*/
	Elf32_Word e_version;				/*20-23*/
	Elf32_Addr e_entry;					/*24-27*/
	Elf32_Off e_phoff;					/*28-31*/
	Elf32_Off e_shoff;					/*32-35*/
	Elf32_Word e_flags;					/*36-39*/
	Elf32_Half e_ehsize;				/*40-41*/
	Elf32_Half e_phentsize;				/*42-43*/
	Elf32_Half e_phnum;					/*44-45*/
	Elf32_Half e_shentsize;				/*46-47*/
	Elf32_Half e_shnum;					/*48-49*/
	Elf32_Half e_shstrndx;				/*49-50*/
}Elf32_Ehdr;

/*Segments info*/
typedef struct{
	Elf32_Word p_type;					/*0-3*/
	Elf32_Off p_offset;					/*4-7*/
	Elf32_Addr p_vaddr;					/*8-11*/
	Elf32_Addr p_paddr;					/*12-15*/
	Elf32_Word p_filesz;				/*16-19*/
	Elf32_Word p_memsz;					/*20-23*/
	Elf32_Word p_flags;					/*24-27*/
	Elf32_Word p_align;					/*28-31*/
}Elf32_Phdr;

/*Seccions info*/
typedef struct{
	Elf32_Word sh_name;					/*0-3*/
	Elf32_Word sh_type;					/*4-7*/
	Elf32_Word sh_flags;				/*8-11*/
	Elf32_Addr sh_addr;					/*12-15*/
	Elf32_Off sh_offset;				/*16-19*/
	Elf32_Word sh_size;					/*20-23*/
	Elf32_Word sh_link;					/*24-27*/
	Elf32_Word sh_info;					/*28-31*/
	Elf32_Word sh_addralign;			/*32-35*/
	Elf32_Word sh_entsize;				/*36-39*/
}Elf32_Shdr;

/*reubicadors*/
typedef struct{
	Elf32_Addr r_offset;				/*0-3*/
	Elf32_Word r_info;					/*4-7*/
}Elf32_Rel;

/* _gm_initFS: inicializa el sistema de ficheros, devolviendo un valor booleano
					para indiciar si dicha inicialización ha tenido éxito; */
int _gm_initFS()
{
	return nitroFSInit(NULL); // inicializar sistema de ficheros NITRO	
}



/* _gm_cargarPrograma: busca un fichero de nombre "(keyName).elf" dentro del
					directorio "/Programas/" del sistema de ficheros, y
					carga los segmentos de programa a partir de una posición de
					memoria libre, efectuando la reubicación de las referencias
					a los símbolos del programa, según el desplazamiento del
					código en la memoria destino;
	Parámetros:
		keyName ->	vector de 4 caracteres con el nombre en clave del programa
	Resultado:
		!= 0	->	dirección de inicio del programa (intFunc)
		== 0	->	no se ha podido cargar el programa
*/
intFunc _gm_cargarPrograma(char *keyName)
{
	/*Inicialitzar variables*/
	long mida;
	char *buffer;
	int i,adress=0,aux=0;
	FILE* programa;
	Elf32_Ehdr cap;
	Elf32_Phdr segments;
	char path[19];
	sprintf(path, "/Programas/%s.elf", keyName);		/*Obtenim la direcció del fitxer .elf*/
	programa = fopen(path, "rb");						/*Obrim el fitxer binari en mode lectura*/
	if (programa==NULL)									/*Comprovem que existeixi*/
		return ((intFunc) 0);
	fseek(programa, 0L, SEEK_END);						/*Ens situem al final del fitxer*/
	mida = ftell (programa);							/*Obtenim la mida del contigut del fitxer*/
	buffer =(char*)malloc(mida);						/*Reservem memoria dinamica per al buffer*/
	fseek(programa,0L,SEEK_SET);						/*Ens situem a l'inici del fitxer*/
	fread(buffer,1,mida,programa);						/*Obtenim tot el contingut del fitxer*/
	if (buffer == NULL)									/*Comprovem que el buffer s'ha omplert*/
		return ((intFunc) 0);
	fseek(programa,0L,SEEK_SET);						/*Ens tornem a situar a l'inici del fitxer*/
	fread(&cap,1,sizeof(Elf32_Ehdr), programa);			/*Obtenim només la informació de la capçalera del fitxer*/
	for(i=0;i<cap.e_phnum;i++)							/*Bucle per recorrer els diferents segments*/
	{											
		fseek(programa, cap.e_phoff+cap.e_phentsize*i, SEEK_SET);
		fread(&segments,1,sizeof(Elf32_Phdr), programa);/*Obtenim la informació de la taula del segment*/
		if(segments.p_type == 1)						/*Analitzem els segments tipus PT_LOAD (tipus 1)*/
		{
			if (mem_ini > mem_max)						/*Comprovem que no arribem a la posició máxima de memoria itcm*/ 
			{
				fclose(programa);
				free(buffer);
				return ((intFunc)0);
			}
			_gs_copiaMem((const void *) &buffer[segments.p_offset],  (void *) mem_ini, segments.p_filesz);/*Copiar el contingut de la taula de segments a la memoria*/
			_gm_reubicar( buffer, segments.p_paddr, (unsigned int *) mem_ini);							 /*Reubiquem les posibles posicions sensibles*/
			aux = segments.p_filesz%4;																	 /*Analitzem si  el tamany del segment dins la memoria es múltiple de 4*/
			if(aux!=0)																					 /*Sino ho es, asegurem un tamany múltiple de 4  (sempre més tamany) per poder realitzar el copiaMem*/
			{
				aux=4-aux;
				segments.p_filesz += aux;
			}
			adress = (int) mem_ini+cap.e_entry-segments.p_paddr;/*Calculem la direcció inicial en memoria del programa*/
			mem_ini = mem_ini + segments.p_filesz; 				/*Actualitzem la nova posició de memoria*/
		}
	}
	fclose(programa);											/*Tanquem el fitxer*/
	free(buffer);												/*Alliberem el vector dinàmic*/
	
	return ((intFunc) adress);									/*Retornam la direcció d'inici en memoria del programa*/
	
}