colorflood
==========

A tiny game of changing colors for the Commodore 64

The goal of the game is easy: 

Bring all 256 Fields to the same color with the least possible moves,
as fast as you can.

This is a little just-for-fun-project inspired by a python game, that
was pre installed on raspian wheezy for the Raspberry Pi.


My motivation
-------------
In 2013 I visited some really good lectures about old 8Bit computers
in the department of media theory at the Humboldt University in Berlin.
I was courious, if I can manage to complete a game in 6502 Assembler
more than 25 Years after I sold my Commodore 64.


development tools
-----------------
I prefer crossdevelopment, because it's more comfortable and you get
a much faster turnaround. To be as independent as possible, I'm using
tools, that are available on all three important operating systems:

- VICE Emulator

- Kick Assembler (written in Java)

- assCharEdit for character Editing (written in Java)

- Grab your preferred ASCII-Editor. On Linux, I use Geany

- Sound Monitor from Chris Huelsbeck


the files
---------
colorflood_basic.txt - the proof for the colorchanging algorithm. working but unbelievable slow.
colorflood.asm - the 6502 assembler sourcecode
font.bin - the new character set with game graphics

 

project status
--------------

Working:

- A basic start screen appears and waits for a pressed fire button
  on joystick #2.

- The playfield is shown, with 256 random colored tiles, a frame,
  a counter for the moves, a countdown and the selected color
  
- Change the color with up/down of the joystick

- Select the color with the fire botton. This will change the upper 
  left tile and all connected tiles with the same color

- Detection, if the field is finished

- basic sound in game

- music in the title (huelsbeck player)

- unpacking routine

- moves countdown. Zero stops game


Not working until now:

- no detection, if the countdown is on zero

- no end of level action
