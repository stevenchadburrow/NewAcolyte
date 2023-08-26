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
ps2_space		.EQU $29
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
via_t1cl		.EQU via+$04
via_t1ch		.EQU via+$05
via_acr			.EQU via+$0B
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

key_write		.EQU $0280
key_read		.EQU $0281
key_data		.EQU $0282
key_counter		.EQU $0283
key_release		.EQU $0284
key_extended		.EQU $0285
key_shift		.EQU $0286
key_capslock		.EQU $0287
key_alt_control		.EQU $0288

mouse_buttons		.EQU $0289
mouse_pos_x		.EQU $028A
mouse_pos_y		.EQU $028B
mouse_prev_buttons	.EQU $028C
mouse_prev_x		.EQU $028D
mouse_prev_y		.EQU $028E
mouse_data		.EQU $028F
mouse_counter		.EQU $0290
mouse_state		.EQU $0291

joy_buttons		.EQU $0292

tetra_score_low		.EQU $0293
tetra_score_high	.EQU $0294
tetra_piece		.EQU $0295
tetra_piece_next	.EQU $0296
tetra_location		.EQU $0297
tetra_speed		.EQU $0298
tetra_overscan		.EQU $0299
tetra_joy_prev		.EQU $029A
tetra_values		.EQU $029B ; 3 bytes

monitor_mode		.EQU $029E
monitor_nibble		.EQU $029F
monitor_values		.EQU $02A0 ; 8 bytes long

sub_jump		.EQU $02A8 ; 3 bytes long
sub_random_var		.EQU $02AB
sub_read		.EQU $02AC ; 4 bytes long
sub_index		.EQU $02B0 ; 4 bytes long
sub_write		.EQU $02B4 ; 4 bytes long

vector_irq		.EQU $02B8 ; 4 bytes long
vector_nmi		.EQU $02BC ; 4 bytes long

sub_inputchar		.EQU $02C0 ; 4 bytes long
sub_printchar		.EQU $02C4 ; 4 bytes long

printchar_x		.EQU $02C8 ; from $00 to $3F
printchar_y		.EQU $02C9 ; from $00 to $1D
printchar_foreground	.EQU $02CA ; either $00, $55, $AA, or $FF
printchar_background	.EQU $02CB ; either $00, $55, $AA, or $FF
printchar_inverse	.EQU $02CC ; either $00 or $FF
printchar_storage	.EQU $02CD
colorchar_input		.EQU $02CE
colorchar_output	.EQU $02CF
printchar_read		.EQU $02D0 ; 4 bytes long
printchar_write		.EQU $02D4 ; 4 bytes long

sub_sdcard_initialize	.EQU $02D8 ; 4 bytes
sub_sdcard_readblock	.EQU $02DC ; 4 bytes
sub_sdcard_writeblock	.EQU $02E0 ; 4 bytes

sdcard_block		.EQU $02E4 ; 2 bytes 

basic_line_low		.EQU $02E6
basic_line_high		.EQU $02E7
basic_value1_low	.EQU $02E8
basic_value1_high	.EQU $02E9
basic_value2_low	.EQU $02EA
basic_value2_high	.EQU $02EB
basic_value3_low	.EQU $02EC
basic_value3_high	.EQU $02ED
basic_value4_low	.EQU $02EE
basic_value4_high	.EQU $02EF
basic_character		.EQU $02F0
basic_operator		.EQU $02F1
basic_wait_end		.EQU $02F2
basic_wait_delete	.EQU $02F3

scratchpad_lastchar	.EQU $02F4

function_mode		.EQU $02F5

defense_joy_prev	.EQU $02F6
defense_key_space	.EQU $02F7
defense_key_up		.EQU $02F8
defense_key_down	.EQU $02F9
defense_key_left	.EQU $02FA
defense_key_right	.EQU $02FB
defense_pop_value	.EQU $02FC
defense_score_value	.EQU $02FD

