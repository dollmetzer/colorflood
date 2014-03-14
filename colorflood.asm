/*
 * C O L O R F L O O D
 * ===================
 *
 * A tiny game of changing colors for the Commodore 64
 * (c) 2014 Dirk Ollmetzer, www.ollmetzer.com 
 * License: GPL V3.0
 *
 * Code was made for KickAssembler
 * (http://theweb.dk/KickAssembler/Main.php)
 */

.pc =$0801


 
/*
 * B a s i c s t a r t
 * -------------------
 *  2011 SYS 2062
 */

basicstart:	.byte 12, 8, 219, 7, 158, 32
			.byte 50, 48, 54, 50, 0, 0, 0



/*
 * P r o g r a m s t a r t
 * -----------------------
 */			
			jsr unpack
			jsr initprg
			jsr title
			jsr prepscreen
			jsr initrirq
hold:		jmp hold



/*
 * I n i t   P r o g r a m
 * -----------------------
 */
initprg:	lda #$00
			sta $d020		// black border
			sta $d021		// black background
			lda #147		// clear screen
			jsr $ffd2
			lda #$1c		// char memory is 12288...
			sta $d018
			lda #$00		// joystick mode
			sta mode
			lda #$01		// startcolor white
			sta $f6
			rts



/**
 * Unpack Music to $a000
 */
unpack:		lda #< music	// source
			sta $fc
			lda #> music
			sta $fd
			lda #< $a000-2	// target (-2, because first 2 bytes are loading address)
			sta $fe
			lda #> $a000-2
			sta $ff
			ldx #44	// music has 11262 bytes = 44 pages
unpack1:	ldy #0
unpack2:	lda ($fc),y
			sta ($fe),y
			sty $0400
			stx $0401
			dey
			bne unpack2
			clc
			lda $fc
			adc #0
			sta $fc
			lda $fd
			adc #01
			sta $fd
			clc
			lda $fe
			adc #0
			sta $fe
			lda $ff
			adc #01
			sta $ff			
			dex
			bne unpack1

			// unpack charset to $3000
			lda #< charset	// source
			sta $fc
			lda #> charset
			sta $fd
			lda #< $3000	// target
			sta $fe
			lda #> $3000
			sta $ff
			ldx #8	// chaset has 2048 bytes = 8 pages
unpack3:	ldy #0
unpack4:	lda ($fc),y
			sta ($fe),y
			sty $0400
			stx $0401
			dey
			bne unpack4
			clc
			lda $fc
			adc #0
			sta $fc
			lda $fd
			adc #01
			sta $fd
			clc
			lda $fe
			adc #0
			sta $fe
			lda $ff
			adc #01
			sta $ff			
			dex
			bne unpack3
			rts
			
			
			
/**
 *   T I T L E   S C R E E N
 *   -----------------------
 */
title:		lda #$00
			sta $d021		// black background
			lda #5			// white
			jsr $ffd2
			lda #147		// clear screen
			jsr $ffd2

			// switch music on (interrupt to c01f)
			sei
			lda #$c0
			sta $0315
			lda #$1f
			sta $0314
			cli
			
			// paint horizontal lines
			ldy #$28
titleFence:	lda #102
			sta 1023,y
			lda #103
			sta 1063,y
			lda #104
			sta 1103,y
			dey
			bne titleFence

			// pint title Logo
			ldy #$08
titleL:		lda titleLogo1-1,y
			sta 1039,y
			lda titleLogo2-1,y
			sta 1079,y
			lda titleLogo3-1,y
			sta 1119,y
			dey
			bne titleL

			// print copyright
			ldy #$00
titleC:		lda	copyright,y
			beq titleWait
			sta 1984,y	// last row
			iny
			bne titleC

			// wait for joystick fire
titleWait:	lda $dc00   	// read joystick 2
			and #$10		// check bit 5 - fire button
			bne titleWait	// no fire
			ldy #$00
titleWait1:	dey				// short delay
			nop
			bne titleWait1
			// wait for release fire
titleWait2:	lda $dc00   	// read joystick 2
			and #$10		// check bit 5 - fire button
			beq titleWait2	// fire

			lda #151		// grey 1
			jsr $ffd2
			lda #147		// clrscr
			jsr $ffd2
			rts


			// some values for the title

