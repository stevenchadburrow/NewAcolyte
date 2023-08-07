; Acolyte 3 Computer Code

; First, run
; ~/dev65/bin/as65 Acolyte3Code.asm

; Second, run
; ./Parser.o Acolyte3Code.lst Acolyte3Code.bin 49152 0 16384 114688

; Third, run
; minipro -p "SST39SF010" -w Acolyte3Code.bin

; OR
; ./AcolyteSimulator.o Acolyte3Code.bin



; Acolyte Computer

; Running a W65C02 at 6.29 MHz

; VGA display at
; 256x240 16-color
; and
; 512x240 4-color

; Support for
; PS/2 Keyboard and Mouse
; Genesis Gamepad
; SPI SDcard
; 2-Voice Square Wave Audio

; Memory Map
; $0000-$01FF = Zero Page / Stack
; $0200-$06FF = System RAM
; $0700-$07FF = VIA
; $0800-$7FFF = Video RAM
; $8000-$BFFF = General Purpose RAM (2x banks)
; $C000-$FFFF = ROM (2x banks)

; Writing to ROM changes the video mode
; If writing $00 to ROM, video mode is 256x240 16-color
; Else, the upper and lower nibbles determine the colors
; used in 512x240 4-color mode.  
; Black and White are always available, but other two
; colors are defined when entering that mode.

; VIA pins
; PA0 = JOY-UP
; PA1 = JOY-DOWN
; PA2 = JOY-LEFT (with 10K pull-up)
; PA3 = JOY-RIGHT (with 10K pull-up)
; PA4 = JOY-BUTTON1
; PA5 = JOY-BUTTON2
; PA6 = MOUSE-DATA
; PA7 = KEY-DATA
; CA1 = KEY-CLOCK
; CA2 = MOUSE-CLOCK
; PB0 = SPI-CLOCK
; PB1 = SPI-MOSI
; PB2 = SPI-CS (for SDCARD)
; PB3 = JOY-SELECT
; PB4 = RAM-BANK
; PB5 = ROM-BANK
; PB6 = SPI-MISO
; PB7 = AUDIO-CH-A
; CB1 = AUDIO-CH-B
; CB2 = Unused

; /NMI is connected to V-SYNC through a bodge wire


	.65C02


; PS/2 Keyboard Keycodes
ps2_return		.EQU $5A
ps2_backspace		.EQU $66
ps2_escape		.EQU $76
ps2_shift_left		.EQU $12
ps2_shift_right		.EQU $59
ps2_capslock		.EQU $58
ps2_numlock		.EQU $77
ps2_scrolllock		.EQU $7E
ps2_control		.EQU $14
ps2_alt			.EQU $11
ps2_tab			.EQU $0D
ps2_page_up		.EQU $7D
ps2_page_down		.EQU $7A
ps2_arrow_up		.EQU $75
ps2_arrow_down		.EQU $72
ps2_arrow_left		.EQU $6B
ps2_arrow_right		.EQU $74
ps2_insert		.EQU $70
ps2_delete		.EQU $71
ps2_home		.EQU $6C
ps2_end			.EQU $69
ps2_slash		.EQU $4A
ps2_f1			.EQU $05
ps2_f2			.EQU $06
ps2_f3			.EQU $04
ps2_f4			.EQU $0C
ps2_f5			.EQU $03
ps2_f6			.EQU $0B
ps2_f7			.EQU $83
ps2_f8			.EQU $0A
ps2_f9			.EQU $01
ps2_f10			.EQU $09
ps2_f11			.EQU $78
ps2_f12			.EQU $07


; VIA locations

via			.EQU $0700 ; full page
via_pb			.EQU via+$00
via_pa			.EQU via+$01
via_db			.EQU via+$02
via_da			.EQU via+$03
via_pcr			.EQU via+$0C
via_ifr			.EQU via+$0D
via_ier			.EQU via+$0E
via_pah			.EQU via+$0F ; via_pa without handshake

spi_clk			.EQU %00000001
spi_clk_inv		.EQU %11111110
spi_mosi		.EQU %00000010
spi_mosi_inv		.EQU %11111101
spi_cs			.EQU %00000100
spi_cs_inv		.EQU %11111011
spi_miso		.EQU %01000000
spi_miso_inv		.EQU %10111111

joy_select		.EQU %00001000
joy_select_inv		.EQU %11110111


; System RAM locations

key_array		.EQU $0200

key_write		.EQU $0300
key_read		.EQU $0301
key_data		.EQU $0302
key_counter		.EQU $0303
key_release		.EQU $0304
key_extended		.EQU $0305
key_shift		.EQU $0306
key_capslock		.EQU $0307
key_alt_control		.EQU $0308
sub_jump		.EQU $0309 ; 3 bytes long
sub_read		.EQU $030C ; 4 bytes long
sub_index		.EQU $0310 ; 4 bytes long
sub_write		.EQU $0314 ; 4 bytes long
vector_irq		.EQU $0318 ; 3 bytes long
sub_random_var		.EQU $031B
vector_nmi		.EQU $031C ; 3 bytes long
sub_random		.EQU $031F ; 16 bytes long
sub_inputchar		.EQU $0330 ; 3 bytes long
printchar_inverse	.EQU $0333 ; either $00 or $FF
sub_printchar		.EQU $0334 ; 3 bytes long
printchar_storage	.EQU $0337
sub_printchar_coords	.EQU $0338 ; 8 bytes long
printchar_x		.EQU $0340 ; from $00 to $3F
printchar_y		.EQU $0341 ; from $00 to $1D
printchar_foreground	.EQU $0342 ; either $00, $55, $AA, or $FF
printchar_background	.EQU $0343 ; either $00, $55, $AA, or $FF
printchar_read		.EQU $0344 ; 4 bytes long
printchar_write		.EQU $0348 ; 4 bytes long
colorchar_input		.EQU $034C
colorchar_output	.EQU $034D
monitor_mode		.EQU $034E
monitor_nibble		.EQU $034F
monitor_values		.EQU $0350 ; 8 bytes long
tetra_score_low		.EQU $0358
tetra_score_high	.EQU $0359
tetra_piece		.EQU $035A
tetra_piece_next	.EQU $035B
tetra_location		.EQU $035C
tetra_speed		.EQU $035D
tetra_overscan		.EQU $035E
tetra_joy_prev		.EQU $035F
tetra_values		.EQU $0360 ; 3 bytes
joy_buttons		.EQU $0363
sdcard_block		.EQU $0364 ; 2 bytes 
clock_low		.EQU $0366
clock_high		.EQU $0367
	; unused space
monitor_string		.EQU $03C0 ; 64 bytes long

tetra_field		.EQU $0400 ; 256 bytes long





	
	.ORG $C000 ; start of code

vector_reset
	JSR setup

	JSR key_init
	JSR joy_init

	JSR function_keys_scratchpad

	.ORG $E400 ; intro and help text

intro
	LDX #$00
intro_loop
	LDA intro_text,X
	CMP #$00
	BEQ intro_exit
	JSR printchar
	INX
	BNE intro_loop
intro_exit
	RTS
intro_text
	.BYTE "Acolyte"
	.BYTE $0D
	.BYTE "F1=Scrat"
	.BYTE "chpad, F"
	.BYTE "2=Monito"
	.BYTE "r, F3=Te"
	.BYTE "tra, F4="
	.BYTE "SDcard"
	.BYTE $0D,$00	


help	
	LDX #$00
help_loop
	LDA help_text,X
	CMP #$00
	BEQ help_exit
	JSR printchar
	INX
	BNE help_loop
help_exit
	RTS
help_text
	.BYTE "Monitor "
	.BYTE "EXs"
	.BYTE $0D
	.BYTE "Dsp ="
	.BYTE " ",$5C
	.BYTE "F000;",$0D
	.BYTE "Lst ="
	.BYTE " ",$5C
	.BYTE "F000.F03"
	.BYTE "FL",$0D
	.BYTE "Wrt ="
	.BYTE " ",$5C
	.BYTE "0000",$3A
	.BYTE "ABCDEF'Z"
	.BYTE ".0007L",$0D
	.BYTE "Jmp ="
	.BYTE " ",$5C
	.BYTE "0007;000"
	.BYTE "0",$3A
	.BYTE "EE070060"
	.BYTE ",J0007;",$0D
	.BYTE "Pak ="
	.BYTE " ",$5C
	.BYTE "EA>0000."
	.BYTE "0007PL",$0D
	.BYTE "Mov ="
	.BYTE " ",$5C
	.BYTE "0000<F00"
	.BYTE "0.F03FM"
	.BYTE $0D
	.BYTE "Brk = Es"
	.BYTE "cape",$0D
	.BYTE $00


	.ORG $E500 ; function keys and sdcard functions

function_keys
	CMP #$1C ; F1, scratchpad
	BNE function_keys_next1
function_keys_scratchpad
	LDA #$0C ; return
	JSR printchar
	JSR intro
	PLA
	PLA
	JMP scratchpad
function_keys_next1
	CMP #$1D ; F2, monitor
	BNE function_keys_next2
	LDA #$0C ; return
	JSR printchar
	JSR help
	PLA
	PLA
	JMP monitor
function_keys_next2
	CMP #$1E ; F3, tetra
	BNE function_keys_next3
	PLA
	PLA
	JMP tetra
function_keys_next3
	CMP #$1F ; F4, sdcard_bootloader
	BNE function_keys_next4
	JSR sdcard_bootloader
	CMP #$00
	BNE function_keys_exit ; successful exit
	JMP vector_reset ; error exit
function_keys_next4
	NOP
function_keys_exit
	RTS

sdcard_enable
	PHA
	LDA via_pb
	AND #spi_cs_inv
	STA via_pb
	PLA
	RTS

sdcard_disable
	PHA
	LDA via_pb
	ORA #spi_cs
	STA via_pb
	PLA
	RTS

sdcard_output_low
	PHA
	LDA via_pb
	AND #spi_mosi_inv
	STA via_pb
	PLA
	RTS

sdcard_output_high
	PHA
	LDA via_pb
	ORA #spi_mosi
	STA via_pb
	PLA
	RTS

sdcard_input ; results in $00 or $80
	LDA via_pb
	AND #spi_miso
	CLC
	ROL A
	RTS

sdcard_toggle
	PHA
	LDA via_pb
	ORA #spi_clk
	STA via_pb
	; delay here?
	AND #spi_clk_inv
	STA via_pb
	PLA
	RTS

