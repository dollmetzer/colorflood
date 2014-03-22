colorflood
==========

A tiny game of changing colors for the Commodore 64

The goal of the game is easy: 

Bring all 256 fields to the same color with the least possible moves,
as fast as you can by constantly changing the color of the upper left
field.

This is a little just-for-fun-project inspired by a python game, that
was pre installed on raspian wheezy for the Raspberry Pi.


My motivation
-------------
In 2013 I visited some really good lectures about old 8Bit computers
in the department of media theory at the Humboldt University in Berlin.
I was courious, if I can manage to complete a game in 6502 assembler
more than 25 years after I sold my Commodore 64.


Development tools
-----------------
I prefer crossdevelopment, because it's more comfortable and you get
a much faster turnaround. To be as independent as possible, I'm using
tools, that are available on all three important operating systems:

- VICE Emulator (for all main Operating Systems)

- Kick Assembler (written in Java)

- Ascraeus Font Editor (written in Java)

- DroiD64 for handling D64 files on development machine (written in Java)

- Grab your preferred ASCII-Editor. On Linux, I use Geany

- Sound Monitor from Chris Huelsbeck (on the C64)


The files
---------
colorflood_basic.txt - the proof for the colorchanging algorithm. working but unbelievable slow.

colorflood.asm - the 6502 assembler sourcecode

font.bin - the new character set with game graphics

music.bin - the music (huelsbeck player)
 

Project status
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

- Basic sound in game

- Music in the title (huelsbeck player)

- Unpacking routine

- Moves countdown. Zero stops game

- Timer countdown. Zero stops game

- At the end of a game, message "You lost" oder "score 1234" is displayed

- 5 seconds after end of game, jump back to title

- DEBUG: fixed music in title after first game

- DEBUG: Win on last move is displayed as "you lost"

Still to do:

- After first game, music starts not exactly at 00:00

- Short lost or won melody at the end of level

