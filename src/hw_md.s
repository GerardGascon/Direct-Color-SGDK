| SEGA MegaDrive support code
| by Chilly Willy

	.text
	.align  2

| Initialize the hardware & load font tiles
	.global init_hardware
init_hardware:
	movem.l %d2-%d7/%a2-%a6,-(%sp)

| wait on VDP DMA (in case we reset in the middle of DMA)
	move.w  #0x8114,(%a4)            /* display off, dma enabled */
0:
	move.w  (%a4),%d0                 /* read VDP status */
	btst    #1,%d0                   /* DMA busy? */
	bne.b   0b                      /* yes */

	moveq   #0,%d0
	move.w  #0x8000,%d5              /* set VDP register 0 */
	move.w  #0x0100,%d7

| Set VDP registers
	lea     InitVDPRegs(%pc),%a5
	moveq   #18,%d1
1:
	move.b  (%a5)+,%d5                /* lower byte = register data */
	move.w  %d5,(%a4)                 /* set VDP register */
	add.w   %d7,%d5                   /* + 0x0100 = next register */
	dbra    %d1,1b

| clear VRAM
	move.w  #0x8F02,(%a4)            /* set INC to 2 */
	move.l  #0x40000000,(%a4)        /* write VRAM address 0 */
	move.w  #0x7FFF,%d1              /* 32K - 1 words */
2:
	move.w  %d0,(%a3)                 /* clear VRAM */
	dbra    %d1,2b

| The VDP state at this point is: Display disabled, ints disabled, Name Tbl A at 0xC000,
| Name Tbl B at 0xE000, Name Tbl W at 0xB000, Sprite Attr Tbl at 0xA800, HScroll Tbl at 0xAC00,
| H40 V28 mode, and Scroll size is 64x32.

| Clear CRAM
	lea     InitVDPRAM(%pc),%a5
	move.l  (%a5)+,(%a4)              /* set reg 1 and reg 15 */
	move.l  (%a5)+,(%a4)              /* write CRAM address 0 */
	moveq   #31,%d3
3:
	move.l  %d0,(%a3)
	dbra    %d3,3b

| Clear VSRAM
	move.l  (%a5)+,(%a4)              /* write VSRAM address 0 */
	moveq   #19,%d4
4:
	move.l  %d0,(%a3)
	dbra    %d4,4b

| set the default palette for text
	move.l  #0xC0000000,(%a4)        /* write CRAM address 0 */
	move.l  #0x00000CCC,(%a3)        /* entry 0 (black) and 1 (lt gray) */
	move.l  #0xC0200000,(%a4)        /* write CRAM address 32 */
	move.l  #0x000000A0,(%a3)        /* entry 16 (black) and 17 (green) */
	move.l  #0xC0400000,(%a4)        /* write CRAM address 64 */
	move.l  #0x0000000A,(%a3)        /* entry 32 (black) and 33 (red) */

	move.w  #0x8174,(%a4)            /* display on, vblank enabled */
	move    #0x2000,%sr              /* enable interrupts */

	movem.l (%sp)+,%d2-%d7/%a2-%a6
	rts

| VDP register initialization values
InitVDPRegs:
	.byte   0x04    /* 8004 => write reg 0 = /IE1 (no HBL INT), /M3 (enable read H/V cnt) */
	.byte   0x14    /* 8114 => write reg 1 = /DISP (display off), /IE0 (no VBL INT), M1 (DMA enabled), /M2 (V28 mode) */
	.byte   0x30    /* 8230 => write reg 2 = Name Tbl A = 0xC000 */
	.byte   0x2C    /* 832C => write reg 3 = Name Tbl W = 0xB000 */
	.byte   0x07    /* 8407 => write reg 4 = Name Tbl B = 0xE000 */
	.byte   0x54    /* 8554 => write reg 5 = Sprite Attr Tbl = 0xA800 */
	.byte   0x00    /* 8600 => write reg 6 = always 0 */
	.byte   0x00    /* 8700 => write reg 7 = BG color */
	.byte   0x00    /* 8800 => write reg 8 = always 0 */
	.byte   0x00    /* 8900 => write reg 9 = always 0 */
	.byte   0x00    /* 8A00 => write reg 10 = HINT = 0 */
	.byte   0x00    /* 8B00 => write reg 11 = /IE2 (no EXT INT), full scroll */
	.byte   0x81    /* 8C81 => write reg 12 = H40 mode, no lace, no shadow/hilite */
	.byte   0x2B    /* 8D2B => write reg 13 = HScroll Tbl = 0xAC00 */
	.byte   0x00    /* 8E00 => write reg 14 = always 0 */
	.byte   0x01    /* 8F01 => write reg 15 = data INC = 1 */
	.byte   0x01    /* 9001 => write reg 16 = Scroll Size = 64x32 */
	.byte   0x00    /* 9100 => write reg 17 = W Pos H = left */
	.byte   0x00    /* 9200 => write reg 18 = W Pos V = top */

	.align  2

| VDP Commands
InitVDPRAM:
	.word   0x8104, 0x8F01  /* set registers 1 (display off) and 15 (INC = 1) */
	.word   0xC000, 0x0000  /* write CRAM address 0 */
	.word   0x4000, 0x0010  /* write VSRAM address 0 */

| void clear_screen(void);
| clear the name table for plane B
	.global clear_screen