sdcard_longdelay
	PHA
	PHX
	PHY
	LDA #$FF ; arbitrary values
	LDX #$80
	LDY #$01
sdcard_longdelay_loop
	DEC A
	BNE sdcard_longdelay_loop
	DEX
	BNE sdcard_longdelay_loop
	DEY
	BNE sdcard_longdelay_loop
	PLY
	PLX
	PLA
	RTS

sdcard_sendbyte ; already in A
	PHA
	PHX
	LDX #$08
sdcard_sendbyte_loop
	ROL A
	BCC sdcard_sendbyte_zero
	JSR sdcard_output_high
	JMP sdcard_sendbyte_toggle
sdcard_sendbyte_zero
	JSR sdcard_output_low
sdcard_sendbyte_toggle
	JSR sdcard_toggle
	DEX
	BNE sdcard_sendbyte_loop
	PLX
	PLA
	RTS

sdcard_receivebyte ; into A
	PHX
	LDA #$00
	LDX #$08
sdcard_receivebyte_loop
	PHA
	JSR sdcard_input
	BEQ sdcard_receivebyte_zero
	PLA
	SEC
	ROL A
	JMP sdcard_receivebyte_toggle
sdcard_receivebyte_zero
	PLA
	CLC
	ROL A
sdcard_receivebyte_toggle
	JSR sdcard_toggle
	DEX
	BNE sdcard_receivebyte_loop
	PLX
	RTS

sdcard_waitresult
	PHX
	PHY
	LDX #$FF
	LDY #$08 ; arbitrary values
sdcard_waitresult_loop
	JSR sdcard_receivebyte
	CMP #$FF
	BNE sdcard_waitresult_exit
	DEX
	BNE sdcard_waitresult_loop
	DEY
	BNE sdcard_waitresult_loop
	LDA #$FF
sdcard_waitresult_exit
	PLY
	PLX
	RTS
	
sdcard_pump
	PHA
	PHX
	JSR sdcard_disable
	JSR sdcard_output_high
	JSR sdcard_longdelay
	LDX #$50
sdcard_pump_loop
	JSR sdcard_toggle
	DEX
	BNE sdcard_pump_loop
	PLX
	PLA
	RTS

; sets A to $00 for error, $01 for success
sdcard_initialize
	JSR sdcard_disable
	JSR sdcard_pump
	JSR sdcard_longdelay
	JSR sdcard_enable
	LDA #$40 ; CMD0 = 0x40 + 0x00 (0 in hex)
	JSR sdcard_sendbyte
	LDA #$00
	JSR sdcard_sendbyte
	JSR sdcard_sendbyte
	JSR sdcard_sendbyte
	JSR sdcard_sendbyte
	LDA #$95 ; CRC for CMD0
	JSR sdcard_sendbyte
	JSR sdcard_waitresult
	;CMP #$FF
	;BEQ sdcard_initialize_error
	JSR sdcard_disable
	CMP #$01
	BNE sdcard_initialize_error ; expecting 0x01
	JSR sdcard_longdelay
	JSR sdcard_pump
	JSR sdcard_enable
	LDA #$48 ; CMD8 = 0x40 + 0x08 (8 in hex)
	JSR sdcard_sendbyte 
	LDA #$00 ; CMD8 needs 0x000001AA argument
	JSR sdcard_sendbyte
	JSR sdcard_sendbyte
	LDA #$01
	JSR sdcard_sendbyte
	LDA #$AA
	JSR sdcard_sendbyte
	LDA #$87 ; CRC for CMD8
	JSR sdcard_sendbyte
	JSR sdcard_waitresult
	;CMP #$FF
	;BEQ sdcard_initialize_error
	JSR sdcard_disable
	CMP #$01
	BNE sdcard_initialize_error ; expecting 0x01
	JSR sdcard_enable
	JSR sdcard_receivebyte ; 32-bit return value, ignore
	JSR sdcard_receivebyte
	JSR sdcard_receivebyte
	JSR sdcard_receivebyte
	JSR sdcard_disable
	JMP sdcard_initialize_loop
sdcard_initialize_error
	LDA #$00 ; return $00 for error
	RTS
sdcard_initialize_loop
	JSR sdcard_pump
	JSR sdcard_longdelay
	JSR sdcard_enable
	LDA #$77 ; CMD55 = 0x40 + 0x37 (55 in hex)
	JSR sdcard_sendbyte
	LDA #$00
	JSR sdcard_sendbyte
	JSR sdcard_sendbyte
	JSR sdcard_sendbyte
	JSR sdcard_sendbyte
	LDA #$01 ; CRC (general)
	JSR sdcard_sendbyte
	JSR sdcard_waitresult
	;CMP #$FF
	;BEQ sdcard_initialize_error
	JSR sdcard_disable
	CMP #$01
	BNE sdcard_initialize_error ; expecting 0x01
	JSR sdcard_pump
	JSR sdcard_longdelay
	JSR sdcard_enable
	LDA #$69 ; CMD41 = 0x40 + 0x29 (41 in hex)
	JSR sdcard_sendbyte
	LDA #$40 ; needed for CMD41?
	JSR sdcard_sendbyte
	LDA #$00
	JSR sdcard_sendbyte
	JSR sdcard_sendbyte
	JSR sdcard_sendbyte
	LDA #$01 ; CRC (general)
	JSR sdcard_sendbyte
	JSR sdcard_waitresult
	;CMP #$FF
	;BEQ sdcard_initialize_error
	JSR sdcard_disable
	CMP #$00
	BEQ sdcard_initialize_exit ; expecting 0x00
	CMP #$01
	BNE sdcard_initialize_error ; if 0x01, try again
	JMP sdcard_initialize_loop
sdcard_initialize_exit
	LDA #$01 ; return $01 for success
	RTS
	
; X = low block addr, Y = high block addr, sets A to $00 for error, $01 for success
; always stores 512 bytes wherever 'sdcard_block' says
sdcard_readblock
	PHY
	PHX
	JSR sdcard_disable
	JSR sdcard_pump
	JSR sdcard_longdelay
	JSR sdcard_enable
	LDA #$51 ; CMD17 = 0x40 + 0x11 (17 in hex)
	JSR sdcard_sendbyte
	LDA #$00
	JSR sdcard_sendbyte
	TYA
	JSR sdcard_sendbyte
	TXA
	AND #$FE ; only blocks of 512 bytes
	JSR sdcard_sendbyte
	LDA #$00
	JSR sdcard_sendbyte
	LDA #$01 ; CRC (general)
	JSR sdcard_sendbyte
	JSR sdcard_waitresult
	;CMP #$FF
	;BEQ sdcard_readblock_error
	CMP #$00
	BNE sdcard_readblock_error ; expecting 0x00
	JSR sdcard_waitresult
	CMP #$FF
	BEQ sdcard_readblock_error
	CMP #$FE
	BNE sdcard_readblock_error ; data packet starts with 0xFE
	LDY #$02
	LDX #$00
	LDA sdcard_block+0
	STA sub_write+1
	LDA sdcard_block+1
	STA sub_write+2
	JMP sdcard_readblock_loop
sdcard_readblock_error
	PLX
	PLY
	LDA #$00 ; return $00 for error
	RTS
sdcard_readblock_loop
	JSR sdcard_receivebyte
	JSR sub_write
	INC sub_write+1
	BNE sdcard_readblock_increment
	INC sub_write+2
sdcard_readblock_increment
	INX
	BNE sdcard_readblock_loop
	DEY
	BNE sdcard_readblock_loop
	JSR sdcard_receivebyte ; data packet ends with 0x55
	JSR sdcard_receivebyte ; and then 0xAA, ignore here
	JSR sdcard_disable
	PLX
	PLY
	LDA #$01 ; return $01 for success
	RTS

; X = low block addr, Y = high block addr, sets A to $00 for error, $01 for success
; always takes 512 bytes wherever 'sdcard_block' says
sdcard_writeblock
	PHY
	PHX
	JSR sdcard_disable
	JSR sdcard_pump
	JSR sdcard_longdelay
	JSR sdcard_enable
	LDA #$58 ; CMD24 = 0x40 + 0x18 (24 in hex)
	JSR sdcard_sendbyte
	LDA #$00
	JSR sdcard_sendbyte
	TYA
	JSR sdcard_sendbyte
	TXA
	AND #$FE ; only blocks of 512 bytes
	JSR sdcard_sendbyte
	LDA #$00
	JSR sdcard_sendbyte
	LDA #$01 ; CRC (general)
	JSR sdcard_sendbyte
	JSR sdcard_waitresult
	;CMP #$FF
	;BEQ sdcard_writeblock_error
	CMP #$00
	BNE sdcard_writeblock_error ; expecting 0x00
	LDA #$FE ; data packet starts with 0xFE
	JSR sdcard_sendbyte
	LDY #$02
	LDX #$00
	LDA sdcard_block+0
	STA sub_read+1
	LDA sdcard_block+1
	STA sub_read+2
	JMP sdcard_writeblock_loop
sdcard_writeblock_error
	PLX
	PLY
	LDA #$00 ; return $00 for error
	RTS
sdcard_writeblock_loop
	JSR sub_read
	JSR sdcard_sendbyte
	INC sub_read+1
	BNE sdcard_writeblock_increment
	INC sub_read+2
sdcard_writeblock_increment
	INX
	BNE sdcard_writeblock_loop
	DEY
	BNE sdcard_writeblock_loop
	LDA #$55 ; data packet ends with 0x55
	JSR sdcard_sendbyte
	LDA #$AA ; and then 0xAA
	JSR sdcard_sendbyte
	JSR sdcard_receivebyte ; toggles clock 8 times, ignore
	JSR sdcard_disable
	PLY
	PLX
	LDA #$01 ; return $01 for success
	RTS
	
; loads first 512 bytes on SDcard into $0500-$06FF and then executes starting at $0500
sdcard_bootloader
	LDA #$00 ; low addr
	STA sdcard_block+0
	LDA #$05 ; high addr
	STA sdcard_block+1
	PHX
	PHY
	JSR sdcard_initialize
	CMP #$00
	BEQ sdcard_bootloader_error
	LDY #$00 ; high addr
	LDX #$00 ; low addr
	JSR sdcard_readblock
	CMP #$00
	BEQ sdcard_bootloader_error
	LDA sdcard_block+0
	STA sub_jump+1
	LDA sdcard_block+1
	STA sub_jump+2
	JSR sub_jump ; start executing at top of sdcard memory, using JSR in hopes of coming back here
	PLY
	PLX
	LDA #$01 ; returns $01 for success
	RTS
