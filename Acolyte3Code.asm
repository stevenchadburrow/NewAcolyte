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

	JSR int_init
	JSR via_init
	JSR joy_init

	JSR setup

	JSR function_keys_scratchpad
	




defense
	LDA #$00
	STA $FFFF ; turn on 16 color mode
	STZ defense_paused
	LDA #$0A ; arbitrary amount of initial population
	STA defense_pop_value
	STZ defense_score_value
	STZ defense_round_value
	LDA #$20
	STA defense_ammo_constant
	LDA #$0A
	STA defense_enemy_constant
	LDA #$08
	STA defense_random_constant
	LDA #$05
	STA defense_speed_constant
	JMP defense_start

defense_reset
	LDA defense_ammo_value
	CLC
	ROR A
	CLC
	ROR A
	CLC
	ADC defense_score_value
	INC A
	STA defense_score_value
	LDA defense_ammo_constant
	CLC
	ADC #$02
	STA defense_ammo_constant
	LDA defense_enemy_constant
	CLC
	ADC #$04
	STA defense_enemy_constant
	LDA defense_random_constant
	CLC
	ADC #$02
	STA defense_random_constant
	LDA defense_round_value
	CLC
	CMP #$03
	BCC defense_start
	STZ defense_round_value
	DEC defense_speed_constant
	LDA defense_speed_constant
	CMP #$02
	BCS defense_start
	INC defense_speed_constant

defense_start
	INC defense_round_value
	STZ mouse_prev_x
	STZ mouse_prev_y
	LDA #$08
	STA mouse_prev_buttons
	STA mouse_buttons
	LDA #$80
	STA mouse_pos_x
	STA mouse_pos_y
	LDA #$08
	STA defense_key_space
	STZ defense_key_up
	STZ defense_key_down
	STZ defense_key_left
	STZ defense_key_right
	STZ defense_dist_value
	LDA defense_enemy_constant ; arbitrary amount of enemies each round
	STA defense_enemy_value
	STA defense_stop_value
	LDA defense_ammo_constant ; arbitrary amount of ammo each round
	STA defense_ammo_value
	LDX #$00
defense_target_loop
	STZ defense_missile_x,X
	STZ defense_missile_y,X
	STZ defense_target_x,X
	STZ defense_target_y,X
	STZ defense_slope_x,X
	STZ defense_slope_y,X
	STZ defense_count_x,X
	STZ defense_count_y,X
	JSR defense_prev_clear
	INX
	CPX #$10
	BNE defense_target_loop
	STZ sub_write+1	
	LDA #$08
	STA sub_write+2
defense_screen_loop
	LDA #$00 ; black
	JSR sub_write
	INC sub_write+1
	BNE defense_screen_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE defense_screen_loop
	LDY #$00
defense_input_loop
	LDA defense_pop_value
	BEQ defense_input_gameover
	CMP #$80
	BCS defense_input_gameover
	JMP defense_input_check
defense_input_gameover
	JMP defense_gameover ; game over when zero population
defense_input_check
	LDA defense_enemy_value
	BNE defense_input_continue
	LDA defense_stop_value
	BNE defense_input_continue
	JMP defense_reset ; reset game after each round
defense_input_continue
	CLC
	JSR sub_random ; helps randomize
	JSR defense_keyboard
	LDA defense_paused
	BNE defense_input_continue
	JSR defense_joystick
	JSR defense_keycheck
	JSR defense_mouse
	LDA clock_low
	CLC
	CMP #$01 ; arbitrary for frame rate
	BCC defense_input_loop
	STZ clock_low
	JSR defense_player
	INY
	CPY defense_speed_constant ; arbitrary for missile movement
	BCC defense_input_loop
	LDA #$12
	JSR defense_draw_building
	LDA #$23
	JSR defense_draw_building
	LDA #$4D
	JSR defense_draw_building
	LDA #$5E
	JSR defense_draw_building
	LDA #$37
	JSR defense_draw_bunker
	LDY #$00
	JSR defense_draw
	LDA #$00
	STA printchar_x
	LDA #$1D
	STA printchar_y
	LDA defense_pop_value
	JSR colornum
	LDA #$0E
	STA printchar_x
	LDA #$1D
	STA printchar_y
	LDA defense_ammo_value
	JSR colornum
	LDA #$1C
	STA printchar_x
	LDA #$1D
	STA printchar_y
	LDA defense_score_value
	JSR colornum
	CLC
	JSR sub_random
	CLC
	CMP defense_random_constant ; arbitrary for appearance enemy missiles
	BCS defense_input_jump_loop
	LDA defense_enemy_value
	BEQ defense_input_jump_loop
	JSR defense_enemy
	CMP #$00
	BEQ defense_input_jump_loop
	DEC defense_enemy_value
defense_input_jump_loop
	JMP defense_input_loop

defense_gameover
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
defense_gameover_end_loop
	LDA defense_end_text,Y
	JSR colorchar
	INC printchar_x
	INY
	CPY #$07
	BNE defense_gameover_end_loop
defense_gameover_preloop
	JSR inputchar
	CMP #$00
	BNE defense_gameover_preloop
	LDA joy_buttons
	CMP #$FF
	BNE defense_gameover_preloop
	LDA mouse_buttons
	AND #%00000111
	BNE defense_gameover_preloop
defense_gameover_postloop
	JSR inputchar
	JSR function_keys
	CMP #$20 ; space
	BEQ defense_gameover_reset
	LDA joy_buttons
	AND #%00110000
	CMP #%00110000
	BNE defense_gameover_reset
	LDA mouse_buttons
	AND #%00000111
	BNE defense_gameover_reset
	JMP defense_gameover_postloop
defense_gameover_reset
	JMP defense

defense_player
	PHA
	LDA #$00
	JSR defense_draw_cursor
	LDA mouse_pos_x
	CLC
	CMP #$10
	BCS defense_player_next1
	LDA #$10
	STA mouse_pos_x
defense_player_next1
	LDA mouse_pos_x
	CLC
	CMP #$F1
	BCC defense_player_next2
	LDA #$F0
	STA mouse_pos_x
defense_player_next2
	LDA mouse_pos_y
	CLC
	CMP #$20
	BCS defense_player_next3
	LDA #$20
	STA mouse_pos_y
defense_player_next3
	LDA mouse_pos_y
	CLC
	CMP #$E1
	BCC defense_player_next4
	LDA #$E0
	STA mouse_pos_y
defense_player_next4
	; check to see that mouse hasn't just passed through the borders!
	LDA mouse_pos_x
	STA mouse_prev_x
	LDA mouse_pos_y
	STA mouse_prev_y
	LDA #$FF
	JSR defense_draw_cursor
	PLA
	RTS

defense_enemy
	PHX
	PHY
	LDX #$08
defense_enemy_loop
	CLC
	JSR sub_random ; helps randomize
	LDA defense_target_x,X
	BNE defense_enemy_increment
	LDA defense_target_y,X
	BNE defense_enemy_increment
defense_enemy_random
	CLC
	JSR sub_random
	CLC
	CMP #$18
	BCC defense_enemy_random
	CLC
	CMP #$E8
	BCS defense_enemy_random
	STA defense_target_x,X
	LDA #$08
	STA defense_target_y,X
	CLC
	JSR sub_random
	CLC
	CMP #$18
	BCC defense_enemy_random
	CLC
	CMP #$E8
	BCS defense_enemy_random
	STA defense_missile_x,X ; initial location of missiles
	LDA #$F0
	STA defense_missile_y,X
	LDA defense_target_x,X
	SEC
	SBC defense_missile_x,X
	BCC defense_enemy_invert1
	STA defense_slope_x,X
	STA defense_count_x,X
	JMP defense_enemy_skip
defense_enemy_invert1
	EOR #$FF
	INC A
	STA defense_slope_x,X
	STA defense_count_x,X
defense_enemy_skip
	LDA defense_target_y,X
	SEC
	SBC defense_missile_y,X
	BCC defense_enemy_invert2
	STA defense_slope_y,X
	STA defense_count_y,X
	JMP defense_mouse_exit
defense_enemy_invert2
	EOR #$FF
	INC A
	STA defense_slope_y,X
	STA defense_count_y,X
	JMP defense_enemy_exit
defense_enemy_increment
	INX
	CPX #$10
	BNE defense_enemy_loop
	PLY
	PLX
	LDA #$00 ; error
	RTS
defense_enemy_exit
	PLY
	PLX
	LDA #$FF ; success
	RTS

defense_keycheck
	PHA
	LDA defense_key_up
	BEQ defense_keycheck_down
	INC defense_key_up
	CLC
	CMP #$FF
	BCC defense_keycheck_down
	STZ defense_key_up
	INC defense_key_up
	INC mouse_pos_y
	INC mouse_pos_y
defense_keycheck_down
	LDA defense_key_down
	BEQ defense_keycheck_left
	INC defense_key_down
	CLC
	CMP #$FF
	BCC defense_keycheck_left
	STZ defense_key_down
	INC defense_key_down
	DEC mouse_pos_y
	DEC mouse_pos_y
defense_keycheck_left
	LDA defense_key_left
	BEQ defense_keycheck_right
	INC defense_key_left
	CLC
	CMP #$FF
	BCC defense_keycheck_right
	STZ defense_key_left
	INC defense_key_left
	DEC mouse_pos_x
	DEC mouse_pos_x
defense_keycheck_right
	LDA defense_key_right
	BEQ defense_keycheck_exit
	INC defense_key_right
	CLC
	CMP #$FF
	BCC defense_keycheck_exit
	STZ defense_key_right
	INC defense_key_right
	INC mouse_pos_x
	INC mouse_pos_x
defense_keycheck_exit
	PLA
	RTS

defense_keyboard
	PHX
	PHA
defense_keyboard_start
	LDX key_read
	CPX key_write
	BNE defense_keyboard_compare
	JMP defense_keyboard_exit
defense_keyboard_compare
	LDA key_read
	INC A
	STA key_read
	CMP #$80
	BNE defense_keyboard_success
	STZ key_read
defense_keyboard_success
	LDA key_array,X
	CLC
	CMP #$10
	BCS defense_keyboard_others
	JMP defense_keyboard_functions
defense_keyboard_others
	CMP #$F0 ; release
	BEQ defense_keyboard_release
	CMP #$E0 ; extended
	BEQ defense_keyboard_extended
	CMP #ps2_escape ; escape to exit
	BNE defense_keyboard_regular
	JMP defense_keyboard_escape
defense_keyboard_regular
	PHA
	LDA key_release
	BNE defense_keyboard_unpressed
defense_keyboard_pressed
	LDA key_extended
	BNE defense_keyboard_pressed_shifted
	PLA
	PHA
	CMP #ps2_space
	BNE defense_keyboard_clear
	LDA #$09
	STA mouse_buttons
	JMP defense_keyboard_clear
defense_keyboard_pressed_shifted
	PLA
	PHA
	CMP #ps2_arrow_up
	BEQ defense_keyboard_pressed_up
	CMP #ps2_arrow_down
	BEQ defense_keyboard_pressed_down
	CMP #ps2_arrow_left
	BEQ defense_keyboard_pressed_left
	CMP #ps2_arrow_right
	BEQ defense_keyboard_pressed_right
	JMP defense_keyboard_clear
defense_keyboard_unpressed
	LDA key_extended
	BNE defense_keyboard_unpressed_shifted
	PLA
	PHA
	CMP #ps2_space
	BNE defense_keyboard_clear
	LDA #$08
	STA mouse_buttons
	JMP defense_keyboard_clear
defense_keyboard_unpressed_shifted
	PLA
	PHA
	CMP #ps2_arrow_up
	BEQ defense_keyboard_unpressed_up
	CMP #ps2_arrow_down
	BEQ defense_keyboard_unpressed_down
	CMP #ps2_arrow_left
	BEQ defense_keyboard_unpressed_left
	CMP #ps2_arrow_right
	BEQ defense_keyboard_unpressed_right
defense_keyboard_clear
	PLA
	STZ key_release
	STZ key_extended
defense_keyboard_exit
	PLA
	PLX
	RTS
defense_keyboard_release
	STA key_release
	JMP defense_keyboard_exit
defense_keyboard_extended
	STA key_extended
	JMP defense_keyboard_exit
defense_keyboard_pressed_space
	INC defense_key_space
	JMP defense_keyboard_clear
defense_keyboard_pressed_up
	INC defense_key_up
	JMP defense_keyboard_clear
defense_keyboard_pressed_down
	INC defense_key_down
	JMP defense_keyboard_clear
defense_keyboard_pressed_left
	INC defense_key_left
	JMP defense_keyboard_clear
defense_keyboard_pressed_right
	INC defense_key_right
	JMP defense_keyboard_clear
defense_keyboard_unpressed_space
	STZ defense_key_space
	JMP defense_keyboard_clear
defense_keyboard_unpressed_up
	STZ defense_key_up
	JMP defense_keyboard_clear
defense_keyboard_unpressed_down
	STZ defense_key_down
	JMP defense_keyboard_clear
defense_keyboard_unpressed_left
	STZ defense_key_left
	JMP defense_keyboard_clear
defense_keyboard_unpressed_right
	STZ defense_key_right
	JMP defense_keyboard_clear
defense_keyboard_escape
	LDA key_release
	BEQ defense_keyboard_pause_start
	STZ key_release
	STZ key_extended
	JMP defense_keyboard_exit
defense_keyboard_pause_start
	LDA defense_paused
	EOR #$FF
	STA defense_paused
	BEQ defense_keyboard_pause_stop
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
defense_keyboard_pause_start_loop
	LDA defense_pause_text,Y
	JSR colorchar
	INC printchar_x
	INY
	CPY #$06
	BNE defense_keyboard_pause_start_loop
	STZ key_release
	STZ key_extended
	JMP defense_keyboard_exit
defense_keyboard_pause_stop
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
defense_keyboard_pause_stop_loop
	LDA #" "
	JSR colorchar
	INC printchar_x
	INY
	CPY #$06
	BNE defense_keyboard_pause_stop_loop
	STZ key_release
	STZ key_extended
	JMP defense_keyboard_exit	
defense_keyboard_functions
	TAX
	LDA key_conversion,X
	STZ key_release
	STZ key_extended
	JSR function_keys
	JMP defense_keyboard_exit

defense_joystick
	PHA
	LDA joy_buttons
	PHA
	AND #%00000001
	BNE defense_joystick_zero1
	INC defense_key_up
	JMP defense_joystick_next1
defense_joystick_zero1
	LDA defense_joy_prev
	AND #%00000001
	BNE defense_joystick_next1
	STZ defense_key_up
defense_joystick_next1
	PLA
	PHA
	AND #%00000010
	BNE defense_joystick_zero2
	INC defense_key_down
	JMP defense_joystick_next2
defense_joystick_zero2
	LDA defense_joy_prev
	AND #%00000010
	BNE defense_joystick_next2
	STZ defense_key_down
defense_joystick_next2
	PLA
	PHA
	AND #%00000100
	BNE defense_joystick_zero3
	INC defense_key_left
	JMP defense_joystick_next3
defense_joystick_zero3
	LDA defense_joy_prev
	AND #%00000100
	BNE defense_joystick_next3
	STZ defense_key_left
defense_joystick_next3
	PLA
	PHA
	AND #%00001000
	BNE defense_joystick_zero4
	INC defense_key_right
	JMP defense_joystick_next4
defense_joystick_zero4
	LDA defense_joy_prev
	AND #%00001000
	BNE defense_joystick_next4
	STZ defense_key_right