clear_screen:
	moveq   #0,%d0
	lea     0xC00000,%a0
	move.w  #0x8F02,4(%a0)           /* set INC to 2 */
	move.l  #0x60000003,%d1          /* VDP write VRAM at 0xE000 (scroll plane B) */
	move.l  %d1,4(%a0)                /* write VRAM at plane B start */
	move.w  #64*32-1,%d1
1:
	move.w  %d0,(%a0)                 /* clear name pattern */
	dbra    %d1,1b
	rts

| void set_vram(int offset, int val);
| store word to vram at offset
| entry: first arg = offset in vram
|        second arg = word to store
	.global set_vram
set_vram:
	lea     0xC00000,%a1
	move.w  #0x8F02,4(%a1)           /* set INC to 2 */
	move.l  4(%sp),%d1                /* vram offset */
	lsl.l   #2,%d1
	lsr.w   #2,%d1
	swap    %d1
	ori.l   #0x40000000,%d1          /* VDP write VRAM */
	move.l  %d1,4(%a1)                /* write VRAM at offset*/
	move.l  8(%sp),%d0                /* data word */
	move.w  %d0,(%a1)                 /* set vram word */
	rts

| void next_vram(int val);
| store word to vram at next offset
| entry: first arg = word to store
	.global next_vram
next_vram:
	move.l  4(%sp),%d0                /* data word */
	move.w  %d0,0xC00000             /* set vram word */
	rts

| void set_palette(short *pal, int start, int count)
| copy count entries pointed to by pal into the palette starting at the index start
| entry: pal = pointer to an array of words holding the colors
|		 start = index of the first color in the palette to set
|		 count = number of colors to copy
	.global set_palette
set_palette:
	movea.l 4(%sp),%a0                /* pal */
	move.l  8(%sp),%d0                /* start */
	move.l  12(%sp),%d1               /* count */
	add.w   %d0,%d0                   /* start*2 */
	swap    %d0                      /* high word holds address */
	ori.l   #0xC0000000,%d0          /* write CRAM address (0 + index*2) */
	subq.w  #1,%d1                   /* for dbra */

	lea     0xC00000,%a1
	move.w  #0x8F02,4(%a1)           /* set INC to 2 */
	move.l  %d0,4(%a1)                /* write CRAM */
0:
	move.w  (%a0)+,(%a1)              /* copy color to palette */
	dbra    %d1,0b
	rts

| Any following functions need to be run from ram

	.data

	.align  4

| void dma_screen(short *buffer);
| dma buffer to background cmap entry
	.global dma_screen
dma_screen:
	/*Address is stored inside the 4(%sp)*/

	move.l  4(%sp),%d0                /* buffer */
	movem.l %d2-%d7/%a2-%a6,-(%sp)
	move.w  #0x2700,%sr

	/* self-modifying code for buffer start */
	lsr.l   #1,%d0                   /* word bus */
	move.b  %d0,dma_src+3
	lsr.l   #8,%d0
	move.b  %d0,dma_src+5
	lsr.l   #8,%d0
	andi.w  #0x007F,%d0
	move.b  %d0,dma_src+9

	/* clear palette */
	moveq   #0,%d0
	lea     0xC00000,%a2
	lea     0xC00004,%a3
	moveq   #31,%d1
	move.l  #0xC0000000,(%a3)        /* write CRAM address 0 */
0:
	move.l  %d0,(%a2)                 /* clear palette */
	dbra    %d1,0b

	/* init VDP regs */
	move.w  #0x8AFF,(%a3)            /* HINT value is 255 */
	move.w  #0x8F00,(%a3)            /* AutoIncrement is 0 !!! */

	/* loop - turn on display and wait for vblank */
dma_loop:
	move.w  #0x8154,(%a3)            /* Turn on Display */
	move.l  #0x40000000,(%a3)        /* write to vram */
1:
	btst    #3,1(%a3)
	beq.b   1b                      /* wait for VB */
2:
	btst    #3,1(%a3)
	bne.b   2b                      /* wait for not VB */

	move.w  %d0,(%a2)
	move.w  %d0,(%a2)
	move.w  %d0,(%a2)
	move.w  %d0,(%a2)
	move.w  %d0,(%a2)
	move.w  %d0,(%a2)
	move.w  %d0,(%a2)
	move.w  %d0,(%a2)
	move.w  %d0,(%a2)
	move.w  %d0,(%a2)
	move.w  %d0,(%a2)
	move.w  %d0,(%a2)
	move.w  %d0,(%a2)

	nop
	nop
	nop
	nop

	/* Execute DMA */
	move.l  #0x934094ad,(%a3)        /* DMALEN LO/HI = 0xAD40 (198*224) */
dma_src:
	move.l  #0x95729603,(%a3)        /* DMA SRC LO/MID */
	move.l  #0x97008114,(%a3)        /* DMA SRC HI/MODE, Turn off Display */
	move.l  #0xC0000080,(%a3)        /* dest = write cram => start DMA */
	/* CPU is halted until DMA is complete */

	/* do other tasks here */
	pea     0.w
	addq.l  #4,%sp
	andi.w  #0x0070,%d0
	bne.b   exit_dma
	moveq   #0,%d0
	bra.b   dma_loop
exit_dma:
	jsr     init_hardware
0:
	move.l  gTicks,%d0
	addq.l  #1,%d0
1:
	cmp.l   gTicks,%d0
	bne.b   1b
	pea     0.w
	addq.l  #4,%sp
	andi.w  #0x0070,%d0
	bne.b   0b
	movem.l (%sp)+,%d2-%d7/%a2-%a6
	rts

	.text