sdcard_bootloader_error
	PLY
	PLX
	LDA #$00 ; returns $00 for error
	RTS


	
	.ORG $E800 ; tetra

tetra_color_fore	.EQU $55
tetra_color_back	.EQU $AA
	
tetra
	LDA #$00
	STA $FFFF ; turn on 16 color mode
	
	STZ sub_write+1				; clear out all screen RAM 
	LDA #$08
	STA sub_write+2
tetra_screen_loop
	LDA #$00 ; black
	JSR sub_write
	INC sub_write+1
	BNE tetra_screen_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE tetra_screen_loop
	STZ sub_write+1
	LDA #$08
	STA sub_write+2
tetra_init_loop
	LDA #tetra_color_back ; fill color
	JSR sub_write
	INC sub_write+1
	LDA sub_write+1
	CMP #$60 ; change this for width
	BEQ tetra_init_loop_inc1
	CMP #$E0 ; change this for width
	BEQ tetra_init_loop_inc2
	JMP tetra_init_loop
tetra_init_loop_inc1
	LDA #$80
	STA sub_write+1
	JMP tetra_init_loop
tetra_init_loop_inc2
	STZ sub_write+1
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE tetra_init_loop

tetra_random
	CLC
	JSR sub_random
	AND #%00011100
	BNE tetra_field_start
	JMP tetra
tetra_field_start
	STA tetra_piece_next
	STZ tetra_score_low
	STZ tetra_score_high
	LDA #$41 ; around once per second
	STA tetra_speed
	LDX #$00
tetra_field_loop
	STZ tetra_field,X
	INX
	BNE tetra_field_loop

tetra_start
	CLC
	JSR sub_random
	AND #%00011100
	BEQ tetra_start
	PHA
	LDA tetra_piece_next
	STA tetra_piece
	PLA
	STA tetra_piece_next
	LDA #$06 
	STA tetra_location
	JSR tetra_display
	JSR tetra_clear
	JSR tetra_place
	JSR tetra_draw
tetra_loop
	CLC
	JSR sub_random ; to add some randomization
	LDA clock_low
	CLC
	CMP tetra_speed
	BCC tetra_continue
	STZ clock_low
	JSR tetra_down
	JMP tetra_refresh
tetra_continue
	JSR tetra_input
	CMP #$00
	BEQ tetra_loop
	CMP #$1B ; escape to pause
	BNE tetra_next
tetra_pause_start
	LDA #$19
	STA printchar_x
	LDA #$1C
	STA printchar_y	
	LDY #$00
tetra_display_loop_paused
	LDA tetra_display_text_paused,Y
	JSR tetra_display_char
	INY
	CPY #$06
	BNE tetra_display_loop_paused
tetra_pause_loop
	JSR inputchar
	JSR function_keys
	CMP #$1B
	BNE tetra_pause_loop
tetra_pause_end
	LDA #$19
	STA printchar_x
	LDA #$1C
	STA printchar_y
	LDA #" "
	LDY #$06
tetra_pause_clear
	JSR tetra_display_char
	DEY
	BNE tetra_pause_clear
	JMP tetra_refresh

tetra_next
	CLC
	CMP #$60
	BCC tetra_upper_skip
	SEC
	SBC #$20 ; lower convert to upper
tetra_upper_skip
	TAY
	LDA #>tetra_refresh ; these are for the RTS in direction subroutines
	PHA
	LDA #<tetra_refresh
	PHA
	TYA
	CMP #$17 ; joystick
	BNE tetra_key_list
	JMP tetra_buttons
tetra_key_list
	CMP #"W"
	BEQ tetra_up
	CMP #$11 ; arrow up
	BEQ tetra_up
	CMP #"S"
	BEQ tetra_down
	CMP #$12 ; arrow down
	BEQ tetra_down
	CMP #"A"
	BEQ tetra_left
	CMP #$13 ; arrow left
	BEQ tetra_left
	CMP #"D"
	BEQ tetra_right
	CMP #$14 ; arrow right
	BEQ tetra_right
	CMP #"Q"
	BEQ tetra_rotate_ccw
	CMP #$20 ; space
	BEQ tetra_rotate_ccw
	CMP #"E"
	BEQ tetra_rotate_cw
	CMP #"0"
	BEQ tetra_rotate_cw
tetra_none
	PLA
	PLA
tetra_refresh
	NOP ; this is needed for weird RTS setup
	JSR tetra_draw
	JMP tetra_loop

tetra_up
	LDX #$00
	STZ clock_low
	RTS
tetra_down
	LDX #$00
	STZ clock_low
	LDA tetra_location
	CLC
	ADC #$10
	STA tetra_location
	JSR tetra_clear
	JSR tetra_place
	CMP #$FF ; error
	BEQ tetra_down_error
	RTS
tetra_rotate_ccw
	LDA tetra_piece
	TAY
	PHA
	AND #%00011100
	STA tetra_piece
	PLA
	INC A
	JMP tetra_rotate_both
tetra_rotate_cw
	LDA tetra_piece
	TAY
	PHA
	AND #%00011100
	STA tetra_piece
	PLA
	DEC A
	JMP tetra_rotate_both
tetra_left
	DEC tetra_location
	JSR tetra_clear
	JSR tetra_place
	CMP #$FF ; error
	BEQ tetra_left_error
	RTS
tetra_right
	INC tetra_location
	JSR tetra_clear
	JSR tetra_place
	CMP #$FF ; error
	BEQ tetra_right_error
	RTS
tetra_down_error
	LDA tetra_location
	SEC
	SBC #$10
	STA tetra_location
	JSR tetra_clear
	JSR tetra_place
	JSR tetra_solid
	JSR tetra_lines
	JSR tetra_display
	JSR tetra_draw
	PLA
	PLA
	JMP tetra_start
tetra_left_error
	INC tetra_location
	JSR tetra_clear
	JSR tetra_place
	RTS
tetra_right_error
	DEC tetra_location
	JSR tetra_clear
	JSR tetra_place
	RTS
tetra_rotate_both
	AND #%00000011
	ORA tetra_piece
	STA tetra_piece
	JSR tetra_clear
	JSR tetra_place
	CMP #$FF ; error
	BEQ tetra_rotate_error
	RTS
tetra_rotate_error
	STY tetra_piece
	JSR tetra_clear
	JSR tetra_place
	RTS

tetra_buttons
	LDA joy_buttons
	ROR A
	BCS tetra_buttons_next1
	PHA
	JSR tetra_up
	PLA
tetra_buttons_next1
	ROR A
	BCS tetra_buttons_next2
	PHA
	JSR tetra_down
	PLA
tetra_buttons_next2
	ROR A
	BCS tetra_buttons_next3
	PHA
	JSR tetra_left
	PLA
tetra_buttons_next3
	ROR A
	BCS tetra_buttons_next4
	PHA
	JSR tetra_right
	PLA
tetra_buttons_next4
	ROR A
	BCS tetra_buttons_next5
	PHA
	LDA tetra_joy_prev
	AND #%00010000
	BEQ tetra_buttons_skip_cw
	JSR tetra_rotate_cw
tetra_buttons_skip_cw
	PLA
tetra_buttons_next5
	ROR A
	BCS tetra_buttons_next6
	PHA
	LDA tetra_joy_prev
	AND #%00100000
	BEQ tetra_buttons_skip_ccw
	JSR tetra_rotate_ccw
tetra_buttons_skip_ccw
	PLA
tetra_buttons_next6
	LDA joy_buttons
	STA tetra_joy_prev
	RTS
	

tetra_clear
	PHA
	PHX
	LDX #$00
tetra_clear_loop
	LDA tetra_field,X
	CMP #$FF
	BNE tetra_clear_increment
	STZ tetra_field,X
tetra_clear_increment
	INX
	BNE tetra_clear_loop
	PLX
	PLA
	RTS

tetra_place
	STZ tetra_overscan
	PHX
	PHY
	LDA tetra_piece
	AND #%00011111
	CLC
	ROL A
	ROL A
	ROL A
	ROL A
	TAX
	BCS tetra_place_second
	TXA
	SEC
	SBC #$40 ; removes need for 'zero' placeholder data
	TAX
	LDA #<tetra_piece_data_first
	STA sub_index+1
	LDA #>tetra_piece_data_first
	STA sub_index+2
	JMP tetra_place_ready
tetra_place_second
	LDA #<tetra_piece_data_second
	STA sub_index+1
	LDA #>tetra_piece_data_second
	STA sub_index+2
tetra_place_ready
	LDY tetra_location
	STZ tetra_values+0
	STZ tetra_values+1
tetra_place_loop
	JSR sub_index
	CMP #$00 ; needed
	BEQ tetra_place_skip
	LDA tetra_overscan
	BNE tetra_place_error
	TYA
	AND #%00001111
	CLC
	CMP #$03
	BCC tetra_place_error
	CLC
	CMP #$0D
	BCS tetra_place_error	
	LDA tetra_field,Y
	BEQ tetra_place_write
tetra_place_error
	PLY
	PLX
	LDA #$FF ; error
	RTS
tetra_place_write
	JSR sub_index
	STA tetra_field,Y
tetra_place_skip
	INX
	INY
	INC tetra_values+1
	LDA tetra_values+1
	CMP #$04
	BNE tetra_place_loop
	TYA
	CLC
	ADC #$0C
	ROL tetra_overscan
	TAY
	STZ tetra_values+1
	INC tetra_values+0
	LDA tetra_values+0
	CMP #$04
	BNE tetra_place_loop
	PLY
	PLX
	LDA #$00 ; good
	RTS

tetra_solid
	PHA
	PHX
	LDX #$00
tetra_solid_loop
	LDA tetra_field,X
	CMP #$FF
	BNE tetra_solid_increment
	LDA #tetra_color_fore
	STA tetra_field,X
tetra_solid_increment
	INX
	BNE tetra_solid_loop
	LDA tetra_location
	CLC
	CMP #$0A
	BCC tetra_gameover
	PLX
	PLA
	RTS

tetra_gameover
	
	LDA #$19
	STA printchar_x
	LDA #$1C
	STA printchar_y	
	LDY #$00
tetra_display_loop_reset
	LDA tetra_display_text_reset,Y
	JSR tetra_display_char
	INY
	CPY #$06
	BNE tetra_display_loop_reset

	JSR tetra_input
	CMP #$00
	BEQ tetra_gameover
	CMP #$17
	BEQ tetra_gameover_buttons
	JMP tetra_gameover_exit