titleLogo1:	.byte 101, 96, 97, 98, 99,100,101,101
titleLogo2:	.byte 101,112,113,114,115,116,117,101
titleLogo3:	.byte 101,128,129,130,131,132,133,101

copyright:	.byte 64, 32, 50, 48, 49, 52, 32		// c 2014
			.byte 68, 73, 82, 75, 32, 79, 76, 76	// dirk oll
			.byte 77, 69, 84, 90, 69, 82			// metzer
			.byte 0	// end of string



/*
 * P r e p a r e   S c r e e n
 * ---------------------------
 * print a 16 by 16 grid in random colors and a color selector
 *
 * Random Number Code is:
 * lda $d012
 * eor $dc04
 * sbc $dc05
 */
prepscreen:	ldy #200
printLoop:	lda screen1 -1,y
			sta 1023,y
			lda screen2 -1,y
			sta 1223,y
			lda screen3 -1,y
			sta 1423,y
			lda screen4 -1,y
			sta 1623,y
			dey
			bne printLoop

			ldy #12
			lda #1			// white
hilite:		sta 55354,y
			sta 55434,y
			sta 55514,y
			dey
			bne hilite

			// fill playfield with random colors
			lda #$28		// $fc/$fd is pointer to color ram
			sta $fc
			lda #$d8
			sta $fd
			lda #<buffer+40	// $fe/$ff is pointer to color buffer
			sta $fe
			lda #>buffer+40
			sta $ff
			ldx #$10		// 16 rows
colorfill:	ldy #$10		// 16 columns
colorfill1:	lda $d012		// begin random calculation			
			eor $dc04
			sbc $dc05
			and #$07		// only 0-7
			beq colorfill1	// not 0 (0black)
			sta ($fc),y
			sta ($fe),y
			dey
			bne colorfill1
			clc				// calculate new row
			lda $fc
			adc #40
			sta $fc
			lda $fd
			adc #0
			sta $fd
			clc
			lda $fe
			adc #40
			sta $fe
			lda $ff
			adc #0
			sta $ff
			dex
			bne colorfill

			lda #$45		// set turn counter
			sta moves
			jsr showScore

			lda #51			// set microtimer
			sta timer50th
			lda #$03		// set timer to 300s. in dec.
			sta timerScore
			lda #$00
			sta timerScore+1
			jsr showTimer
				
			lda #0			// print colorselector
			sta $043b
			sta $043c
			sta $043d
			lda $f6			// selected color
			sta $d83b

			// initialize sound			
			lda #0
			sta $d415	// reset filter freq
			sta $d416	// reset filter freq
			sta $d417	// filter off, resonance off
			lda #$0f	// Volume 15, no filterPlay it loud
			sta $d418
			
			rts

screen1:	.byte  16, 17, 17, 17, 17, 17, 17, 17, 17, 17
			.byte  17, 17, 17, 17, 17, 17, 17, 24, 17, 17
			.byte  17, 17, 17, 17, 17, 17, 17, 17, 17, 17
			.byte  17, 18,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  0
			.byte   0,  0,  8, 67, 79, 76, 79, 82,  8,  8
			.byte   8, 20,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 22, 17, 17
			.byte  17, 17, 17, 17, 17, 17, 17, 17, 17, 17
			.byte  17, 23,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  8
			.byte   8,  8,  8, 77, 79, 86, 69, 83,  8,  8
			.byte   8, 20,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 22, 17, 17
			.byte  17, 17, 17, 17, 17, 17, 17, 17, 17, 17
			.byte  17, 23,  8,  8,  8,  8,  8,  8,  8,  8

screen2:	.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  8
			.byte   8,  8,  8, 83, 69, 67, 79, 78, 68, 83
			.byte   8, 20,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 22, 17, 17
			.byte  17, 17, 17, 17, 17, 17, 17, 17, 17, 17
			.byte  17, 21,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8

screen3:	.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8

screen4:	.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  20,  0,  0,  0,  0,  0,  0,  0,  0,  0
			.byte   0,  0,  0,  0,  0,  0,  0, 20,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8

			.byte  19, 17, 17, 17, 17, 17, 17, 17, 17, 17
			.byte  17, 17, 17, 17, 17, 17, 17, 21,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8

			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8

			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8
			.byte   8,  8,  8,  8,  8,  8,  8,  8,  8,  8