clock_low		.EQU $02FE
clock_high		.EQU $02FF

sub_random		.EQU $0300 ; 18 bytes long

basic_variables_low	.EQU $0312 ; 26 bytes
basic_variables_high	.EQU $032C ; 26 bytes

basic_keys		.EQU $0346 ; 16 bytes long
basic_keys_plus_one	.EQU $0347

defense_ammo_value	.EQU $0356
defense_dist_value	.EQU $0357
defense_enemy_value	.EQU $0358
defense_stop_value	.EQU $0359
defense_round_value	.EQU $035A
defense_enemy_constant	.EQU $035B
defense_speed_constant	.EQU $035C
defense_random_constant	.EQU $035D
defense_ammo_constant	.EQU $035E
defense_paused		.EQU $035F

; unused

command_string		.EQU $03C0 ; 64 bytes long

tetra_field		.EQU $0400 ; 256 bytes long

defense_missile_x	.EQU $0400 ; 16 bytes long
defense_missile_y	.EQU $0410 ; 16 bytes long
defense_target_x	.EQU $0420 ; 16 bytes long
defense_target_y	.EQU $0430 ; 16 bytes long
defense_slope_x		.EQU $0440 ; 16 bytes long
defense_slope_y		.EQU $0450 ; 16 bytes long
defense_count_x		.EQU $0460 ; 16 bytes long
defense_count_y		.EQU $0470 ; 16 bytes long
defense_prev1_x		.EQU $0480 ; 8 bytes long
defense_prev1_y		.EQU $0488 ; 8 bytes long
defense_prev2_x		.EQU $0490 ; 8 bytes long
defense_prev2_y		.EQU $0498 ; 8 bytes long
defense_prev3_x		.EQU $04A0 ; 8 bytes long
defense_prev3_y		.EQU $04A8 ; 8 bytes long
defense_prev4_x		.EQU $04B0 ; 8 bytes long
defense_prev4_y		.EQU $04B8 ; 8 bytes long
defense_prev5_x		.EQU $04C0 ; 8 bytes long
defense_prev5_y		.EQU $04C8 ; 8 bytes long
defense_prev6_x		.EQU $04D0 ; 8 bytes long
defense_prev6_y		.EQU $04D8 ; 8 bytes long
defense_prev7_x		.EQU $04E0 ; 8 bytes long
defense_prev7_y		.EQU $04E8 ; 8 bytes long
defense_prev8_x		.EQU $04F0 ; 8 bytes long
defense_prev8_y		.EQU $04F8 ; 8 bytes long

intruder_player_pos	.EQU $0400 ; reusing memory location
intruder_player_lives	.EQU $0401
intruder_missile_pos_x	.EQU $0402
intruder_missile_pos_y	.EQU $0403
intruder_enemy_fall	.EQU $0404
intruder_enemy_pos_x	.EQU $0405
intruder_enemy_pos_y	.EQU $0406
intruder_enemy_dir_x	.EQU $0407
intruder_enemy_speed	.EQU $0408
intruder_enemy_miss_s	.EQU $0409
intruder_enemy_miss_x	.EQU $040A
intruder_enemy_miss_y	.EQU $040B
intruder_delay_timer	.EQU $040C
intruder_button_left	.EQU $040D
intruder_button_right	.EQU $040E
intruder_button_fire	.EQU $040F
intruder_mystery_pos	.EQU $0410
intruder_mystery_speed	.EQU $0411
intruder_points_low	.EQU $0412
intruder_points_high	.EQU $0413
intruder_level		.EQU $0414
intruder_overall_delay	.EQU $0415
intruder_mystery_bank	.EQU $0416
intruder_char_value	.EQU $0417
intruder_color_current	.EQU $0418
intruder_paused		.EQU $0419
intruder_joy_prev	.EQU $041A
; unused
intruder_enemy_visible	.EQU $0420