tetra_gameover_buttons
	LDA tetra_joy_prev
	CMP #$FF
	BNE tetra_gameover
tetra_gameover_exit
	JMP tetra
	
tetra_input
	LDA joy_buttons
	CMP #$FF
	BNE tetra_input_button
	STA tetra_joy_prev
	JMP tetra_input_key ; jump to tetra_input_none to skip keyboard
tetra_input_button
	LDA #$17 ; check joystick
	JMP tetra_input_both
tetra_input_key
	JSR inputchar
	JSR function_keys
	CMP #$00 ; needed
	BNE tetra_input_both
tetra_input_none
	LDA #$00
tetra_input_both
	RTS


tetra_lines
	STZ tetra_values+2
	PHA
	PHX
	PHY
	LDX #$00
	LDY #$00
tetra_lines_loop
	LDA tetra_field,X
	CMP #$55 ; blue
	BNE tetra_lines_check
	INY
tetra_lines_check
	TXA
	AND #%00001111
	CMP #$0F
	BNE tetra_lines_increment
	CPY #$0A ; 10 columns
	BEQ tetra_lines_remove
	LDY #$00
	JMP tetra_lines_increment
tetra_lines_remove
	INC tetra_values+2
	INC tetra_score_low
	LDA tetra_score_low
	AND #%00001111
	BNE tetra_lines_remove_score
	LDA tetra_speed
	SEC
	SBC #$04 ; adjust as need be
	STA tetra_speed
	INC tetra_score_high
tetra_lines_remove_score
	TXA
	AND #%11110000
	TAX
tetra_lines_remove_loop
	STZ tetra_field,X
	INX
	TXA
	AND #%00001111
	CMP #$0F
	BNE tetra_lines_remove_loop
	PHX
	TXA
	SEC
	SBC #$10
	TAY
tetra_lines_remove_shift
	LDA tetra_field,Y
	STA tetra_field,X
	DEX
	DEY
	BNE tetra_lines_remove_shift
	LDX #$00
tetra_lines_remove_clear
	STZ tetra_field,X
	INX
	TXA
	AND #%00001111
	CMP #$0F
	BNE tetra_lines_remove_clear
	PLX
	LDY #$00
tetra_lines_increment
	INX
	BNE tetra_lines_loop
	LDA tetra_values+2
	BEQ tetra_lines_exit
	CMP #$04
	BNE tetra_lines_exit
	LDA #$FF ; draw
	;JSR easter_egg	
tetra_lines_exit
	PLY
	PLX
	PLA
	RTS

tetra_draw	
	PHA
	PHX
	PHY
	LDA #$08 ; start of playfield
	STA sub_write+1
	LDA #$08
	STA sub_write+2
	LDX #$00
	LDY #$00
tetra_draw_loop
	TXA
	AND #%00001111
	CLC	
	CMP #$03
	BCC tetra_draw_jump
	CLC	
	CMP #$0D
	BCS tetra_draw_jump
	JMP tetra_draw_continue
tetra_draw_jump
	JMP tetra_draw_increment
tetra_draw_continue
	LDA tetra_field,X
	CPY #$00
	BNE tetra_draw_corner1
	AND #tetra_color_fore
	JMP tetra_draw_corner2
tetra_draw_corner1
	AND #tetra_color_fore
tetra_draw_corner2
	JSR sub_write
	INC sub_write+1
	LDA tetra_field,X
	CPY #$00
	BNE tetra_draw_normal
	AND #tetra_color_fore
tetra_draw_normal
	PHX
	LDX #$07 ; change this for width
tetra_draw_normal_loop1
	JSR sub_write
	INC sub_write+1
	DEX
	BNE tetra_draw_normal_loop1
	PLX
	LDA sub_write+1
	CLC
	ADC #$78 ; change this for width
	STA sub_write+1
	LDA tetra_field,X
	AND #tetra_color_fore
	JSR sub_write
	INC sub_write+1
	LDA tetra_field,X
	CPY #$00
	BNE tetra_draw_skip
	AND #tetra_color_fore
tetra_draw_skip
	PHX
	LDX #$07 ; change this for width
tetra_draw_normal_loop2
	JSR sub_write
	INC sub_write+1
	DEX
	BNE tetra_draw_normal_loop2
	PLX
	LDA sub_write+1
	CLC
	ADC #$78 ; change this for width
	STA sub_write+1
	INC sub_write+2
	INY
	CPY #$07 ; change this for height
	BNE tetra_draw_loop
	LDY #$00
	LDA sub_write+2
	SEC
	SBC #$07 ; change this for height
	STA sub_write+2
	LDA sub_write+1
	CLC
	ADC #$08 ; change this for width
	STA sub_write+1
tetra_draw_increment
	INX
	BEQ tetra_draw_exit
	TXA
	AND #%00001111
	BEQ tetra_draw_shift
	JMP tetra_draw_loop
tetra_draw_shift
	LDA #$08 ; start of playfield
	STA sub_write+1
	LDA sub_write+2
	CLC
	ADC #$07 ; change this for height
	STA sub_write+2
	JMP tetra_draw_loop
tetra_draw_exit
	PLY
	PLX
	PLA
	RTS

tetra_display
	PHX
	PHA
	LDA #$19
	STA printchar_x
	LDA #$01
	STA printchar_y
	LDX #$00
tetra_display_loop_level
	LDA tetra_display_text_level,X
	JSR tetra_display_char
	INX
	CPX #$05
	BNE tetra_display_loop_level
	LDA #$19
	STA printchar_x
	LDA #$03
	STA printchar_y
	LDA tetra_score_high
	JSR colornum
	LDA #$19
	STA printchar_x
	LDA #$06
	STA printchar_y
	LDX #$00
tetra_display_loop_lines
	LDA tetra_display_text_lines,X
	JSR tetra_display_char
	INX
	CPX #$05
	BNE tetra_display_loop_lines
	LDA #$19
	STA printchar_x
	LDA #$08
	STA printchar_y
	LDA tetra_score_low
	JSR colornum
	LDA #$19
	STA printchar_x
	LDA #$0B
	STA printchar_y
	LDX #$00
tetra_display_loop_next
	LDA tetra_display_text_next,X
	JSR tetra_display_char
	INX
	CPX #$04
	BNE tetra_display_loop_next
	LDA tetra_piece_next
	AND #%00011100
	CLC
	ROR A
	ROR A
	CMP #$01 ; I
	BNE tetra_display_next1
	LDA #"I"
	JMP tetra_display_exit
tetra_display_next1
	CMP #$02 ; J
	BNE tetra_display_next2
	LDA #"J"
	JMP tetra_display_exit
tetra_display_next2
	CMP #$03 ; L
	BNE tetra_display_next3
	LDA #"L"
	JMP tetra_display_exit
tetra_display_next3
	CMP #$04 ; O
	BNE tetra_display_next4
	LDA #"O"
	JMP tetra_display_exit
tetra_display_next4
	CMP #$05 ; S
	BNE tetra_display_next5
	LDA #"S"
	JMP tetra_display_exit
tetra_display_next5
	CMP #$06 ; T
	BNE tetra_display_next6
	LDA #"T"
	JMP tetra_display_exit
tetra_display_next6
	CMP #$07 ; Z
	BNE tetra_display_exit
	LDA #"Z"
	JMP tetra_display_exit
tetra_display_exit
	PHA
	LDA #$19
	STA printchar_x
	LDA #$0D
	STA printchar_y
	PLA
	JSR colorchar
	PLA
	PLX
	RTS
tetra_display_char
	JSR colorchar
	INC printchar_x
	RTS

tetra_display_text_level
	.BYTE "Level"

tetra_display_text_lines
	.BYTE "Lines"

tetra_display_text_next
	.BYTE "Next"

tetra_display_text_paused
	.BYTE "Paused"

tetra_display_text_reset
	.BYTE "Reset?"


tetra_piece_data_first
;	.BYTE $00,$00,$00,$00
;	.BYTE $00,$00,$00,$00
;	.BYTE $00,$00,$00,$00
;	.BYTE $00,$00,$00,$00
;
;	.BYTE $00,$00,$00,$00
;	.BYTE $00,$00,$00,$00
;	.BYTE $00,$00,$00,$00
;	.BYTE $00,$00,$00,$00
;	
;	.BYTE $00,$00,$00,$00
;	.BYTE $00,$00,$00,$00
;	.BYTE $00,$00,$00,$00
;	.BYTE $00,$00,$00,$00
;
;	.BYTE $00,$00,$00,$00
;	.BYTE $00,$00,$00,$00
;	.BYTE $00,$00,$00,$00
;	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $FF,$FF,$FF,$FF
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $FF,$FF,$FF,$FF
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$FF,$FF
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$FF,$00
	.BYTE $00,$00,$FF,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $FF,$FF,$FF,$00
	.BYTE $00,$00,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$FF
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$FF,$00
	.BYTE $FF,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$FF,$00
	.BYTE $00,$00,$FF,$00

tetra_piece_data_second
	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $FF,$FF,$FF,$00
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $FF,$FF,$FF,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $FF,$00,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $FF,$00,$00,$00
	.BYTE $00,$00,$00,$00
	

colorchar ; 32-column characters in 16-color mode
	PHA
	PHX
	PHY
	PHA
	LDA printchar_x
	CLC
	ROL A
	CLC
	ROL A
	STA printchar_write+1
	LDA printchar_y
	CLC
	ROL A
	CLC
	ROL A
	CLC
	ADC #$08
	STA printchar_write+2
	PLA
	SEC
	SBC #$20
	TAX
	LDA #<key_bitmap
	STA printchar_read+1
	LDA #>key_bitmap
	STA printchar_read+2
colorchar_lookup
	CPX #$00
	BEQ colorchar_found
	DEX
	LDA printchar_read+1
	CLC
	ADC #$10
	STA printchar_read+1
	BNE colorchar_lookup
	INC printchar_read+2
	JMP colorchar_lookup
colorchar_found
	LDX #$00
colorchar_loop
	JSR colorchar_move
	INC printchar_read+1
	INX
	JSR colorchar_move
	INC printchar_read+1
	LDA printchar_write+1
	CLC
	ADC #$7C
	STA printchar_write+1
	BCC colorchar_increment
	INC printchar_write+2
colorchar_increment
	INX
	CPX #$10
	BNE colorchar_loop
	PLY	
	PLX
	PLA
	RTS
colorchar_move ; subroutine
	LDA #%10000000
	STA colorchar_input
colorchar_move_start
	STZ printchar_storage	
	LDA #%11000000
	STA colorchar_output
	LDY #$04