defense_joystick_next4
	PLA
	PHA
	AND #%00110000 ; B or C buttons
	CMP #%00110000
	BEQ defense_joystick_zero5
	LDA #$09
	STA mouse_buttons
	JMP defense_joystick_next5
defense_joystick_zero5
	LDA defense_joy_prev
	AND #%00110000 ; B or C buttons
	CMP #%00110000
	BEQ defense_joystick_next5
	LDA #$08
	STA mouse_buttons	
defense_joystick_next5
	PLA
	STA defense_joy_prev
	PLA
	RTS
	
defense_mouse
	PHA
	PHX
	PHY
	LDA mouse_buttons
	AND #%00001111
	CMP mouse_prev_buttons
	BNE defense_mouse_click
	JMP defense_mouse_exit ; odd?
defense_mouse_click
	LDA mouse_buttons
	AND #%00000001
	BNE defense_mouse_click_start
	JMP defense_mouse_exit
defense_mouse_click_start
	LDX #$00
defense_mouse_click_loop
	LDA defense_target_x,X
	BNE defense_mouse_click_increment
	LDA defense_target_y,X
	BNE defense_mouse_click_increment
	LDA defense_ammo_value
	BEQ defense_mouse_click_increment
	DEC defense_ammo_value
	LDA #$00
	JSR defense_draw_target
	LDA mouse_pos_x
	STA defense_target_x,X
	LDA mouse_pos_y
	STA defense_target_y,X
	LDA #$80
	STA defense_missile_x,X ; initial location of missiles
	LDA #$08
	STA defense_missile_y,X
	LDA defense_target_x,X
	SEC
	SBC defense_missile_x,X
	BCC defense_mouse_click_invert1
	STA defense_slope_x,X
	STA defense_count_x,X
	JMP defense_mouse_click_skip
defense_mouse_click_invert1
	EOR #$FF
	INC A
	STA defense_slope_x,X
	STA defense_count_x,X
defense_mouse_click_skip
	LDA defense_target_y,X
	SEC
	SBC defense_missile_y,X
	BCC defense_mouse_click_invert2
	STA defense_slope_y,X
	STA defense_count_y,X
	JMP defense_mouse_exit
defense_mouse_click_invert2
	EOR #$FF
	INC A
	STA defense_slope_y,X
	STA defense_count_y,X
	JMP defense_mouse_exit
defense_mouse_click_increment
	INX
	CPX #$08
	BNE defense_mouse_click_loop
	JMP defense_mouse_exit
defense_mouse_exit
	LDA mouse_buttons
	AND #%00001111
	STA mouse_prev_buttons
	PLY
	PLX
	PLA
	RTS
	
defense_draw
	PHA
	PHX
	PHY
	LDX #$00
defense_draw_loop
	LDA defense_slope_x,X
	BNE defense_draw_jump_show
	LDA defense_slope_y,X
	BNE defense_draw_jump_show
	LDA defense_count_x,X
	BEQ defense_draw_jump_increment1
	JMP defense_draw_collide_start
defense_draw_jump_show	
	JMP defense_draw_show
defense_draw_jump_increment1
	JMP defense_draw_increment
defense_draw_collide_start
	LDA #$0F
	STA defense_count_y,X
defense_draw_collide_loop
	TXA
	CMP defense_count_y,X
	BNE defense_draw_collide_next
	JMP defense_draw_collide_increment
defense_draw_collide_next
	LDY defense_count_y,X
	LDA defense_slope_x,Y
	BNE defense_draw_collide_check
	LDA defense_slope_y,Y
	BNE defense_draw_collide_check
	JMP defense_draw_collide_increment
defense_draw_collide_check
	CLC
	CPX #$08
	BCS defense_draw_collide_distance
	CLC
	CPY #$08
	BCS defense_draw_collide_distance
	JSR defense_pythagorean
	CLC
	CMP #$20 ; arbitrary no-collide distance
	BCS defense_draw_collide_distance
	JMP defense_draw_collide_increment
defense_draw_collide_distance
	LDA defense_missile_x,Y
	SEC
	SBC defense_missile_x,X	
	CLC
	CMP #$08
	BCC defense_draw_collide_x
	CLC	
	CMP #$F8
	BCS defense_draw_collide_x
	JMP defense_draw_collide_increment
defense_draw_collide_x
	LDA defense_missile_y,Y
	SEC
	SBC defense_missile_y,X
	CLC
	CMP #$08
	BCC defense_draw_collide_y
	CLC	
	CMP #$F8
	BCS defense_draw_collide_y
	JMP defense_draw_collide_increment
defense_draw_collide_y
	PHX
	TYA
	TAX
	CLC
	CPX #$08
	BCS defense_draw_collide_target
	LDA #$00
	JSR defense_draw_target
defense_draw_collide_target
	LDA #$00
	JSR defense_draw_line
	STZ defense_slope_x,X
	STZ defense_slope_y,X
	LDA #$40 ; arbitrary duration of explosion
	STA defense_count_x,X
	STZ defense_count_y,X
	CLC
	CPX #$08
	BCC defense_draw_collide_target_end
	PHX
	TXA
	SEC
	SBC #$08
	TAX
	JSR defense_prev_clear
	PLX
defense_draw_collide_target_end
	PLX
defense_draw_collide_increment
	DEC defense_count_y,X
	LDA defense_count_y,X
	CMP #$FF
	BEQ defense_draw_collide_explosion 
	JMP defense_draw_collide_loop
defense_draw_jump_increment2	
	JMP defense_draw_increment
defense_draw_collide_explosion
	CPX #$08
	BCC defense_draw_explosion_white
	LDA #$99 ; red
	BNE defense_draw_explosion_color
defense_draw_explosion_white
	LDA #$FF
defense_draw_explosion_color
	JSR defense_draw_explosion
	DEC defense_count_x,X
	BNE defense_draw_jump_increment2
	LDA #$00
	JSR defense_draw_explosion
	CLC
	CPX #$08
	BCC defense_draw_zero_stats
	LDA defense_missile_y,X
	CLC
	CMP #$18 ; height above ground to still hit pop
	BCS defense_draw_zero_score
	DEC defense_pop_value
	JMP defense_draw_zero_stats
defense_draw_zero_score
	;INC defense_score_value
defense_draw_zero_stats
	STZ defense_missile_x,X
	STZ defense_missile_y,X
	STZ defense_target_x,X
	STZ defense_target_y,X
	STZ defense_count_x,X
	CLC
	CPX #$08
	BCC defense_draw_jump_increment2
	DEC defense_stop_value
	JMP defense_draw_increment
defense_draw_show
	CLC
	CPX #$08
	BCS defense_draw_show_target
	LDA #$FF
	JSR defense_draw_target
defense_draw_show_target
	LDA #$00
	JSR defense_draw_missile
	CLC
	CPX #$08
	BCS defense_draw_prev_line
	JMP defense_draw_move_start
defense_draw_prev_line
	JSR defense_draw_line	
	PHY
	TXA
	SEC
	SBC #$08
	TAY
	LDA defense_missile_x,X
	CLC
	ROR A
	CMP defense_prev1_x,Y
	BNE defense_draw_prev_start
	LDA defense_missile_y,X
	EOR #$FF
	INC A
	CLC
	ROR A
	CMP defense_prev1_y,Y
	BNE defense_draw_prev_start
	JMP defense_draw_prev_end
defense_draw_prev_start
;	LDA defense_prev7_x,Y
;	STA defense_prev8_x,Y
;	LDA defense_prev7_y,Y
;	STA defense_prev8_y,Y
;	LDA defense_prev6_x,Y
;	STA defense_prev7_x,Y
;	LDA defense_prev6_y,Y
;	STA defense_prev7_y,Y
;	LDA defense_prev5_x,Y
;	STA defense_prev6_x,Y
;	LDA defense_prev5_y,Y
;	STA defense_prev6_y,Y
;	LDA defense_prev4_x,Y
;	STA defense_prev5_x,Y
;	LDA defense_prev4_y,Y
;	STA defense_prev5_y,Y
;	LDA defense_prev3_x,Y
;	STA defense_prev4_x,Y
;	LDA defense_prev3_y,Y
;	STA defense_prev4_y,Y
;	LDA defense_prev2_x,Y
;	STA defense_prev3_x,Y
;	LDA defense_prev2_y,Y
;	STA defense_prev3_y,Y
;	LDA defense_prev1_x,Y
;	STA defense_prev2_x,Y
;	LDA defense_prev1_y,Y
;	STA defense_prev2_y,Y

	PHX
	TYA
	CLC
	ADC #<defense_prev7_y
	STA sub_read+1
	LDA #>defense_prev7_y
	STA sub_read+2
	TYA
	CLC
	ADC #<defense_prev8_y
	STA sub_write+1
	LDA #>defense_prev8_y
	STA sub_write+2
	LDX #$0E
defense_draw_prev_loop
	JSR sub_read
	JSR sub_write
	LDA sub_read+1
	SEC
	SBC #$08
	STA sub_read+1
	LDA sub_write+1
	SEC
	SBC #$08
	STA sub_write+1
	DEX
	BNE defense_draw_prev_loop
	PLX

	LDA defense_missile_x,X
	CLC
	ROR A
	STA defense_prev1_x,Y
	LDA defense_missile_y,X
	EOR #$FF
	INC A
	CLC
	ROR A
	STA defense_prev1_y,Y
defense_draw_prev_end
	PLY
defense_draw_move_start
	LDY #$00
defense_draw_move_counter
	DEC defense_count_y,X
	BNE defense_draw_move_skip1
	LDA defense_slope_y,X
	STA defense_count_y,X
	LDA defense_target_x,X
	CLC
	CMP defense_missile_x,X
	BEQ defense_draw_move_skip1
	BCC defense_draw_move_invert1
	INC defense_missile_x,X
	INY
	JMP defense_draw_move_skip2
defense_draw_move_invert1
	DEC defense_missile_x,X
	INY
defense_draw_move_skip1
	DEC defense_count_x,X
	BNE defense_draw_move_skip2
	LDA defense_slope_x,X
	STA defense_count_x,X
	LDA defense_target_y,X
	CLC
	CMP defense_missile_y,X
	BEQ defense_draw_move_skip2
	BCC defense_draw_move_invert2
	INC defense_missile_y,X
	INY
	JMP defense_draw_move_skip2
defense_draw_move_invert2
	DEC defense_missile_y,X
	INY
defense_draw_move_skip2
	LDA defense_missile_x,X
	CMP defense_target_x,X
	BNE defense_draw_move_done
	LDA defense_missile_y,X
	CMP defense_target_y,X
	BNE defense_draw_move_done
	CLC
	CPX #$08
	BCS defense_draw_move_target
	LDA #$00
	JSR defense_draw_target
defense_draw_move_target
	STZ defense_slope_x,X
	STZ defense_slope_y,X
	LDA #$40 ; arbitrary duration of explosion
	STA defense_count_x,X
	STZ defense_count_y,X
	CLC
	CPX #$08
	BCC defense_draw_move_target_end
	PHX
	TXA
	SEC
	SBC #$08
	TAX
	JSR defense_prev_clear
	PLX
defense_draw_move_target_end
	JMP defense_draw_increment
defense_draw_move_done
	CPY #$00
	BNE defense_draw_move_missile 
	JMP defense_draw_move_counter
defense_draw_move_missile
	CPX #$08
	BCC defense_draw_missile_check
	LDA #$09 ; red
	JSR defense_draw_line
	LDA #$99 ; red
	BNE defense_draw_missile_color
defense_draw_missile_check
	CLC
	CPY #$03 ; arbitrary speed of missiles
	BCS defense_draw_missile_white
	JMP defense_draw_move_counter
defense_draw_missile_white
	LDA #$FF
defense_draw_missile_color
	JSR defense_draw_missile
defense_draw_increment
	INX
	CPX #$10
	BEQ defense_draw_exit
	JMP defense_draw_loop
defense_draw_exit
	PLY
	PLX
	PLA
	RTS

defense_draw_cursor
	PHY
	PHX
	PHA
	LDA mouse_prev_x
	CLC
	ROR A
	STA sub_write+1
	LDA mouse_prev_y
	EOR #$FF
	INC A
	CLC
	ROR A
	STA sub_write+2 
	CLC
	CMP #$08
	BCC defense_draw_cursor_exit
	LDY #$00
	LDX #$00
defense_draw_cursor_loop
	LDA defense_cursor_data,X
	BEQ defense_draw_cursor_skip
	PLA
	PHA
	AND defense_cursor_data,X
	JSR sub_write
defense_draw_cursor_skip
	INC sub_write+1
	INX
	INY
	CPY #$04
	BNE defense_draw_cursor_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7C
	STA sub_write+1
	BCC defense_draw_cursor_line
	INC sub_write+2
defense_draw_cursor_line
	CPX #$10
	BNE defense_draw_cursor_loop
defense_draw_cursor_exit
	PLA
	PLX	
	PLY
	RTS

defense_draw_target
	PHY
	PHX
	PHA
	LDA defense_target_x,X
	SEC
	SBC #$08
	CLC
	ROR A
	STA sub_write+1
	LDA defense_target_y,X
	CLC
	ADC #$04
	EOR #$FF
	INC A
	CLC
	ROR A
	STA sub_write+2 
	CLC
	CMP #$08
	BCC defense_draw_target_exit
	LDY #$00
	LDX #$00
defense_draw_target_loop
	LDA defense_target_data,X
	BEQ defense_draw_target_skip
	PLA
	PHA
	AND defense_target_data,X
	JSR sub_write
defense_draw_target_skip
	INC sub_write+1
	INX
	INY
	CPY #$04
	BNE defense_draw_target_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7C
	STA sub_write+1
	BCC defense_draw_target_line
	INC sub_write+2
defense_draw_target_line
	CPX #$10
	BNE defense_draw_target_loop
defense_draw_target_exit
	PLA
	PLX	
	PLY
	RTS

defense_draw_missile
	PHY
	PHX
	PHA
	LDA defense_missile_x,X
	CLC
	ROR A
	DEC A
	STA sub_write+1
	LDA defense_missile_y,X
	EOR #$FF
	INC A
	CLC
	ROR A
	DEC A
	STA sub_write+2 
	CLC
	CMP #$08
	BCC defense_draw_missile_exit
	LDY #$00
	LDX #$00
defense_draw_missile_loop
	LDA defense_missile_data,X
	BEQ defense_draw_missile_skip
	PLA
	PHA
	AND defense_missile_data,X
	JSR sub_write
defense_draw_missile_skip
	INC sub_write+1
	INX
	INY
	CPY #$02
	BNE defense_draw_missile_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7E
	STA sub_write+1
	BCC defense_draw_missile_line
	INC sub_write+2
defense_draw_missile_line
	CPX #$08
	BNE defense_draw_missile_loop
defense_draw_missile_exit
	PLA
	PLX	
	PLY
	RTS

defense_draw_line
	PHY
	PHX
	PHA
	TXA
	SEC
	SBC #$08
	TAX
	LDY #$08
defense_draw_line_loop
	LDA defense_prev1_x,X
	DEC A
	STA sub_write+1
	LDA defense_prev1_y,X
	DEC A
	STA sub_write+2
	CLC
	CMP #$08
	BCC defense_draw_line_exit
	CLC
	CMP #$80
	BCS defense_draw_line_exit
	PLA
	PHA
	JSR sub_write
	TXA
	CLC
	ADC #$10
	TAX
	DEY
	BNE defense_draw_line_loop
defense_draw_line_exit
	PLA
	PLX	
	PLY
	RTS

