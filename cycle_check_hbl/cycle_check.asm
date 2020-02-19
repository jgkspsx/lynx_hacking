****************
*
* chained_scbs.asm
*
* (c) 42Bastian Schick
*
* July 2019
*


DEBUG		set 1
Baudrate	set 62500

_1000HZ_TIMER	set 7

IRQ_SWITCHBUF_USR set 1

	include <includes\hardware.inc>
****************
	MACRO DoSWITCH
	dec SWITCHFlag
.\wait_vbl
	bit SWITCHFlag
	bmi .\wait_vbl
	ENDM

****************
* macros
	include <macros/help.mac>
	include <macros/if_while.mac>
	include <macros/font.mac>
	include <macros/mikey.mac>
	include <macros/suzy.mac>
	include <macros/irq.mac>
	include <macros/newkey.mac>
	include <macros/debug.mac>
****************
* variables
	include <vardefs/debug.var>
	include <vardefs/help.var>
	include <vardefs/font.var>
	include <vardefs/mikey.var>
	include <vardefs/suzy.var>
	include <vardefs/irq.var>
	include <vardefs/newkey.var>
	include <vardefs/serial.var>
	include <vardefs/1000Hz.var>
****************************************************

 BEGIN_ZP
ptr		ds 2
ptr1		ds 2
ptr2		ds 2
tmp		ds 1
*********************
 END_ZP

 BEGIN_MEM
irq_vektoren	ds 16
		ALIGN 4
screen0		ds SCREEN.LEN
screen1		ds SCREEN.LEN
 END_MEM
	run LOMEM
ECHO "START :%HLOMEM ZP : %HNEXT_ZP"
Start::
	sei
	cld
	CLEAR_MEM
	CLEAR_ZP
	ldx #0
	txs
	INITMIKEY
	INITSUZY
	SETRGB pal
	INITIRQ irq_vektoren
	INITKEY
	INITFONT LITTLEFNT,RED,WHITE
	FRAMERATE 75

	jsr InitComLynx

	SETIRQ 2,VBL
	SETIRQ 0,HBL
	SCRBASE screen0,screen1
	SET_MINMAX 0,0,160,102

	lda #$c0
	ora _SPRSYS
	sta SPRSYS
	sta _SPRSYS

	cli

main:
	nop
	bra	main

	ALIGN	256
HBL:
	inx
	inx
	jmp	(test,x)

dummy:
	dec $FDA0
	stz $fda0
	END_IRQ

	ALIGN 256
test_a
	dec $FDA0
	REPT 32
	dc.b $1b
	ENDR
	stz $fda0
	END_IRQ

	ALIGN 256
test_b
	dec $FDA0
	REPT 32
	nop
	ENDR
	stz $fda0
	END_IRQ

	ALIGN 256
test_c
	dec $fda0
	rept 32
	adc $ff
	endr
	stz $fda0
	END_IRQ

	ALIGN 256
test_d
	dec $fda0
	rept 32
	inc $ff
	endr
	stz $fda0
	END_IRQ

	ALIGN 256
test_e
	dec $fda0
	rept 32
	inc $8000
	endr
	stz $fda0
	END_IRQ

cnt set 1
test:
	dc.w 0
	rept 8
	dc.w test_a
cnt set cnt+1
	endr
	rept 8
	dc.w test_b
cnt set cnt+1
	endr
	rept 8
	dc.w test_c
cnt set cnt+1
	endr
	rept 8
	dc.w test_d
cnt set cnt+1
	endr
	rept 8
	dc.w test_e
cnt set cnt+1
	endr
	rept 108-cnt
	dc.w dummy
	endr



****************
VBL::
	ldx #0
	stz $fda0
	IRQ_SWITCHBUF
	END_IRQ
****************
_cls::	lda #<clsSCB
	ldy #>clsSCB
	jmp DrawSprite

clsSCB
	dc.b $0,$10,0
	dc.w 0,clsDATA
	dc.w 0,0
	dc.w $100*10,$100*102
clsCOLOR
	dc.b $00
clsDATA
	dc.b 2,%01111100
	dc.b 0

****************
* INCLUDES
	include <includes/draw_spr.inc>
	include <includes/irq.inc>
	include <includes/1000Hz.inc>
	include <includes/serial.inc>
	include <includes/font.inc>
	include <includes/font2.hlp>
	include <includes/newkey.inc>
	include <includes/debug.inc>
	include <includes/hexdez.inc>
	align 2

pal
	STANDARD_PAL