colorchar_move_loop
	JSR printchar_read
	AND colorchar_input
	BEQ colorchar_move_skip
	LDA printchar_storage
	ORA colorchar_output
	STA printchar_storage
colorchar_move_skip
	CLC
	ROR colorchar_input
	CLC
	ROR colorchar_output
	CLC
	ROR colorchar_output
	DEY
	BNE colorchar_move_loop
	LDA printchar_storage
	JSR printchar_write
	INC printchar_write+1
	LDA colorchar_input
	BNE colorchar_move_start
	RTS

colornum ; converts hex to decimal value
	PHY
	PHX
	PHA
	LDX #$00
colornum_100_count
	TAY
	SEC
	SBC #$64 ; 100 in hex
	INX
	BCS colornum_100_count
	DEX
	TXA
	CLC
	ADC #"0"
	JSR colorchar
	INC printchar_x
	TYA
	LDX #$00
colornum_10_count
	TAY
	SEC
	SBC #$0A ; 10 in hex
	INX
	BCS colornum_10_count
	DEX
	TXA
	CLC
	ADC #"0"
	JSR colorchar
	INC printchar_x
	TYA
	CLC
	ADC #"0"
	JSR colorchar
	INC printchar_x
	PLA
	PLX
	PLY
	RTS

	
	.ORG $F000 ; setup

setup
	STZ printchar_inverse ; turn off inverse
	LDA #$FF ; white 
	STA printchar_foreground
	LDA #$00 ; black
	STA printchar_background

	LDA #%10111111 ; PB is mostly output
	STA via_db
	LDA #%00000000 ; set output pins to low
	STA via_pb
	LDA #%00000000 ; PA is all input
	STA via_da
	LDA #%00001110 ; CA2 high, CA1 falling edge
	STA via_pcr
	LDA #%10000010 ; interrupts on CA1
	STA via_ier

	LDA #$4C ; JMPa
	STA vector_irq+0
	LDA #<key_isr
	STA vector_irq+1
	LDA #>key_isr
	STA vector_irq+2

	LDA #$4C ; JMPa
	STA vector_nmi+0
	LDA #<joy_isr
	STA vector_nmi+1
	LDA #>joy_isr
	STA vector_nmi+2

	LDA #$AD ; LDAa
	STA sub_read+0
	STA printchar_read+0
	LDA #$60 ; RTS
	STA sub_read+3
	STA printchar_read+3

	LDA #$BD ; LDAax
	STA sub_index+0
	LDA #$60 ; RTS
	STA sub_index+3

	LDA #$8D ; STAa
	STA sub_write+0
	STA printchar_write+0
	LDA #$60 ; RTS
	STA sub_write+3
	STA printchar_write+3

	LDA #$4C ; JMPa
	STA sub_jump+0

	LDA #$4C ; JMPa
	STA sub_inputchar+0
	LDA #<inputchar
	STA sub_inputchar+1
	LDA #>inputchar
	STA sub_inputchar+2

	LDA #$4C ; JMPa
	STA sub_printchar+0
	LDA #<printchar
	STA sub_printchar+1
	LDA #>printchar
	STA sub_printchar+2

	LDA #$8E ; STXa
	STA sub_printchar_coords+0
	LDA #<printchar_x
	STA sub_printchar_coords+1
	LDA #>printchar_x
	STA sub_printchar_coords+2
	LDA #$8C ; STYa
	STA sub_printchar_coords+3
	LDA #<printchar_y
	STA sub_printchar_coords+4
	LDA #>printchar_y
	STA sub_printchar_coords+5
	LDA #$60 ; RTS
	STA sub_printchar_coords+6

	STZ sub_random_var

	LDX #$10
setup_random_loop
	LDA setup_random_code,X
	STA sub_random,X
	DEX
	CPX #$FF
	BNE setup_random_loop

	JMP setup_done

setup_random_code
	.BYTE $AD
	.WORD sub_random_var
	.BYTE $2A,$18,$2A,$18,$6D
	.WORD sub_random_var
	.BYTE $18,$69,$11,$8D
	.WORD sub_random_var
	.BYTE $60

setup_done
	RTS



	.ORG $F100 ; scratchpad and monitor

scratchpad
	LDA #$E1 ; produces greyscale
	STA $FFFF ; write non-$00 to ROM for 64-column 4-color mode

	LDA #$10 ; cursor
	JSR printchar

scratchpad_loop
	CLC
	JSR sub_random ; helps randomize

	JSR inputchar
	CMP #$00
	BEQ scratchpad_loop

	PHA
	LDA #$10 ; cursor
	JSR printchar
	PLA

	JSR function_keys
	CMP #$1B ; escape
	BEQ scratchpad_escape

	JSR printchar ; print actual character
	LDA #$10 ; cursor
	JSR printchar
	JMP scratchpad_loop

scratchpad_escape
	LDA #$0C ; form feed
	JSR printchar
	LDA #$10 ; cursor
	JSR printchar
	JMP scratchpad_loop

monitor
	LDA #$E1 ; produces greyscale
	STA $FFFF ; write non-$00 to ROM for 64-column 4-color mode

monitor_prompt
	LDA #$5C ; prompt
	JSR printchar
	LDA #$10 ; cursor
	JSR printchar

	STZ monitor_mode
	
	LDX #$40
monitor_clear
	DEX
	STZ monitor_string,X
	CPX #$00
	BNE monitor_clear

monitor_loop
	CLC
	JSR sub_random ; helps randomize
	
	JSR inputchar
	CMP #$00
	BEQ monitor_loop

	CMP #$11 ; arrow up
	BEQ monitor_loop
	CMP #$12 ; arrow down
	BEQ monitor_loop
	CMP #$13 ; arrow left
	BEQ monitor_loop
	CMP #$14 ; arrow right
	BEQ monitor_loop

	PHA
	LDA #$10 ; cursor
	JSR printchar
	PLA

	JSR function_keys
	CMP #$1B ; escape
	BEQ monitor_escape
	CMP #$0D ; return
	BEQ monitor_return
	
	CLC
	CMP #$61 ; lower A
	BCC monitor_loop_print
	CLC
	CMP #$7B ; one past lower Z
	BCS monitor_loop_print
	SEC
	SBC #$20 ; make upper case

monitor_loop_print
	LDX printchar_x
	STA monitor_string,X
	JSR printchar ; print actual character
	LDA #$10 ; cursor
	JSR printchar
	JMP monitor_loop

monitor_escape
	LDA #$0D ; return
	JSR printchar
	JMP monitor_prompt

monitor_return
	JSR printchar ; print return character

	LDY #$00
monitor_run
	JSR inputchar
	CMP #$1B ; escape to break
	BEQ monitor_escape

	LDA monitor_string,Y
	INY
	CPY #$40
	BEQ monitor_escape
	
	CMP #","
	BEQ monitor_addr_one
	CMP #"."
	BEQ monitor_addr_two
	CMP #"<"
	BEQ monitor_addr_three
	CMP #">"
	BEQ monitor_data_one
	CMP #$3A ; colon
	BEQ monitor_write
	CMP #";"
	BEQ monitor_read
	CMP #$22 ; double quotes
	BEQ monitor_literal
	CMP #"'"
	BEQ monitor_char
	CLC
	CMP #$30 ; zero
	BCC monitor_run
	CLC
	CMP #$3A ; one past nine
	BCC monitor_run_hex
	CLC
	CMP #$41 ; A
	BCC monitor_run
	CLC
	CMP #$47 ; one past F
	BCC monitor_run_hex
	CLC
	CMP #$5B ; one past Z
	BCS monitor_run

	JMP monitor_command

monitor_run_hex
	JMP monitor_hex

monitor_addr_one
	LDA #$00
	STA monitor_mode
	JMP monitor_run

monitor_addr_two
	LDA #$04
	STA monitor_mode
	JMP monitor_run

monitor_addr_three
	LDA monitor_values+0
	STA monitor_values+4
	LDA monitor_values+1
	STA monitor_values+5
	LDA #$00
	STA monitor_mode
	JMP monitor_run

monitor_data_one
	LDA monitor_values+0
	STA monitor_values+6
	LDA #$00
	STA monitor_mode
	JMP monitor_run

monitor_write
	LDA monitor_values+0
	STA sub_write+2
	LDA monitor_values+1
	STA sub_write+1
	LDA #$0E
	STA monitor_mode
	JMP monitor_run	

monitor_read
	LDA #$00
	STA monitor_mode
	JSR monitor_single
	JMP monitor_run

monitor_literal
	; what should I do here?
	JMP monitor_run

monitor_char
	INC monitor_mode
	LDA monitor_string,Y
	INY
	CPY #$40
	BNE monitor_char_continue
	JMP monitor_escape
monitor_char_continue
	PHA
	LDA monitor_mode
	CLC
	ROR A
	TAX
	PLA
	STA monitor_values,X
	JMP monitor_increment

monitor_hex
	PHA
	LDA monitor_mode
	AND #%00000001
	BNE monitor_number_nibble
	PLA
	CLC
	CMP #$3A
	BCC monitor_hex_number
	SEC
	SBC #$41
	CLC
	ADC #$0A
	JMP monitor_hex_first
monitor_hex_number
	SEC
	SBC #$30
monitor_hex_first
	CLC
	ROL A
	ROL A
	ROL A
	ROL A
	STA monitor_nibble
	INC monitor_mode
	JMP monitor_run
monitor_number_nibble
	PLA
	CLC
	CMP #$41
	BCS monitor_hex_letter
	SEC
	SBC #$30
	JMP monitor_hex_second
monitor_hex_letter
	SEC
	SBC #$41
	CLC
	ADC #$0A
monitor_hex_second
	ORA monitor_nibble
	PHA
	LDA monitor_mode
	CLC
	ROR A
	TAX
	PLA
	STA monitor_values,X
	JMP monitor_increment

monitor_increment
	LDA monitor_mode
	CLC
	CMP #$0E
	BCS monitor_increment_data
	AND #%00000011
	CMP #%00000011
	BEQ monitor_increment_shift
	INC monitor_mode
	JMP monitor_run
monitor_increment_shift
	LDA monitor_mode
	AND #%11111100
	STA monitor_mode
	JMP monitor_run
monitor_increment_data
	DEC monitor_mode
	LDA monitor_values+7
	JSR sub_write
	INC sub_write+1
	BNE monitor_increment_done
	INC sub_write+2
monitor_increment_done
	JMP monitor_run

