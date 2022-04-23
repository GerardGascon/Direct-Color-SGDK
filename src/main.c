#include <genesis.h>

#include "../inc/hw_md.h"
#include "../inc/files.h"

#define FILE_ADDRESS 131072

extern unsigned short bitmap;
volatile unsigned int gTicks;
int filePtr1 = 131072;

int main(){
	clear_screen();

	while (1){
		dma_screen((unsigned short*)filePtr);
	}

	clear_screen();
	return 0;
}