basic_memory		.EQU $8000 ; 16KB available
basic_memory_end	.EQU $C000 ; one past





	
	.ORG $C000 ; start of code

vector_reset

	LDA #$E1 ; produces greyscale
	STA $FFFF ; write non-$00 to ROM for 64-column 4-color mode

	LDA #$0C ; form feed
	JSR printchar
	
	STZ printchar_x
	STZ printchar_y	

	LDA #"P"
	JSR printchar
	LDA #"l"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"a"
	JSR printchar
	LDA #"s"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #" "
	JSR printchar
	LDA #"R"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"s"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"t"
	JSR printchar

	LDA #" "
	JSR printchar
	LDA #"o"
	JSR printchar
	LDA #"r"
	JSR printchar
	LDA #" "
	JSR printchar
	LDA #"P"
	JSR printchar
	LDA #"r"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"s"
	JSR printchar
	LDA #"s"
	JSR printchar
	LDA #" "
	JSR printchar
	LDA #"E"
	JSR printchar
	LDA #"S"
	JSR printchar
	LDA #"C"
	JSR printchar

inf
	JSR inputchar
	CMP #$1B ; escape
	BNE inf
	JMP bank_switch



; unused space here



	.ORG $F200 ; most important things below including sdcard, inputchar, printchar, and interrupts


sdcard_sendbyte ; already in A
	PHA
	PHX
	LDX #$08
sdcard_sendbyte_loop
	ROL A
	BCC sdcard_sendbyte_zero
	JSR spi_output_high
	JMP sdcard_sendbyte_toggle
sdcard_sendbyte_zero
	JSR spi_output_low
sdcard_sendbyte_toggle
	JSR spi_toggle
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
	JSR spi_input
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
	JSR spi_toggle
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
	JSR spi_disable
	JSR spi_output_high
	JSR longdelay
	LDX #$50
sdcard_pump_loop
	JSR spi_toggle
	DEX
	BNE sdcard_pump_loop
	PLX
	PLA
	RTS

; sets A to $00 for error, $01 for success
sdcard_initialize
	JSR spi_disable
	JSR sdcard_pump
	JSR longdelay
	JSR spi_enable
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
	JSR spi_disable
	CMP #$01
	BNE sdcard_initialize_error ; expecting 0x01
	JSR longdelay
	JSR sdcard_pump
	JSR spi_enable
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
	JSR spi_disable
	CMP #$01
	BNE sdcard_initialize_error ; expecting 0x01
	JSR spi_enable
	JSR sdcard_receivebyte ; 32-bit return value, ignore
	JSR sdcard_receivebyte
	JSR sdcard_receivebyte
	JSR sdcard_receivebyte
	JSR spi_disable
	JMP sdcard_initialize_loop
sdcard_initialize_error
	LDA #$00 ; return $00 for error
	RTS
sdcard_initialize_loop
	JSR sdcard_pump
	JSR longdelay
	JSR spi_enable
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
	JSR spi_disable
	CMP #$01
	BNE sdcard_initialize_error ; expecting 0x01
	JSR sdcard_pump
	JSR longdelay
	JSR spi_enable
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
	JSR spi_disable
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
	JSR spi_disable
	JSR sdcard_pump
	JSR longdelay
	JSR spi_enable
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
	JSR spi_disable
	PLX
	PLY
	LDA #$01 ; return $01 for success
	RTS

; X = low block addr, Y = high block addr, sets A to $00 for error, $01 for success
; always takes 512 bytes wherever 'sdcard_block' says
sdcard_writeblock
	PHY
	PHX
	JSR spi_disable
	JSR sdcard_pump
	JSR longdelay
	JSR spi_enable
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
	JSR spi_disable
	PLY
	PLX
	LDA #$01 ; return $01 for success
	RTS


longdelay
	PHA
	PHX
	PHY
	LDA #$FF ; arbitrary values
	LDX #$80
	LDY #$01