/*
 * I n i t   R a s t e r   I n t e r r u p t 
 * -----------------------------------------
 */
initrirq:	sei				// disable interrupt
			lda #<gameloop	// set IRQ Pointer to gameloop
			sta $0314
			lda #>gameloop
			sta $0315
			asl $d019		//
			lda #$7b		//
			sta $dc0d
			lda #$81		// set interrupt request to raster
			sta $d01a
			lda #$1b 		// set raster row
			sta $d011 
			lda #$c0 
			sta $d012
			lda #$00		// field is not ready (completed
			sta isready
			cli				// enable interrupt
			rts



/*
 * G a m e l o o p
 * ---------------
 */
 
gameloop:	asl $d019		// delete IRQ flag

			lda isready
			bne gameEnd

			inc $d020		// increase border color
			lda mode		// 0 = joystick mode, 1 = flood mode
			bne doFlood

			lda moves		// first check, if there are moves left
			bne gameloop1
			lda #1
			sta isready		// quit
			jsr sfxWon		// play won tune
			lda #0
			sta $d020		// Set border back to black
			jmp gameEnd

gameloop1:	jsr sfxReset
			jsr joystick	// read joystick
			jsr checkReady  // check, if everything is filled
			jmp quitirq
doFlood:	jsr flood		
quitirq:	nop
			jsr timerDec	// timer decrease
			lda #0
			sta $d020		// Set border back to black
gameEnd:	pla				// restore a, y and x
			tay
			pla
			tax
			pla
			rti				// return from interrupt



/*
 * R e a d   J o y s t i c k   # 2
 * -------------------------------
 */
joystick:	ldx $dc00   	// read joystick 2
			ldy retard		// delay color selection?
			beq joyup
			dey
			sty retard
			jmp joyfire		// skip color selection
			
joyup:		txa
			and #$01		// check bit 1 - up
			bne joydown		// not up - next check down
			lda #$0f		// change max 4 time per sec.
			sta retard
			jsr sfxBing		// play sound
			dec $f6
			beq joyup1
			jmp joyend
joyup1:		lda #$07
			sta $f6
			jmp joyend
			
joydown:	txa
			and #$02		// check bit 2 - down
			bne joyfire		// not down - next check fire
			lda #$0f		// change max 4 time per sec.
			sta retard
			jsr sfxBing		// play sound
			lda $f6			// increase selected color number
			clc
			adc #$01
			cmp #$08
			bne joydownend
			lda #$01
joydownend:	sta $f6
			jmp joyend
			
joyfire:	txa
			and #$10		// check bit 5 - fire button
			bne joyend		// no fire
			lda mode		// in "flood" mode?
			bne joyend
			lda buffer+41	// save current start color
			sta $f9			
			lda $f6			// take selected color...
			cmp $f9			// skip, if already the same color
			beq joyend			
			sta buffer+41	// ...and store it in the upper left tile
			sta $d829		// Color change tile
			lda #$08		
			sta $0429
			lda #$01		// switch to flood mode
			sta mode
			jsr sfxWoosh	// Begin sound effect woosh

			// increase turn counter in decimal mode
			sed				//set decimal mode
			sec
			lda moves
			sbc #$01
			sta moves
			cld				//clear decimal mode
			jsr showScore
			
joyend:		lda $f6
			sta $d83b		// show selected color
			sta $d83c
			sta $d83d
			rts



/*
 * D e c r e a s e   T i m e r
 * ---------------------------
 */
timerDec:	dec timer50th
			beq timerTick
			rts
			// reset 50th timer and add one second
timerTick:	lda #51			
			sta timer50th
			
			sed		//set decimal mode
			sec
			lda timerScore+1
			sbc #$01
			sta timerScore+1
			lda timerScore
			sbc #$0
			sta timerScore
			cld		//clear decimal mode

			jsr showTimer
			rts



/*
 * F l o o d
 * ---------
 */
flood:		sec				// soundeffect
			lda $d400
			sbc #08
			sta $d400
			lda $d401
			sbc #0
			sta $d401
			sec
			lda $d40e
			sbc 08
			sta $d40e
			lda $d40f
			sbc #0
			sta $d40f
	
			lda #$00 		// pointer to char screen $0400
			sta $fa			// $fa,$fb
			lda #04
			sta $fb
			lda #$00 		// pointer to color screen $d800
			sta $fc			// $fc,$fd
			lda #$d8
			sta $fd
			lda #<buffer	// pointer to color buffer
			sta $fe			// $fe,$ff
			lda #>buffer
			sta $ff
			lda #$00		// no tilechange until now
			sta tilechange

			ldx #$10		// 16 rows