defense_draw_explosion
	PHY
	PHX
	PHA
	LDA defense_missile_x,X
	SEC
	SBC #$08
	CLC
	ROR A
	STA sub_write+1
	LDA defense_missile_y,X
	CLC
	ADC #$04
	EOR #$FF
	INC A
	CLC
	ROR A
	SEC
	SBC #$02
	STA sub_write+2 
	CLC
	CMP #$08
	BCC defense_draw_explosion_exit
	LDY #$00
	LDX #$00
defense_draw_explosion_loop
	LDA defense_explosion_data,X
	BEQ defense_draw_explosion_skip
	PLA
	PHA
	AND defense_explosion_data,X
	JSR sub_write
defense_draw_explosion_skip
	INC sub_write+1
	INX
	INY
	CPY #$08
	BNE defense_draw_explosion_loop
	LDY #$00
	TXA
	SEC
	SBC #$08
	TAX
	LDA sub_write+1
	CLC
	ADC #$78
	STA sub_write+1
	BCC defense_draw_explosion_line
	TXA
	CLC
	ADC #$08
	TAX
	INC sub_write+2
defense_draw_explosion_line
	CPX #$40
	BNE defense_draw_explosion_loop
defense_draw_explosion_exit
	PLA
	PLX	
	PLY
	RTS

defense_draw_building
	PHY
	PHX
	PHA
	STA sub_write+1
	LDA #$78
	STA sub_write+2
	LDX #$08 ; length
	LDA #$FF ; color
	JSR defense_draw_line_horizontal
	LDX #$08
	LDA #$FF
	JSR defense_draw_line_vertical
	PLA
	PHA
	CLC
	ADC #$06
	STA sub_write+1
	LDA #$7C
	STA sub_write+2
	LDX #$08
	LDA #$FF
	JSR defense_draw_line_vertical
	PLA
	PHA
	CLC
	ADC #$06
	STA sub_write+1
	LDA #$7C
	STA sub_write+2
	LDX #$08
	LDA #$FF
	JSR defense_draw_line_horizontal
	LDX #$08
	LDA #$FF
	JSR defense_draw_line_vertical
	PLA
	PHA
	STA sub_write+1
	LDA #$78
	STA sub_write+2
	LDX #$10
	LDA #$FF
	JSR defense_draw_line_vertical
defense_draw_building_exit
	PLA
	PLX
	PLY
	RTS

defense_draw_bunker
	PHY
	PHX
	PHA
	STA sub_write+1
	LDA #$76
	STA sub_write+2
	LDX #$10 ; length
	LDA #$FF ; color
	JSR defense_draw_line_horizontal
	PLA
	PHA
	STA sub_write+1
	LDA #$74
	STA sub_write+2
	LDX #$10 ; length
	LDA #$FF ; color
	JSR defense_draw_line_horizontal
	LDX #$18
	LDA #$FF
	JSR defense_draw_line_vertical
	PLA
	PHA
	STA sub_write+1
	LDA #$74
	STA sub_write+2
	LDX #$18
	LDA #$FF
	JSR defense_draw_line_vertical
defense_draw_bunker_exit
	PLA
	PLX
	PLY
	RTS

defense_draw_line_horizontal
	JSR sub_write
	INC sub_write+1
	DEX
	BNE defense_draw_line_horizontal
	RTS

defense_draw_line_vertical
	JSR sub_write
	PHA
	LDA sub_write+1
	CLC
	ADC #$80
	STA sub_write+1
	BCC defense_draw_line_vertical_increment
	INC sub_write+2
defense_draw_line_vertical_increment
	PLA
	DEX
	BNE defense_draw_line_vertical
	RTS
	
defense_pythagorean
	LDA defense_missile_x,Y
	SEC
	SBC #$80
	CLC
	CMP #$80
	BCC defense_pythagorean_ready
	EOR #$FF
	INC A
defense_pythagorean_ready
	STA defense_dist_value
	CMP defense_missile_y,Y
	BCC defense_pythagorean_horizontal
	CLC
	ROR A
	CLC
	ADC defense_missile_y,Y
	STA defense_dist_value
	RTS
defense_pythagorean_horizontal
	LDA defense_missile_y,Y
	CLC
	ROR A
	CLC
	ADC defense_dist_value
	STA defense_dist_value
	RTS

defense_prev_clear
	PHA
	PHY
	TXA
	CLC
	ADC #<defense_prev1_x
	STA sub_write+1
	LDA #>defense_prev1_x
	STA sub_write+2
	LDY #$10
defense_prev_clear_loop
	LDA #$00
	JSR sub_write
	LDA sub_write+1
	CLC
	ADC #$08
	STA sub_write+1
	DEY
	BNE defense_prev_clear_loop
	PLY
	PLA
	RTS
	

defense_cursor_data
	.BYTE $FF,$FF,$FF,$E1
	.BYTE $FF,$FF,$E1,$00
	.BYTE $FF,$E1,$00,$00
	.BYTE $E1,$00,$00,$00

defense_target_data
	.BYTE $00,$00,$00,$1E
	.BYTE $00,$00,$1E,$FF
	.BYTE $00,$1E,$FF,$FF
	.BYTE $1E,$FF,$FF,$FF

defense_missile_data
	.BYTE $1E,$E1
	.BYTE $EF,$FE
	.BYTE $EF,$FE
	.BYTE $1E,$E1

defense_explosion_data
	.BYTE $00,$00,$1E,$FF,$FF,$E1,$00,$00
	.BYTE $00,$1E,$FF,$FF,$FF,$FF,$E1,$00
	.BYTE $1E,$FF,$FF,$FF,$FF,$FF,$FF,$E1
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $1E,$FF,$FF,$FF,$FF,$FF,$FF,$E1
	.BYTE $00,$1E,$FF,$FF,$FF,$FF,$E1,$00
	.BYTE $00,$00,$1E,$FF,$FF,$E1,$00,$00

defense_end_text
	.BYTE "The End"

defense_pause_text
	.BYTE "Paused"





intruder_max_enemies		.EQU $2F ; $2F, a constant
intruder_color_enemy		.EQU $77 ; constant
intruder_color_shield		.EQU $AA ; constant
intruder_color_missile		.EQU $DD ; constant
intruder_color_mystery		.EQU $DD ; constant

intruder
	LDA #$00
	STA $FFFF ; turn on 16 color mode

	JMP intruder_init

intruder_level_enemy_fall
	.BYTE $10,$10,$30,$30,$50,$50,$70,$70
intruder_level_enemy_speed
	.BYTE $20,$40,$40,$60,$60,$80,$80,$A0
intruder_level_enemy_missile_speed
	.BYTE $02,$02,$03,$03,$04,$04,$04,$04
intruder_level_overall_delay
	.BYTE $80,$70,$60,$50,$40,$30,$20,$10

intruder_init
	STZ intruder_paused
	LDA #$03
	STA intruder_player_lives
	STZ intruder_level
	STZ intruder_points_low
	STZ intruder_points_high
	
intruder_init_level
	LDA intruder_level
	AND #%00000111
	TAX
	LDA #$3C ; #$2E? port change
	STA intruder_player_pos
	STZ intruder_button_left
	STZ intruder_button_right
	STZ intruder_button_fire
	STZ intruder_missile_pos_y
	STZ intruder_delay_timer
	LDA intruder_level_enemy_fall,X
	STA intruder_enemy_fall
	LDA #$08
	STA intruder_enemy_pos_x
	LDA #$18
	STA intruder_enemy_pos_y
	LDA intruder_level_enemy_speed,X
	STA intruder_enemy_speed
	LDA intruder_level_enemy_missile_speed,X
	STA intruder_enemy_miss_s
	LDA #$28
	STA intruder_enemy_miss_x
	STZ intruder_enemy_miss_y
	LDA #$00
	STA intruder_mystery_pos
	LDA #$01
	STA intruder_mystery_speed
	LDA intruder_level_overall_delay,X
	STA intruder_overall_delay
	LDA #$FA ; 250 in decimal
	STA intruder_mystery_bank ; total points you can get from the mystery ship each round

intruder_init_start
	STZ sub_write+1				; clear out screen RAM
	LDA #$08
	STA sub_write+2
intruder_init_wipeout
	LDA #$00 ; fill color
	JSR sub_write
	INC sub_write+1
	BNE intruder_init_wipeout
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE intruder_init_wipeout

	JSR intruder_draw_menu

	LDX #intruder_max_enemies
	LDA #$FF
intruder_init_visible_loop
	STA intruder_enemy_visible,X
	DEX
	CPX #$FF
	BNE intruder_init_visible_loop

	LDA #$14 ; #$0C port change
	JSR intruder_init_shield
	LDA #$28 ; #$18 port change
	JSR intruder_init_shield
	LDA #$3C ; #$24 port change
	JSR intruder_init_shield
	LDA #$50 ; #$30 port change
	JSR intruder_init_shield
	LDA #$64 ; #$3C port change
	JSR intruder_init_shield

	LDY #$00
	JMP intruder_draw_mystery	

intruder_input
	LDA clock_low
	CLC	
	CMP #$01
	BCC intruder_input_keys
	STZ clock_low
	LDA joy_buttons
	AND intruder_joy_prev ; maybe?
	CMP #$FF
	BEQ intruder_input_keys
	JMP intruder_joy
intruder_input_keys
	;LDA joy_buttons
	;STA intruder_joy_prev ; maybe?
	LDX key_read
	CPX key_write
	BNE intruder_input_next
	LDA intruder_paused
	BNE intruder_input
	JMP intruder_input_check
intruder_input_next
	CLC
	JSR sub_random ; just to add randomness
	LDA key_array,X
	INC key_read
	BPL intruder_input_positive
	STZ key_read
intruder_input_positive
	CMP #$F0
	BEQ intruder_input_release
	STA intruder_char_value
	LDA key_release
	STZ key_release
	BEQ intruder_input_down
	LDA intruder_char_value
	CMP #ps2_escape
	BEQ intruder_input_pause
	LDA intruder_paused
	BNE intruder_input
	LDA intruder_char_value
	CMP #ps2_arrow_left
	BEQ intruder_input_left_up
	CMP #$1C ; A
	BEQ intruder_input_left_up
	CMP #ps2_arrow_right
	BEQ intruder_input_right_up
	CMP #$23 ; D
	BEQ intruder_input_right_up
	CMP #ps2_space
	BEQ intruder_input_fire_up
	CMP #ps2_arrow_up
	BEQ intruder_input_fire_up
	CMP #$1D ; W
	BEQ intruder_input_fire_up
	TAX
	LDA key_conversion,X
	STZ key_release
	STZ key_extended
	JSR function_keys
	JMP intruder_input_check

intruder_input_pause
	LDA intruder_paused
	EOR #$FF
	STA intruder_paused
	BEQ intruder_input_pause_clear
	JSR intruder_pause_draw
	JMP intruder_input
intruder_input_pause_clear
	JSR intruder_pause_clear
	STZ key_read
	STZ key_write
	STZ intruder_button_left
	STZ intruder_button_right
	STZ intruder_button_fire
	JMP intruder_input

intruder_input_release
	STA key_release
	JMP intruder_input_check
intruder_input_down
	LDA intruder_char_value
	CMP #ps2_arrow_left
	BEQ intruder_input_left_down
	CMP #$1C ; A
	BEQ intruder_input_left_down
	CMP #ps2_arrow_right
	BEQ intruder_input_right_down
	CMP #$23 ; D
	BEQ intruder_input_right_down
	CMP #ps2_space
	BEQ intruder_input_fire_down
	CMP #ps2_arrow_up
	BEQ intruder_input_fire_down
	CMP #$1D ; W
	BEQ intruder_input_fire_down
	JMP intruder_input_check
intruder_input_left_up
	STZ intruder_button_left
	JMP intruder_input_check
intruder_input_right_up
	STZ intruder_button_right
	JMP intruder_input_check
intruder_input_fire_up
	STZ intruder_button_fire
	JMP intruder_input_check
intruder_input_left_down
	STA intruder_button_left
	JMP intruder_input_check
intruder_input_right_down	
	STA intruder_button_right
	JMP intruder_input_check
intruder_input_fire_down	
	STA intruder_button_fire
	JMP intruder_input_check

intruder_joy
	LDA joy_buttons
	ORA #%11001111
	CMP #$FF 
	BEQ intruder_joy_nofire
	LDA #$FF
	STA intruder_button_fire
	JMP intruder_joy_continue
intruder_joy_nofire
	STZ intruder_button_fire
intruder_joy_continue
	LDA joy_buttons
	ORA #%11111011
	CMP #$FF
	BEQ intruder_joy_noleft
	LDA #$FF
	STA intruder_button_left
	JMP intruder_joy_next
intruder_joy_noleft
;	LDA intruder_joy_prev
;	ORA #%11111011
;	CMP #$FF
;	BEQ intruder_joy_next
	STZ intruder_button_left
intruder_joy_next
	LDA joy_buttons
	ORA #%11110111
	CMP #$FF
	BEQ intruder_joy_noright
	LDA #$FF
	STA intruder_button_right
	JMP intruder_joy_exit
intruder_joy_noright
;	LDA intruder_joy_prev
;	ORA #%11110111
;	CMP #$FF
;	BEQ intruder_joy_exit
	STZ intruder_button_right
intruder_joy_exit
	LDA joy_buttons
	STA intruder_joy_prev ; maybe?
	JMP intruder_input_check

intruder_input_check	
	INY
	CPY intruder_overall_delay
	BEQ intruder_input_check_next
	JMP intruder_input
intruder_input_check_next
	LDY #$00
	DEC intruder_delay_timer
	LDA intruder_delay_timer
	AND #%00001111
	BEQ intruder_reaction
	JMP intruder_input
intruder_reaction
	LDA intruder_button_left
	BEQ intruder_reaction_next1
	LDA intruder_player_pos
	SEC
	SBC #$02
	CLC
	CMP #$02 ; #$08 port change
	BCC intruder_reaction_next1
	STA intruder_player_pos
intruder_reaction_next1
	LDA intruder_button_right
	BEQ intruder_reaction_next2
	LDA intruder_player_pos
	CLC
	ADC #$02
	CLC
	CMP #$78 ; #$42 port change
	BCS intruder_reaction_next2
	STA intruder_player_pos
intruder_reaction_next2
	LDA intruder_button_fire
	BEQ intruder_reaction_next3
	STZ intruder_button_fire
	LDA intruder_missile_pos_y
	BNE intruder_reaction_next3
	LDA intruder_player_pos
	CLC
	ADC #$03
	STA intruder_missile_pos_x
	LDA #$72
	STA intruder_missile_pos_y
intruder_reaction_next3
	NOP


intruder_draw_mystery
	LDA intruder_mystery_pos
	CMP #$FF
	BEQ intruder_draw_player
	CLC	
	ADC intruder_mystery_speed
	BMI intruder_draw_mystery_offscreen
	CLC	
	CMP #$78 ; #$50 port change
	BCS intruder_draw_mystery_offscreen
	JMP intruder_draw_mystery_onscreen
intruder_draw_mystery_offscreen
	LDA #$FF
	STA intruder_mystery_pos
	JSR intruder_mystery_clear
	JMP intruder_draw_player
intruder_draw_mystery_onscreen
	STA intruder_mystery_pos
	STA sub_write+1
	LDA #$10
	STA sub_write+2
	LDA #<intruder_mystery_data
	STA sub_index+1
	LDA #>intruder_mystery_data
	STA sub_index+2
	LDX #$00
	LDY #$00
intruder_draw_mystery_loop
	JSR sub_index
	AND #intruder_color_mystery
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$08
	BNE intruder_draw_mystery_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$78
	STA sub_write+1
	BCC intruder_draw_mystery_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$14
	BCC intruder_draw_mystery_loop


