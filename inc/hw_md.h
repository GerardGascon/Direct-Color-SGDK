#pragma once

extern void dma_screen(unsigned short* buffer);

extern void clear_screen(void);
extern void set_vram(int offset, int val);
extern void next_vram(int val);