fLoopY:		ldy #$29		// next row, next col = 41 (#$29)
			lda #$10        // 16 cols
			sta $f7		 	// $f7 is register for col counting
fLoopX:		lda ($fa),y		// load char tile from screen
			beq detectend	// if char zero, jump to finalize char
			sec				// decrease char
			sbc #$01
 			sta ($fa),y		// store in buffer
			lda ($fa),y		//
			cmp #$06		// fresh switch?
			bne skipseach
			jsr perimeter	// perform a perimetersearch
skipseach:	lda #$01		
			sta tilechange	// remember - we changed an tile
detectend:  iny
			dec $f7			// next column
			bne fLoopX

			clc				// calculate new screen row
			lda $fa
			adc #$28
			sta $fa
			lda $fb
			adc #0
			sta $fb
			clc				// calculate color row
			lda $fc
			adc #$28
			sta $fc
			lda $fd
			adc #0
			sta $fd
			clc				// calculate buffer row
			lda $fe
			adc #$28
			sta $fe
			lda $ff
			adc #0
			sta $ff

			dex
			bne fLoopY
			
			lda tilechange	// flood is only complete, if nothing changed
			bne floodend
			lda #$0			// switch off flood
			sta mode

floodend: 	rts				// nothing changed - no need to redraw



/**
 * Perimetersearch around changing tile
 */
perimeter:	sty $f8			// rescue y

lookleft:	ldy $f8
			dey				// left tile from current
			lda ($fa),y
			bne lookright	// skip, if tile is already changing
			lda ($fe),y		// load color right from current cursor
			cmp $f9			// compare with start color 
			bne lookright	// not switching
			lda #$08
			sta ($fa),y		// switching char
			lda $f6			// take selected color
			sta ($fc),y		// and change char color
			sta ($fe),y		// and in color buffer
			
lookright:	ldy $f8
			iny				// right tile from current
			lda ($fa),y
			bne lookup		// skip, if tile is already changing
			lda ($fe),y		// load color right from current cursor
			cmp $f9			// compare with start color 
			bne lookup		// not switching
			lda #$08
			sta ($fa),y		// switching char
			lda $f6			// take selected color
			sta ($fc),y		// and change char color
			sta ($fe),y		// and in color buffer

lookup:		sec
			lda $f8
			sbc #$28
			tay
			lda ($fa),y
			bne lookdown	// skip, if tile is already changing
			lda ($fe),y		// load color right from current cursor
			cmp $f9			// compare with start color 
			bne lookdown	// not switching
			lda #$08
			sta ($fa),y		// switching char
			lda $f6			// take selected color
			sta ($fc),y		// and change char color
			sta ($fe),y		// and in color buffer
			
lookdown:	clc
			lda $f8
			adc #$28
			tay
			lda ($fa),y
			bne lookend		// skip, if tile is already changing
			lda ($fe),y		// load color right from current cursor
			cmp $f9			// compare with start color 
			bne lookend		// not switching
			lda #$08
			sta ($fa),y		// switching char
			lda $f6			// take selected color
			sta ($fc),y		// and change char color
			sta ($fe),y		// and in color buffer
						
lookend:    ldy $f8			// restore y position
			rts



/**
 * check, if screen has only one color
 */
checkReady:	lda #1				// assume - yes
			sta isready
			lda buffer+41		// store color of upper left corner
			sta $f5

			lda #<buffer+40		// set pointer to color buffer
			sta $fe
			lda #>buffer+40
			sta $ff
			
			ldx #$10
checkX:		ldy #$10
checkY:		lda ($fe),y
			cmp $f5
			beq checkEQ
			lda #0				// found difference - not ready
			sta isready
checkEQ:	dey
			bne checkY
			clc
			lda $fe
			adc #$28
			sta $fe
			lda $ff
			adc #0
			sta $ff
			dex
			bne checkX

			lda isready
			bne checkEnd
			rts	
checkEnd:	jsr sfxWon
			rts



/**
 * show 2 digit score on screen from decimal coded byte
 */