intruder_draw_player
	LDA intruder_player_pos
	STA sub_write+1
	LDA #$76
	STA sub_write+2
	LDA #<intruder_player_data
	STA sub_index+1
	LDA #>intruder_player_data
	STA sub_index+2
	LDX #$00
	LDY #$00
intruder_draw_player_loop
	JSR sub_index
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$08
	BNE intruder_draw_player_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$78
	STA sub_write+1
	BCC intruder_draw_player_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$79
	BCC intruder_draw_player_loop
	LDA intruder_missile_pos_y
	BNE intruder_draw_missile
	
	LDX #$FF
	LDY #$18
intruder_draw_no_missile
	NOP
	DEX
	BNE intruder_draw_no_missile
	DEY
	BNE intruder_draw_no_missile

	JMP intruder_draw_enemy_missile
intruder_draw_missile
	LDA intruder_missile_pos_x
	STA sub_write+1
	LDA intruder_missile_pos_y
	STA sub_write+2
	JSR intruder_draw_missile_particle_clear
	LDA intruder_missile_pos_y
	SEC
	SBC #$04
	CLC	
	CMP #$08
	BCS intruder_draw_missile_normal
	JMP intruder_draw_missile_reset
intruder_draw_missile_normal
	STA intruder_missile_pos_y


	LDA intruder_missile_pos_y
	CLC	
	CMP #$10
	BCC intruder_draw_missile_mystery_skip
	CLC
	CMP #$14
	BCS intruder_draw_missile_mystery_skip
	LDA intruder_missile_pos_x
	CLC
	CMP intruder_mystery_pos
	BCC intruder_draw_missile_mystery_skip
	SEC
	SBC #$08
	CMP intruder_mystery_pos
	BCS intruder_draw_missile_mystery_skip
	LDA #$FF
	STA intruder_mystery_pos ; hit the mystery ship!
	JSR intruder_mystery_clear

;	LDA #$41
;	STA printchar_x
;	LDA #$0C
;	STA printchar_y
;	LDA #" "
;	JSR printchar
;	JSR printchar
;	JSR printchar
;	JSR printchar
;	JSR printchar
;	JSR printchar
	LDA intruder_mystery_bank ; only 250 points available each level
	BEQ intruder_draw_missile_mystery_skip
	SEC
	SBC #$32
	STA intruder_mystery_bank
	LDA #$32 ; 50 in decimal
	CLC
	ADC intruder_points_low
	STA intruder_points_low ; increment points
	CLC
	CMP #$64 ; 100 in decimal
	BCC intruder_draw_missile_mystery_skip
	SEC
	SBC #$64
	STA intruder_points_low
	INC intruder_points_high
	LDA intruder_points_high
	AND #%00000011 ; every 400 points is new life
	BNE intruder_draw_missile_mystery_skip
	LDA intruder_player_lives
	AND #%00001111
	CLC
	CMP #$09
	BCS intruder_draw_missile_mystery_skip
	INC intruder_player_lives
intruder_draw_missile_mystery_skip
	JSR intruder_draw_menu

	LDX #intruder_max_enemies
intruder_draw_missile_array
	LDA intruder_enemy_visible,X
	BNE intruder_draw_missile_check
	JMP intruder_draw_missile_loop
intruder_draw_missile_check
	TXA
	AND #%11111000
	EOR #$FF
	INC A
	ADC intruder_missile_pos_y
	CLC
	CMP intruder_enemy_pos_y
	BCS intruder_draw_missile_check_next1
	JMP intruder_draw_missile_loop
intruder_draw_missile_check_next1
	SEC
	SBC #$04
	CLC
	CMP intruder_enemy_pos_y
	BCC intruder_draw_missile_check_next2
	JMP intruder_draw_missile_loop
intruder_draw_missile_check_next2
	TXA
	AND #%00000111
	PHY ; port change down
	TAY
	LDA #$00
intruder_draw_enemy_check_addition
	CLC
	ADC #$0E
	DEY
	BNE intruder_draw_enemy_check_addition
	PLY	
;	CLC
;	ROL A
;	ROL A
;	ROL A ; port change up
	ADC intruder_enemy_pos_x
	CLC
	ADC #$04 ; should be #$05?
	CLC
	CMP intruder_missile_pos_x
	BCS intruder_draw_missile_check_next3
	JMP intruder_draw_missile_loop
intruder_draw_missile_check_next3
	SEC
	SBC #$05 ; #$05 port change
	CLC
	CMP intruder_missile_pos_x
	BCC intruder_draw_missile_check_next4
	JMP intruder_draw_missile_loop
intruder_draw_missile_check_next4
	LDA #$80	
	STA intruder_enemy_visible,X ; hit enemy
	STZ intruder_missile_pos_y

;	LDA #$41
;	STA printchar_x
;	LDA #$0C
;	STA printchar_y
;	LDA #" "
;	JSR printchar
;	JSR printchar
;	JSR printchar
;	JSR printchar
;	JSR printchar
;	JSR printchar
	TXA
	AND #%11111000
	CLC
	ROR A
	ROR A
	ROR A
	EOR #$FF
	DEC A
	AND #%00000111
	CLC
	ADC intruder_points_low
	STA intruder_points_low ; increment points
	CLC
	CMP #$64 ; 100 in decimal
	BCC intruder_draw_missile_points
	SEC
	SBC #$64
	STA intruder_points_low
	INC intruder_points_high
	LDA intruder_points_high
	AND #%00000011 ; every 400 points is new life
	BNE intruder_draw_missile_points
	LDA intruder_player_lives
	AND #%00001111
	CLC
	CMP #$09
	BCS intruder_draw_missile_points
	INC intruder_player_lives
intruder_draw_missile_points
	JSR intruder_draw_menu

	PHX
	LDX #intruder_max_enemies
intruder_draw_missile_win_loop
	LDA intruder_enemy_visible,X
	AND #%01111111
	BNE intruder_draw_missile_win_fail
	DEX
	CPX #$FF
	BNE intruder_draw_missile_win_loop
	PLX
	JMP intruder_nextlevel ; won the game!
intruder_draw_missile_win_fail
	PLX
intruder_draw_missile_loop
	DEX
	CPX #$FF
	BEQ intruder_draw_missile_flying
	JMP intruder_draw_missile_array
intruder_draw_missile_flying
	LDA intruder_missile_pos_y
	BNE intruder_draw_missile_flying_next1
	JMP intruder_draw_enemy_missile
intruder_draw_missile_flying_next1
	LDA intruder_missile_pos_x
	STA sub_write+1
	LDA intruder_missile_pos_y
	STA sub_write+2
	PHY
	LDY #intruder_color_missile
	JSR intruder_draw_missile_particle_color
	PLY
	CPX #$00
	BNE intruder_draw_missile_flying_next2
	JMP intruder_draw_enemy_missile
intruder_draw_missile_flying_next2
	LDA intruder_missile_pos_x
	STA sub_write+1
	LDA intruder_missile_pos_y
	STA sub_write+2
	LDY #intruder_color_missile
	JSR intruder_draw_missile_particle_clear
intruder_draw_missile_reset
	STZ intruder_missile_pos_y

	JSR intruder_draw_menu

intruder_draw_enemy_missile
	LDA intruder_enemy_miss_y
	BEQ intruder_draw_enemy_missile_skip
	LDA intruder_enemy_miss_x
	STA sub_write+1
	LDA intruder_enemy_miss_y
	STA sub_write+2
	LDY #intruder_color_enemy
	JSR intruder_draw_missile_particle_clear
	LDA intruder_enemy_miss_y
	BEQ intruder_draw_enemy_missile_skip
	JMP intruder_draw_enemy_missile_ready
intruder_draw_enemy_missile_skip
	LDA intruder_delay_timer
	CLC
	CMP intruder_enemy_speed 
	BCC intruder_draw_enemy_missile_timed
	JMP intruder_draw_enemy
intruder_draw_enemy_missile_timed
	LDA intruder_enemy_fall
	EOR #$FF
	STA intruder_enemy_fall
	CLC
	JSR sub_random
	AND intruder_enemy_speed
	AND #%11110000
	PHA
	LDA intruder_enemy_fall
	EOR #$FF
	STA intruder_enemy_fall
	PLA
	BEQ intruder_draw_enemy_missile_search
	JMP intruder_draw_enemy
intruder_draw_enemy_missile_search


	LDA intruder_mystery_pos
	CMP #$FF
	BNE intruder_draw_mystery_skip
	CLC
	JSR sub_random
	AND #%00001111
	BNE intruder_draw_mystery_skip
	STZ intruder_mystery_pos
	LDA #$01
	STA intruder_mystery_speed
	LDA intruder_level
	CLC
	CMP #$04
	BCC intruder_draw_mystery_next
	LDA #$02
	STA intruder_mystery_speed
intruder_draw_mystery_next
	CLC
	JSR sub_random
	AND #%10000000
	BEQ intruder_draw_mystery_skip
	LDA #$77 ; #$4F port change
	STA intruder_mystery_pos
	LDA #$FF
	STA intruder_mystery_speed
	LDA intruder_level
	CLC
	CMP #$04
	BCC intruder_draw_mystery_skip
	LDA #$FE
	STA intruder_mystery_speed
intruder_draw_mystery_skip


	CLC
	JSR sub_random
	AND #%11111100
	CLC
	ROR A
	ROR A
	CLC
	CMP #$30
	BCS intruder_draw_enemy_missile_search
	TAX
	LDA intruder_enemy_visible,X
	BEQ intruder_draw_enemy_missile_search	
	TXA
	AND #%00000111
	PHY ; port change down
	TAY
	LDA #$00
intruder_draw_enemy_missile_addition
	CLC
	ADC #$0E
	DEY
	BNE intruder_draw_enemy_missile_addition
	PLY	
;	CLC
;	ROL A
;	ROL A
;	ROL A ; port change up
	ADC intruder_enemy_pos_x
	ADC #$02
	STA intruder_enemy_miss_x
	TXA
	AND #%11111000
	ADC intruder_enemy_pos_y
	CLC
	ADC #$04
	STA intruder_enemy_miss_y
intruder_draw_enemy_missile_ready
	LDA intruder_enemy_miss_s
	DEC A
	CLC
	ADC intruder_enemy_miss_y
	CLC
	CMP #$80
	BCS intruder_draw_enemy_missile_miss
	STA intruder_enemy_miss_y
	CLC
	CMP #$72
	BCC intruder_draw_enemy_missile_normal	
	LDA intruder_player_pos
	CLC
	ADC #$06
	CLC
	CMP intruder_enemy_miss_x
	BCC intruder_draw_enemy_missile_normal
	SEC
	SBC #$06
	CMP intruder_enemy_miss_x
	BCS intruder_draw_enemy_missile_normal
	DEC intruder_player_lives ; got hit!

	JSR intruder_draw_menu

	LDA intruder_player_lives
	AND #%00001111
	BNE intruder_draw_enemy_missile_miss
	JMP intruder_gameover
intruder_draw_enemy_missile_normal
	LDA intruder_enemy_miss_x
	STA sub_write+1
	LDA intruder_enemy_miss_y
	STA sub_write+2
	PHY
	LDY #intruder_color_enemy
	JSR intruder_draw_missile_particle_color
	PLY
	CPX #$00
	BEQ intruder_draw_enemy
	LDA intruder_enemy_miss_x
	STA sub_write+1
	LDA intruder_enemy_miss_y
	STA sub_write+2
	LDY #intruder_color_enemy
	JSR intruder_draw_missile_particle_clear
intruder_draw_enemy_missile_miss
	STZ intruder_enemy_miss_y
intruder_draw_enemy
	LDX #intruder_max_enemies
intruder_draw_enemy_array
	LDA intruder_enemy_visible,X
	BNE intruder_draw_enemy_visible
	JMP intruder_draw_enemy_loop
intruder_draw_enemy_visible
	CMP #$80
	BNE intruder_draw_enemy_full
	JSR intruder_draw_enemy_clear
	STZ intruder_enemy_visible,X
	JMP intruder_draw_enemy_loop
intruder_draw_enemy_full
	PHX
	TXA
	AND #%00000111
	PHY ; port change down
	TAY
	LDA #$00
intruder_draw_enemy_full_addition
	CLC
	ADC #$0E
	DEY
	BNE intruder_draw_enemy_full_addition
	PLY	
;	CLC
;	ROL A
;	ROL A
;	ROL A ; port change up
	ADC intruder_enemy_pos_x
	STA sub_write+1
	TXA
	AND #%11111000
	ADC intruder_enemy_pos_y
	STA sub_write+2
	LDA intruder_level
	AND #%00000001
	BEQ intruder_draw_enemy_pic2
	LDA intruder_enemy_pos_x
	AND #%00000001
	BEQ intruder_draw_enemy_pic1
	LDA #<intruder_enemy_data1
	STA sub_index+1
	LDA #>intruder_enemy_data1
	STA sub_index+2
	JMP intruder_draw_enemy_pic_done
intruder_draw_enemy_pic1
	LDA #<intruder_enemy_data2
	STA sub_index+1
	LDA #>intruder_enemy_data2
	STA sub_index+2
	JMP intruder_draw_enemy_pic_done
intruder_draw_enemy_pic2
	LDA intruder_enemy_pos_x
	AND #%00000001
	BEQ intruder_draw_enemy_pic3
	LDA #<intruder_enemy_data3
	STA sub_index+1
	LDA #>intruder_enemy_data3
	STA sub_index+2
	JMP intruder_draw_enemy_pic_done
intruder_draw_enemy_pic3
	LDA #<intruder_enemy_data4
	STA sub_index+1
	LDA #>intruder_enemy_data4
	STA sub_index+2
intruder_draw_enemy_pic_done
	LDX #$00
	LDY #$00
	PHY
intruder_draw_enemy_visible_loop
	JSR sub_index
	AND #intruder_color_enemy
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$06
	BNE intruder_draw_enemy_visible_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7A
	STA sub_write+1
	BCC intruder_draw_enemy_visible_loop
	INC sub_write+2
	LDA sub_write+2
	CLC
	CMP #$72
	BCC intruder_draw_enemy_visible_continue ; too far down!
	JMP intruder_gameover
intruder_draw_enemy_visible_continue
	PLA
	INC A
	CMP #$03
	PHA
	BNE intruder_draw_enemy_visible_loop
	PLA
	PLX
intruder_draw_enemy_loop
	DEX
	CPX #$FF
	BEQ intruder_draw_enemy_move
	JMP intruder_draw_enemy_array
intruder_draw_enemy_move
	LDA intruder_delay_timer
	CLC
	CMP intruder_enemy_speed 
	BCC intruder_draw_enemy_ready
	JMP intruder_loop
intruder_draw_enemy_ready
	STZ intruder_delay_timer
	LDA intruder_enemy_pos_y
	AND #%00000001
	BEQ intruder_draw_enemy_back
	LDA #$01
	JMP intruder_draw_enemy_shift
intruder_draw_enemy_back
	LDA #$FF
intruder_draw_enemy_shift
	CLC
	ADC intruder_enemy_pos_x
	STA intruder_enemy_pos_x
	CLC
	CMP #$16 ; #$0E port change
	BCS intruder_draw_enemy_down
	CLC
	CMP #$02 ; #$02 port change
	BCC intruder_draw_enemy_down
	JMP intruder_loop
intruder_draw_enemy_down
	LDX #intruder_max_enemies
intruder_draw_enemy_down_clear
	LDA intruder_enemy_visible,X
	BEQ intruder_draw_enemy_down_skip
	JSR intruder_draw_enemy_clear