longdelay_loop
	DEC A
	BNE longdelay_loop
	DEX
	BNE longdelay_loop
	DEY
	BNE longdelay_loop
	PLY
	PLX
	PLA
	RTS



inputchar
	PHY
	PHX
	LDA #$00
	LDX key_read
	CPX key_write
	BEQ inputchar_exit
	LDA key_read
	INC A
	STA key_read
	CMP #$80
	BNE inputchar_success
	STZ key_read
inputchar_success
	LDA key_array,X
	CMP #$F0 ; release
	BEQ inputchar_release
	CMP #$E0 ; extended
	BEQ inputchar_extended
	CLC
	CMP #$80
	BCS inputchar_error
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
inputchar_error
	LDA #$00
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
	CMP #$5F ; delete character becomes space
	BNE printchar_transfer
	LDA #$00
printchar_transfer
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
	JMP printchar_move_print
printchar_move_inverted
	JSR printchar_read
	PHA
	EOR #$FF
	EOR printchar_inverse
	AND printchar_foreground
	STA printchar_storage
	PLA
printchar_move_print
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


	.ORG $F700 ; needed to put the tables on start of pages


; converts PS/2 codes to ASCII
; 256 bytes
key_conversion
	.BYTE $00,$16,$0C,$0E,$1E,$1C,$1D,$15
	.BYTE $00,$18,$07,$0F,$1F,$09,$60,$00
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

	.BYTE $00,$16,$0C,$0E,$1E,$1C,$1D,$15
	.BYTE $00,$18,$07,$0F,$1F,$09,$7E,$00
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
	;.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	;.BYTE $00,$00,$00,$00,$00,$00,$00,$00


spi_enable
	PHA
	LDA via_pb
	AND #spi_cs_inv
	STA via_pb
	PLA
	RTS

spi_disable
	PHA
	LDA via_pb
	ORA #spi_cs
	STA via_pb
	PLA
	RTS

spi_output_low
	PHA
	LDA via_pb
	AND #spi_mosi_inv
	STA via_pb
	PLA
	RTS

spi_output_high
	PHA
	LDA via_pb
	ORA #spi_mosi
	STA via_pb
	PLA
	RTS

spi_input ; results in $00 or $80
	LDA via_pb
	AND #spi_miso
	CLC
	ROL A
	RTS

spi_toggle
	PHA
	LDA via_pb
	ORA #spi_clk
	STA via_pb
	; delay here?
	AND #spi_clk_inv
	STA via_pb
	PLA
	RTS


; upon move/button change
mouse_isr
	LDA #%00000001
	STA via_ifr				; clear CA2 interrupt flag
	LDA mouse_state
	INC mouse_state
	CLC
	CMP #$1F
	BEQ mouse_isr_output
	BCS mouse_isr_normal
	CLC
	CMP #$16
	BCC mouse_isr_normal
	CMP #$1E
	BCS mouse_isr_parity
	LDA via_pah
	ROR mouse_data
	BCC mouse_isr_zero
	ORA #%01000000
	BCS mouse_isr_one
mouse_isr_zero
	AND #%10111111
mouse_isr_one
	STA via_pah
	PLA
	RTI
mouse_isr_parity
	LDA via_pah
	AND #%10111111
	STA via_pah
	PLA
	RTI
mouse_isr_input
	LDA #%00001100 ; CA2 low output, CA1 falling edge
	STA via_pcr
	JSR longdelay ; 100ms minimum delay
	JSR longdelay
	JSR longdelay
	JSR longdelay
	LDA #%01000000 ; PA6 is output now
	STA via_da
	LDA #%00000000
	STA via_pah
	LDA #%00000010 ; CA2 independent falling edge, CA1 falling edge
	STA via_pcr
	LDA #$F4 ; enable code
	STA mouse_data
	JMP mouse_isr_store