monitor_command
	CMP #"L"
	BNE monitor_command_next1
	JMP monitor_list
monitor_command_next1
	CMP #"J"
	BNE monitor_command_next2
	JMP monitor_jump
monitor_command_next2
	CMP #"M"
	BNE monitor_command_next3
	JMP monitor_move
monitor_command_next3
	CMP #"P"
	BNE monitor_command_next4
	JMP monitor_pack
monitor_command_next4
	CMP #"R"
	BNE monitor_command_next5
	JMP monitor_sdcard_read
monitor_command_next5
	CMP #"W"
	BNE monitor_command_next6
	JMP monitor_sdcard_write
monitor_command_next6
	JMP monitor_run

monitor_list	
	LDA monitor_values+0
	STA sub_index+2
	LDA monitor_values+1
	AND #%11110000
	STA sub_index+1	
monitor_list_line
	LDA sub_index+2
	JSR monitor_print
	LDA sub_index+1
	JSR monitor_print
	LDA #$3A ; colon
	JSR printchar
	LDA #" "
	JSR printchar
	LDX #$00
monitor_list_byte
	JSR sub_index
	JSR monitor_print
	INX
	TXA
	AND #%00000001
	BNE monitor_list_skip
	LDA #" "
	JSR printchar
monitor_list_skip
	JSR inputchar
	CMP #$1B ; escape to break
	BEQ monitor_list_done
	CPX #$10
	BNE monitor_list_byte
	LDA #" "
	JSR printchar
	LDX #$00
monitor_list_char
	JSR sub_index
	AND #%01111111 ; don't print inverses
	CLC
	CMP #$20
	BCS monitor_list_next
	LDA #" "  ; replace control characters
monitor_list_next
	JSR printchar
	INX
	JSR inputchar
	CMP #$1B ; escape to break
	BEQ monitor_list_done
	CPX #$10
	BNE monitor_list_char
	LDA sub_index+1
	CLC
	ADC #$10
	STA sub_index+1
	BNE monitor_list_page
	INC sub_index+2
	BEQ monitor_list_done
monitor_list_page
	LDA sub_index+2
	CLC
	CMP monitor_values+2
	BCC monitor_list_continue
	BNE monitor_list_done
	LDA sub_index+1
	CLC
	CMP monitor_values+3
	BCC monitor_list_continue
	BEQ monitor_list_continue
monitor_list_done
	LDA #$0D ; return
	JSR printchar
	JMP monitor_run
monitor_list_continue
	LDA #$0D ; return
	JSR printchar
	JMP monitor_list_line

monitor_jump
	LDA monitor_values+0
	STA sub_jump+2
	LDA monitor_values+1
	STA sub_jump+1
	JSR sub_jump ; expects an RTS eventually
	JMP monitor_run

monitor_move
	LDA monitor_values+0
	STA sub_read+2
	LDA monitor_values+1
	STA sub_read+1
	LDA monitor_values+4
	STA sub_write+2
	LDA monitor_values+5
	STA sub_write+1
monitor_move_loop
	JSR inputchar
	CMP #$1B ; escape to break
	BEQ monitor_move_done
	JSR sub_read
	JSR sub_write
	INC sub_read+1
	BNE monitor_move_skip1
	INC sub_read+2
monitor_move_skip1
	INC sub_write+1
	BNE monitor_move_skip2
	INC sub_write+2
monitor_move_skip2
	LDA sub_read+2
	CLC
	CMP monitor_values+2
	BCC monitor_move_loop
	LDA sub_read+1
	CLC
	CMP monitor_values+3
	BCC monitor_move_loop
	JSR sub_read
	JSR sub_write
monitor_move_done
	JMP monitor_run

monitor_pack
	LDA monitor_values+0
	STA sub_write+2
	LDA monitor_values+1
	STA sub_write+1
monitor_pack_loop
	JSR inputchar
	CMP #$1B ; escape to break
	BEQ monitor_pack_done
	LDA monitor_values+6
	JSR sub_write
	INC sub_write+1
	BNE monitor_pack_skip
	INC sub_write+2
monitor_pack_skip
	LDA sub_write+2
	CLC
	CMP monitor_values+2
	BCC monitor_pack_loop
	LDA sub_write+1
	CLC
	CMP monitor_values+3
	BCC monitor_pack_loop
	LDA monitor_values+6
	JSR sub_write
monitor_pack_done
	JMP monitor_run

monitor_sdcard_read
;	JSR monitor_sdcard_initialize
;	JSR sdcard_readblock
;	CMP #$00
;	BEQ monitor_sdcard_error
	JMP monitor_run

monitor_sdcard_write
;	JSR monitor_sdcard_initialize
;	JSR sdcard_writeblock
;	CMP #$00
;	BEQ monitor_sdcard_error
	JMP monitor_run

monitor_sdcard_initialize
;	JSR sdcard_initialize
;	CMP #$00
;	BEQ monitor_sdcard_error
;	LDY monitor_values+4
;	LDX monitor_values+5
;	LDA monitor_values+0
;	STA sdcard_block+1
;	LDA monitor_values+1
;	STA sdcard_block+0
;	RTS

monitor_sdcard_error
;	LDA #"?"
;	JSR printchar
;	LDA #$0D ; return
;	JSR printchar
;	JMP monitor_run

monitor_print ; subroutine
	PHA
	PHA	
	AND #%11110000
	CLC
	ROR A
	ROR A
	ROR A
	ROR A
	CMP #$0A
	BCC monitor_print_skip1
	SEC
	SBC #$0A	
	CLC
	ADC #$41
	JSR printchar
	JMP monitor_print_skip2
monitor_print_skip1
	CLC
	ADC #$30
	JSR printchar
monitor_print_skip2
	PLA
	AND #%00001111
	CLC
	CMP #$0A
	BCC monitor_print_skip3
	SEC
	SBC #$0A	
	CLC
	ADC #$41
	JSR printchar
	PLA
	RTS
monitor_print_skip3
	CLC
	ADC #$30
	JSR printchar
	PLA
	RTS

monitor_single ; subroutine
	PHA
	LDA monitor_values+0
	JSR monitor_print
	STA sub_read+2
	LDA monitor_values+1
	JSR monitor_print
	STA sub_read+1
	LDA #$3A ; colon
	JSR printchar
	LDA #" "
	JSR printchar
	JSR sub_read
	JSR monitor_print
	LDA #$0D ; return
	JSR printchar
	PLA
	RTS	


	.ORG $F500 ; inputchar and printchar

inputchar
	PHY
	PHX
	LDA #$00
	LDX key_read
	CPX key_write
	BEQ inputchar_exit
	INC key_read
	LDA key_array,X
	CMP #$F0 ; release
	BEQ inputchar_release
	CMP #$E0 ; extended
	BEQ inputchar_extended
	CMP #ps2_shift_left
	BEQ inputchar_shift
	CMP #ps2_shift_right
	BEQ inputchar_shift
	CMP #ps2_capslock
	BEQ inputchar_capslock
	CMP #ps2_alt
	BEQ inputchar_altcontrol
	CMP #ps2_control
	BEQ inputchar_altcontrol
	LDY key_release
	CPY #$00
	BNE inputchar_ignore
	CMP #ps2_slash
	BNE inputchar_continue
	LDY key_extended
	CPY #$00
	BNE inputchar_skip
inputchar_continue
	CLC
	ADC key_extended
	STZ key_extended
	CLC
	ADC key_shift
	CLC
	ADC key_capslock
inputchar_skip
	TAX
	LDA key_conversion,X
	JMP inputchar_exit
inputchar_exit
	PLX
	PLY
	RTS
inputchar_release
	LDA #$80
	STA key_release
	LDA #$00
	JMP inputchar_exit
inputchar_extended
	LDA #$80
	STA key_extended
	LDA #$00
	JMP inputchar_exit
inputchar_shift
	LDA key_release
	CLC
	ADC #$80
	STA key_shift
	JMP inputchar_ignore
inputchar_capslock
	LDA key_release
	BNE inputchar_ignore
	LDA key_capslock
	CLC
	ADC #$80
	STA key_capslock
	JMP inputchar_ignore
inputchar_altcontrol
	LDA key_release
	CLC
	ADC #$80
	STA key_alt_control
	JMP inputchar_ignore
inputchar_ignore
	STZ key_release
	STZ key_extended
	LDA #$00
	JMP inputchar_exit

printchar
	PHA
	PHY
	PHX
	LDY #$00
	CLC
	CMP #$80
	BCC printchar_lower
	LDY #$80
	AND #%01111111
printchar_lower
	PHA
	CLC
	CMP #$20
	BCC printchar_control
	JMP printchar_normal
printchar_control ; control characters
	CMP #$08 ; backspace
	BEQ printchar_backspace
	CMP #$09 ; tab
	BEQ printchar_tab
	CMP #$10 ; data link, used for cursor
	BEQ printchar_cursor
	CMP #$0A ; line feed
	BEQ printchar_linefeed
	CMP #$0C ; form feed
	BEQ printchar_formfeed
	CMP #$0D ; carriage return
	BEQ printchar_return
	CMP #$11 ; arrow up
	BEQ printchar_arrowup
	CMP #$12 ; arrow down
	BEQ printchar_arrowdown
	CMP #$13 ; arrow_left
	BEQ printchar_arrowleft
	CMP #$14 ; arrow_right
	BEQ printchar_arrowright
	JMP printchar_exit
printchar_backspace
	LDA printchar_x
	CMP #$00
	BEQ printchar_exit
	DEC printchar_x
	JMP printchar_exit
printchar_tab
	LDA printchar_x
	CMP #$3F
	BEQ printchar_exit
	INC printchar_x
	JMP printchar_exit
printchar_cursor
	LDY #$FF
	LDA #$00
	JMP printchar_normal
printchar_linefeed
	JMP printchar_scroll
printchar_formfeed
	JMP printchar_clearscreen
printchar_return
	STZ printchar_x
	INC printchar_y
	LDA printchar_y
	CLC
	CMP #$1E
	BCC printchar_exit
	STZ printchar_x
	LDA #$1D
	STA printchar_y
	JMP printchar_scroll
printchar_arrowup
	LDA printchar_y
	CMP #$00
	BEQ printchar_exit
	DEC printchar_y
	JMP printchar_exit
printchar_arrowdown
	LDA printchar_y
	CMP #$1D
	BEQ printchar_exit
	INC printchar_y
	JMP printchar_exit
printchar_arrowleft
	LDA printchar_x
	CMP #$00
	BEQ printchar_exit
	DEC printchar_x
	JMP printchar_exit