intruder_draw_enemy_down_skip
	DEX
	CPX #$FF
	BNE intruder_draw_enemy_down_clear
	LDA intruder_enemy_fall
	CLC
	ROR A
	ROR A
	ROR A
	ROR A 
	CLC
	ADC intruder_enemy_pos_y
	STA intruder_enemy_pos_y
intruder_loop
	JMP intruder_input


intruder_draw_menu
	LDA #$03
	STA printchar_x
	LDA #$00
	STA printchar_y
	LDA intruder_points_low ; needs colornum to not display hundreds digit if zero!!!
	JSR colornum
	LDA #$01
	STA printchar_x
	LDA #$00
	STA printchar_y
	LDA intruder_points_high
	JSR colornum
	LDA #$3C
	STA printchar_x
	LDA #$00
	STA printchar_y
	LDA intruder_player_lives
	JSR colornum
	RTS


intruder_gameover
	JSR intruder_gameover_draw
intruder_gameover_loop1
	LDA joy_buttons
	CMP #$FF
	BNE intruder_gameover_loop1
intruder_gameover_loop2
	LDA joy_buttons
	ORA #%11001111
	CMP #$FF
	BEQ intruder_gameover_keys
	JMP intruder
intruder_gameover_keys
	JSR inputchar
	CMP #$00
	BEQ intruder_gameover_loop2
	JSR function_keys
	CMP #$20 ; space
	BNE intruder_gameover_loop2
	JMP intruder


intruder_nextlevel
	; put stuff here?
	INC intruder_level
	JMP intruder_init_level
	

intruder_mystery_clear
	LDX #$00
intruder_draw_mystery_clear1
	STZ $1000,X
	INX
	BNE intruder_draw_mystery_clear1
intruder_draw_mystery_clear2
	STZ $1100,X
	INX
	BNE intruder_draw_mystery_clear2
intruder_draw_mystery_clear3
	STZ $1200,X
	INX
	BNE intruder_draw_mystery_clear3
intruder_draw_mystery_clear4
	STZ $1300,X
	INX
	BNE intruder_draw_mystery_clear4
	RTS


intruder_draw_missile_particle_write
	PHA
	AND #%00001111
	JSR sub_write
	INC sub_write+1
	PLA
	AND #%11110000
	JSR sub_write
	RTS

intruder_draw_missile_particle_clear ; sub_write already populated!
	PHX
	LDX #$08
intruder_draw_missile_particle_clear_start
	LDA #$00
	JSR intruder_draw_missile_particle_write
	LDA sub_write+1
	CLC
	ADC #$7F
	STA sub_write+1
	BCC intruder_draw_missile_particle_clear_increment
	INC sub_write+2
intruder_draw_missile_particle_clear_increment	
	DEX
	BNE intruder_draw_missile_particle_clear_start
	PLX
	RTS

intruder_draw_missile_particle_color ; sub_write already populated! Y has color	
	TYA
	EOR #$FF	
	STA intruder_color_current
	PHX
	LDA sub_write+1
	STA sub_read+1
	LDA sub_write+2
	STA sub_read+2
	LDX #$08
intruder_draw_missile_particle_color_start
	JSR sub_read
	AND intruder_color_current
	BNE intruder_draw_missile_particle_color_hit
	INC sub_read+1
	JSR sub_read
	AND intruder_color_current
	BNE intruder_draw_missile_particle_color_hit
	TYA
	JSR intruder_draw_missile_particle_write
	LDA sub_write+1
	CLC
	ADC #$7F
	STA sub_write+1
	STA sub_read+1
	BCC intruder_draw_missile_particle_color_increment
	INC sub_write+2
	INC sub_read+2
intruder_draw_missile_particle_color_increment	
	DEX
	BNE intruder_draw_missile_particle_color_start
	PLX
	LDX #$00
	RTS
intruder_draw_missile_particle_color_hit
	JSR sub_read
	PLX
	LDX #$01
	RTS

intruder_draw_enemy_clear ; X already populated
	PHX
	TXA
	AND #%00000111
	PHY ; port change down
	TAY
	LDA #$00
intruder_draw_enemy_clear_addition
	CLC
	ADC #$0E
	DEY
	BNE intruder_draw_enemy_clear_addition
	PLY	
;	CLC
;	ROL A
;	ROL A
;	ROL A ; port change up
	ADC intruder_enemy_pos_x
	STA sub_write+1
	TXA
	AND #%11111000
	ADC intruder_enemy_pos_y
	STA sub_write+2
	LDX #$00
	LDY #$00
	PHY
intruder_draw_enemy_clear_loop
	LDA #$00
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$06
	BNE intruder_draw_enemy_clear_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7A
	STA sub_write+1
	BCC intruder_draw_enemy_clear_loop
	INC sub_write+2
	PLA
	INC A
	CMP #$03
	PHA
	BNE intruder_draw_enemy_clear_loop
	PLA
	PLX
	RTS

intruder_init_shield ; A has horizontal position
	STA sub_write+1
	LDA #$6C
	STA sub_write+2
	LDA #<intruder_shield_data
	STA sub_index+1
	LDA #>intruder_shield_data
	STA sub_index+2
	LDX #$00
	LDY #$00
intruder_init_shield_loop
	JSR sub_index
	AND #intruder_color_shield
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$08
	BNE intruder_init_shield_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$78
	STA sub_write+1
	BCC intruder_init_shield_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$72
	BCC intruder_init_shield_loop
	RTS

intruder_pause_draw
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
intruder_pause_draw_loop
	LDA intruder_pause_text,Y
	JSR colorchar
	INC printchar_x
	INY
	CPY #$06
	BNE intruder_pause_draw_loop
	RTS

intruder_pause_clear
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
intruder_pause_clear_loop
	LDA #" "
	JSR colorchar
	INC printchar_x
	INY
	CPY #$06
	BNE intruder_pause_clear_loop
	RTS

intruder_gameover_draw
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
intruder_gameover_draw_loop
	LDA intruder_gameover_text,Y
	JSR colorchar
	INC printchar_x
	INY
	CPY #$09
	BNE intruder_gameover_draw_loop
	RTS


intruder_pause_text
	.BYTE "Paused"
intruder_gameover_text
	.BYTE "Game "
	.BYTE "Over"

intruder_player_data
	.BYTE $00,$00,$00,$0F,$F0,$00,$00,$00
	.BYTE $00,$00,$00,$FF,$FF,$00,$00,$00
	.BYTE $00,$00,$0F,$FF,$FF,$F0,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00
	;.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00
	;.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00

intruder_shield_data
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00
	.BYTE $00,$FF,$FF,$FF,$FF,$FF,$FF,$00
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$00,$00,$FF,$FF,$FF

intruder_mystery_data
	.BYTE $00,$00,$FF,$00,$00,$FF,$00,$00
	.BYTE $00,$00,$0F,$F0,$0F,$F0,$00,$00
	.BYTE $00,$00,$00,$FF,$FF,$00,$00,$00
	.BYTE $00,$00,$0F,$FF,$FF,$F0,$00,$00
	.BYTE $00,$00,$FF,$0F,$F0,$FF,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00
	.BYTE $00,$00,$0F,$FF,$FF,$F0,$00,$00
	.BYTE $00,$00,$00,$FF,$FF,$00,$00,$00

intruder_enemy_data1
	.BYTE $00,$00,$FF,$FF,$00,$00
	.BYTE $00,$0F,$FF,$FF,$F0,$00
	.BYTE $00,$FF,$00,$00,$FF,$00
	.BYTE $00,$0F,$FF,$FF,$F0,$00
	.BYTE $00,$00,$F0,$0F,$00,$00
	.BYTE $00,$FF,$F0,$0F,$FF,$00

intruder_enemy_data2
	.BYTE $00,$0F,$FF,$FF,$F0,$00
	.BYTE $00,$FF,$00,$00,$FF,$00
	.BYTE $00,$0F,$FF,$FF,$F0,$00
	.BYTE $00,$00,$FF,$FF,$00,$00
	.BYTE $00,$00,$F0,$0F,$00,$00
	.BYTE $00,$0F,$F0,$0F,$F0,$00

intruder_enemy_data3
	.BYTE $00,$0F,$F0,$0F,$F0,$00
	.BYTE $00,$F0,$FF,$FF,$0F,$00
	.BYTE $00,$00,$F0,$0F,$00,$00
	.BYTE $00,$FF,$FF,$FF,$FF,$00
	.BYTE $00,$FF,$F0,$0F,$FF,$00
	.BYTE $00,$F0,$00,$00,$0F,$00

intruder_enemy_data4
	.BYTE $00,$FF,$F0,$0F,$FF,$00
	.BYTE $00,$00,$FF,$FF,$00,$00
	.BYTE $00,$00,$F0,$0F,$00,$00
	.BYTE $00,$0F,$FF,$FF,$F0,$00
	.BYTE $00,$FF,$F0,$0F,$FF,$00
	.BYTE $00,$0F,$F0,$0F,$F0,$00



tetra_color_fore	.EQU $77
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
	CMP #$00
	BEQ colornum_100_skip
	CLC
	ADC #"0"
	JSR colorchar
colornum_100_skip
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
;	CMP #$00
;	BEQ colornum_10_skip
	CLC
	ADC #"0"
	JSR colorchar
colornum_10_skip
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



basic
	LDA #$E1 ; produces greyscale
	STA $FFFF ; write non-$00 to ROM for 64-column 4-color mode

basic_prompt
	STZ basic_wait_end
	STZ basic_wait_delete

	STZ basic_line_low
	STZ basic_line_high

	LDA #$5C ; prompt
	JSR printchar
	LDA #$10 ; cursor
	JSR printchar
	
	LDX #$40
basic_string
	DEX
	STZ command_string,X
	CPX #$00
	BNE basic_string

basic_loop
	CLC
	JSR sub_random ; helps randomize
	
	JSR inputchar
	CMP #$00
	BEQ basic_loop

	CMP #$15 ; F12 for help
	BNE basic_loop_continue
	JSR help_basic
	JMP basic_prompt
basic_loop_continue

	CMP #$11 ; arrow up
	BEQ basic_loop
	CMP #$12 ; arrow down
	BEQ basic_loop
	CMP #$13 ; arrow left
	BEQ basic_loop
	CMP #$14 ; arrow right
	BEQ basic_loop
	CMP #$09 ; tab
	BNE basic_loop_tab
	LDX printchar_x
	LDA command_string,X
	BEQ basic_loop

basic_loop_tab
	PHA
	LDA #$10 ; cursor
	JSR printchar
	PLA

	JSR function_keys
	CMP #$1B ; escape
	BEQ basic_escape
	CMP #$0D ; return
	BEQ basic_carriage
	
	CLC
	CMP #$20
	BCC basic_loop_print
	CLC
	CMP #$61 ; lower A
	BCC basic_loop_store
	CLC
	CMP #$7B ; one past lower Z
	BCS basic_loop_store
	SEC
	SBC #$20 ; make upper case

basic_loop_store
	LDX printchar_x
	CPX #$3F
	BEQ basic_loop_cursor
	STA command_string,X
basic_loop_print
	JSR printchar ; print actual character
basic_loop_cursor
	LDA #$10 ; cursor
	JSR printchar
	JMP basic_loop


basic_escape
	LDA #$0D ; return
	JSR printchar
	JMP basic_prompt
basic_escape_check ; subroutine
	JSR inputchar
	CMP #$1B ; escape to break
	BEQ basic_escape
	CMP #$00
	BEQ basic_escape_exit
	PHX
	PHA
	LDX #$0F
basic_escape_loop
	LDA basic_keys,X
	CMP #$00
	BEQ basic_escape_found
	DEX
	CPX #$FF
	BNE basic_escape_loop
	LDX #$0F
basic_escape_shift
	LDA basic_keys_plus_one,X
	STA basic_keys,X
	DEX
	BNE basic_escape_shift
basic_escape_found
	PLA
	STA basic_keys,X
	PLX
basic_escape_exit
	RTS


basic_carriage
	JSR printchar ; print return character
	LDX #$00
basic_carriage_clear
	STZ basic_keys,X
	INX
	CPX #$10
	BNE basic_carriage_clear
	LDY #$00
basic_return
	JSR basic_escape_check
	CLC
	CPY #$40
	BCC basic_return_next
	JMP basic_prompt
basic_return_next
	LDA command_string,Y
	CLC
	CMP #$30 ; 0
	BCC basic_return_increment
	CLC
	CMP #$3A ; 9 + 1
	BCS basic_return_commands
	JSR basic_line
	JMP basic_return
basic_return_commands
	PHA
	JSR basic_commands
	STA basic_character
	PLA
	CMP #"P"
	BNE basic_return_success
	LDA #$0D
	JSR printchar
basic_return_success
	LDA basic_character
	CMP #$FF ; change to $00???
	BEQ basic_return
basic_return_increment
	INY
	CLC
	CPY #$40
	BCC basic_return
	JMP basic_prompt



basic_commands
	CMP #"Q" ; quit
	BNE basic_commands_end
	JMP basic_prompt
basic_commands_end
	CMP #"E" ; end
	BNE basic_commands_wait
	JSR basic_end
	JMP basic_commands_success
basic_commands_wait
	PHA
	LDA basic_wait_end
	BEQ basic_commands_continue
	PLA
	INY
basic_commands_wait_loop
	LDA command_string,Y
	CMP #$00
	BEQ basic_commands_wait_found
	CMP #$17
	BEQ basic_commands_wait_found
	CMP #$3A
	BEQ basic_commands_wait_increment
	INY
	CLC
	CPY #$40
	BCC basic_commands_wait_loop
	JMP basic_commands_failure
basic_commands_wait_increment
	INY
basic_commands_wait_found
	JMP basic_commands_success
basic_commands_continue
	PLA
	CMP #"R" ; run
	BNE basic_commands_next1
	JMP basic_run
basic_commands_next1
	CMP #"L" ; list
	BNE basic_commands_next2
	JSR basic_list
	LDA #$0D
	JSR printchar
	JMP basic_commands_success
basic_commands_next2
	CMP #"D" ; delete
	BNE basic_commands_next3
	JSR basic_delete
	JMP basic_commands_success
basic_commands_next3
	CMP #"C" ; clear
	BNE basic_commands_next4
	JSR basic_clear
	JMP basic_commands_success
basic_commands_next4
	CMP #"V" ; var
	BNE basic_commands_next5
	JSR basic_var
	JMP basic_commands_success
basic_commands_next5
	CMP #"P" ; print
	BNE basic_commands_next6
	JSR basic_print
	JMP basic_commands_success
basic_commands_next6
	CMP #"G" ; goto
	BNE basic_commands_next7
	JSR basic_run ; same as 'run'
	JMP basic_commands_success
basic_commands_next7
	CMP #"S" ; scan 
	BNE basic_commands_next8
	JSR basic_scan
	JMP basic_commands_success
basic_commands_next8
	CMP #"N" ; num
	BNE basic_commands_next9
	JSR basic_num
	JMP basic_commands_success
basic_commands_next9
	CMP #"I" ; if
	BNE basic_commands_next10
	JSR basic_if
	JMP basic_commands_success
basic_commands_next10
	CMP #"M" ; mem
	BNE basic_commands_next11
	JSR basic_mem
	JMP basic_commands_success
basic_commands_next11
	CMP #"T" ; tune
	BNE basic_commands_next12
	JSR basic_tune
	JMP basic_commands_success
basic_commands_next12
	NOP
basic_commands_failure
	LDA #$00
	RTS
basic_commands_success
	LDA #$FF
	RTS


basic_line
	STZ basic_value1_low
	STZ basic_value1_high	
