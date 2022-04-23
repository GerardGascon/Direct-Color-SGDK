#include <genesis.h>

#include "../inc/hw_md.h"
#include "../inc/files.h"

extern unsigned short bitmap;
volatile unsigned int gTicks;

int main()
{
    clear_screen();

    while (1)
    {
        // show bitmap
        dma_screen((unsigned short*)filePtr);
    }

    clear_screen();
    return 0;
}