mouse_isr_output
	LDA #%00000000 ; PA is all input
	STA via_da
	DEC mouse_counter
	DEC mouse_counter
	JMP mouse_isr_normal
mouse_isr_normal
	LDA via_pah
	AND #%01000000				; read PA6 (without handshake)
	CLC	
	ROL A
	CLC
	ROR mouse_data				; shift mouse_code
	CLC
	ADC mouse_data				; add the PA6 bit into mouse_code
	STA mouse_data
	INC mouse_counter			; increment mouse_counter
	LDA mouse_counter
	CMP #$09 ; data ready			; 1 start bit, 8 data bits = 9 bits until real data ready
	BNE mouse_isr_check
mouse_isr_store
	LDA mouse_state
	CLC
	CMP #$2D	
	BCC mouse_isr_exit
	CMP #$35
	BEQ mouse_isr_buttons
	CMP #$40
	BEQ mouse_isr_pos_x
	CMP #$4B
	BEQ mouse_isr_pos_y
	; error
mouse_isr_reset
	STZ mouse_counter			; reset the counter
	LDA mouse_state
	CMP #$16
	BEQ mouse_isr_input
mouse_isr_exit
	PLA
	RTI				; and exit
mouse_isr_check
	CMP #$0B ; reset counter		; 1 start bit, 8 data bits, 1 parity bit, 1 stop bit = 11 bits to complete a full signal
	BEQ mouse_isr_reset
	PLA
	RTI					; and exit
mouse_isr_buttons
	LDA mouse_data
	STA mouse_buttons
	PLA
	RTI
mouse_isr_pos_x
	LDA mouse_data	
	CLC
	ADC mouse_pos_x
	STA mouse_pos_x
	PLA
	RTI
mouse_isr_pos_y
	LDA mouse_data	
	CLC
	ADC mouse_pos_y
	STA mouse_pos_y
	LDA #$2A
	STA mouse_state
	PLA	
	RTI



int_init
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
	
	RTS

via_init
	LDA #%10111111 ; PB is mostly output
	STA via_db
	LDA #%00000000 ; set output pins to low
	STA via_pb
	LDA #%00000000 ; PA is all input
	STA via_da
	LDA #%00000010 ; CA2 independent falling edge, CA1 falling edge
	STA via_pcr
	LDA #%10000011 ; interrupts on CA1 and CA2
	STA via_ier

	STZ key_write
	STZ key_read
	;STZ key_data
	STZ key_counter
	STZ key_release
	STZ key_extended
	STZ key_shift
	STZ key_capslock
	STZ key_alt_control

	LDA #$80
	STA mouse_pos_x
	STA mouse_pos_y
	STA mouse_prev_x
	STA mouse_prev_y
	STZ mouse_buttons
	STZ mouse_prev_buttons
	;STZ mouse_data
	STZ mouse_counter
	STZ mouse_state

	LDA #%11000000 ; free run on T1 for audio
	STA via_acr
	
	STZ via_t1cl ; zero out T1 counter to silence
	STZ via_t1ch
	
	CLI

	RTS


joy_init ; use at beginning
	PHA
	LDA #$FF
	STA joy_buttons
	LDA via_pb
	ORA #joy_select ; now leave it high always for speed sake
	STA via_pb
	PLA
	RTS

; upon keystroke
key_isr
	PHA
	LDA via_ifr
	AND #%00000010				; check if it was CA1
	BNE key_isr_start
	JMP mouse_isr				; if not, it's the mouse
key_isr_start	
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
	TXA
	INC A
	STA key_write
	CMP #$80
	BNE key_isr_success
	STZ key_write
key_isr_success
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

bank_switch
	LDA via_pb
	AND #%11011111
	STA via_pb
	NOP
	NOP
	JMP vector_reset


	.ORG $FFFA ; vectors

	.WORD vector_nmi
	.WORD vector_reset
	.WORD vector_irq









	
	