printchar_arrowright
	LDA printchar_x
	CMP #$3F
	BEQ printchar_exit
	INC printchar_x
	JMP printchar_exit
printchar_exit
	PLA
	PLX
	PLY
	PLA
	RTS
printchar_normal ; normal characters
	LDA printchar_x
	CLC
	ROL A
	STA printchar_write+1
	LDA printchar_y
	CLC
	ROL A
	CLC
	ROL A
	CLC
	ADC #$08
	STA printchar_write+2
	PLA
	PHA
	SEC
	SBC #$20
	TAX
	LDA #<key_bitmap
	STA printchar_read+1
	LDA #>key_bitmap
	STA printchar_read+2
printchar_lookup
	CPX #$00
	BEQ printchar_found
	DEX
	LDA printchar_read+1
	CLC
	ADC #$10
	STA printchar_read+1
	BNE printchar_lookup
	INC printchar_read+2
	JMP printchar_lookup
printchar_found
	LDX #$00
printchar_loop
	JSR printchar_move
	INC printchar_read+1
	INC printchar_write+1
	INX
	JSR printchar_move
	INC printchar_read+1
	LDA printchar_write+1
	CLC
	ADC #$7F
	STA printchar_write+1
	BCC printchar_increment
	INC printchar_write+2
printchar_increment
	INX
	CPX #$10
	BNE printchar_loop
	CPY #$FF
	BEQ printchar_exit
	INC printchar_x
	LDA printchar_x
	CMP #$40
	BNE printchar_exit
	STZ printchar_x
	INC printchar_y
	LDA printchar_y
	CLC
	CMP #$1E
	BCS printchar_last
	JMP printchar_exit
printchar_last
	STZ printchar_x
	LDA #$1D
	STA printchar_y
	JMP printchar_scroll
printchar_move ; subroutine
	CPY #$00
	BEQ printchar_move_original
	CPY #$80
	BEQ printchar_move_inverted
	LDA printchar_write+1
	STA printchar_read+1
	LDA printchar_write+2
	STA printchar_read+2
	JSR printchar_read
	EOR #$FF
	JSR printchar_write
	RTS
printchar_move_original
	JSR printchar_read
	PHA
	EOR printchar_inverse
	AND printchar_foreground
	STA printchar_storage
	PLA
	EOR #$FF
	EOR printchar_inverse
	AND printchar_background
	ORA printchar_storage
	JSR printchar_write
	RTS
printchar_move_inverted
	JSR printchar_read
	PHA
	EOR #$FF
	EOR printchar_inverse
	AND printchar_foreground
	STA printchar_storage
	PLA
	EOR printchar_inverse
	AND printchar_background
	ORA printchar_storage
	JSR printchar_write
	RTS
printchar_scroll
	LDY #$08 ; start of screen
	LDX #$00
printchar_scroll_loop
	STX printchar_read+1
	TYA
	CLC
	ADC #$04 ; height of characters
	STA printchar_read+2
	STX printchar_write+1
	STY printchar_write+2
	JSR printchar_read
	CLC
	CPY #$7C ; last line
	BCC printchar_scroll_next
	LDA printchar_inverse
	AND printchar_foreground
	STA printchar_storage
	LDA printchar_inverse
	EOR #$FF
	AND printchar_background
	ORA printchar_storage
printchar_scroll_next
	JSR printchar_write
	INX
	BNE printchar_scroll_loop
	INY
	CPY #$80 ; end of screen
	BNE printchar_scroll_loop
	JMP printchar_exit
printchar_clearscreen
	LDA printchar_inverse ; clear color
	AND printchar_foreground
	STA printchar_storage
	LDA printchar_inverse
	EOR #$FF
	AND printchar_background
	ORA printchar_storage
	LDY #$08 ; start of screen
	LDX #$00
printchar_clearscreen_loop
	STX printchar_write+1
	STY printchar_write+2
	JSR printchar_write
	INX
	BNE printchar_clearscreen_loop
	INY
	CPY #$80 ; end of screen
	BNE printchar_clearscreen_loop
	STZ printchar_x
	STZ printchar_y
	JMP printchar_exit


	.ORG $F800 ; key tables

; converts PS/2 codes to ASCII
; 256 bytes
key_conversion
	.BYTE $00,$16,$0C,$0F,$1E,$1C,$1D,$15
	.BYTE $00,$18,$07,$0E,$1F,$09,$60,$00
	.BYTE $00,$00,$00,$00,$00,$71,$31,$00
	.BYTE $00,$00,$7A,$73,$61,$77,$32,$00
	.BYTE $00,$63,$78,$64,$65,$34,$33,$00
	.BYTE $00,$20,$76,$66,$74,$72,$35,$00
	.BYTE $00,$6E,$62,$68,$67,$79,$36,$00
	.BYTE $00,$00,$6D,$6A,$75,$37,$38,$00
	.BYTE $00,$2C,$6B,$69,$6F,$30,$39,$00
	.BYTE $00,$2E,$2F,$6C,$3B,$70,$2D,$00
	.BYTE $00,$00,$27,$00,$5B,$3D,$00,$00
	.BYTE $00,$00,$0D,$5D,$00,$5C,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$08,$00
	.BYTE $00,$31,$00,$34,$37,$00,$00,$00
	.BYTE $30,$2E,$32,$35,$36,$38,$1B,$00
	.BYTE $19,$2B,$33,$2D,$2A,$39,$00,$00

	.BYTE $00,$16,$0C,$0F,$1E,$1C,$1D,$15
	.BYTE $00,$18,$07,$0E,$1F,$09,$7E,$00
	.BYTE $00,$00,$00,$00,$00,$51,$21,$00
	.BYTE $00,$00,$5A,$53,$41,$57,$40,$00
	.BYTE $00,$43,$58,$44,$45,$24,$23,$00
	.BYTE $00,$20,$56,$46,$54,$52,$25,$00
	.BYTE $00,$4E,$42,$48,$47,$59,$5E,$00
	.BYTE $00,$00,$4D,$4A,$55,$26,$2A,$00
	.BYTE $00,$3C,$4B,$49,$4F,$29,$28,$00
	.BYTE $00,$3E,$3F,$4C,$3A,$50,$5F,$00
	.BYTE $00,$00,$22,$00,$7B,$2B,$00,$00
	.BYTE $00,$00,$0D,$7D,$00,$7C,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$08,$00
	.BYTE $00,$03,$00,$13,$02,$00,$00,$00
	.BYTE $1A,$7F,$12,$35,$14,$11,$1B,$00
	.BYTE $19,$2B,$04,$2D,$2A,$01,$00,$00