basic_line_value_start
	LDA command_string,Y
	CMP #" "
	BEQ basic_line_value_exit
	CLC
	CMP #$30 ; 0
	BCC basic_line_value_wrong
	CLC
	CMP #$3A ; 9 + 1
	BCS basic_line_value_wrong
	STA basic_character
	LDA #$0A
	STA basic_value2_low
	STZ basic_value2_high
	JSR basic_mul
	LDA basic_character
	SEC
	SBC #"0"
	STA basic_value2_low
	STZ basic_value2_high
	JSR basic_add	
	INY
	CLC
	CPY #$40
	BCC basic_line_value_start
basic_line_value_exit
	LDA basic_value1_high
	CMP #$00
	CLC
	CMP #$80
	BCS basic_line_value_error
	CMP #$00
	BNE basic_line_value_ready
	LDA basic_value1_low
	BNE basic_line_value_ready
basic_line_value_error
	LDA #$FF
	RTS
basic_line_value_wrong
	LDA basic_wait_delete
	BEQ basic_line_value_error
	JMP basic_line_value_exit
basic_line_value_ready
	LDA #<basic_memory
	STA sub_read+1
	LDA #>basic_memory
	STA sub_read+2
basic_line_seek
	JSR sub_read
	CMP #$00
	BNE basic_line_seek_continue
	JMP basic_line_seek_check
basic_line_seek_continue
	CMP #$17 ; line delimiter
	BEQ basic_line_seek_number
basic_line_seek_increment
	INC sub_read+1
	BNE basic_line_seek
	INC sub_read+2
	LDA sub_read+2
	CMP #>basic_memory_end
	BNE basic_line_seek
	JMP basic_line_new_exit
basic_line_seek_number
	LDA sub_read+1
	STA basic_value3_low
	LDA sub_read+2
	STA basic_value3_high
	INC sub_read+1
	BNE basic_line_seek_number_next1
	INC sub_read+2
	LDA sub_read+2
	CMP #>basic_memory_end
	BNE basic_line_seek_number_next2
	JMP basic_line_new_exit
basic_line_seek_number_next1
	JSR sub_read
	STA basic_value4_low
	INC sub_read+1
	BNE basic_line_seek_number_next2
	INC sub_read+2
	LDA sub_read+2
	CMP #>basic_memory_end
	BNE basic_line_seek_number_next2
	JMP basic_line_new_exit
basic_line_seek_number_next2
	JSR sub_read
	STA basic_value4_high
	CLC
	CMP basic_value1_high
	BCC basic_line_seek_increment
	BEQ basic_line_seek_number_equal
	LDA basic_value3_low
	STA sub_read+1
	LDA basic_value3_high
	STA sub_read+2
	JMP basic_line_seek_check
basic_line_seek_number_equal
	LDA basic_value4_low
	CLC
	CMP basic_value1_low
	BCC basic_line_seek_increment
	BNE basic_line_seek_number_check
	JSR basic_line_delete
	JMP basic_line_seek_check
basic_line_seek_number_check
	LDA basic_value3_low
	STA sub_read+1
	LDA basic_value3_high
	STA sub_read+2
basic_line_seek_check
	JSR sub_read
	CMP #$00
	BEQ basic_line_new
	LDA basic_wait_delete
	BEQ basic_line_insert
	JMP basic_line_new_exit
basic_line_insert
	PHY
	LDX #$00
basic_line_insert_count
	LDA command_string,Y
	INY
	CLC
	CPY #$40
	BCS basic_line_insert_count_complete	
	CMP #$00
	BEQ basic_line_insert_count_complete
	INX
	JMP basic_line_insert_count
basic_line_insert_count_complete
	PLY
	LDA sub_read+1
	STA basic_value3_low
	LDA sub_read+2
	STA basic_value3_high
	TXA
	CLC
	ADC #$04
	EOR #$FF
	INC A
	STA sub_read+1
	LDA #>basic_memory_end
	DEC A
	STA sub_read+2
	LDA #$FF
	STA sub_write+1
	LDA #>basic_memory_end
	DEC A
	STA sub_write+2
basic_line_insert_loop
	JSR sub_read
	JSR sub_write
	DEC sub_write+1
	LDA sub_write+1
	CMP #$FF
	BNE basic_line_insert_decrement
	DEC sub_write+2
basic_line_insert_decrement
	DEC sub_read+1
	LDA sub_read+1
	CMP #$FF
	BNE basic_line_insert_compare
	DEC sub_read+2
basic_line_insert_compare
	LDA sub_read+2
	CMP basic_value3_high
	BNE basic_line_insert_loop
	LDA sub_read+1
	CMP basic_value3_low
	BNE basic_line_insert_loop
	JSR sub_read
	JSR sub_write
	
basic_line_new
	LDA basic_wait_delete
	BNE basic_line_new_exit
	LDA sub_read+1
	STA sub_write+1
	LDA sub_read+2
	STA sub_write+2
	LDA #$17 ; line delimiter
	JSR sub_write
	JSR basic_line_new_increment
	LDA basic_value1_low
	JSR sub_write
	JSR basic_line_new_increment
	LDA basic_value1_high
	JSR sub_write
	JSR basic_line_new_increment
basic_line_new_loop
	LDA command_string,Y
	BEQ basic_line_new_exit
	JSR sub_write
	JSR basic_line_new_increment
	INY
	CLC
	CPY #$40
	BCC basic_line_new_loop
	JMP basic_line_new_exit
basic_line_new_increment ; subroutine
	INC sub_write+1
	BNE basic_line_new_exit
	INC sub_write+2
	LDA sub_write+2
	CMP #>basic_memory_end
	BNE basic_line_new_exit
	LDY #$40
	PLA
	PLA
basic_line_new_exit
	RTS

basic_line_delete
	LDA sub_read+1
	STA basic_value3_low
	LDA sub_read+2
	STA basic_value3_high
	LDX #$00
basic_line_delete_count
	INC sub_read+1
	BNE basic_line_delete_count_increment
	INC sub_read+2
basic_line_delete_count_increment
	INX
	JSR sub_read
	CMP #$00
	BEQ basic_line_delete_count_done
	CMP #$17
	BEQ basic_line_delete_count_done
	JMP basic_line_delete_count
basic_line_delete_count_done
	LDA basic_value3_low
	STA sub_write+1
	LDA basic_value3_high
	STA sub_write+2
	DEC sub_write+1
	LDA sub_write+1
	CMP #$FF
	BNE basic_line_delete_shift1
	DEC sub_write+2
basic_line_delete_shift1
	DEC sub_write+1
	LDA sub_write+1
	CMP #$FF
	BNE basic_line_delete_shift2
	DEC sub_write+2
basic_line_delete_shift2
	LDA sub_write+2
	STA sub_read+2
	TXA
	CLC
	ADC basic_value3_low
	STA sub_read+1
	BCC basic_line_delete_loop
	INC sub_read+2
basic_line_delete_loop
	JSR sub_read
	JSR sub_write
	INC sub_write+1
	BNE basic_line_delete_loop_increment
	INC sub_write+2
basic_line_delete_loop_increment
	INC sub_read+1
	BNE basic_line_delete_loop_check
	INC sub_read+2
basic_line_delete_loop_check
	LDA sub_read+2
	CMP #>basic_memory_end
	BNE basic_line_delete_loop
	JSR sub_read
	JSR sub_write
	LDA basic_value3_low
	STA sub_read+1
	LDA basic_value3_high
	STA sub_read+2
	DEC sub_read+1
	LDA sub_read+1
	CMP #$FF
	BNE basic_line_delete_shift3
	DEC sub_read+2
basic_line_delete_shift3
	DEC sub_read+1
	LDA sub_read+1
	CMP #$FF
	BNE basic_line_delete_shift4
	DEC sub_read+2
basic_line_delete_shift4
	LDA basic_wait_delete
	BEQ basic_line_delete_exit
	PLA
	PLA
basic_line_delete_exit
	RTS


basic_run
	LDA #" "
	JSR basic_search_character
	LDA #<basic_memory
	STA sub_read+1
	LDA #>basic_memory
	STA sub_read+2
	JSR basic_search_value
	LDA basic_value1_low
	STA basic_line_low
	LDA basic_value1_high
	STA basic_line_high
basic_run_line
	CMP #$00
	BNE basic_run_decrement
	LDA basic_line_low
	CMP #$00
	BNE basic_run_decrement
	JMP basic_run_loop
basic_run_decrement
	DEC basic_line_low
	LDA basic_line_low
	CMP #$FF
	BNE basic_run_loop
	DEC basic_line_high
basic_run_loop
	JSR basic_escape_check
	JSR sub_read
	INC sub_read+1
	BNE basic_run_loop_next
	INC sub_read+2
basic_run_loop_next
	CMP #$00
	BEQ basic_run_exit
	CMP #$17
	BEQ basic_run_ready
	LDA sub_read+2
	CMP #>basic_memory_end
	BEQ basic_run_exit
	JMP basic_run_loop
basic_run_exit
	JMP basic_escape
basic_run_ready
	JSR sub_read
	STA basic_value2_low
	INC sub_read+1
	BNE basic_run_second
	INC sub_read+2
basic_run_second
	JSR sub_read
	STA basic_value2_high
	INC sub_read+1
	BNE basic_run_check
	INC sub_read+2
basic_run_check
	LDA basic_line_high
	CLC
	CMP basic_value2_high
	BCC basic_run_higher
	LDA basic_line_low
	CLC
	CMP basic_value2_low
	BCC basic_run_higher
	JMP basic_run_loop
basic_run_higher
	LDA basic_value2_low
	STA basic_line_low
	LDA basic_value2_high
	STA basic_line_high
	LDX #$00
basic_run_clear
	STZ command_string,X
	INX 
	CPX #$40
	BNE basic_run_clear
	LDY #$00
basic_run_sub
	JSR basic_escape_check
	JSR sub_read
	CMP #$00
	BEQ basic_run_execute
	CMP #$17
	BEQ basic_run_execute
	STA command_string,Y
	INY
	INC sub_read+1
	BNE basic_run_sub
	INC sub_read+2
	JMP basic_run_sub
basic_run_execute
	LDY #$00
basic_run_execute_loop
	LDA command_string,Y
	JSR basic_commands
	INY
	CLC
	CPY #$40
	BCC basic_run_execute_loop
	JMP basic_run_loop


basic_list
	DEC printchar_y ; shift output up
	LDA #" "
	JSR basic_search_character
	JSR basic_search_value
	LDA basic_value1_low
	PHA
	LDA basic_value1_high
	PHA
	INY
	JSR basic_search_value
	LDA basic_value1_high
	BNE basic_list_nonzero
	LDA basic_value1_low
	BNE basic_list_nonzero
	LDA #$FF
	STA basic_value3_low
	STA basic_value3_high
	JMP basic_list_nonzero_done
basic_list_nonzero
	LDA basic_value1_low
	STA basic_value3_low
	LDA basic_value1_high
	STA basic_value3_high
basic_list_nonzero_done
	PLA
	STA basic_value2_high
	PLA
	STA basic_value2_low 
	LDA #$3A ; colon
	JSR basic_search_character 
	LDA #<basic_memory
	STA sub_read+1
	LDA #>basic_memory
	STA sub_read+2
	STZ basic_character
basic_list_loop
	JSR basic_escape_check
	JSR sub_read
	CMP #$00
	BEQ basic_list_exit
basic_list_increment
	INC sub_read+1
	BNE basic_list_continue
	INC sub_read+2
basic_list_continue
	CMP #$17
	BEQ basic_list_line
	PHA
	LDA basic_character
	CMP #$01
	BNE basic_list_postprint
	PLA
	JSR printchar
	PHA
basic_list_postprint
	PLA
	LDA sub_read+2
	CMP #>basic_memory_end
	BNE basic_list_loop
basic_list_exit
	RTS
basic_list_line
	JSR sub_read
	STA basic_value1_low
	INC sub_read+1
	BNE basic_list_next
	INC sub_read+2
basic_list_next	
	JSR sub_read
	STA basic_value1_high
	CLC
	CMP basic_value2_high
	BCC basic_list_jump_low
	LDA basic_value1_low
	CLC
	CMP basic_value2_low
	BCC basic_list_jump_low
	LDA basic_value3_high
	CLC
	CMP basic_value1_high
	BCC basic_list_jump_high
	LDA basic_value3_low
	CLC
	CMP basic_value1_low
	BCC basic_list_jump_high
	LDA #$0D
	JSR printchar
	LDA basic_value2_low
	PHA
	LDA basic_value2_high
	PHA
	LDA basic_value3_low
	PHA
	LDA basic_value3_high
	PHA
	JSR basic_print_number
	PLA
	STA basic_value3_high
	PLA
	STA basic_value3_low
	PLA
	STA basic_value2_high
	PLA
	STA basic_value2_low
	LDA #$01
	STA basic_character
	JMP basic_list_increment
basic_list_jump_low
	LDA #$00
	STA basic_character
	JMP basic_list_increment
basic_list_jump_high
	LDA #$02
	STA basic_character
	JMP basic_list_increment


basic_delete
	JSR basic_search_space
	LDA #$FF
	STA basic_wait_delete
	JMP basic_line
	STZ basic_wait_delete	
	RTS


basic_clear
	LDA #3A ; colon
	JSR basic_search_character
	LDA #<basic_memory
	STA sub_write+1
	LDA #>basic_memory
	STA sub_write+2
basic_clear_loop
	LDA #$00
	JSR sub_write
	INC sub_write+1
	BNE basic_clear_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #>basic_memory_end
	BNE basic_clear_loop
	RTS


basic_var
	JSR basic_search_space
	JSR basic_search_letter
	CMP #$00
	BEQ basic_var_exit
	SEC
	SBC #"A"
	PHA
	LDA #"="
	JSR basic_search_character
	CMP #$00
	BEQ basic_var_exit
	INY
	JSR basic_search_value
	PLX
	LDA basic_value1_low
	STA basic_variables_low,X
	LDA basic_value1_high
	STA basic_variables_high,X
	PHA
basic_var_exit
	PLA
	RTS

basic_print
	LDA #" "
	JSR basic_search_character
	CMP #$00
	BEQ basic_print_exit
	PHY
	LDA #$22 ; double quotes
	JSR basic_search_character
	CMP #$00
	BEQ basic_print_value
	PLA
	INY
basic_print_text
	JSR basic_escape_check
	LDA command_string,Y
	INY
	CLC
	CPY #$40
	BCS basic_print_exit
	CMP #$22 ; double quote
	BEQ basic_print_exit
	CMP #$5C ; slash
	BNE basic_print_text_ready	
	LDA #$0D ; return
basic_print_text_ready
	JSR printchar
	JMP basic_print_text
basic_print_exit
	INY
	RTS
basic_print_value
	PLY
	JSR basic_search_value
basic_print_number
	LDA basic_value1_high
	CLC
	CMP #$80
	BCC basic_print_unsigned
	EOR #$FF
	STA basic_value1_high
	LDA basic_value1_low
	EOR #$FF
	INC A
	STA basic_value1_low
	BNE basic_print_negative
	INC basic_value1_high
basic_print_negative
	LDA #"-"
	JSR printchar
basic_print_unsigned
	STZ basic_character
	LDA basic_value1_low
	STA basic_value4_low
	LDA basic_value1_high
	STA basic_value4_high
	LDA #$10
	STA basic_value2_low
	LDA #$27
	STA basic_value2_high
	JSR basic_print_digit
	LDA #$E8
	STA basic_value2_low
	LDA #$03
	STA basic_value2_high
	JSR basic_print_digit
	LDA #$64
	STA basic_value2_low
	LDA #$00
	STA basic_value2_high
	JSR basic_print_digit
	LDA #$0A
	STA basic_value2_low
	LDA #$00
	STA basic_value2_high
	JSR basic_print_digit
	LDA basic_value1_low
	CLC
	ADC #$30
	JSR printchar
	JMP basic_print_exit