showScore:	lda moves
			and #$f0
			lsr
			lsr
			lsr
			lsr
			ora #$30		// -->ascii
			sta 1024+120+20	//print on screen
			lda moves
			and #$0f
			ora #$30		// -->ascii
			sta 1024+120+21	//print on screen
			rts



/**
 * show 3 digit timer on screen from decimal coded bytes
 */

showTimer:	lda timerScore
			and #$0f
			ora #$30
			sta 1024+200+19
			lda timerScore+1
			and #$f0
			lsr
			lsr
			lsr
			lsr
			ora #$30
			sta 1024+200+20
			lda timerScore+1
			and #$0f
			ora #$30
			sta 1024+200+21
			rts



/**
 * Sound Effect Woosh initialisation on voice 1
 */
sfxWoosh:	lda #$a2	// Attack slow, Decay quick
			sta $d405	// AD
			lda #$48
			sta $d413	// AD voice 3
			lda #$fc	// Sustain high, Release medium
			sta $d406	// SR
			lda #$00
			sta $d414	// SR voice 3
			lda #207	// Frequency C5 Lo Byte
			sta $d400
			sta $d40e	// voice 3
			lda #34		// Frequency C5 Hi Byte
			sta $d401
			sta $d40f	// voice 3
			lda #$81	// Noise + Gate on voice 1
			sta $d404
			lda #$21	// Sawtooth + gate on voice 3
			sta $d412			
			rts

/**
 * Sound effect Bing initialisation on voice 2
 */
sfxBing:	lda #$22	// Attack slow, Decay quick
			sta $d40c	// AD voice 2
			lda #$f2	// Sustain high, Release quick
			sta $d40d	// SR voice 2
			lda #207	// Frequency C5 Lo Byte
			sta $d407	// voice 1
			lda #34		// Frequency C5 Hi Byte
			sta $d408	// voice 1
			lda #$11	// Triangle gate on
			sta $d40b
			nop
			nop
			nop
			nop
			lda #$10	// Triangle gate off
			sta $d40b
			rts

/**
 * Sound effect level won
 */
sfxWon:		lda #$22	// Attack quick Decay quick
			sta $d405	// AD voice 1
			sta $d40c	// AD voice 2
			sta $d413	// AD voice 3
			lda #$f8	// Sustain high, Release quick
			sta $d406	// SR voice 1
			sta $d40d	// SR voice 2
			sta $d414	// SR voice 3
			lda #207	// note C5, voice 1
			sta $d400
			lda #34
			sta $d401
			lda#103		// note C4, voice 2
			sta $d407
			lda#17
			sta $d408
			lda#180		// note C3, voice 3
			sta $d40e
			lda#8
			sta $d40f
			lda #0		// no filter
			sta $d417
			lda #$0f	// full volume
			sta $d418
			lda #$13	// triangle, sync, gate on
			sta $d404	// voice 1
			lda #$23	// sawtooth, sync, gate on
			sta $d40b
			lda #$43	// square, sync, gate on
			sta $d412
			nop
			nop
			nop
			nop
			lda #$12	// triangle, sync, gate off
			sta $d404	// voice 1
			lda #$22	// sawtooth, sync, gate off
			sta $d40b
			lda #$40	// square, sync, gate off
			sta $d412
			rts


/**
 * All sound effects stop
 */
sfxReset:	lda #0		
			sta $d400	// Frequency Lo Byte off
			sta $d401	// Frequency Hi Byte off
			lda #$80
			sta $d404	// gate off
			lda #$20	// gate off voice 3
			sta $d412			
			rts

/*
 * S o m e   v a r i a b l e s
 * ---------------------------
 */
retard:		.byte 0			// delay selection by joystick
mode:		.byte 0			// 0 = joystick mode, 1 = flood mode
tilechange: .byte 0			// 0 = no tile changed - flood complete
isready:	.byte 0			// field completed? 0 = no, 1 = yes
moves:		.byte 0			// number of moves in decimal
timer50th:	.byte 0			// timer 50th of a second 
timerScore:	.byte 0, 0		// timer score in decimal


buffer:		.fill 1000,0	// color ram buffer


// new charset at 12288
//			.pc = $3000
charset:	.import binary "font.bin"

// music (huelsbeck player)
// must be copied to a000, player starts c000
music:		.import binary "music.bin"