; character bitmap for each ASCII character
; ~2K version for 64-columns
key_bitmap
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $0F,$00,$3F,$C0,$3F,$C0,$3F,$C0
	.BYTE $0F,$00,$00,$00,$0F,$00,$00,$00
	.BYTE $0C,$30,$30,$C0,$3C,$F0,$3C,$F0
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $3C,$F0,$FF,$FC,$3C,$F0,$3C,$F0
	.BYTE $3C,$F0,$FF,$FC,$3C,$F0,$00,$00
	.BYTE $03,$00,$3F,$FC,$F3,$00,$3F,$F0
	.BYTE $03,$3C,$FF,$F0,$03,$00,$00,$00
	.BYTE $30,$0C,$CC,$3C,$30,$F0,$03,$C0
	.BYTE $0F,$30,$3C,$CC,$F0,$30,$00,$00
	.BYTE $3F,$00,$F3,$C0,$3F,$00,$F3,$CC
	.BYTE $F0,$FC,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $0F,$00,$0F,$00,$03,$00,$0C,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $03,$F0,$0F,$00,$3C,$00,$3C,$00
	.BYTE $3C,$00,$0F,$00,$03,$F0,$00,$00
	.BYTE $3F,$00,$03,$C0,$00,$F0,$00,$F0
	.BYTE $00,$F0,$03,$C0,$3F,$00,$00,$00
	.BYTE $00,$00,$00,$00,$3C,$F0,$0F,$C0
	.BYTE $3C,$F0,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$03,$00,$03,$00
	.BYTE $3F,$F0,$03,$00,$03,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$0F,$00
	.BYTE $0F,$00,$03,$00,$0C,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $3F,$F0,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$0F,$00,$0F,$00,$00,$00
	.BYTE $00,$30,$00,$F0,$03,$C0,$0F,$00
	.BYTE $3C,$00,$F0,$00,$C0,$00,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$FC,$F3,$3C
	.BYTE $FC,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $FF,$C0,$0F,$C0,$0F,$C0,$0F,$C0
	.BYTE $0F,$C0,$0F,$C0,$FF,$FC,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$00,$F0,$0F,$C0
	.BYTE $3C,$00,$F0,$00,$FF,$FC,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$00,$3C,$0F,$F0
	.BYTE $00,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $03,$FC,$0F,$3C,$3C,$3C,$F0,$3C
	.BYTE $FF,$FC,$00,$3C,$00,$3C,$00,$00
	.BYTE $FF,$FC,$F0,$00,$FF,$F0,$00,$3C
	.BYTE $00,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$00,$FF,$F0
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $FF,$FC,$F0,$3C,$00,$F0,$03,$C0
	.BYTE $0F,$00,$3C,$00,$F0,$00,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$3C,$3F,$F0
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$3C,$3F,$FC
	.BYTE $00,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $00,$00,$0F,$00,$00,$00,$00,$00
	.BYTE $00,$00,$0F,$00,$00,$00,$00,$00
	.BYTE $00,$00,$0F,$00,$00,$00,$00,$00
	.BYTE $0F,$00,$0F,$00,$3C,$00,$00,$00
	.BYTE $00,$00,$00,$00,$03,$F0,$0F,$C0
	.BYTE $3F,$00,$0F,$C0,$03,$F0,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$3F,$F0
	.BYTE $00,$00,$3F,$F0,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$00,$0F,$C0
	.BYTE $03,$F0,$0F,$C0,$3F,$00,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$00,$3C,$0F,$F0
	.BYTE $0F,$00,$00,$00,$0F,$00,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F3,$3C,$F3,$3C
	.BYTE $F3,$F0,$F0,$00,$3F,$F0,$00,$00
	.BYTE $0F,$C0,$3C,$F0,$F0,$3C,$F0,$3C
	.BYTE $FF,$FC,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $FF,$F0,$F0,$3C,$F0,$3C,$FF,$F0
	.BYTE $F0,$3C,$F0,$3C,$FF,$F0,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$00,$F0,$00
	.BYTE $F0,$00,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $FF,$C0,$F0,$F0,$F0,$3C,$F0,$3C
	.BYTE $F0,$3C,$F0,$F0,$FF,$C0,$00,$00
	.BYTE $FF,$FC,$F0,$00,$F0,$00,$FF,$C0
	.BYTE $F0,$00,$F0,$00,$FF,$FC,$00,$00
	.BYTE $FF,$FC,$F0,$00,$F0,$00,$FF,$C0
	.BYTE $F0,$00,$F0,$00,$F0,$00,$00,$00
	.BYTE $3F,$FC,$F0,$00,$F0,$00,$F3,$FC
	.BYTE $F0,$3C,$F0,$3C,$3F,$FC,$00,$00
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$FF,$FC
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $FF,$FC,$0F,$C0,$0F,$C0,$0F,$C0
	.BYTE $0F,$C0,$0F,$C0,$FF,$FC,$00,$00
	.BYTE $03,$FC,$00,$3C,$00,$3C,$00,$3C
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $F0,$3C,$F0,$F0,$F3,$C0,$FF,$00
	.BYTE $F3,$C0,$F0,$F0,$F0,$3C,$00,$00
	.BYTE $F0,$00,$F0,$00,$F0,$00,$F0,$00
	.BYTE $F0,$00,$F0,$00,$FF,$FC,$00,$00
	.BYTE $F0,$3C,$FC,$FC,$FF,$FC,$F3,$3C
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $F0,$3C,$FC,$3C,$FF,$3C,$F3,$FC
	.BYTE $F0,$FC,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$3C,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $FF,$F0,$F0,$3C,$F0,$3C,$FF,$F0
	.BYTE $F0,$00,$F0,$00,$F0,$00,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$3C,$F0,$3C
	.BYTE $F3,$FC,$F0,$F0,$3F,$CC,$00,$00
	.BYTE $FF,$F0,$F0,$3C,$F0,$3C,$FF,$F0
	.BYTE $F3,$C0,$F0,$F0,$F0,$3C,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$00,$3F,$F0
	.BYTE $00,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $FF,$FC,$0F,$C0,$0F,$C0,$0F,$C0
	.BYTE $0F,$C0,$0F,$C0,$0F,$C0,$00,$00
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$F0,$3C
	.BYTE $3C,$F0,$0F,$C0,$03,$00,$00,$00
	.BYTE $F0,$3C,$F0,$3C,$F3,$3C,$FF,$FC
	.BYTE $FC,$FC,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $F0,$3C,$FC,$FC,$3F,$F0,$0F,$C0
	.BYTE $3F,$F0,$FC,$FC,$F0,$3C,$00,$00
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$3F,$F0
	.BYTE $0F,$C0,$0F,$C0,$0F,$C0,$00,$00
	.BYTE $FF,$FC,$00,$FC,$03,$F0,$0F,$C0
	.BYTE $3F,$00,$FC,$00,$FF,$FC,$00,$00
	.BYTE $3F,$F0,$3C,$00,$3C,$00,$3C,$00
	.BYTE $3C,$00,$3C,$00,$3F,$F0,$00,$00
	.BYTE $30,$00,$3C,$00,$0F,$00,$03,$C0
	.BYTE $00,$F0,$00,$3C,$00,$0C,$00,$00
	.BYTE $3F,$F0,$00,$F0,$00,$F0,$00,$F0
	.BYTE $00,$F0,$00,$F0,$3F,$F0,$00,$00
	.BYTE $03,$00,$0F,$C0,$3C,$F0,$F0,$3C
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$FF,$FC,$00,$00
	.BYTE $0C,$00,$03,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$F0,$00,$3C
	.BYTE $3F,$FC,$F0,$3C,$3F,$FC,$00,$00
	.BYTE $F0,$00,$F0,$00,$FF,$F0,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$FF,$F0,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$F0,$F0,$3C
	.BYTE $F0,$00,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $00,$3C,$00,$3C,$3F,$FC,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$3F,$FC,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$F0,$F0,$3C
	.BYTE $FF,$FC,$F0,$00,$3F,$F0,$00,$00
	.BYTE $0F,$F0,$0F,$00,$FF,$FC,$0F,$00
	.BYTE $0F,$00,$0F,$00,$0F,$00,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$FC,$F0,$3C
	.BYTE $3F,$FC,$00,$3C,$3F,$F0,$00,$00
	.BYTE $F0,$00,$F0,$00,$FF,$F0,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $03,$C0,$00,$00,$3F,$C0,$03,$C0
	.BYTE $03,$C0,$03,$C0,$FF,$FC,$00,$00
	.BYTE $00,$3C,$00,$00,$00,$3C,$00,$3C
	.BYTE $00,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $F0,$00,$F0,$00,$F0,$3C,$F0,$F0
	.BYTE $FF,$C0,$F0,$F0,$F0,$3C,$00,$00
	.BYTE $F0,$00,$F0,$00,$F0,$00,$F0,$00
	.BYTE $F0,$00,$3F,$00,$03,$FC,$00,$00
	.BYTE $00,$00,$00,$00,$FF,$F0,$F3,$3C
	.BYTE $F3,$3C,$F3,$3C,$F3,$3C,$00,$00
	.BYTE $00,$00,$00,$00,$FF,$F0,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$F0,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $00,$00,$00,$00,$FF,$F0,$F0,$3C
	.BYTE $FF,$F0,$F0,$00,$F0,$00,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$FC,$F0,$3C
	.BYTE $3F,$FC,$00,$3C,$00,$3C,$00,$00
	.BYTE $00,$00,$00,$00,$F3,$F0,$FC,$3C
	.BYTE $F0,$00,$F0,$00,$F0,$00,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$FC,$F0,$00
	.BYTE $FF,$FC,$00,$3C,$FF,$F0,$00,$00
	.BYTE $0F,$00,$0F,$00,$FF,$FC,$0F,$00
	.BYTE $0F,$00,$0F,$00,$0F,$FC,$00,$00
	.BYTE $00,$00,$00,$00,$F0,$3C,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $00,$00,$00,$00,$F0,$3C,$F0,$3C
	.BYTE $3C,$F0,$0F,$C0,$03,$00,$00,$00
	.BYTE $00,$00,$00,$00,$F0,$3C,$F3,$3C
	.BYTE $F3,$3C,$FF,$FC,$3C,$F0,$00,$00
	.BYTE $00,$00,$00,$00,$FC,$FC,$3F,$F0
	.BYTE $0F,$C0,$3F,$F0,$FC,$FC,$00,$00
	.BYTE $00,$00,$00,$00,$F0,$3C,$F0,$3C
	.BYTE $3C,$F0,$0F,$C0,$FF,$00,$00,$00
	.BYTE $00,$00,$00,$00,$FF,$FC,$03,$F0
	.BYTE $0F,$C0,$3F,$00,$FF,$FC,$00,$00
	.BYTE $03,$F0,$0F,$00,$0F,$00,$3F,$00
	.BYTE $0F,$00,$0F,$00,$03,$F0,$00,$00
	.BYTE $0F,$00,$0F,$00,$0F,$00,$0F,$00
	.BYTE $0F,$00,$0F,$00,$0F,$00,$00,$00
	.BYTE $3F,$00,$03,$C0,$03,$C0,$03,$F0
	.BYTE $03,$C0,$03,$C0,$3F,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$3F,$3C
	.BYTE $F3,$3C,$F3,$F0,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00


	.ORG $FF00 ; keyboard interrupt code and joystick poll code

key_init
	STZ key_write
	STZ key_read
	STZ key_data
	STZ key_counter
	STZ key_release
	STZ key_extended
	STZ key_shift
	STZ key_capslock
	STZ key_alt_control

	CLI

	RTS

; upon keystroke
key_isr
	PHA
	LDA via_ifr
	AND #%00000010				; check if it was CA1
	BEQ key_isr_exit			; if not, just exit (for now)
	LDA via_pa
	AND #%10000000				; read PA7
	CLC	
	ROR key_data				; shift key_code
	CLC
	ADC key_data				; add the PA7 bit into key_code
	STA key_data
	INC key_counter				; increment key_counter
	LDA key_counter
	CMP #$09 ; data ready			; 1 start bit, 8 data bits = 9 bits until real data ready
	BNE key_isr_check
	LDA key_data
	PHX
	LDX key_write
	STA key_array,X				; put the key code into key_array
	INC key_write
	PLX
	PLA
	RTI					; and exit
key_isr_check
	CMP #$0B ; reset counter		; 1 start bit, 8 data bits, 1 parity bit, 1 stop bit = 11 bits to complete a full signal
	BEQ key_isr_reset
	PLA
	RTI					; and exit
key_isr_reset
	STZ key_counter				; reset the counter
key_isr_exit
	PLA
	RTI

joy_init ; use at beginning
	PHA
	LDA #$FF
	STA joy_buttons
	LDA via_pb
	ORA #joy_select ; now leave it high always for speed sake
	STA via_pb 
	PLA
	RTS

joy_isr ; /NMI connected to V-SYNC, so this fires 60 times per second
	PHA
	INC clock_low
	BNE joy_isr_clock
	INC clock_high
joy_isr_clock
	LDA via_pah ; read PA without handshake
	ORA #%11000000 ; ignore last two buttons for speed sake
	STA joy_buttons
	PLA
	RTI






;	STZ joy_ready
;	LDA joy_enable
;	BNE joy_isr_error
;	LDA via_pa
;	AND #%00001100
;	BNE joy_isr_error
;joy_isr_continue
;	LDA via_pa
;	AND #%00110000
;	CLC
;	ROL A
;	ROL A
;	STA joy_buttons
;	LDA via_pb
;	ORA #joy_select
;	STA via_pb
;	LDA via_pa
;	AND #%00111111
;	ORA joy_buttons
;	STA joy_buttons
;	PHX
;	LDX #$03
;	LDA via_pb
;joy_isr_loop
;	AND #joy_select_inv
;	STA via_pb
;	ORA #joy_select
;	STA via_pb
;	DEX
;	BNE joy_isr_loop
;	PLX
;	LDA via_pb
;	AND #joy_select_inv
;	STA via_pb
;joy_isr_exit
;	PLA
;	RTI
;joy_isr_error
;	LDA #$FF
;	STA joy_buttons
;	PLA
;	RTI


	.ORG $FFFA ; vectors

	.WORD vector_nmi
	.WORD vector_reset
	.WORD vector_irq









	
	