basic_print_digit
	JSR basic_div
	LDA basic_character
	BNE basic_print_digit_ready
	LDA basic_value1_low
	BEQ basic_print_digit_skip
basic_print_digit_ready
	LDA basic_value1_low
	CLC
	ADC #$30
	JSR printchar
	STA basic_character
basic_print_digit_skip
	LDA basic_value4_low
	STA basic_value1_low
	LDA basic_value4_high
	STA basic_value1_high
	JSR basic_mod
	LDA basic_value1_low
	STA basic_value4_low
	LDA basic_value1_high	
	STA basic_value4_high
	RTS

basic_scan
	JSR basic_search_space
	JSR basic_search_letter
	CMP #$00
	BEQ basic_scan_exit
	SEC
	SBC #"A"
	PHA
	LDX #$00
basic_scan_loop
	LDA basic_keys,X
	BNE basic_scan_found
	INX
	CPX #$10
	BNE basic_scan_loop
	JMP basic_scan_get
basic_scan_found
	STZ basic_keys,X
basic_scan_get	
	PLX
	STA basic_variables_low,X
	STZ basic_variables_high,X
basic_scan_exit
	RTS



basic_num
	LDA #$0D ; return
	JSR printchar
	LDA #$10 ; cursor
	JSR printchar
	JSR basic_search_space
	JSR basic_search_letter
	CMP #$00
	BEQ basic_num_exit
	SEC
	SBC #"A"
	PHA ; letter
	LDA #$00
	PHA ; negative
	LDX #$00
basic_num_clear
	STZ basic_keys,X
	INX
	CPX #$10
	BNE basic_num_clear
basic_num_loop
	JSR inputchar
	CMP #$00
	BEQ basic_num_loop
	CMP #$1B ; escape
	BEQ basic_num_escape
	CMP #$0D
	BEQ basic_num_return
	CMP #$08
	BEQ basic_num_backspace
	CMP #$09
	BEQ basic_num_tab
	CMP #"-"
	BEQ basic_num_print
	CLC
	CMP #$30 ; 0
	BCC basic_num_loop
	CLC
	CMP #$3A ; 9 + 1
	BCS basic_num_loop
basic_num_print
	PHX
	LDX printchar_x
	STA basic_keys,X
	PLX
	JSR printchar
	LDA #$10 ; cursor
	JSR printchar
	LDA printchar_x
	CLC	
	CMP #$10
	BCC basic_num_loop
	JMP basic_num_return
basic_num_escape
	LDA #$0D ; return
	JSR printchar
	PLA
	PLA
	JMP basic_prompt
basic_num_exit
	RTS
basic_num_backspace
	LDA #$10 ; cursor
	JSR printchar
	LDA #$08
	JSR printchar
	LDA #$10 ; cursor
	JSR printchar
	JMP basic_num_loop
basic_num_tab
	LDA #$10 ; cursor
	JSR printchar
	PHX
	LDX printchar_x
	LDA basic_keys,X
	PLX
	CMP #$00
	BEQ basic_num_tab_cursor
	INC printchar_x
	LDA printchar_x
	CLC
	CMP #$10
	BCC basic_num_tab_cursor
	DEC printchar_x
basic_num_tab_cursor
	LDA #$10 ; cursor
	JSR printchar
	JMP basic_num_loop
basic_num_return
	LDA #$10 ; cursor
	JSR printchar
	LDA #$0D ; return
	JSR printchar
	STZ basic_value1_low
	STZ basic_value1_high
	LDX #$00
basic_num_count
	LDA basic_keys,X
	BEQ basic_num_store
	LDA #$0A
	STA basic_value2_low
	STZ basic_value2_high
	JSR basic_mul
	LDA basic_keys,X
	CMP #"-"
	BEQ basic_num_negative
	SEC
	SBC #"0"
	STA basic_value2_low
	STZ basic_value2_high
	JSR basic_add
basic_num_increment
	INX
	CPX #$10
	BNE basic_num_count
basic_num_store
	PLA
	BEQ basic_num_final
	LDA basic_value1_high
	EOR #$FF
	STA basic_value1_high
	LDA basic_value1_low
	EOR #$FF
	INC A
	STA basic_value1_low
	BNE basic_num_final
	INC basic_value1_high
basic_num_final
	PLX
	LDA basic_value1_low
	STA basic_variables_low,X
	LDA basic_value1_high
	STA basic_variables_high,X
	JMP basic_num_exit
basic_num_negative
	PLA
	EOR #$FF
	PHA
	JMP basic_num_increment


basic_if
	LDA #" "
	JSR basic_search_character
	CMP #$00
	BEQ basic_if_exit
	JSR basic_search_value
	CMP #$00
	BEQ basic_if_exit
	LDA command_string,Y
	PHA
	LDA basic_value1_low
	PHA
	LDA basic_value1_high
	PHA
	INY
	JSR basic_search_value
	LDA basic_value1_low
	STA basic_value3_low
	LDA basic_value1_high
	CLC
	ADC #$80 ; because everything is signed integers
	STA basic_value3_high
	PLA
	CLC
	ADC #$80 ; because everything is signed integers
	STA basic_value2_high
	PLA
	STA basic_value2_low
	PLA
	JMP basic_if_comparator1
basic_if_exit
	LDA #$FF
	RTS
basic_if_comparator1
	CMP #"="
	BNE basic_if_comparator2
	LDA basic_value2_high
	CMP basic_value3_high
	BNE basic_if_not
	LDA basic_value2_low
	CMP basic_value3_low
	BNE basic_if_not
	JMP basic_if_exit	
basic_if_comparator2
	CMP #$3C ; less than
	BNE basic_if_comparator3
	LDA basic_value3_high
	CLC
	CMP basic_value2_high
	BCC basic_if_not
	BNE basic_if_exit
	LDA basic_value3_low
	CLC
	CMP basic_value2_low
	BCC basic_if_not
	BEQ basic_if_not
	JMP basic_if_exit
basic_if_comparator3
	CMP #$3E ; greater than
	BNE basic_if_comparator4
	LDA basic_value2_high
	CLC
	CMP basic_value3_high
	BCC basic_if_not
	BNE basic_if_exit
	LDA basic_value2_low
	CLC
	CMP basic_value3_low
	BCC basic_if_not
	BEQ basic_if_not
	JMP basic_if_exit
basic_if_comparator4
	CMP #"#"
	BNE basic_if_exit
	LDA basic_value2_high
	CMP basic_value3_high
	BNE basic_if_exit
	LDA basic_value2_low
	CMP basic_value3_low
	BNE basic_if_exit
basic_if_not
	LDA #$FF
	STA basic_wait_end
	RTS

basic_end	
	STZ basic_wait_end
	LDA #$3A ; colon
	JSR basic_search_character
	RTS


basic_mem
	JSR basic_search_space
	JSR basic_search_value
	LDA command_string,Y
	CMP #"<"
	BEQ basic_mem_write
	CMP #">"
	BEQ basic_mem_read
	JMP basic_mem_exit
basic_mem_write
	LDA basic_value1_low
	STA sub_write+1
	LDA basic_value1_high
	STA sub_write+2
	INY
	JSR basic_search_value
	LDA basic_value1_low
	JSR sub_write
	RTS	
basic_mem_read
	LDA basic_value1_low
	PHA
	LDA basic_value1_high
	PHA
	INY
	JSR basic_search_letter
	CMP #$00
	BEQ basic_mem_exit
	SEC
	SBC #"A"
	TAX
	PLA
	STA sub_read+2
	PLA
	STA sub_read+1
	JSR sub_read
	STA basic_variables_low,X
	STZ basic_variables_high,X
basic_mem_exit
	RTS


basic_tune
	JSR basic_search_space
	JSR basic_search_value
	LDA basic_value1_low
	STA via_t1cl
	LDA basic_value1_high
	STA via_t1ch
	RTS



; pre-loaded in A
basic_search_character
	STA basic_character
basic_search_character_start
	LDA command_string,Y
	CMP #$3A ; colon
	BEQ basic_search_character_exit
	CMP basic_character
	BNE basic_search_character_loop
	RTS
basic_search_character_loop
	INY
	CLC
	CPY #$40
	BCC basic_search_character_start
basic_search_character_exit
	LDA #$00
	RTS

basic_search_space
	LDA #" "
	JSR basic_search_character
	CMP #$00
	BNE basic_search_space_exit
	PLA
	PLA ; remove last return address
basic_search_space_exit
	RTS

basic_search_letter
	LDA command_string,Y
	CLC
	CMP #$41
	BCC basic_search_letter_loop
	CLC
	CMP #$5B
	BCS basic_search_letter_loop
	RTS
basic_search_letter_loop
	INY
	CLC
	CPY #$40
	BCC basic_search_letter
	LDA #$00
	RTS

basic_search_value
	STZ basic_value1_low
	STZ basic_value1_high	
	STZ basic_value4_low
	STZ basic_value4_high
	LDA #"+"
	STA basic_operator
basic_search_value_start
	JSR basic_escape_check
	LDA command_string,Y
	CMP #"!" ; random
	BEQ basic_search_value_random
	CLC
	CMP #$30 ; 0
	BCC basic_search_value_list1
	CLC
	CMP #$3A ; 9 + 1
	BCS basic_search_value_list1
	JMP basic_search_value_digit
basic_search_value_random
	CLC
	JSR sub_random
	STA basic_value4_low
	STZ basic_value4_high
	JMP basic_search_value_loop
basic_search_value_list1
	CLC
	CMP #$41 ; A
	BCC basic_search_value_list2
	CLC
	CMP #$5B ; Z + 1
	BCS basic_search_value_list2
	JMP basic_search_value_letter
basic_search_value_list2
	CMP #"=" ; comparator
	BEQ basic_search_value_comparator
	CMP #$3C ; less than
	BEQ basic_search_value_comparator
	CMP #$3E ; greater than
	BEQ basic_search_value_comparator
	CMP #"#"
	BEQ basic_search_value_comparator
	CMP #$3A ; colon
	BEQ basic_search_value_comparator
	CMP #"+"
	BEQ basic_search_value_operator
	CMP #"-"
	BEQ basic_search_value_operator
	CMP #"*"
	BEQ basic_search_value_operator
	CMP #"/"
	BEQ basic_search_value_operator
	CMP #$25 ; mod
	BEQ basic_search_value_operator
	JMP basic_search_value_loop
basic_search_value_comparator
	JMP basic_search_value_operator
basic_search_value_loop
	INY
	CLC
	CPY #$40
	BCC basic_search_value_start
	LDA #$3A ; colon
	BNE basic_search_value_operator
basic_search_value_digit
	STA basic_character
	LDA basic_value1_low
	PHA
	LDA basic_value1_high
	PHA
	LDA basic_value4_low
	STA basic_value1_low
	LDA basic_value4_high
	STA basic_value1_high
	LDA #$0A
	STA basic_value2_low
	STZ basic_value2_high
	JSR basic_mul
	LDA basic_character
	SEC
	SBC #"0"
	STA basic_value2_low
	STZ basic_value2_high
	JSR basic_add	
	LDA basic_value1_low
	STA basic_value4_low
	LDA basic_value1_high
	STA basic_value4_high
	PLA
	STA basic_value1_high
	PLA
	STA basic_value1_low
	JMP basic_search_value_loop
basic_search_value_letter
	SEC
	SBC #"A"
	TAX
	LDA basic_variables_low,X
	STA basic_value4_low
	LDA basic_variables_high,X
	STA basic_value4_high
	JMP basic_search_value_loop
basic_search_value_operator
	PHA
	LDA basic_value4_low
	STA basic_value2_low
	LDA basic_value4_high
	STA basic_value2_high
	LDA basic_operator
	CMP #"+"
	BNE basic_search_value_operator_next1
	JSR basic_add
	JMP basic_search_value_operator_end
basic_search_value_operator_next1
	CMP #"-"
	BNE basic_search_value_operator_next2
	JSR basic_sub
	JMP basic_search_value_operator_end
basic_search_value_operator_next2
	CMP #"*"
	BNE basic_search_value_operator_next3
	JSR basic_mul
	JMP basic_search_value_operator_end
basic_search_value_operator_next3
	CMP #"/"
	BNE basic_search_value_operator_next4
	JSR basic_div
	JMP basic_search_value_operator_end
basic_search_value_operator_next4
	CMP #$25 ; mod
	BNE basic_search_value_operator_next5
	JSR basic_mod
	JMP basic_search_value_operator_end
basic_search_value_operator_next5
	NOP
basic_search_value_operator_end
	PLA
	STA basic_operator
	CMP #"="
	BEQ basic_search_value_exit
	CMP #$3C
	BEQ basic_search_value_exit
	CMP #$3E
	BEQ basic_search_value_exit
	CMP #"#"
	BEQ basic_search_value_exit
	CMP #$3A ; colon
	BEQ basic_search_value_exit
	STZ basic_value4_low
	STZ basic_value4_high
	JMP basic_search_value_loop
basic_search_value_exit
	RTS


basic_add
	LDA basic_value1_low
	CLC
	ADC basic_value2_low
	STA basic_value1_low
	BCC basic_add_next
	INC basic_value1_high
basic_add_next
	LDA basic_value1_high
	CLC
	ADC basic_value2_high
	STA basic_value1_high
	RTS

basic_sub
	LDA basic_value1_low
	SEC
	SBC basic_value2_low
	STA basic_value1_low
	BCS basic_sub_next
	DEC basic_value1_high
basic_sub_next
	LDA basic_value1_high
	SEC
	SBC basic_value2_high
	STA basic_value1_high
	RTS

basic_mul
	LDA basic_value2_low
	PHA
	LDA basic_value2_high
	PHA
	LDA basic_value1_low
	STA basic_value3_low
	LDA basic_value1_high
	STA basic_value3_high
	STZ basic_value1_low
	STZ basic_value1_high
basic_mul_start
	LDA basic_value2_high
	BNE basic_mul_ready
	LDA basic_value2_low
	BNE basic_mul_ready
	PLA
	STA basic_value2_high
	PLA
	STA basic_value2_low
	RTS
basic_mul_ready
	DEC basic_value2_low
	LDA basic_value2_low
	CMP #$FF
	BNE basic_mul_check
	DEC basic_value2_high
basic_mul_check
	LDA basic_value1_low
	CLC
	ADC basic_value3_low
	STA basic_value1_low
	BCC basic_mul_add
	INC basic_value1_high
basic_mul_add
	LDA basic_value1_high
	CLC
	ADC basic_value3_high
	STA basic_value1_high
	JMP basic_mul_start

basic_div
	STZ basic_value3_low
	STZ basic_value3_high
basic_div_start
	LDA basic_value1_low
	SEC
	SBC basic_value2_low
	STA basic_value1_low
	BCS basic_div_sub
	DEC basic_value1_high
	LDA basic_value1_high
	CMP #$FF
	BEQ basic_div_exit
basic_div_sub
	LDA basic_value1_high
	SEC
	SBC basic_value2_high
	STA basic_value1_high
	BCS basic_div_increment
basic_div_exit
	LDA basic_value3_low
	STA basic_value1_low
	LDA basic_value3_high
	STA basic_value1_high
	RTS
