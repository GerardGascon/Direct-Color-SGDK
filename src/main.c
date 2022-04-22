#include <genesis.h>

#include "../inc/hw_md.h"
#include "../inc/files.h"

extern unsigned short bitmap;

int main()
{
    int curr = 0;

    clear_screen();

    while (1)
    {
        // show bitmap
        dma_screen((unsigned short*)filePtr[curr]);

        curr = (curr + 1) % 7;
    }

    clear_screen();
    return 0;
}