basic_div_increment
	INC basic_value3_low
	BNE basic_div_start
	INC basic_value3_high
	JMP basic_div_start

basic_mod
	LDA basic_value1_low
	STA basic_value3_low
	LDA basic_value1_high
	STA basic_value3_high
basic_mod_start
	LDA basic_value1_low
	SEC
	SBC basic_value2_low
	STA basic_value1_low
	BCS basic_mod_sub
	DEC basic_value1_high
	LDA basic_value1_high
	CMP #$FF
	BEQ basic_mod_exit
basic_mod_sub
	LDA basic_value1_high
	SEC
	SBC basic_value2_high
	STA basic_value1_high
	BCS basic_mod_store
basic_mod_exit
	LDA basic_value3_low
	STA basic_value1_low
	LDA basic_value3_high
	STA basic_value1_high
	RTS
basic_mod_store
	LDA basic_value1_low
	STA basic_value3_low
	LDA basic_value1_high
	STA basic_value3_high
	JMP basic_mod_start



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
	JSR longdelay
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
	JSR longdelay
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
	JSR longdelay
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
	JSR longdelay
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
	JSR longdelay
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
	JSR longdelay
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
	JSR longdelay
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
	LDX #$40 ; low addr
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


; A = $00 to write, A = $01 to read, returns $FF on success
sdcard_saveload
	PHX
	PHA
	LDA #$00
	STA sdcard_block+0
	LDA #$80
	STA sdcard_block+1
	LDX #$00
	LDY #$00
	JSR sdcard_initialize
	CMP #00
	BEQ sdcard_saveload_exit
sdcard_saveload_loop
	JSR inputchar
	CMP #$1B
	BEQ sdcard_saveload_exit
	PLA
	BEQ sdcard_saveload_write
	PHA
	JSR sdcard_readblock
	JMP sdcard_saveload_done
sdcard_saveload_write
	PHA
	JSR sdcard_writeblock
sdcard_saveload_done
	CMP #$00
	BEQ sdcard_saveload_exit
	INC sdcard_block+1
	INC sdcard_block+1
	INX
	INX
	CPX #$40
	BNE sdcard_saveload_loop
	PLA
	LDA #$FF ; success
	PHA
sdcard_saveload_exit
	PLA
	PLX
	RTS




scratchpad
	LDA #$E1 ; produces greyscale
	STA $FFFF ; write non-$00 to ROM for 64-column 4-color mode

	LDA #"*"
	STA scratchpad_lastchar

	LDA #$10 ; cursor
	JSR printchar

scratchpad_loop
	CLC
	JSR sub_random ; helps randomize

	JSR scratchpad_mouse

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

	STA scratchpad_lastchar
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

scratchpad_mouse
	PHA
	LDA mouse_buttons
	AND #%00001111
	CMP mouse_prev_buttons
	BNE scratchpad_mouse_draw
	LDA mouse_prev_x
	CMP mouse_pos_x
	BNE scratchpad_mouse_draw
	LDA mouse_prev_y
	CMP mouse_pos_y
	BNE scratchpad_mouse_draw
	JMP scratchpad_mouse_exit
scratchpad_mouse_draw
	LDA #$10
	JSR printchar
	LDA mouse_pos_x
	STA mouse_prev_x
	AND #%11111100
	CLC
	ROR A
	ROR A
	STA printchar_x
	LDA mouse_pos_y
	STA mouse_prev_y
	EOR #$FF
	INC A
	AND #%11111000
	CLC
	ROR A
	ROR A
	ROR A
	STA printchar_y
	LDA mouse_buttons
	AND #%00001111
	STA mouse_prev_buttons
	AND #%00000001
	BEQ scratchpad_mouse_space
	LDA scratchpad_lastchar
	JSR printchar
	LDA #$08 ; backspace
	JSR printchar
	JMP scratchpad_mouse_cursor
scratchpad_mouse_space
	LDA mouse_buttons
	AND #%00000010
	BEQ scratchpad_mouse_cursor
	LDA #" "
	JSR printchar
	LDA #$08 ; backspace
	JSR printchar
scratchpad_mouse_cursor
	LDA #$10
	JSR printchar
scratchpad_mouse_exit
	PLA
	RTS

monitor
	LDA #$E1 ; produces greyscale
	STA $FFFF ; write non-$00 to ROM for 64-column 4-color mode

monitor_prompt
	LDA #$24 ; prompt
	JSR printchar
	LDA #$10 ; cursor
	JSR printchar

	STZ monitor_mode
	
	LDX #$40
monitor_clear
	DEX
	STZ command_string,X
	CPX #$00
	BNE monitor_clear

monitor_loop
	CLC
	JSR sub_random ; helps randomize
	
	JSR inputchar
	CMP #$00
	BEQ monitor_loop

	CMP #$15 ; F12 for help
	BNE monitor_loop_continue
	JSR help_monitor
	JMP monitor_prompt
monitor_loop_continue

	CMP #$11 ; arrow up
	BEQ monitor_loop
	CMP #$12 ; arrow down
	BEQ monitor_loop
	CMP #$13 ; arrow left
	BEQ monitor_loop
	CMP #$14 ; arrow right
	BEQ monitor_loop
	CMP #$09 ; tab
	BNE monitor_loop_tab
	LDX printchar_x
	LDA command_string,X
	BEQ monitor_loop

monitor_loop_tab
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
	CMP #$20
	BCC monitor_loop_print
	CLC
	CMP #$61 ; lower A
	BCC monitor_loop_store
	CLC
	CMP #$7B ; one past lower Z
	BCS monitor_loop_store
	SEC
	SBC #$20 ; make upper case

monitor_loop_store
	LDX printchar_x
	CPX #$3F
	BEQ monitor_loop_cursor
	STA command_string,X
monitor_loop_print
	JSR printchar ; print actual character
monitor_loop_cursor
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

	LDA command_string,Y
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
	LDA command_string,Y
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



setup
	STZ printchar_inverse ; turn off inverse
	LDA #$FF ; white 
	STA printchar_foreground
	LDA #$00 ; black
	STA printchar_background

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

	LDA #$4C ; JMPa
	STA sub_sdcard_initialize+0
	LDA #<sdcard_initialize
	STA sub_sdcard_initialize+1
	LDA #>sdcard_initialize
	STA sub_sdcard_initialize+2

	LDA #$4C ; JMPa
	STA sub_sdcard_readblock+0
	LDA #<sdcard_readblock
	STA sub_sdcard_readblock+1
	LDA #>sdcard_readblock
	STA sub_sdcard_readblock+2

	LDA #$4C ; JMPa
	STA sub_sdcard_writeblock+0
	LDA #<sdcard_writeblock
	STA sub_sdcard_writeblock+1
	LDA #>sdcard_writeblock
	STA sub_sdcard_writeblock+2

	STZ sub_random_var

	LDX #$10
setup_random_loop
	LDA setup_random_code,X
	STA sub_random,X
	DEX
	CPX #$FF
	BNE setup_random_loop

	JSR basic_clear

	RTS

setup_random_code
	.BYTE $AD
	.WORD sub_random_var
	.BYTE $2A,$18,$2A,$18,$6D
	.WORD sub_random_var
	.BYTE $18,$69,$11,$8D
	.WORD sub_random_var
	.BYTE $60


function_keys
	CMP #$1C ; F1, scratchpad
	BNE function_keys_next1
function_keys_scratchpad
	LDA #$0C ; form feed
	JSR printchar
	JSR intro
	LDA #$FF
	STA function_mode
	PLA
	PLA
	JMP scratchpad
function_keys_next1
	CMP #$1D ; F2, monitor
	BNE function_keys_next2
	LDA #$0C ; form feed
	JSR printchar
	JSR menu
	LDA #$00
	STA function_mode
	PLA
	PLA
	JMP monitor
function_keys_next2
	CMP #$1E ; F3, basic
	BNE function_keys_next3
	LDA #$0C ; form feed
	JSR printchar
	JSR menu
	LDA #$01
	STA function_mode
	PLA
	PLA
	JMP basic
function_keys_next3
	CMP #$1F ; F4, tetra
	BNE function_keys_next4
	LDA #$02
	STA function_mode
	PLA
	PLA
	JMP tetra
function_keys_next4
	CMP #$16 ; F9, sdcard_bootloader
	BNE function_keys_next5
	LDA function_mode
	CMP #$FF
	BNE function_keys_exit
	JSR sdcard_bootloader
	CMP #$00
	BNE function_keys_exit ; successful exit
	BEQ function_keys_exit ; error	
	;JMP vector_reset ; error exit
function_keys_next5
	CMP #$0E ; F5, intruder
	BNE function_keys_next6
	LDA #$03
	STA function_mode
	PLA
	PLA
	JMP intruder
function_keys_next6
	CMP #$0F ; F6, defense
	BNE function_keys_next7
	LDA #$04
	STA function_mode
	PLA
	PLA
	JMP defense
function_keys_next7
	CMP #$07 ; F8, save/load (or bell)
	BNE function_keys_next8
	
	LDA function_mode
	CLC
	CMP #$02
	BCS function_keys_exit	

	LDA #"?"
	JSR printchar
	LDA #$08
	JSR printchar
function_keys_wait
	JSR inputchar
	CMP #$00
	BEQ function_keys_wait
	CMP #"<"
	BEQ function_keys_saveload_save
	CMP #">"
	BEQ function_keys_saveload_load
function_keys_next8
	RTS
function_keys_exit
	LDA #$00
	RTS

function_keys_saveload_load
	LDA #$01
	BNE function_keys_saveload_continue
function_keys_saveload_save
	LDA #$00
function_keys_saveload_continue
	JSR sdcard_saveload
	CMP #$FF
	BEQ function_keys_exit ; successful exit
function_keys_saveload_error
	LDA #"!"
	JSR printchar
	LDA #$08
	JSR printchar
	BNE function_keys_exit ; error	



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
	.BYTE "Acolyte "
	.BYTE "Computer"
	.BYTE $0D
	.BYTE "F1=Scrat"
	.BYTE "chpad, F"
	.BYTE "2=Monito"
	.BYTE "r, F3=BA"
	.BYTE "SIC, F4-"
	.BYTE "F6=Games"
	.BYTE ", F9=SDc"
	.BYTE "ard",$0D
	.BYTE $00	


menu
	LDX #$00
menu_loop
	LDA menu_text,X
	CMP #$00
	BEQ menu_exit
	JSR printchar
	INX
	BNE menu_loop
menu_exit
	LDA #$10
	JSR printchar
	RTS
menu_text
	.BYTE "ESC=Brea"
	.BYTE "k, F8=Sa"
	.BYTE "ve/Load,"
	.BYTE " F12=Hel"
	.BYTE "p",$0D
	.BYTE $00


help_monitor	
	LDX #$00
help_monitor_loop
	JSR inputchar
	CMP #$1B
	BEQ help_monitor_exit
	LDA help_monitor_text,X
	CMP #$00
	BEQ help_monitor_exit
	CMP #$17
	BEQ help_monitor_location
	JSR printchar
help_monitor_increment
	INX
	BNE help_monitor_loop
help_monitor_exit
	LDA #$10
	JSR printchar
	RTS
help_monitor_location
	LDA #>help_monitor_text+$02
	JSR help_print_hex
	LDA #<help_monitor_text+$02
	JSR help_print_hex
	LDA #"."
	JSR printchar
	LDA #>help_monitor_text+$11
	JSR help_print_hex
	LDA #<help_monitor_text+$11
	JSR help_print_hex
	JMP help_monitor_increment
help_monitor_text
	.BYTE $10,$0D
	.BYTE "Monitor "
	.BYTE "Examples"
	.BYTE $0D
	.BYTE "00>0000"
	.BYTE ".000FP",$3A
	.BYTE "EE0F0060"
	.BYTE ",LJJJ000"
	.BYTE "F;",$0D
	.BYTE "0000<",$17
	.BYTE "M,0000.0"
	.BYTE "00FL",$0D
	.BYTE $00

help_basic	
	LDA #<help_basic_text
	STA sub_read+1
	LDA #>help_basic_text
	STA sub_read+2
help_basic_loop
	JSR inputchar
	CMP #$1B
	BEQ help_monitor_exit
	JSR sub_read
	CMP #$00
	BEQ help_basic_exit
	JSR printchar
	INC sub_read+1
	BNE help_basic_loop
	INC sub_read+2	
	JMP help_basic_loop
help_basic_exit
	RTS
help_basic_text
	.BYTE $10,$0D
	.BYTE "BASIC Ke"
	.BYTE "ywords",$0D
	.BYTE "VAR, PRI"
	.BYTE "NT, SCAN"
	.BYTE ", NUM, T"
	.BYTE "UNE,",$0D
	.BYTE "IF, END,"
	.BYTE " GOTO, M"
	.BYTE "EM, QUIT"
	.BYTE ",",$0D
	.BYTE "LIST, RU"
	.BYTE "N, DELET"
	.BYTE "E, CLEAR"
	.BYTE $0D
	.BYTE "BASIC Ex"
	.BYTE "ample",$0D
	.BYTE "10 PRINT"
	.BYTE " ",$22
	.BYTE "NUM?",$22,$0D
	.BYTE "20 NUM X"
	.BYTE $0D
	.BYTE "30 VAR A"
	.BYTE " = 2",$0D
	.BYTE "40 PRINT"
	.BYTE " A ",$3A
	.BYTE " PRINT "
	.BYTE $22,$5C,$22,$0D
	.BYTE "50 VAR A"
	.BYTE " = A + 1"
	.BYTE $0D
	.BYTE "60 IF A "
	.BYTE "> X ",$3A
	.BYTE " QUIT ",$3A
	.BYTE " END",$0D
	.BYTE "70 VAR B"
	.BYTE " = A - 1"
	.BYTE $0D
	.BYTE "80 IF A "
	.BYTE $25," B ="
	.BYTE " 0 ",$3A
	.BYTE " GOTO 5"
	.BYTE "0 ",$3A
	.BYTE " END",$0D
	.BYTE "90 VAR B"
	.BYTE " = B - 1"
	.BYTE $0D
	.BYTE "100 IF B"
	.BYTE " = 1 ",$3A
	.BYTE " GOTO 40"
	.BYTE " ",$3A
	.BYTE " END",$0D
	.BYTE "110 GOTO"
	.BYTE " 80",$0D
	.BYTE "RUN",$0D
	.BYTE $00

help_print_hex
	PHA
	AND #%11110000
	CLC
	ROR A
	ROR A
	ROR A
	ROR A
	JSR help_print_hex_compare
	PLA
	AND #%00001111
	JSR help_print_hex_compare
	RTS
help_print_hex_compare
	CLC
	CMP #$0A
	BCC help_print_hex_number
	SEC
	SBC #$0A
	CLC
	ADC #$41
	JSR printchar
	RTS
help_print_hex_number
	CLC
	ADC #$30
	JSR printchar
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


	.ORG $F700


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
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00

	

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
	JSR longdelay ; 100ms minimum
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
	PLA
	RTI					; and exit
mouse_isr_check
	CMP #$0B ; reset counter		; 1 start bit, 8 data bits, 1 parity bit, 1 stop bit = 11 bits to complete a full signal
	BEQ mouse_isr_reset
	PLA
	RTI					; and exit
mouse_isr_reset
	STZ mouse_counter			; reset the counter
	LDA mouse_state
	CMP #$16
	BEQ mouse_isr_input
mouse_isr_exit
	PLA
	RTI
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
	STZ key_data
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
	STZ mouse_data
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


; unused space here


	.ORG $FFFA ; vectors

	.WORD vector_nmi
	.WORD vector_reset
	.WORD vector_irq









	
	
