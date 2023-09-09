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
via_t2cl		.EQU via+$08
via_t2ch		.EQU via+$09
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

sub_random		.EQU $0293 ; 18 bytes long
sub_random_var		.EQU $02A5

clock_low		.EQU $02A6
clock_high		.EQU $02A7

vector_irq		.EQU $02A8 ; 4 bytes long
vector_nmi		.EQU $02AC ; 4 bytes long

sub_jump		.EQU $02B0 ; 4 bytes long
sub_read		.EQU $02B4 ; 4 bytes long
sub_index		.EQU $02B8 ; 4 bytes long
sub_write		.EQU $02BC ; 4 bytes long

sdcard_block		.EQU $02C0 ; 2 bytes 

printchar_x		.EQU $02C2 ; from $00 to $3F
printchar_y		.EQU $02C3 ; from $00 to $1D
printchar_foreground	.EQU $02C4 ; either $00, $55, $AA, or $FF
printchar_background	.EQU $02C5 ; either $00, $55, $AA, or $FF
printchar_inverse	.EQU $02C6 ; either $00 or $FF
printchar_storage	.EQU $02C7
printchar_read		.EQU $02C8 ; 4 bytes long
printchar_write		.EQU $02CC ; 4 bytes long

colorchar_input		.EQU $02D0
colorchar_output	.EQU $02D1

selector_joy_prev	.EQU $02D2
selector_position	.EQU $02D3

; unused memory here

; memory from $0300 to $04FF is available for any program
; but changes for each program

command_string		.EQU $0300 ; 64 bytes long

function_mode		.EQU $0340

scratchpad_lastchar	.EQU $0341

monitor_mode		.EQU $0342
monitor_nibble		.EQU $0343
monitor_values		.EQU $0344 ; 8 bytes long

basic_line_low		.EQU $034C
basic_line_high		.EQU $034D
basic_value1_low	.EQU $034E
basic_value1_high	.EQU $034F
basic_value2_low	.EQU $0350
basic_value2_high	.EQU $0351
basic_value3_low	.EQU $0352
basic_value3_high	.EQU $0353
basic_value4_low	.EQU $0354
basic_value4_high	.EQU $0355
basic_character		.EQU $0356
basic_operator		.EQU $0357
basic_wait_end		.EQU $0358
basic_wait_delete	.EQU $0359
basic_variables_low	.EQU $035A ; 26 bytes
basic_variables_high	.EQU $0374 ; 26 bytes
basic_keys		.EQU $038E ; 16 bytes long
basic_keys_plus_one	.EQU $039F
basic_memory		.EQU $8000 ; 16KB available
basic_memory_end	.EQU $C000 ; one past

tetra_score_low		.EQU $0300 ; reusing memory location
tetra_score_high	.EQU $0301
tetra_piece		.EQU $0302
tetra_piece_next	.EQU $0303
tetra_location		.EQU $0304
tetra_speed		.EQU $0305
tetra_overscan		.EQU $0306
tetra_joy_prev		.EQU $0307
tetra_values		.EQU $0308 ; 3 bytes
tetra_field		.EQU $0400 ; 256 bytes long

intruders_player_pos	.EQU $0300 ; reusing memory location
intruders_player_lives	.EQU $0301
intruders_missile_pos_x	.EQU $0302
intruders_missile_pos_y	.EQU $0303
intruders_enemy_fall	.EQU $0304
intruders_enemy_pos_x	.EQU $0305
intruders_enemy_pos_y	.EQU $0306
intruders_enemy_dir_x	.EQU $0307
intruders_enemy_speed	.EQU $0308
intruders_enemy_miss_s	.EQU $0309
intruders_enemy_miss_x	.EQU $030A
intruders_enemy_miss_y	.EQU $030B
intruders_delay_timer	.EQU $030C
intruders_button_left	.EQU $030D
intruders_button_right	.EQU $030E
intruders_button_fire	.EQU $030F
intruders_mystery_pos	.EQU $0310
intruders_mystery_speed	.EQU $0311
intruders_points_low	.EQU $0312
intruders_points_high	.EQU $0313
intruders_level		.EQU $0314
intruders_overall_delay	.EQU $0315
intruders_mystery_bank	.EQU $0316
intruders_char_value	.EQU $0317
intruders_color_current	.EQU $0318
intruders_paused	.EQU $0319
intruders_joy_prev	.EQU $031A
intruders_fire_delay	.EQU $031B
intruders_hit_delay	.EQU $031C
intruders_enemy_visible	.EQU $0400 ; many bytes long

missile_ammo_value	.EQU $0300
missile_dist_value	.EQU $0301
missile_enemy_value	.EQU $0302
missile_stop_value	.EQU $0303
missile_round_value	.EQU $0304
missile_enemy_constant	.EQU $0305
missile_speed_constant	.EQU $0306
missile_random_constant	.EQU $0307
missile_ammo_constant	.EQU $0308
missile_paused		.EQU $0309
missile_score_low	.EQU $030A
missile_score_high	.EQU $030B
missile_joy_prev	.EQU $030C
missile_key_space	.EQU $030D
missile_key_up		.EQU $030E
missile_key_down	.EQU $030F
missile_key_left	.EQU $0310
missile_key_right	.EQU $0311
missile_pop_value	.EQU $0312
missile_missile_x	.EQU $0400 ; 16 bytes long
missile_missile_y	.EQU $0410 ; 16 bytes long
missile_target_x	.EQU $0420 ; 16 bytes long
missile_target_y	.EQU $0430 ; 16 bytes long
missile_slope_x		.EQU $0440 ; 16 bytes long
missile_slope_y		.EQU $0450 ; 16 bytes long
missile_count_x		.EQU $0460 ; 16 bytes long
missile_count_y		.EQU $0470 ; 16 bytes long
missile_prev1_x		.EQU $0480 ; 8 bytes long
missile_prev1_y		.EQU $0488 ; 8 bytes long
missile_prev2_x		.EQU $0490 ; 8 bytes long
missile_prev2_y		.EQU $0498 ; 8 bytes long
missile_prev3_x		.EQU $04A0 ; 8 bytes long
missile_prev3_y		.EQU $04A8 ; 8 bytes long
missile_prev4_x		.EQU $04B0 ; 8 bytes long
missile_prev4_y		.EQU $04B8 ; 8 bytes long
missile_prev5_x		.EQU $04C0 ; 8 bytes long
missile_prev5_y		.EQU $04C8 ; 8 bytes long
missile_prev6_x		.EQU $04D0 ; 8 bytes long
missile_prev6_y		.EQU $04D8 ; 8 bytes long
missile_prev7_x		.EQU $04E0 ; 8 bytes long
missile_prev7_y		.EQU $04E8 ; 8 bytes long
missile_prev8_x		.EQU $04F0 ; 8 bytes long
missile_prev8_y		.EQU $04F8 ; 8 bytes long

galian_player_x		.EQU $0300 ; reusing memory location
galian_player_y		.EQU $0301
galian_player_lives	.EQU $0302
galian_player_flash	.EQU $0303
galian_release		.EQU $0304
galian_button_up	.EQU $0305
galian_button_down	.EQU $0306
galian_button_left	.EQU $0307
galian_button_right	.EQU $0308
galian_button_fire	.EQU $0309
galian_fire_delay	.EQU $030A
galian_frame		.EQU $030B
galian_clock		.EQU $030C
galian_filter		.EQU $030D
galian_enemy_count	.EQU $030E
galian_joy_prev		.EQU $030F
galian_enemy_speed	.EQU $0310
galian_bullet_speed	.EQU $0311
galian_star_speed	.EQU $0312
galian_score_low	.EQU $0313
galian_score_high	.EQU $0314
galian_level		.EQU $0315
galian_pause_mode	.EQU $0316
galian_bullet_x		.EQU $0400 ; 16 bytes
galian_bullet_y		.EQU $0410 ; 16 bytes
galian_enemy_x		.EQU $0420 ; 16 bytes
galian_enemy_y		.EQU $0430 ; 16 bytes
galian_enemy_dx		.EQU $0440 ; 16 bytes
galian_enemy_dy		.EQU $0450 ; 16 bytes
galian_enemy_t		.EQU $0460 ; 16 bytes
galian_enemy_h		.EQU $0470 ; 16 bytes
galian_enemy_s		.EQU $0480 ; 16 bytes
galian_particle_x	.EQU $0490 ; 16 bytes
galian_particle_y	.EQU $04A0 ; 16 bytes
galian_particle_dx	.EQU $04B0 ; 16 bytes
galian_star_x		.EQU $04C0 ; 16 bytes
galian_star_y		.EQU $04D0 ; 16 bytes

rogue_player_x		.EQU $0300 ; reusing memory
rogue_player_y		.EQU $0301
rogue_stairs_x		.EQU $0302
rogue_stairs_y		.EQU $0303
rogue_check_x		.EQU $0304
rogue_check_y		.EQU $0305
rogue_location_x	.EQU $0306
rogue_location_y	.EQU $0307
rogue_walk_low		.EQU $0308
rogue_walk_high		.EQU $0309
rogue_distance		.EQU $030A
rogue_lamp		.EQU $030B
rogue_pickaxe		.EQU $030C
rogue_potions		.EQU $030D
rogue_bombs		.EQU $030E
rogue_attack		.EQU $030F
rogue_defense		.EQU $0310
rogue_health		.EQU $0311
rogue_health_max	.EQU $0312
rogue_food_low		.EQU $0313
rogue_food_high		.EQU $0314
rogue_level		.EQU $0315
rogue_gold		.EQU $0316
rogue_filter		.EQU $0317
rogue_floor		.EQU $8000 ; 2K
rogue_floor_end		.EQU $8700 ; last 4 lines
rogue_items		.EQU $8800 ; 2K
rogue_digged		.EQU $9000 ; 2K
rogue_digged_end	.EQU $9800 ; end






	.ORG $C000 ; start of code

vector_reset

;	JSR setup ; only needed for simulator

	JMP selector

	
selector
	LDA #$00
	STA $FFFF ; turn on 16 color mode

	LDY #$08 ; start of screen
	LDX #$00
	LDA #$00 ; clear color
selector_clearscreen_loop
	STX sub_write+1
	STY sub_write+2
	JSR sub_write
	INX
	BNE selector_clearscreen_loop
	INY
	CPY #$80 ; end of screen
	BNE selector_clearscreen_loop


	STZ selector_position
	LDA joy_buttons
	STA selector_joy_prev
	STZ printchar_x
	STZ printchar_y
	LDX #$00
selector_draw
	LDA selector_text,X
	BEQ selector_loop
	CMP #$0D ; return
	BNE selector_skip
	STZ printchar_x
	INC printchar_y
	LDA #" "
selector_skip
	JSR colorchar
	INC printchar_x
	INX
	JMP selector_draw
selector_loop
	STZ printchar_x
	LDA selector_position
	INC A
	STA printchar_y
	LDA #$3E ; greater than
	JSR colorchar
	LDA joy_buttons
	CMP selector_joy_prev
	BEQ selector_keys
	LDA joy_buttons
	AND #%00000001
	BEQ selector_joy_up
	LDA joy_buttons
	AND #%00000010
	BEQ selector_joy_down
	LDA joy_buttons
	AND #%00110000
	CMP #%00110000
	BNE selector_joy_fire
selector_keys
	CLC
	JSR sub_random ; for more randomization
	LDA joy_buttons
	STA selector_joy_prev
	JSR inputchar
	CMP #$00
	BEQ selector_loop
	CMP #$1B ; escape
	BEQ selector_bank
	CMP #$11 ; arrow up
	BEQ selector_key_up
	CMP #$12 ; arrow down
	BEQ selector_key_down
	CMP #$20 ; space
	BEQ selector_activate
	JMP selector_loop
selector_bank
	JMP bank_switch
selector_joy_up
	LDA selector_joy_prev
	AND #%00000001
	BEQ selector_keys
selector_key_up
	LDA #" "
	JSR colorchar
	LDA selector_position
	BEQ selector_keys
	DEC selector_position
	JMP selector_keys
selector_joy_down
	LDA selector_joy_prev
	AND #%00000010
	BEQ selector_keys
selector_key_down
	LDA #" "
	JSR colorchar
	LDA selector_position
	CLC
	CMP #$10 ; 16 positions possible
	BCS selector_keys
	INC selector_position
	JMP selector_keys
selector_joy_fire
	LDA selector_joy_prev
	AND #%00110000
	CMP #%00110000
	BNE selector_keys
selector_activate
	LDA selector_position
	CMP #$00
	BNE selector_next1
	JMP tetra
selector_next1
	CMP #$01
	BNE selector_next2
	JMP intruders
selector_next2
	CMP #$02
	BNE selector_next3
	JMP mission
selector_next3
	CMP #$03
	BNE selector_next4
	JMP galian
selector_next4
	NOP
	JMP selector_loop

selector_text
	.BYTE "Select "
	.BYTE "a Game "
	.BYTE "to Play"
	.BYTE $0D
	.BYTE "  "
	.BYTE "Tetra"
	.BYTE $0D
	.BYTE "  "
	.BYTE "Intruder"
	.BYTE "s"
	.BYTE $0D
	.BYTE "  "
	.BYTE "Missile"
	.BYTE $0D
	.BYTE "  "
	.BYTE "Galian"
	.BYTE $0D
	.BYTE $00




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
	CMP #$15 ; F12 to pause
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
	CMP #$1B ; escape to exit
	BNE tetra_pause_check
	JMP bank_switch
tetra_pause_check
	CMP #$15 ; F12 to pause
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
	CMP #$1B ; escape to exit
	BNE tetra_input_check
	JMP bank_switch
tetra_input_check
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
	CMP #tetra_color_fore
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
	;LDA #$FF ; draw
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
	



intruders_max_enemies		.EQU $2F ; $2F, a constant
intruders_color_enemy		.EQU $77 ; constant
intruders_color_shield		.EQU $AA ; constant
intruders_color_missile		.EQU $DD ; constant
intruders_color_mystery		.EQU $FF ; constant

intruders
	LDA #$00
	STA $FFFF ; turn on 16 color mode

	JMP intruders_init

intruders_level_enemy_fall
	.BYTE $10,$10,$30,$30,$50,$50,$70,$70
intruders_level_enemy_speed
	.BYTE $20,$30,$40,$50,$60,$70,$80,$90
intruders_level_enemy_missile_speed
	.BYTE $02,$02,$02,$02,$03,$03,$03,$03
intruders_level_overall_delay
	.BYTE $80,$78,$70,$68,$60,$50,$40,$30

intruders_init
	STZ intruders_paused
	LDA #$03
	STA intruders_player_lives
	STZ intruders_level
	STZ intruders_points_low
	STZ intruders_points_high
	STZ intruders_fire_delay
	STZ intruders_hit_delay
	
intruders_init_level
	LDA intruders_level
	AND #%00000111
	TAX
	LDA #$3B ; #$2E? port change
	STA intruders_player_pos
	STZ intruders_button_left
	STZ intruders_button_right
	STZ intruders_button_fire
	STZ intruders_missile_pos_y
	STZ intruders_delay_timer
	LDA intruders_level_enemy_fall,X
	STA intruders_enemy_fall
	LDA #$08
	STA intruders_enemy_pos_x
	LDA #$18
	STA intruders_enemy_pos_y
	LDA intruders_level_enemy_speed,X
	STA intruders_enemy_speed
	LDA intruders_level_enemy_missile_speed,X
	STA intruders_enemy_miss_s
	LDA #$28
	STA intruders_enemy_miss_x
	STZ intruders_enemy_miss_y
	LDA #$00
	STA intruders_mystery_pos
	LDA #$01
	STA intruders_mystery_speed
	LDA intruders_level_overall_delay,X
	STA intruders_overall_delay
	LDA #$FA ; 250 in decimal
	STA intruders_mystery_bank ; total points you can get from the mystery ship each round

intruders_init_start
	STZ sub_write+1				; clear out screen RAM
	LDA #$08
	STA sub_write+2
intruders_init_wipeout
	LDA #$00 ; fill color
	JSR sub_write
	INC sub_write+1
	BNE intruders_init_wipeout
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE intruders_init_wipeout

	JSR intruders_draw_menu

	LDX #intruders_max_enemies
	LDA #$FF
intruders_init_visible_loop
	STA intruders_enemy_visible,X
	DEX
	CPX #$FF
	BNE intruders_init_visible_loop

	LDA #$14 ; #$0C port change
	JSR intruders_init_shield
	LDA #$28 ; #$18 port change
	JSR intruders_init_shield
	LDA #$3C ; #$24 port change
	JSR intruders_init_shield
	LDA #$50 ; #$30 port change
	JSR intruders_init_shield
	LDA #$64 ; #$3C port change
	JSR intruders_init_shield

	LDY #$00
	JMP intruders_draw_mystery	

intruders_input
	LDA clock_low
	CLC	
	CMP #$01
	BCC intruders_input_keys
	LDA intruders_hit_delay
	BEQ intruders_input_clock
	DEC intruders_hit_delay
intruders_input_clock
	STZ clock_low
	DEC intruders_fire_delay
	LDA intruders_fire_delay
	CMP #$FF
	BNE intruders_input_fire_delay
	STZ intruders_fire_delay
intruders_input_fire_delay
	LDA joy_buttons
	AND intruders_joy_prev ; maybe?
	CMP #$FF
	BEQ intruders_input_keys
	JMP intruders_joy
intruders_input_keys
	;LDA joy_buttons
	;STA intruders_joy_prev ; maybe?
	LDX key_read
	CPX key_write
	BNE intruders_input_next
	LDA intruders_paused
	BNE intruders_input
	JMP intruders_input_check
intruders_input_next
	CLC
	JSR sub_random ; just to add randomness
	LDA key_array,X
	INC key_read
	BPL intruders_input_positive
	STZ key_read
intruders_input_positive
	CMP #$F0
	BEQ intruders_input_release
	STA intruders_char_value
	LDA key_release
	STZ key_release
	BEQ intruders_input_down
	LDA intruders_char_value
	CMP #ps2_f12
	BEQ intruders_input_pause
	LDA intruders_paused
	BNE intruders_input
	LDA intruders_char_value
	CMP #ps2_arrow_left
	BEQ intruders_input_left_up
	CMP #$1C ; A
	BEQ intruders_input_left_up
	CMP #ps2_arrow_right
	BEQ intruders_input_right_up
	CMP #$23 ; D
	BEQ intruders_input_right_up
	CMP #ps2_space
	BEQ intruders_input_fire_up
	CMP #ps2_arrow_up
	BEQ intruders_input_fire_up
	CMP #$1D ; W
	BEQ intruders_input_fire_up
	CMP #ps2_escape
	BEQ intruders_input_bank
	JMP intruders_input_check
intruders_input_bank
	JMP bank_switch

intruders_input_pause
	LDA intruders_paused
	EOR #$FF
	STA intruders_paused
	BEQ intruders_input_pause_clear
	JSR intruders_pause_draw
	JMP intruders_input
intruders_input_pause_clear
	JSR intruders_pause_clear
	STZ key_read
	STZ key_write
	STZ intruders_button_left
	STZ intruders_button_right
	STZ intruders_button_fire
	JMP intruders_input

intruders_input_release
	STA key_release
	JMP intruders_input_check
intruders_input_down
	LDA intruders_char_value
	CMP #ps2_arrow_left
	BEQ intruders_input_left_down
	CMP #$1C ; A
	BEQ intruders_input_left_down
	CMP #ps2_arrow_right
	BEQ intruders_input_right_down
	CMP #$23 ; D
	BEQ intruders_input_right_down
	CMP #ps2_space
	BEQ intruders_input_fire_down
	CMP #ps2_arrow_up
	BEQ intruders_input_fire_down
	CMP #$1D ; W
	BEQ intruders_input_fire_down
	JMP intruders_input_check
intruders_input_left_up
	STZ intruders_button_left
	JMP intruders_input_check
intruders_input_right_up
	STZ intruders_button_right
	JMP intruders_input_check
intruders_input_fire_up
	STZ intruders_button_fire
	JMP intruders_input_check
intruders_input_left_down
	STA intruders_button_left
	JMP intruders_input_check
intruders_input_right_down	
	STA intruders_button_right
	JMP intruders_input_check
intruders_input_fire_down	
	STA intruders_button_fire
	JMP intruders_input_check

intruders_joy
	LDA joy_buttons
	ORA #%11001111
	CMP #$FF 
	BEQ intruders_joy_nofire
	LDA #$FF
	STA intruders_button_fire
	JMP intruders_joy_continue
intruders_joy_nofire
	STZ intruders_button_fire
intruders_joy_continue
	LDA joy_buttons
	ORA #%11111011
	CMP #$FF
	BEQ intruders_joy_noleft
	LDA #$FF
	STA intruders_button_left
	JMP intruders_joy_next
intruders_joy_noleft
;	LDA intruders_joy_prev
;	ORA #%11111011
;	CMP #$FF
;	BEQ intruders_joy_next
	STZ intruders_button_left
intruders_joy_next
	LDA joy_buttons
	ORA #%11110111
	CMP #$FF
	BEQ intruders_joy_noright
	LDA #$FF
	STA intruders_button_right
	JMP intruders_joy_exit
intruders_joy_noright
;	LDA intruders_joy_prev
;	ORA #%11110111
;	CMP #$FF
;	BEQ intruders_joy_exit
	STZ intruders_button_right
intruders_joy_exit
	LDA joy_buttons
	STA intruders_joy_prev ; maybe?
	JMP intruders_input_check

intruders_input_check	
	INY
	CPY intruders_overall_delay
	BEQ intruders_input_check_next
	JMP intruders_input
intruders_input_check_next
	LDY #$00
	DEC intruders_delay_timer
	LDA intruders_delay_timer
	AND #%00001111
	BEQ intruders_reaction
	JMP intruders_input
intruders_reaction
	LDA intruders_button_left
	BEQ intruders_reaction_next1
	LDA intruders_player_pos
	SEC
	SBC #$02
	CLC
	CMP #$02 ; #$08 port change
	BCC intruders_reaction_next1
	STA intruders_player_pos
intruders_reaction_next1
	LDA intruders_button_right
	BEQ intruders_reaction_next2
	LDA intruders_player_pos
	CLC
	ADC #$02
	CLC
	CMP #$75 ; #$42 port change
	BCS intruders_reaction_next2
	STA intruders_player_pos
intruders_reaction_next2
	LDA intruders_fire_delay
	BNE intruders_reaction_next3
	LDA intruders_button_fire
	BEQ intruders_reaction_next3
	STZ intruders_button_fire
	LDA #$10 ; arbitrary wait time between firing
	STA intruders_fire_delay
	LDA intruders_missile_pos_y
	BNE intruders_reaction_next3
	LDA intruders_player_pos
	CLC
	ADC #$04
	STA intruders_missile_pos_x
	LDA #$72
	STA intruders_missile_pos_y
intruders_reaction_next3
	NOP


intruders_draw_mystery
	LDA intruders_mystery_pos
	CMP #$FF
	BEQ intruders_draw_player
	CLC	
	ADC intruders_mystery_speed
	BMI intruders_draw_mystery_offscreen
	CLC	
	CMP #$78 ; #$50 port change
	BCS intruders_draw_mystery_offscreen
	JMP intruders_draw_mystery_onscreen
intruders_draw_mystery_offscreen
	LDA #$FF
	STA intruders_mystery_pos
	JSR intruders_mystery_clear
	JMP intruders_draw_player
intruders_draw_mystery_onscreen
	STA intruders_mystery_pos
	STA sub_write+1
	LDA #$10
	STA sub_write+2
	LDA #<intruders_mystery_data
	STA sub_index+1
	LDA #>intruders_mystery_data
	STA sub_index+2
	LDX #$00
	LDY #$00
intruders_draw_mystery_loop
	JSR sub_index
	AND #intruders_color_mystery
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$08
	BNE intruders_draw_mystery_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$78
	STA sub_write+1
	BCC intruders_draw_mystery_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$14
	BCC intruders_draw_mystery_loop


intruders_draw_player
	LDA intruders_player_pos
	STA sub_write+1
	LDA #$76
	STA sub_write+2
	LDA #<intruders_player_data
	STA sub_index+1
	LDA #>intruders_player_data
	STA sub_index+2
	LDX #$00
	LDY #$00
intruders_draw_player_loop
	LDA intruders_hit_delay
	BEQ intruders_draw_player_normal
	AND #%00000001
	BEQ intruders_draw_player_normal
	JSR sub_index
	AND #intruders_color_missile
	AND #%11101110
	JSR sub_write
	JMP intruders_draw_player_increment	
intruders_draw_player_normal
	JSR sub_index
	JSR sub_write
intruders_draw_player_increment
	INC sub_write+1
	INX
	INY
	CPY #$0A
	BNE intruders_draw_player_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$76
	STA sub_write+1
	BCC intruders_draw_player_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$79
	BCC intruders_draw_player_loop
	LDA intruders_missile_pos_y
	BNE intruders_draw_missile
	
	LDX #$FF
	LDY #$18
intruders_draw_no_missile
	NOP
	DEX
	BNE intruders_draw_no_missile
	DEY
	BNE intruders_draw_no_missile

	JMP intruders_draw_enemy_missile
intruders_draw_missile
	LDA intruders_missile_pos_x
	STA sub_write+1
	LDA intruders_missile_pos_y
	STA sub_write+2
	JSR intruders_draw_missile_particle_clear
	LDA intruders_missile_pos_y
	SEC
	SBC #$04
	CLC	
	CMP #$08
	BCS intruders_draw_missile_normal
	JMP intruders_draw_missile_reset
intruders_draw_missile_normal
	STA intruders_missile_pos_y


	LDA intruders_missile_pos_y
	CLC	
	CMP #$10
	BCC intruders_draw_missile_mystery_skip
	CLC
	CMP #$14
	BCS intruders_draw_missile_mystery_skip
	LDA intruders_missile_pos_x
	CLC
	CMP intruders_mystery_pos
	BCC intruders_draw_missile_mystery_skip
	SEC
	SBC #$08
	CMP intruders_mystery_pos
	BCS intruders_draw_missile_mystery_skip
	LDA #$FF
	STA intruders_mystery_pos ; hit the mystery ship!
	JSR intruders_mystery_clear

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
	LDA intruders_mystery_bank ; only 250 points available each level
	BEQ intruders_draw_missile_mystery_skip
	SEC
	SBC #$32
	STA intruders_mystery_bank
	LDA #$32 ; 50 in decimal
	CLC
	ADC intruders_points_low
	STA intruders_points_low ; increment points
	CLC
	CMP #$64 ; 100 in decimal
	BCC intruders_draw_missile_mystery_skip
	SEC
	SBC #$64
	STA intruders_points_low
	INC intruders_points_high
	LDA intruders_points_high
	AND #%00000011 ; every 400 points is new life
	BNE intruders_draw_missile_mystery_skip
	LDA intruders_player_lives
	AND #%00001111
	CLC
	CMP #$09
	BCS intruders_draw_missile_mystery_skip
	LDA intruders_level
	CLC
	CMP #$08
	BCS intruders_draw_missile_mystery_skip
	INC intruders_player_lives
intruders_draw_missile_mystery_skip
	JSR intruders_draw_menu

	LDX #intruders_max_enemies
intruders_draw_missile_array
	LDA intruders_enemy_visible,X
	BNE intruders_draw_missile_check
	JMP intruders_draw_missile_loop
intruders_draw_missile_check
	TXA
	AND #%11111000
	EOR #$FF
	INC A
	ADC intruders_missile_pos_y
	CLC
	CMP intruders_enemy_pos_y
	BCS intruders_draw_missile_check_next1
	JMP intruders_draw_missile_loop
intruders_draw_missile_check_next1
	SEC
	SBC #$04
	CLC
	CMP intruders_enemy_pos_y
	BCC intruders_draw_missile_check_next2
	JMP intruders_draw_missile_loop
intruders_draw_missile_check_next2
	TXA
	AND #%00000111
	PHY ; port change down
	TAY
	LDA #$00
intruders_draw_enemy_check_addition
	CLC
	ADC #$0E
	DEY
	BNE intruders_draw_enemy_check_addition
	PLY	
;	CLC
;	ROL A
;	ROL A
;	ROL A ; port change up
	ADC intruders_enemy_pos_x
	CLC
	ADC #$04 ; should be #$05?
	CLC
	CMP intruders_missile_pos_x
	BCS intruders_draw_missile_check_next3
	JMP intruders_draw_missile_loop
intruders_draw_missile_check_next3
	SEC
	SBC #$05 ; #$05 port change
	CLC
	CMP intruders_missile_pos_x
	BCC intruders_draw_missile_check_next4
	JMP intruders_draw_missile_loop
intruders_draw_missile_check_next4
	LDA #$80	
	STA intruders_enemy_visible,X ; hit enemy
	STZ intruders_missile_pos_y

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
	ADC intruders_points_low
	STA intruders_points_low ; increment points
	CLC
	CMP #$64 ; 100 in decimal
	BCC intruders_draw_missile_points
	SEC
	SBC #$64
	STA intruders_points_low
	INC intruders_points_high
	LDA intruders_points_high
	AND #%00000011 ; every 400 points is new life
	BNE intruders_draw_missile_points
	LDA intruders_player_lives
	AND #%00001111
	CLC
	CMP #$09
	BCS intruders_draw_missile_points
	LDA intruders_level
	CLC
	CMP #$08
	BCS intruders_draw_missile_points
	INC intruders_player_lives
intruders_draw_missile_points
	JSR intruders_draw_menu

	PHX
	LDX #intruders_max_enemies
intruders_draw_missile_win_loop
	LDA intruders_enemy_visible,X
	AND #%01111111
	BNE intruders_draw_missile_win_fail
	DEX
	CPX #$FF
	BNE intruders_draw_missile_win_loop
	PLX
	JMP intruders_nextlevel ; won the game!
intruders_draw_missile_win_fail
	PLX
intruders_draw_missile_loop
	DEX
	CPX #$FF
	BEQ intruders_draw_missile_flying
	JMP intruders_draw_missile_array
intruders_draw_missile_flying
	LDA intruders_missile_pos_y
	BNE intruders_draw_missile_flying_next1
	JMP intruders_draw_enemy_missile
intruders_draw_missile_flying_next1
	LDA intruders_missile_pos_x
	STA sub_write+1
	LDA intruders_missile_pos_y
	STA sub_write+2
	PHY
	LDY #intruders_color_missile
	JSR intruders_draw_missile_particle_color
	PLY
	CPX #$00
	BNE intruders_draw_missile_flying_next2
	JMP intruders_draw_enemy_missile
intruders_draw_missile_flying_next2
	LDA intruders_missile_pos_x
	STA sub_write+1
	LDA intruders_missile_pos_y
	STA sub_write+2
	LDY #intruders_color_missile
	JSR intruders_draw_missile_particle_clear
intruders_draw_missile_reset
	STZ intruders_missile_pos_y

	JSR intruders_draw_menu

intruders_draw_enemy_missile
	LDA intruders_enemy_miss_y
	BEQ intruders_draw_enemy_missile_skip
	LDA intruders_enemy_miss_x
	STA sub_write+1
	LDA intruders_enemy_miss_y
	STA sub_write+2
	LDY #intruders_color_enemy
	JSR intruders_draw_missile_particle_clear
	LDA intruders_enemy_miss_y
	BEQ intruders_draw_enemy_missile_skip
	JMP intruders_draw_enemy_missile_ready
intruders_draw_enemy_missile_skip
	LDA intruders_delay_timer
	CLC
	CMP intruders_enemy_speed 
	BCC intruders_draw_enemy_missile_timed
	JMP intruders_draw_enemy
intruders_draw_enemy_missile_timed
	LDA intruders_enemy_fall
	EOR #$FF
	STA intruders_enemy_fall
	CLC
	JSR sub_random
	AND intruders_enemy_speed
	AND #%11110000
	PHA
	LDA intruders_enemy_fall
	EOR #$FF
	STA intruders_enemy_fall
	PLA
	CMP #$00 ; needed
	BEQ intruders_draw_enemy_missile_search
	JMP intruders_draw_enemy
intruders_draw_enemy_missile_search


	LDA intruders_mystery_pos
	CMP #$FF
	BNE intruders_draw_mystery_skip
	CLC
	JSR sub_random
	AND #%00001111
	BNE intruders_draw_mystery_skip
	STZ intruders_mystery_pos
	LDA #$01
	STA intruders_mystery_speed
	;LDA intruders_level
	;CLC
	;CMP #$04
	;BCC intruders_draw_mystery_next
	;LDA #$02
	;STA intruders_mystery_speed
intruders_draw_mystery_next
	CLC
	JSR sub_random
	AND #%10000000
	BEQ intruders_draw_mystery_skip
	LDA #$77 ; #$4F port change
	STA intruders_mystery_pos
	LDA #$FF
	STA intruders_mystery_speed
	;LDA intruders_level
	;CLC
	;CMP #$04
	;BCC intruders_draw_mystery_skip
	;LDA #$FE
	;STA intruders_mystery_speed
intruders_draw_mystery_skip


	CLC
	JSR sub_random
;	AND #%11111100
;	CLC
;	ROR A
;	ROR A
	AND #%00111111 ; new
	CLC
	CMP #$30
	BCS intruders_draw_mystery_skip ; was 'intruders_draw_enemy_missile_search'
	TAX
	LDA intruders_enemy_visible,X
	BEQ intruders_draw_mystery_skip	
	TXA
	AND #%00000111
	PHY ; port change down
	TAY
	LDA #$00
	CPY #$00
	BEQ intruders_draw_enemy_missile_addition_end
intruders_draw_enemy_missile_addition
	CLC
	ADC #$0E
	DEY
	BNE intruders_draw_enemy_missile_addition
intruders_draw_enemy_missile_addition_end
	PLY	
;	CLC
;	ROL A
;	ROL A
;	ROL A ; port change up
	ADC intruders_enemy_pos_x
	ADC #$02
	STA intruders_enemy_miss_x
	TXA
	AND #%11111000
	ADC intruders_enemy_pos_y
	CLC
	ADC #$04
	STA intruders_enemy_miss_y
intruders_draw_enemy_missile_ready
	LDA intruders_enemy_miss_s
	DEC A
	CLC
	ADC intruders_enemy_miss_y
	CLC
	CMP #$80
	BCS intruders_draw_enemy_missile_miss
	STA intruders_enemy_miss_y
	CLC
	CMP #$72
	BCC intruders_draw_enemy_missile_normal	
	LDA intruders_player_pos
	CLC
	ADC #$08
	CLC
	CMP intruders_enemy_miss_x
	BCC intruders_draw_enemy_missile_normal
	SEC
	SBC #$08
	CMP intruders_enemy_miss_x
	BCS intruders_draw_enemy_missile_normal
	DEC intruders_player_lives ; got hit!
	LDA #$40 ; arbitrary length of time
	STA intruders_hit_delay

	JSR intruders_draw_menu

	LDA intruders_player_lives
	AND #%00001111
	BNE intruders_draw_enemy_missile_miss
	JMP intruders_gameover
intruders_draw_enemy_missile_normal
	LDA intruders_enemy_miss_x
	STA sub_write+1
	LDA intruders_enemy_miss_y
	STA sub_write+2
	PHY
	LDY #intruders_color_enemy
	JSR intruders_draw_missile_particle_color
	PLY
	CPX #$00
	BEQ intruders_draw_enemy
	LDA intruders_enemy_miss_x
	STA sub_write+1
	LDA intruders_enemy_miss_y
	STA sub_write+2
	LDY #intruders_color_enemy
	JSR intruders_draw_missile_particle_clear
intruders_draw_enemy_missile_miss
	STZ intruders_enemy_miss_y
intruders_draw_enemy
	LDX #intruders_max_enemies
intruders_draw_enemy_array
	LDA intruders_enemy_visible,X
	BNE intruders_draw_enemy_visible
	JMP intruders_draw_enemy_loop
intruders_draw_enemy_visible
	CMP #$80
	BNE intruders_draw_enemy_full
	JSR intruders_draw_enemy_clear
	STZ intruders_enemy_visible,X
	JMP intruders_draw_enemy_loop
intruders_draw_enemy_full
	PHX
	TXA
	AND #%00000111
	PHY ; port change down
	TAY
	LDA #$00
intruders_draw_enemy_full_addition
	CLC
	ADC #$0E
	DEY
	BNE intruders_draw_enemy_full_addition
	PLY	
;	CLC
;	ROL A
;	ROL A
;	ROL A ; port change up
	ADC intruders_enemy_pos_x
	STA sub_write+1
	TXA
	AND #%11111000
	ADC intruders_enemy_pos_y
	STA sub_write+2
	LDA intruders_level
	AND #%00000001
	BEQ intruders_draw_enemy_pic2
	LDA intruders_enemy_pos_x
	AND #%00000001
	BEQ intruders_draw_enemy_pic1
	LDA #<intruders_enemy_data1
	STA sub_index+1
	LDA #>intruders_enemy_data1
	STA sub_index+2
	JMP intruders_draw_enemy_pic_done
intruders_draw_enemy_pic1
	LDA #<intruders_enemy_data2
	STA sub_index+1
	LDA #>intruders_enemy_data2
	STA sub_index+2
	JMP intruders_draw_enemy_pic_done
intruders_draw_enemy_pic2
	LDA intruders_enemy_pos_x
	AND #%00000001
	BEQ intruders_draw_enemy_pic3
	LDA #<intruders_enemy_data3
	STA sub_index+1
	LDA #>intruders_enemy_data3
	STA sub_index+2
	JMP intruders_draw_enemy_pic_done
intruders_draw_enemy_pic3
	LDA #<intruders_enemy_data4
	STA sub_index+1
	LDA #>intruders_enemy_data4
	STA sub_index+2
intruders_draw_enemy_pic_done
	LDX #$00
	LDY #$00
	PHY
intruders_draw_enemy_visible_loop
	JSR sub_index
	AND #intruders_color_enemy
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$06
	BNE intruders_draw_enemy_visible_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7A
	STA sub_write+1
	BCC intruders_draw_enemy_visible_loop
	INC sub_write+2
	LDA sub_write+2
	CLC
	CMP #$72
	BCC intruders_draw_enemy_visible_continue ; too far down!
	JMP intruders_gameover
intruders_draw_enemy_visible_continue
	PLA
	INC A
	CMP #$03
	PHA
	BNE intruders_draw_enemy_visible_loop
	PLA
	PLX
intruders_draw_enemy_loop
	DEX
	CPX #$FF
	BEQ intruders_draw_enemy_move
	JMP intruders_draw_enemy_array
intruders_draw_enemy_move
	LDA intruders_delay_timer
	CLC
	CMP intruders_enemy_speed 
	BCC intruders_draw_enemy_ready
	JMP intruders_loop
intruders_draw_enemy_ready
	STZ intruders_delay_timer
	LDA intruders_enemy_pos_y
	AND #%00000001
	BEQ intruders_draw_enemy_back
	LDA #$01
	JMP intruders_draw_enemy_shift
intruders_draw_enemy_back
	LDA #$FF
intruders_draw_enemy_shift
	CLC
	ADC intruders_enemy_pos_x
	STA intruders_enemy_pos_x
	CLC
	CMP #$16 ; #$0E port change
	BCS intruders_draw_enemy_down
	CLC
	CMP #$02 ; #$02 port change
	BCC intruders_draw_enemy_down
	JMP intruders_loop
intruders_draw_enemy_down
	LDX #intruders_max_enemies
intruders_draw_enemy_down_clear
	LDA intruders_enemy_visible,X
	BEQ intruders_draw_enemy_down_skip
	JSR intruders_draw_enemy_clear
intruders_draw_enemy_down_skip
	DEX
	CPX #$FF
	BNE intruders_draw_enemy_down_clear
	LDA intruders_enemy_fall
	CLC
	ROR A
	ROR A
	ROR A
	ROR A 
	CLC
	ADC intruders_enemy_pos_y
	STA intruders_enemy_pos_y
intruders_loop
	JMP intruders_input


intruders_draw_menu
	LDA #$03
	STA printchar_x
	LDA #$00
	STA printchar_y
	LDA intruders_points_low ; needs colornum to not display hundreds digit if zero!!!
	JSR colornum
	LDA #$01
	STA printchar_x
	LDA #$00
	STA printchar_y
	LDA intruders_points_high
	JSR colornum
	LDA #$3C
	STA printchar_x
	LDA #$00
	STA printchar_y
	LDA intruders_player_lives
	JSR colornum
	RTS


intruders_gameover
	JSR intruders_gameover_draw
intruders_gameover_loop1
	LDA joy_buttons
	CMP #$FF
	BNE intruders_gameover_loop1
intruders_gameover_loop2
	LDA joy_buttons
	ORA #%11001111
	CMP #$FF
	BEQ intruders_gameover_keys
	JMP intruders
intruders_gameover_keys
	JSR inputchar
	CMP #$00
	BEQ intruders_gameover_loop2
	CMP #$1B ; escape to exit
	BNE intruders_gameover_check
	JMP bank_switch
intruders_gameover_check
	CMP #$20 ; space
	BNE intruders_gameover_loop2
	JMP intruders


intruders_nextlevel
	; put stuff here?
	INC intruders_level
	JMP intruders_init_level
	

intruders_mystery_clear
	LDX #$00
intruders_draw_mystery_clear1
	STZ $1000,X
	INX
	BNE intruders_draw_mystery_clear1
intruders_draw_mystery_clear2
	STZ $1100,X
	INX
	BNE intruders_draw_mystery_clear2
intruders_draw_mystery_clear3
	STZ $1200,X
	INX
	BNE intruders_draw_mystery_clear3
intruders_draw_mystery_clear4
	STZ $1300,X
	INX
	BNE intruders_draw_mystery_clear4
	RTS


intruders_draw_missile_particle_write
	PHA
	AND #%00001111
	JSR sub_write
	INC sub_write+1
	PLA
	AND #%11110000
	JSR sub_write
	RTS

intruders_draw_missile_particle_clear ; sub_write already populated!
	PHX
	LDX #$08
intruders_draw_missile_particle_clear_start
	LDA #$00
	JSR intruders_draw_missile_particle_write
	LDA sub_write+1
	CLC
	ADC #$7F
	STA sub_write+1
	BCC intruders_draw_missile_particle_clear_increment
	INC sub_write+2
intruders_draw_missile_particle_clear_increment	
	DEX
	BNE intruders_draw_missile_particle_clear_start
	PLX
	RTS

intruders_draw_missile_particle_color ; sub_write already populated! Y has color	
	TYA
	EOR #$FF	
	STA intruders_color_current
	PHX
	LDA sub_write+1
	STA sub_read+1
	LDA sub_write+2
	STA sub_read+2
	LDX #$08
intruders_draw_missile_particle_color_start
	JSR sub_read
	AND intruders_color_current
	BNE intruders_draw_missile_particle_color_hit
	INC sub_read+1
	JSR sub_read
	AND intruders_color_current
	BNE intruders_draw_missile_particle_color_hit
	TYA
	JSR intruders_draw_missile_particle_write
	LDA sub_write+1
	CLC
	ADC #$7F
	STA sub_write+1
	STA sub_read+1
	BCC intruders_draw_missile_particle_color_increment
	INC sub_write+2
	INC sub_read+2
intruders_draw_missile_particle_color_increment	
	DEX
	BNE intruders_draw_missile_particle_color_start
	PLX
	LDX #$00
	RTS
intruders_draw_missile_particle_color_hit
	JSR sub_read
	PLX
	LDX #$01
	RTS

intruders_draw_enemy_clear ; X already populated
	PHX
	TXA
	AND #%00000111
	PHY ; port change down
	TAY
	LDA #$00
intruders_draw_enemy_clear_addition
	CLC
	ADC #$0E
	DEY
	BNE intruders_draw_enemy_clear_addition
	PLY	
;	CLC
;	ROL A
;	ROL A
;	ROL A ; port change up
	ADC intruders_enemy_pos_x
	STA sub_write+1
	TXA
	AND #%11111000
	ADC intruders_enemy_pos_y
	STA sub_write+2
	LDX #$00
	LDY #$00
	PHY
intruders_draw_enemy_clear_loop
	LDA #$00
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$06
	BNE intruders_draw_enemy_clear_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7A
	STA sub_write+1
	BCC intruders_draw_enemy_clear_loop
	INC sub_write+2
	PLA
	INC A
	CMP #$03
	PHA
	BNE intruders_draw_enemy_clear_loop
	PLA
	PLX
	RTS

intruders_init_shield ; A has horizontal position
	STA sub_write+1
	LDA #$6C
	STA sub_write+2
	LDA #<intruders_shield_data
	STA sub_index+1
	LDA #>intruders_shield_data
	STA sub_index+2
	LDX #$00
	LDY #$00
intruders_init_shield_loop
	JSR sub_index
	AND #intruders_color_shield
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$08
	BNE intruders_init_shield_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$78
	STA sub_write+1
	BCC intruders_init_shield_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$72
	BCC intruders_init_shield_loop
	RTS

intruders_pause_draw
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
intruders_pause_draw_loop
	LDA intruders_pause_text,Y
	JSR colorchar
	INC printchar_x
	INY
	CPY #$06
	BNE intruders_pause_draw_loop
	RTS

intruders_pause_clear
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
intruders_pause_clear_loop
	LDA #" "
	JSR colorchar
	INC printchar_x
	INY
	CPY #$06
	BNE intruders_pause_clear_loop
	RTS

intruders_gameover_draw
	LDA #$0C
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
intruders_gameover_draw_loop
	LDA intruders_gameover_text,Y
	JSR colorchar
	INC printchar_x
	INY
	CPY #$09
	BNE intruders_gameover_draw_loop
	RTS


intruders_pause_text
	.BYTE "Paused"
intruders_gameover_text
	.BYTE "Game "
	.BYTE "Over"

intruders_player_data
	.BYTE $00,$00,$00,$00,$0F,$F0,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$FF,$FF,$00,$00,$00,$00
	.BYTE $00,$00,$0F,$FF,$FF,$FF,$FF,$F0,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00
	;.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00
	;.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00

intruders_shield_data
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

intruders_mystery_data
	.BYTE $00,$00,$FF,$00,$00,$FF,$00,$00
	.BYTE $00,$00,$0F,$F0,$0F,$F0,$00,$00
	.BYTE $00,$00,$00,$FF,$FF,$00,$00,$00
	.BYTE $00,$00,$0F,$FF,$FF,$F0,$00,$00
	.BYTE $00,$00,$FF,$0F,$F0,$FF,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00
	.BYTE $00,$00,$0F,$FF,$FF,$F0,$00,$00
	.BYTE $00,$00,$00,$FF,$FF,$00,$00,$00

intruders_enemy_data1
	.BYTE $00,$00,$FF,$FF,$00,$00
	.BYTE $00,$0F,$FF,$FF,$F0,$00
	.BYTE $00,$FF,$00,$00,$FF,$00
	.BYTE $00,$0F,$FF,$FF,$F0,$00
	.BYTE $00,$00,$F0,$0F,$00,$00
	.BYTE $00,$FF,$F0,$0F,$FF,$00

intruders_enemy_data2
	.BYTE $00,$0F,$FF,$FF,$F0,$00
	.BYTE $00,$FF,$00,$00,$FF,$00
	.BYTE $00,$0F,$FF,$FF,$F0,$00
	.BYTE $00,$00,$FF,$FF,$00,$00
	.BYTE $00,$00,$F0,$0F,$00,$00
	.BYTE $00,$0F,$F0,$0F,$F0,$00

intruders_enemy_data3
	.BYTE $00,$0F,$F0,$0F,$F0,$00
	.BYTE $00,$F0,$FF,$FF,$0F,$00
	.BYTE $00,$00,$F0,$0F,$00,$00
	.BYTE $00,$FF,$FF,$FF,$FF,$00
	.BYTE $00,$FF,$F0,$0F,$FF,$00
	.BYTE $00,$F0,$00,$00,$0F,$00

intruders_enemy_data4
	.BYTE $00,$FF,$F0,$0F,$FF,$00
	.BYTE $00,$00,$FF,$FF,$00,$00
	.BYTE $00,$00,$F0,$0F,$00,$00
	.BYTE $00,$0F,$FF,$FF,$F0,$00
	.BYTE $00,$FF,$F0,$0F,$FF,$00
	.BYTE $00,$0F,$F0,$0F,$F0,$00





mission
	LDA #$00
	STA $FFFF ; turn on 16 color mode
	STZ missile_paused
	LDA #$0A ; arbitrary amount of initial population
	STA missile_pop_value
	STZ missile_score_low
	STZ missile_score_high
	LDA #$08
	STA missile_round_value
	LDA #$20
	STA missile_ammo_constant
	LDA #$0A
	STA missile_enemy_constant
	LDA #$08
	STA missile_random_constant
	LDA #$05
	STA missile_speed_constant
	JMP missile_start

missile_reset
	LDA missile_ammo_value
	CLC
	ADC missile_score_low
	INC A
	STA missile_score_low
	CLC
	CMP #$64 ; 100 in hex
	BCC missile_reset_ammo
	SEC
	SBC #$64
	STA missile_score_low
	INC missile_score_high
missile_reset_ammo
	LDA missile_ammo_constant
	CLC
	ADC #$02
	STA missile_ammo_constant
	LDA missile_enemy_constant
	CLC
	ADC #$04
	STA missile_enemy_constant
	LDA missile_random_constant
	CLC
	ADC #$02
	STA missile_random_constant
	DEC missile_round_value
	LDA missile_round_value
	CLC
	CMP #$03
	BCS missile_start
	LDA #$08
	STA missile_round_value
	DEC missile_speed_constant
	LDA missile_speed_constant
	CMP #$03
	BCS missile_start
	
	LDA #$08
	STA missile_round_value
	LDA #$05
	STA missile_speed_constant

missile_start
	STZ mouse_prev_x
	STZ mouse_prev_y
	LDA #$08
	STA mouse_prev_buttons
	STA mouse_buttons
	LDA #$80
	STA mouse_pos_x
	STA mouse_pos_y
	LDA #$08
	STA missile_key_space
	STZ missile_key_up
	STZ missile_key_down
	STZ missile_key_left
	STZ missile_key_right
	STZ missile_dist_value
	LDA missile_enemy_constant ; arbitrary amount of enemies each round
	STA missile_enemy_value
	STA missile_stop_value
	LDA missile_ammo_constant ; arbitrary amount of ammo each round
	STA missile_ammo_value
	LDX #$00
missile_target_loop
	STZ missile_missile_x,X
	STZ missile_missile_y,X
	STZ missile_target_x,X
	STZ missile_target_y,X
	STZ missile_slope_x,X
	STZ missile_slope_y,X
	STZ missile_count_x,X
	STZ missile_count_y,X
	JSR missile_prev_clear
	INX
	CPX #$10
	BNE missile_target_loop
	STZ sub_write+1	
	LDA #$08
	STA sub_write+2
missile_screen_loop
	LDA #$00 ; black
	JSR sub_write
	INC sub_write+1
	BNE missile_screen_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE missile_screen_loop
	LDY #$00
missile_input_loop
	LDA missile_pop_value
	BEQ missile_input_gameover
	CMP #$80
	BCS missile_input_gameover
	JMP missile_input_check
missile_input_gameover
	JMP missile_gameover ; game over when zero population
missile_input_check
	LDA missile_enemy_value
	BNE missile_input_continue
	LDA missile_stop_value
	BNE missile_input_continue
	JMP missile_reset ; reset game after each round
missile_input_continue
	CLC
	JSR sub_random ; helps randomize
	JSR missile_keyboard
	LDA missile_paused
	BNE missile_input_continue
	JSR missile_joystick
	JSR missile_keycheck
	JSR missile_mouse
	LDA clock_low
	CLC
	CMP #$01 ; arbitrary for frame rate
	BCC missile_input_loop
	STZ clock_low
	JSR missile_player
	INY
	CPY missile_speed_constant ; arbitrary for missile movement
	BCC missile_input_loop
	LDA #$14
	JSR missile_draw_building
	LDA #$25
	JSR missile_draw_building
	LDA #$4B
	JSR missile_draw_building
	LDA #$5C
	JSR missile_draw_building
	LDA #$37
	JSR missile_draw_bunker
	LDY #$00
	JSR missile_draw
	LDA #$00
	STA printchar_x
	LDA #$1D
	STA printchar_y
	LDA missile_pop_value
	JSR colornum
	LDA #$0E
	STA printchar_x
	LDA #$1D
	STA printchar_y
	LDA missile_ammo_value
	JSR colornum
	LDA #$1C
	STA printchar_x
	LDA #$1D
	STA printchar_y
	LDA missile_score_low
	JSR colornum
	LDA #$1A
	STA printchar_x
	LDA #$1D
	STA printchar_y
	LDA missile_score_high
	JSR colornum
	CLC
	JSR sub_random
	CLC
	CMP missile_random_constant ; arbitrary for appearance enemy missiles
	BCS missile_input_jump_loop
	LDA missile_enemy_value
	BEQ missile_input_jump_loop
	JSR missile_enemy
	CMP #$00
	BEQ missile_input_jump_loop
	DEC missile_enemy_value
missile_input_jump_loop
	JMP missile_input_loop

missile_gameover
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
missile_gameover_end_loop
	LDA missile_end_text,Y
	JSR colorchar
	INC printchar_x
	INY
	CPY #$07
	BNE missile_gameover_end_loop
missile_gameover_preloop
	JSR inputchar
	CMP #$00
	BNE missile_gameover_preloop
	LDA joy_buttons
	CMP #$FF
	BNE missile_gameover_preloop
	LDA mouse_buttons
	AND #%00000111
	BNE missile_gameover_preloop
missile_gameover_postloop
	JSR inputchar
	CMP #$1B ; escape to exit
	BNE missile_gameover_check
	JMP bank_switch
missile_gameover_check
	CMP #$20 ; space
	BEQ missile_gameover_reset
	LDA joy_buttons
	AND #%00110000
	CMP #%00110000
	BNE missile_gameover_reset
	LDA mouse_buttons
	AND #%00000111
	BNE missile_gameover_reset
	JMP missile_gameover_postloop
missile_gameover_reset
	JMP mission

missile_player
	PHA
	LDA #$00
	JSR missile_draw_cursor
	LDA mouse_pos_x
	CLC
	CMP #$10
	BCS missile_player_next1
	LDA #$10
	STA mouse_pos_x
missile_player_next1
	LDA mouse_pos_x
	CLC
	CMP #$F1
	BCC missile_player_next2
	LDA #$F0
	STA mouse_pos_x
missile_player_next2
	LDA mouse_pos_y
	CLC
	CMP #$20
	BCS missile_player_next3
	LDA #$20
	STA mouse_pos_y
missile_player_next3
	LDA mouse_pos_y
	CLC
	CMP #$E1
	BCC missile_player_next4
	LDA #$E0
	STA mouse_pos_y
missile_player_next4
	; check to see that mouse hasn't just passed through the borders!
	LDA mouse_pos_x
	STA mouse_prev_x
	LDA mouse_pos_y
	STA mouse_prev_y
	LDA #$FF
	JSR missile_draw_cursor
	PLA
	RTS

missile_enemy
	PHX
	PHY
	LDX #$08
missile_enemy_loop
	CLC
	JSR sub_random ; helps randomize
	LDA missile_target_x,X
	BNE missile_enemy_increment
	LDA missile_target_y,X
	BNE missile_enemy_increment
missile_enemy_random
	CLC
	JSR sub_random
	CLC
	CMP #$18
	BCC missile_enemy_random
	CLC
	CMP #$E8
	BCS missile_enemy_random
	STA missile_target_x,X
	LDA #$08
	STA missile_target_y,X
	CLC
	JSR sub_random
	CLC
	CMP #$18
	BCC missile_enemy_random
	CLC
	CMP #$E8
	BCS missile_enemy_random
	STA missile_missile_x,X ; initial location of missiles
	LDA #$F0
	STA missile_missile_y,X
	LDA missile_target_x,X
	SEC
	SBC missile_missile_x,X
	BCC missile_enemy_invert1
	STA missile_slope_x,X
	STA missile_count_x,X
	JMP missile_enemy_skip
missile_enemy_invert1
	EOR #$FF
	INC A
	STA missile_slope_x,X
	STA missile_count_x,X
missile_enemy_skip
	LDA missile_target_y,X
	SEC
	SBC missile_missile_y,X
	BCC missile_enemy_invert2
	STA missile_slope_y,X
	STA missile_count_y,X
	JMP missile_mouse_exit
missile_enemy_invert2
	EOR #$FF
	INC A
	STA missile_slope_y,X
	STA missile_count_y,X
	JMP missile_enemy_exit
missile_enemy_increment
	INX
	CPX #$10
	BNE missile_enemy_loop
	PLY
	PLX
	LDA #$00 ; error
	RTS
missile_enemy_exit
	PLY
	PLX
	LDA #$FF ; success
	RTS

missile_keycheck
	PHA
	LDA missile_key_up
	BEQ missile_keycheck_down
	INC missile_key_up
	CLC
	CMP #$FF
	BCC missile_keycheck_down
	STZ missile_key_up
	INC missile_key_up
	INC mouse_pos_y
	INC mouse_pos_y
missile_keycheck_down
	LDA missile_key_down
	BEQ missile_keycheck_left
	INC missile_key_down
	CLC
	CMP #$FF
	BCC missile_keycheck_left
	STZ missile_key_down
	INC missile_key_down
	DEC mouse_pos_y
	DEC mouse_pos_y
missile_keycheck_left
	LDA missile_key_left
	BEQ missile_keycheck_right
	INC missile_key_left
	CLC
	CMP #$FF
	BCC missile_keycheck_right
	STZ missile_key_left
	INC missile_key_left
	DEC mouse_pos_x
	DEC mouse_pos_x
missile_keycheck_right
	LDA missile_key_right
	BEQ missile_keycheck_exit
	INC missile_key_right
	CLC
	CMP #$FF
	BCC missile_keycheck_exit
	STZ missile_key_right
	INC missile_key_right
	INC mouse_pos_x
	INC mouse_pos_x
missile_keycheck_exit
	PLA
	RTS

missile_keyboard
	PHX
	PHA
missile_keyboard_start
	LDX key_read
	CPX key_write
	BNE missile_keyboard_compare
	JMP missile_keyboard_exit
missile_keyboard_compare
	LDA key_read
	INC A
	STA key_read
	CMP #$80
	BNE missile_keyboard_success
	STZ key_read
missile_keyboard_success
	LDA key_array,X
	CMP #$F0 ; release
	BEQ missile_keyboard_release
	CMP #$E0 ; extended
	BEQ missile_keyboard_extended
	CMP #ps2_escape
	BEQ missile_keyboard_bank
	CMP #ps2_f12 ; f12 to pause
	BNE missile_keyboard_regular
	JMP missile_keyboard_escape
missile_keyboard_bank
	JMP bank_switch
missile_keyboard_regular
	PHA
	LDA key_release
	BNE missile_keyboard_unpressed
missile_keyboard_pressed
	LDA key_extended
	BNE missile_keyboard_pressed_shifted
	PLA
	PHA
	CMP #ps2_space
	BNE missile_keyboard_clear
	LDA #$09
	STA mouse_buttons
	JMP missile_keyboard_clear
missile_keyboard_pressed_shifted
	PLA
	PHA
	CMP #ps2_arrow_up
	BEQ missile_keyboard_pressed_up
	CMP #ps2_arrow_down
	BEQ missile_keyboard_pressed_down
	CMP #ps2_arrow_left
	BEQ missile_keyboard_pressed_left
	CMP #ps2_arrow_right
	BEQ missile_keyboard_pressed_right
	JMP missile_keyboard_clear
missile_keyboard_unpressed
	LDA key_extended
	BNE missile_keyboard_unpressed_shifted
	PLA
	PHA
	CMP #ps2_space
	BNE missile_keyboard_clear
	LDA #$08
	STA mouse_buttons
	JMP missile_keyboard_clear
missile_keyboard_unpressed_shifted
	PLA
	PHA
	CMP #ps2_arrow_up
	BEQ missile_keyboard_unpressed_up
	CMP #ps2_arrow_down
	BEQ missile_keyboard_unpressed_down
	CMP #ps2_arrow_left
	BEQ missile_keyboard_unpressed_left
	CMP #ps2_arrow_right
	BEQ missile_keyboard_unpressed_right
missile_keyboard_clear
	PLA
	STZ key_release
	STZ key_extended
missile_keyboard_exit
	PLA
	PLX
	RTS
missile_keyboard_release
	STA key_release
	JMP missile_keyboard_exit
missile_keyboard_extended
	STA key_extended
	JMP missile_keyboard_exit
missile_keyboard_pressed_space
	INC missile_key_space
	JMP missile_keyboard_clear
missile_keyboard_pressed_up
	INC missile_key_up
	JMP missile_keyboard_clear
missile_keyboard_pressed_down
	INC missile_key_down
	JMP missile_keyboard_clear
missile_keyboard_pressed_left
	INC missile_key_left
	JMP missile_keyboard_clear
missile_keyboard_pressed_right
	INC missile_key_right
	JMP missile_keyboard_clear
missile_keyboard_unpressed_space
	STZ missile_key_space
	JMP missile_keyboard_clear
missile_keyboard_unpressed_up
	STZ missile_key_up
	JMP missile_keyboard_clear
missile_keyboard_unpressed_down
	STZ missile_key_down
	JMP missile_keyboard_clear
missile_keyboard_unpressed_left
	STZ missile_key_left
	JMP missile_keyboard_clear
missile_keyboard_unpressed_right
	STZ missile_key_right
	JMP missile_keyboard_clear
missile_keyboard_escape
	LDA key_release
	BEQ missile_keyboard_pause_start
	STZ key_release
	STZ key_extended
	JMP missile_keyboard_exit
missile_keyboard_pause_start
	LDA missile_paused
	EOR #$FF
	STA missile_paused
	BEQ missile_keyboard_pause_stop
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
missile_keyboard_pause_start_loop
	LDA missile_pause_text,Y
	JSR colorchar
	INC printchar_x
	INY
	CPY #$06
	BNE missile_keyboard_pause_start_loop
	STZ key_release
	STZ key_extended
	JMP missile_keyboard_exit
missile_keyboard_pause_stop
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
missile_keyboard_pause_stop_loop
	LDA #" "
	JSR colorchar
	INC printchar_x
	INY
	CPY #$06
	BNE missile_keyboard_pause_stop_loop
	STZ key_release
	STZ key_extended
	JMP missile_keyboard_exit	


missile_joystick
	PHA
	LDA joy_buttons
	PHA
	AND #%00000001
	BNE missile_joystick_zero1
	INC missile_key_up
	JMP missile_joystick_next1
missile_joystick_zero1
	LDA missile_joy_prev
	AND #%00000001
	BNE missile_joystick_next1
	STZ missile_key_up
missile_joystick_next1
	PLA
	PHA
	AND #%00000010
	BNE missile_joystick_zero2
	INC missile_key_down
	JMP missile_joystick_next2
missile_joystick_zero2
	LDA missile_joy_prev
	AND #%00000010
	BNE missile_joystick_next2
	STZ missile_key_down
missile_joystick_next2
	PLA
	PHA
	AND #%00000100
	BNE missile_joystick_zero3
	INC missile_key_left
	JMP missile_joystick_next3
missile_joystick_zero3
	LDA missile_joy_prev
	AND #%00000100
	BNE missile_joystick_next3
	STZ missile_key_left
missile_joystick_next3
	PLA
	PHA
	AND #%00001000
	BNE missile_joystick_zero4
	INC missile_key_right
	JMP missile_joystick_next4
missile_joystick_zero4
	LDA missile_joy_prev
	AND #%00001000
	BNE missile_joystick_next4
	STZ missile_key_right
missile_joystick_next4
	PLA
	PHA
	AND #%00110000 ; B or C buttons
	CMP #%00110000
	BEQ missile_joystick_zero5
	LDA #$09
	STA mouse_buttons
	JMP missile_joystick_next5
missile_joystick_zero5
	LDA missile_joy_prev
	AND #%00110000 ; B or C buttons
	CMP #%00110000
	BEQ missile_joystick_next5
	LDA #$08
	STA mouse_buttons	
missile_joystick_next5
	PLA
	STA missile_joy_prev
	PLA
	RTS
	
missile_mouse
	PHA
	PHX
	PHY
	LDA mouse_buttons
	AND #%00001111
	CMP mouse_prev_buttons
	BNE missile_mouse_click
	JMP missile_mouse_exit ; odd?
missile_mouse_click
	LDA mouse_buttons
	AND #%00000001
	BNE missile_mouse_click_start
	JMP missile_mouse_exit
missile_mouse_click_start
	LDX #$00
missile_mouse_click_loop
	LDA missile_target_x,X
	BNE missile_mouse_click_increment
	LDA missile_target_y,X
	BNE missile_mouse_click_increment
	LDA missile_ammo_value
	BEQ missile_mouse_click_increment
	DEC missile_ammo_value
	LDA #$00
	JSR missile_draw_target
	LDA mouse_pos_x
	STA missile_target_x,X
	LDA mouse_pos_y
	STA missile_target_y,X
	LDA #$80
	STA missile_missile_x,X ; initial location of missiles
	LDA #$08
	STA missile_missile_y,X
	LDA missile_target_x,X
	SEC
	SBC missile_missile_x,X
	BCC missile_mouse_click_invert1
	STA missile_slope_x,X
	STA missile_count_x,X
	JMP missile_mouse_click_skip
missile_mouse_click_invert1
	EOR #$FF
	INC A
	STA missile_slope_x,X
	STA missile_count_x,X
missile_mouse_click_skip
	LDA missile_target_y,X
	SEC
	SBC missile_missile_y,X
	BCC missile_mouse_click_invert2
	STA missile_slope_y,X
	STA missile_count_y,X
	JMP missile_mouse_exit
missile_mouse_click_invert2
	EOR #$FF
	INC A
	STA missile_slope_y,X
	STA missile_count_y,X
	JMP missile_mouse_exit
missile_mouse_click_increment
	INX
	CPX #$08
	BNE missile_mouse_click_loop
	JMP missile_mouse_exit
missile_mouse_exit
	LDA mouse_buttons
	AND #%00001111
	STA mouse_prev_buttons
	PLY
	PLX
	PLA
	RTS
	
missile_draw
	PHA
	PHX
	PHY
	LDX #$00
missile_draw_loop
	LDA missile_slope_x,X
	BNE missile_draw_jump_show
	LDA missile_slope_y,X
	BNE missile_draw_jump_show
	LDA missile_count_x,X
	BEQ missile_draw_jump_increment1
	JMP missile_draw_collide_start
missile_draw_jump_show	
	JMP missile_draw_show
missile_draw_jump_increment1
	JMP missile_draw_increment
missile_draw_collide_start
	LDA #$0F
	STA missile_count_y,X
missile_draw_collide_loop
	TXA
	CMP missile_count_y,X
	BNE missile_draw_collide_next
	JMP missile_draw_collide_increment
missile_draw_collide_next
	LDY missile_count_y,X
	LDA missile_slope_x,Y
	BNE missile_draw_collide_check
	LDA missile_slope_y,Y
	BNE missile_draw_collide_check
	JMP missile_draw_collide_increment
missile_draw_collide_check
	CLC
	CPX #$08
	BCS missile_draw_collide_distance
	CLC
	CPY #$08
	BCS missile_draw_collide_distance
	JSR missile_pythagorean
	CLC
	CMP #$20 ; arbitrary no-collide distance
	BCS missile_draw_collide_distance
	JMP missile_draw_collide_increment
missile_draw_collide_distance
	LDA missile_missile_x,Y
	SEC
	SBC missile_missile_x,X	
	CLC
	CMP #$08
	BCC missile_draw_collide_x
	CLC	
	CMP #$F8
	BCS missile_draw_collide_x
	JMP missile_draw_collide_increment
missile_draw_collide_x
	LDA missile_missile_y,Y
	SEC
	SBC missile_missile_y,X
	CLC
	CMP #$08
	BCC missile_draw_collide_y
	CLC	
	CMP #$F8
	BCS missile_draw_collide_y
	JMP missile_draw_collide_increment
missile_draw_collide_y
	PHX
	TYA
	TAX
	CLC
	CPX #$08
	BCS missile_draw_collide_target
	LDA #$00
	JSR missile_draw_target
missile_draw_collide_target
	LDA #$00
	JSR missile_draw_line
	STZ missile_slope_x,X
	STZ missile_slope_y,X
	LDA #$40 ; arbitrary duration of explosion
	STA missile_count_x,X
	STZ missile_count_y,X
	CLC
	CPX #$08
	BCC missile_draw_collide_target_end
	PHX
	TXA
	SEC
	SBC #$08
	TAX
	JSR missile_prev_clear
	PLX
missile_draw_collide_target_end
	PLX
missile_draw_collide_increment
	DEC missile_count_y,X
	LDA missile_count_y,X
	CMP #$FF
	BEQ missile_draw_collide_explosion 
	JMP missile_draw_collide_loop
missile_draw_jump_increment2	
	JMP missile_draw_increment
missile_draw_collide_explosion
	CPX #$08
	BCC missile_draw_explosion_white
	LDA #$99 ; red
	BNE missile_draw_explosion_color
missile_draw_explosion_white
	LDA #$FF
missile_draw_explosion_color
	JSR missile_draw_explosion
	DEC missile_count_x,X
	BNE missile_draw_jump_increment2
	LDA #$00
	JSR missile_draw_explosion
	CLC
	CPX #$08
	BCC missile_draw_zero_stats
	LDA missile_missile_y,X
	CLC
	CMP #$18 ; height above ground to still hit pop
	BCS missile_draw_zero_score
	DEC missile_pop_value
	JMP missile_draw_zero_stats
missile_draw_zero_score
	INC missile_score_low
	LDA missile_score_low
	CLC
	CMP #$64 ; 100 in hex
	BCC missile_draw_zero_stats
	SEC
	SBC #$64
	STA missile_score_low
	INC missile_score_high
missile_draw_zero_stats
	STZ missile_missile_x,X
	STZ missile_missile_y,X
	STZ missile_target_x,X
	STZ missile_target_y,X
	STZ missile_count_x,X
	CLC
	CPX #$08
	BCC missile_draw_jump_increment2
	DEC missile_stop_value
	JMP missile_draw_increment
missile_draw_show
	CLC
	CPX #$08
	BCS missile_draw_show_target
	LDA #$FF
	JSR missile_draw_target
missile_draw_show_target
	LDA #$00
	JSR missile_draw_missile
	CLC
	CPX #$08
	BCS missile_draw_prev_line
	JMP missile_draw_move_start
missile_draw_prev_line
	JSR missile_draw_line	
	PHY
	TXA
	SEC
	SBC #$08
	TAY
	LDA missile_missile_x,X
	CLC
	ROR A
	CMP missile_prev1_x,Y
	BNE missile_draw_prev_start
	LDA missile_missile_y,X
	EOR #$FF
	INC A
	CLC
	ROR A
	CMP missile_prev1_y,Y
	BNE missile_draw_prev_start
	JMP missile_draw_prev_end
missile_draw_prev_start
;	LDA missile_prev7_x,Y
;	STA missile_prev8_x,Y
;	LDA missile_prev7_y,Y
;	STA missile_prev8_y,Y
;	LDA missile_prev6_x,Y
;	STA missile_prev7_x,Y
;	LDA missile_prev6_y,Y
;	STA missile_prev7_y,Y
;	LDA missile_prev5_x,Y
;	STA missile_prev6_x,Y
;	LDA missile_prev5_y,Y
;	STA missile_prev6_y,Y
;	LDA missile_prev4_x,Y
;	STA missile_prev5_x,Y
;	LDA missile_prev4_y,Y
;	STA missile_prev5_y,Y
;	LDA missile_prev3_x,Y
;	STA missile_prev4_x,Y
;	LDA missile_prev3_y,Y
;	STA missile_prev4_y,Y
;	LDA missile_prev2_x,Y
;	STA missile_prev3_x,Y
;	LDA missile_prev2_y,Y
;	STA missile_prev3_y,Y
;	LDA missile_prev1_x,Y
;	STA missile_prev2_x,Y
;	LDA missile_prev1_y,Y
;	STA missile_prev2_y,Y

	PHX
	TYA
	CLC
	ADC #<missile_prev7_y
	STA sub_read+1
	LDA #>missile_prev7_y
	STA sub_read+2
	TYA
	CLC
	ADC #<missile_prev8_y
	STA sub_write+1
	LDA #>missile_prev8_y
	STA sub_write+2
	LDX #$0E
missile_draw_prev_loop
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
	BNE missile_draw_prev_loop
	PLX

	LDA missile_missile_x,X
	CLC
	ROR A
	STA missile_prev1_x,Y
	LDA missile_missile_y,X
	EOR #$FF
	INC A
	CLC
	ROR A
	STA missile_prev1_y,Y
missile_draw_prev_end
	PLY
missile_draw_move_start
	LDY #$00
missile_draw_move_counter
	DEC missile_count_y,X
	BNE missile_draw_move_skip1
	LDA missile_slope_y,X
	STA missile_count_y,X
	LDA missile_target_x,X
	CLC
	CMP missile_missile_x,X
	BEQ missile_draw_move_skip1
	BCC missile_draw_move_invert1
	INC missile_missile_x,X
	INY
	JMP missile_draw_move_skip2
missile_draw_move_invert1
	DEC missile_missile_x,X
	INY
missile_draw_move_skip1
	DEC missile_count_x,X
	BNE missile_draw_move_skip2
	LDA missile_slope_x,X
	STA missile_count_x,X
	LDA missile_target_y,X
	CLC
	CMP missile_missile_y,X
	BEQ missile_draw_move_skip2
	BCC missile_draw_move_invert2
	INC missile_missile_y,X
	INY
	JMP missile_draw_move_skip2
missile_draw_move_invert2
	DEC missile_missile_y,X
	INY
missile_draw_move_skip2
	LDA missile_missile_x,X
	CMP missile_target_x,X
	BNE missile_draw_move_done
	LDA missile_missile_y,X
	CMP missile_target_y,X
	BNE missile_draw_move_done
	CLC
	CPX #$08
	BCS missile_draw_move_target
	LDA #$00
	JSR missile_draw_target
missile_draw_move_target
	STZ missile_slope_x,X
	STZ missile_slope_y,X
	LDA #$40 ; arbitrary duration of explosion
	STA missile_count_x,X
	STZ missile_count_y,X
	CLC
	CPX #$08
	BCC missile_draw_move_target_end
	PHX
	TXA
	SEC
	SBC #$08
	TAX
	JSR missile_prev_clear
	PLX
missile_draw_move_target_end
	JMP missile_draw_increment
missile_draw_move_done
	CPY #$00
	BNE missile_draw_move_missile 
	JMP missile_draw_move_counter
missile_draw_move_missile
	CPX #$08
	BCC missile_draw_missile_check
	LDA #$09 ; red
	JSR missile_draw_line
	LDA #$99 ; red
	BNE missile_draw_missile_color
missile_draw_missile_check
	CLC
	CPY missile_round_value ; arbitrary speed of missiles
	BCS missile_draw_missile_white
	JMP missile_draw_move_counter
missile_draw_missile_white
	LDA #$FF
missile_draw_missile_color
	JSR missile_draw_missile
missile_draw_increment
	INX
	CPX #$10
	BEQ missile_draw_exit
	JMP missile_draw_loop
missile_draw_exit
	PLY
	PLX
	PLA
	RTS

missile_draw_cursor
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
	BCC missile_draw_cursor_exit
	LDY #$00
	LDX #$00
missile_draw_cursor_loop
	LDA missile_cursor_data,X
	BEQ missile_draw_cursor_skip
	PLA
	PHA
	AND missile_cursor_data,X
	JSR sub_write
missile_draw_cursor_skip
	INC sub_write+1
	INX
	INY
	CPY #$04
	BNE missile_draw_cursor_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7C
	STA sub_write+1
	BCC missile_draw_cursor_line
	INC sub_write+2
missile_draw_cursor_line
	CPX #$10
	BNE missile_draw_cursor_loop
missile_draw_cursor_exit
	PLA
	PLX	
	PLY
	RTS

missile_draw_target
	PHY
	PHX
	PHA
	LDA missile_target_x,X
	SEC
	SBC #$08
	CLC
	ROR A
	STA sub_write+1
	LDA missile_target_y,X
	CLC
	ADC #$04
	EOR #$FF
	INC A
	CLC
	ROR A
	STA sub_write+2 
	CLC
	CMP #$08
	BCC missile_draw_target_exit
	LDY #$00
	LDX #$00
missile_draw_target_loop
	LDA missile_target_data,X
	BEQ missile_draw_target_skip
	PLA
	PHA
	AND missile_target_data,X
	JSR sub_write
missile_draw_target_skip
	INC sub_write+1
	INX
	INY
	CPY #$04
	BNE missile_draw_target_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7C
	STA sub_write+1
	BCC missile_draw_target_line
	INC sub_write+2
missile_draw_target_line
	CPX #$10
	BNE missile_draw_target_loop
missile_draw_target_exit
	PLA
	PLX	
	PLY
	RTS

missile_draw_missile
	PHY
	PHX
	PHA
	LDA missile_missile_x,X
	CLC
	ROR A
	DEC A
	STA sub_write+1
	LDA missile_missile_y,X
	EOR #$FF
	INC A
	CLC
	ROR A
	DEC A
	STA sub_write+2 
	CLC
	CMP #$08
	BCC missile_draw_missile_exit
	LDY #$00
	LDX #$00
missile_draw_missile_loop
	LDA missile_missile_data,X
	BEQ missile_draw_missile_skip
	PLA
	PHA
	AND missile_missile_data,X
	JSR sub_write
missile_draw_missile_skip
	INC sub_write+1
	INX
	INY
	CPY #$02
	BNE missile_draw_missile_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7E
	STA sub_write+1
	BCC missile_draw_missile_line
	INC sub_write+2
missile_draw_missile_line
	CPX #$08
	BNE missile_draw_missile_loop
missile_draw_missile_exit
	PLA
	PLX	
	PLY
	RTS

missile_draw_line
	PHY
	PHX
	PHA
	TXA
	SEC
	SBC #$08
	TAX
	LDY #$08
missile_draw_line_loop
	LDA missile_prev1_x,X
	DEC A
	STA sub_write+1
	LDA missile_prev1_y,X
	DEC A
	STA sub_write+2
	CLC
	CMP #$08
	BCC missile_draw_line_exit
	CLC
	CMP #$80
	BCS missile_draw_line_exit
	PLA
	PHA
	JSR sub_write
	TXA
	CLC
	ADC #$10
	TAX
	DEY
	BNE missile_draw_line_loop
missile_draw_line_exit
	PLA
	PLX	
	PLY
	RTS

missile_draw_explosion
	PHY
	PHX
	PHA
	LDA missile_missile_x,X
	SEC
	SBC #$08
	CLC
	ROR A
	STA sub_write+1
	LDA missile_missile_y,X
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
	BCC missile_draw_explosion_exit
	LDY #$00
	LDX #$00
missile_draw_explosion_loop
	LDA missile_explosion_data,X
	BEQ missile_draw_explosion_skip
	PLA
	PHA
	AND missile_explosion_data,X
	JSR sub_write
missile_draw_explosion_skip
	INC sub_write+1
	INX
	INY
	CPY #$08
	BNE missile_draw_explosion_loop
	LDY #$00
	TXA
	SEC
	SBC #$08
	TAX
	LDA sub_write+1
	CLC
	ADC #$78
	STA sub_write+1
	BCC missile_draw_explosion_line
	TXA
	CLC
	ADC #$08
	TAX
	INC sub_write+2
missile_draw_explosion_line
	CPX #$40
	BNE missile_draw_explosion_loop
missile_draw_explosion_exit
	PLA
	PLX	
	PLY
	RTS

missile_draw_building
	PHY
	PHX
	PHA
	STA sub_write+1
	LDA #$78
	STA sub_write+2
	LDX #$08 ; length
	LDA #$FF ; color
	JSR missile_draw_line_horizontal
	LDX #$08
	LDA #$FF
	JSR missile_draw_line_vertical
	PLA
	PHA
	CLC
	ADC #$06
	STA sub_write+1
	LDA #$7C
	STA sub_write+2
	LDX #$08
	LDA #$FF
	JSR missile_draw_line_vertical
	PLA
	PHA
	CLC
	ADC #$06
	STA sub_write+1
	LDA #$7C
	STA sub_write+2
	LDX #$08
	LDA #$FF
	JSR missile_draw_line_horizontal
	LDX #$08
	LDA #$FF
	JSR missile_draw_line_vertical
	PLA
	PHA
	STA sub_write+1
	LDA #$78
	STA sub_write+2
	LDX #$10
	LDA #$FF
	JSR missile_draw_line_vertical
missile_draw_building_exit
	PLA
	PLX
	PLY
	RTS

missile_draw_bunker
	PHY
	PHX
	PHA
	STA sub_write+1
	LDA #$76
	STA sub_write+2
	LDX #$10 ; length
	LDA #$FF ; color
	JSR missile_draw_line_horizontal
	PLA
	PHA
	STA sub_write+1
	LDA #$74
	STA sub_write+2
	LDX #$10 ; length
	LDA #$FF ; color
	JSR missile_draw_line_horizontal
	LDX #$18
	LDA #$FF
	JSR missile_draw_line_vertical
	PLA
	PHA
	STA sub_write+1
	LDA #$74
	STA sub_write+2
	LDX #$18
	LDA #$FF
	JSR missile_draw_line_vertical
missile_draw_bunker_exit
	PLA
	PLX
	PLY
	RTS

missile_draw_line_horizontal
	JSR sub_write
	INC sub_write+1
	DEX
	BNE missile_draw_line_horizontal
	RTS

missile_draw_line_vertical
	JSR sub_write
	PHA
	LDA sub_write+1
	CLC
	ADC #$80
	STA sub_write+1
	BCC missile_draw_line_vertical_increment
	INC sub_write+2
missile_draw_line_vertical_increment
	PLA
	DEX
	BNE missile_draw_line_vertical
	RTS
	
missile_pythagorean
	LDA missile_missile_x,Y
	SEC
	SBC #$80
	CLC
	CMP #$80
	BCC missile_pythagorean_ready
	EOR #$FF
	INC A
missile_pythagorean_ready
	STA missile_dist_value
	CMP missile_missile_y,Y
	BCC missile_pythagorean_horizontal
	CLC
	ROR A
	CLC
	ADC missile_missile_y,Y
	STA missile_dist_value
	RTS
missile_pythagorean_horizontal
	LDA missile_missile_y,Y
	CLC
	ROR A
	CLC
	ADC missile_dist_value
	STA missile_dist_value
	RTS

missile_prev_clear
	PHA
	PHY
	TXA
	CLC
	ADC #<missile_prev1_x
	STA sub_write+1
	LDA #>missile_prev1_x
	STA sub_write+2
	LDY #$10
missile_prev_clear_loop
	LDA #$00
	JSR sub_write
	LDA sub_write+1
	CLC
	ADC #$08
	STA sub_write+1
	DEY
	BNE missile_prev_clear_loop
	PLY
	PLA
	RTS
	

missile_cursor_data
	.BYTE $FF,$FF,$FF,$E1
	.BYTE $FF,$FF,$E1,$00
	.BYTE $FF,$E1,$00,$00
	.BYTE $E1,$00,$00,$00

missile_target_data
	.BYTE $00,$00,$00,$1E
	.BYTE $00,$00,$1E,$FF
	.BYTE $00,$1E,$FF,$FF
	.BYTE $1E,$FF,$FF,$FF

missile_missile_data
	.BYTE $1E,$E1
	.BYTE $EF,$FE
	.BYTE $EF,$FE
	.BYTE $1E,$E1

missile_explosion_data
	.BYTE $00,$00,$1E,$FF,$FF,$E1,$00,$00
	.BYTE $00,$1E,$FF,$FF,$FF,$FF,$E1,$00
	.BYTE $1E,$FF,$FF,$FF,$FF,$FF,$FF,$E1
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $1E,$FF,$FF,$FF,$FF,$FF,$FF,$E1
	.BYTE $00,$1E,$FF,$FF,$FF,$FF,$E1,$00
	.BYTE $00,$00,$1E,$FF,$FF,$E1,$00,$00

missile_end_text
	.BYTE "The End"

missile_pause_text
	.BYTE "Paused"









	
galian
	LDA #$00 ; produces 16-colors
	STA $FFFF 

	JMP galian_start

galian_enemy_stats_health
	.BYTE $08,$02,$02,$04
galian_enemy_stats_dir_x
	.BYTE $00,$02,$00,$00
galian_enemy_stats_dir_y
	.BYTE $00,$00,$02,$00
galian_enemy_stats_state
	.BYTE $00,$00,$00,$00

galian_enemy_limit		.EQU $10 ; max of $10

galian_start
	STZ galian_button_up
	STZ galian_button_down
	STZ galian_button_left
	STZ galian_button_right
	STZ galian_button_fire
	STZ galian_release
	LDA joy_buttons
	STA galian_joy_prev
	STZ galian_fire_delay
	STZ galian_frame
	STZ galian_clock
	STZ galian_filter
	LDA #$31 ; almost start on second level
	STA galian_enemy_count
	LDA #%01111111 ; #%01111111 to start
	STA galian_star_speed
	LDA #%00111111 ; #%00111111 to start
	STA galian_enemy_speed
	LDA #%00000011 ; #%00000011 to start
	STA galian_bullet_speed
	STZ galian_score_low
	STZ galian_score_high
	LDA #$01
	STA galian_level
	STZ galian_pause_mode

	LDX #$00
galian_clear_lists
	STZ galian_bullet_x,X
	STZ galian_bullet_y,X
	STZ galian_enemy_x,X
	STZ galian_enemy_y,X
	STZ galian_enemy_dx,X
	STZ galian_enemy_dy,X
	STZ galian_enemy_t,X
	STZ galian_enemy_h,X
	STZ galian_enemy_s,X
	STZ galian_particle_x,X
	STZ galian_particle_y,X
	STZ galian_particle_dx,X
	CLC
	JSR sub_random
	AND #%01111110
	STA galian_star_x,X
galian_star_random
	CLC
	JSR sub_random
	CLC
	CMP #$12
	BCC galian_star_random
	STA galian_star_y,X
	INX
	CPX #$10
	BNE galian_clear_lists

	LDA #$00
	STA sub_write+1
	LDA #$08
	STA sub_write+2
galian_clear_loop
	LDA #$00
	JSR sub_write
	INC sub_write+1
	BNE galian_clear_loop
	INC sub_write+2
	LDA sub_write+2
	CLC
	CMP #$80
	BCC galian_clear_loop

	LDA #$FF
	STA galian_player_flash
	LDA #$3C
	STA galian_player_x
	LDA #$E0
	STA galian_player_y
	LDA #$03
	STA galian_player_lives
	
galian_loop
	LDA galian_pause_mode
	BEQ galian_loop_continue
	JMP galian_input_keys
galian_loop_continue
	LDA clock_low
	CLC
	CMP #$01
	BCS galian_tick
	JMP galian_draw
galian_tick
	STZ clock_low
	INC galian_frame

	LDA galian_frame
	AND #%00000001
	BNE galian_enemy_appearance
	JMP galian_ai
galian_enemy_appearance
	LDA galian_score_high
	CLC
	CMP #$10
	BCC galian_enemy_appearance_random
	JMP galian_enemy_beginning
galian_enemy_appearance_random
	CLC
	JSR sub_random
	AND galian_star_speed ; arbitrary enemy appearance
	BEQ galian_enemy_beginning
	JMP galian_ai

galian_enemy_beginning
	LDX #$00
galian_enemy_find
	LDA galian_enemy_x,X
	BNE galian_enemy_continue_pre
	LDA galian_enemy_y,X
galian_enemy_continue_pre
	BNE galian_enemy_continue
galian_enemy_random
	CLC
	JSR sub_random
	CLC
	CMP #$10
	BCC galian_enemy_random
	CLC
	CMP #$70
	BCS galian_enemy_random
	STA galian_enemy_x,X
	LDA #$10
	STA galian_enemy_y,X
	CLC
	JSR sub_random
	AND #%00000011 ; arbitrary max enemies
	STA galian_enemy_t,X
	TAY
	LDA galian_enemy_stats_health,Y
	STA galian_enemy_h,X
	LDA galian_enemy_stats_dir_x,Y
	STA galian_enemy_dx,X
	LDA galian_score_high ; at some point, the speed increases a lot
	CLC
	ROR A
	CLC
	ROR A
	CLC
	ROR A
	CLC
	ROR A
	CLC
	ADC galian_enemy_stats_dir_y,Y
	STA galian_enemy_dy,X
	STZ galian_enemy_s,X
	;INC galian_enemy_count ; now incrementing on enemy destroyed
	LDA galian_enemy_count
	CMP #$32 ; arbitrary enemy count to next level
	BCC galian_ai
	STZ galian_enemy_count
	LDA galian_level
	AND #%00000001
	BNE galian_enemy_second
	LDA galian_enemy_speed
	CMP #%00000011
	BEQ galian_ai
	INC galian_level
	CLC
	ROR galian_enemy_speed
	CLC
	ROR galian_star_speed
	DEC galian_bullet_speed
	JMP galian_ai
galian_enemy_second
	LDA galian_enemy_speed
	CMP #%00000011
	BEQ galian_ai
	INC galian_level
	CLC
	ROR galian_enemy_speed
	CLC
	ROR galian_star_speed
	JMP galian_ai
galian_enemy_continue
	INX
	CPX #galian_enemy_limit ; used to be limiting to only 8 enemies on screen at once
	BEQ galian_ai
	JMP galian_enemy_find

galian_ai
	LDX #$00
galian_ai_loop
	LDA galian_enemy_t,X
	BEQ galian_ai_increment
	CMP #$01
	BEQ galian_ai_one
	CMP #$02
	BEQ galian_ai_two
	CMP #$03
	BEQ galian_ai_three
galian_ai_increment
	INX
	CPX #$10
	BNE galian_ai_loop
	JMP galian_delay
galian_ai_one
	INC galian_enemy_s,X
	LDA galian_enemy_s,X
	CMP #$10
	BEQ galian_ai_one_change1
	CMP #$20
	BEQ galian_ai_one_change2
	CMP #$30
	BEQ galian_ai_one_change3
	CMP #$40
	BEQ galian_ai_one_change4
	CMP #$50
	BEQ galian_ai_one_change5
	CMP #$60
	BEQ galian_ai_one_change6
	JMP galian_ai_increment
galian_ai_one_change1
	LDA #$01
	STA galian_enemy_dx,X
	JMP galian_ai_increment
galian_ai_one_change2
	LDA #$FF
	STA galian_enemy_dx,X
	JMP galian_ai_increment
galian_ai_one_change3
	LDA #$FE
	STA galian_enemy_dx,X
	JMP galian_ai_increment
galian_ai_one_change4
	LDA #$FF
	STA galian_enemy_dx,X
	JMP galian_ai_increment
galian_ai_one_change5
	LDA #$01
	STA galian_enemy_dx,X
	JMP galian_ai_increment
galian_ai_one_change6
	LDA #$02
	STA galian_enemy_dx,X
	STZ galian_enemy_s,X
	JMP galian_ai_increment
galian_ai_two
	JMP galian_ai_increment
galian_ai_three
	INC galian_enemy_s,X
	LDA galian_score_high
	CLC
	ROR A
	CLC
	ROR A
	CLC
	ROR A
	CLC
	ROR A
	CLC
	ADC galian_enemy_s,X
	STA galian_enemy_s,X
	LDA galian_enemy_s,X
	CLC
	CMP #$40 ; arbitrary speed of shooting
	BCS galian_ai_three_particles
	JMP galian_ai_increment
galian_ai_three_particles
	STZ galian_enemy_s,X
	LDY #$00
galian_ai_three_loop
	LDA galian_particle_x,Y
	BNE galian_ai_three_increment
	LDA galian_particle_y,Y
	BNE galian_ai_three_increment
	LDA galian_enemy_x,X
	SEC
	SBC #$01
	STA galian_particle_x,y
	LDA galian_enemy_y,X
	CLC	
	ADC #$07
	STA galian_particle_y,Y
	CLC
	JSR sub_random
	CLC
	CMP #$60 ; arbitrary prob
	BCC galian_ai_three_left
	CLC
	CMP #$A0 ; arbitrary prob
	BCC galian_ai_three_right
	LDA #$00
	STA galian_particle_dx,Y
	JMP galian_ai_increment
galian_ai_three_left
	LDA #$FF
	STA galian_particle_dx,Y
	JMP galian_ai_increment
galian_ai_three_right
	LDA #$01
	STA galian_particle_dx,Y
	JMP galian_ai_increment
galian_ai_three_increment
	INY
	CPY #$10
	BNE galian_ai_three_loop
	JMP galian_ai_increment
	
	


galian_delay
	LDA galian_fire_delay
	BEQ galian_controls0
	DEC galian_fire_delay
galian_controls0
	LDA galian_button_up
	BEQ galian_controls1
	DEC galian_player_y
galian_controls1
	LDA galian_button_down
	BEQ galian_controls2
	INC galian_player_y
galian_controls2
	LDA galian_button_left
	BEQ galian_controls3
	DEC galian_player_x
galian_controls3
	LDA galian_button_right
	BEQ galian_controls4
	INC galian_player_x
galian_controls4
	LDA galian_button_fire
	BEQ galian_controls5
	
	LDA galian_fire_delay
	BNE galian_controls5
	LDA #$08 ; arbitrary fire delay
	STA galian_fire_delay
	LDX #$00
galian_bullet_seek
	LDA galian_bullet_x,X
	BNE galian_bullet_increment
	LDA galian_bullet_y,X
	BNE galian_bullet_increment
	LDA galian_player_x
	CLC
	ADC #$03
	STA galian_bullet_x,X
	LDA galian_player_y
	STA galian_bullet_y,X
	JMP galian_controls5
galian_bullet_increment
	INX
	CPX #$10
	BNE galian_bullet_seek

galian_controls5
	LDA galian_player_x
	CLC
	CMP #$08
	BCS galian_controls6
	LDA #$08
	STA galian_player_x
galian_controls6
	CLC
	CMP #$70
	BCC galian_controls7
	LDA #$70
	STA galian_player_x
galian_controls7
	LDA galian_player_y
	CLC
	CMP #$28
	BCS galian_controls8
	LDA #$28
	STA galian_player_y
galian_controls8
	CLC
	CMP #$F0
	BCC galian_controls9
	LDA #$F0
	STA galian_player_y
galian_controls9
	LDA galian_player_flash
	BEQ galian_controls10
	DEC galian_player_flash
galian_controls10

	LDA galian_player_flash	
	BNE galian_draw
	JSR galian_player_collision
	CMP #$FF
	BEQ galian_flying
	DEC galian_player_lives
	BEQ galian_gameover_jump
	TAX
	LDA #$00
	JSR galian_draw_enemy
	STZ galian_enemy_x,X
	STZ galian_enemy_y,X
	STZ galian_enemy_t,X
	JMP galian_collision
galian_flying
	LDX #$00
galian_flying_loop
	JSR galian_particle_collision
	CMP #$FF
	BEQ galian_flying_increment
	DEC galian_player_lives
	BEQ galian_gameover_jump
	LDA #$00
	JSR galian_draw_particle
	STZ galian_particle_x,X
	STZ galian_particle_y,X
	JMP galian_collision
galian_flying_increment
	INX
	CPX #$10
	BNE galian_flying_loop
	JMP galian_draw
galian_gameover_jump
	JMP galian_gameover
galian_collision
	TAX
	LDA #$00
	JSR galian_draw_player
	LDA #$FF
	STA galian_player_flash
	LDA #$3C
	STA galian_player_x
	LDA #$E0
	STA galian_player_y

galian_draw
	INC galian_clock
	LDA galian_clock
	AND #%00000011
	CLC
	CMP galian_bullet_speed ; arbitrary bullet speed limiter
	BCS galian_bullet_beginning
	JMP galian_stars
galian_bullet_beginning
	LDX #$00
galian_bullet_loop
	LDA galian_bullet_x,X
	BEQ galian_bullet_nop
	LDA galian_bullet_y,X
	BEQ galian_bullet_nop
	LDA #$00
	JSR galian_draw_bullet
	LDA galian_bullet_y,X	
	SEC
	SBC #$01 ; arbitrary bullet speed
	STA galian_bullet_y,X
	CLC
	CMP #$11 ; instead of $10 ??
	BCC galian_bullet_zero
	JSR galian_bullet_collision
	CMP #$FF
	BEQ galian_bullet_full
	PHX
	TAX
	DEC galian_enemy_h,X
	BNE galian_bullet_hit
	INC galian_enemy_count
	LDA galian_score_low
	CLC
	ADC galian_level
	INC A
	STA galian_score_low
	CMP #$64 ; 100 in decimal
	BCC galian_bullet_unshow
	SEC
	SBC #$64
	STA galian_score_low
	INC galian_score_high
	LDA galian_score_high
	CLC
	CMP #$10
	BCS galian_bullet_unshow
	INC galian_player_lives
galian_bullet_unshow
	LDA #$00
	JSR galian_draw_enemy
	STZ galian_enemy_x,X
	STZ galian_enemy_y,X
	STZ galian_enemy_t,X
	JMP galian_bullet_hit
galian_bullet_full

	JSR galian_tiny_collision
	CMP #$FF
	BNE galian_bullet_zero

	LDA #$FF
	JSR galian_draw_bullet
	JMP galian_bullet_next
galian_bullet_hit
	PLX
galian_bullet_zero
	STZ galian_bullet_x,X
	STZ galian_bullet_y,X
galian_bullet_next
	INX
	CPX #$10
	BNE galian_bullet_loop
	JMP galian_stars
galian_bullet_nop
	LDY #$80 ; arbitrary delay
galian_bullet_nop_loop ; simulates drawing delay
	NOP
	NOP
	NOP
	NOP	
	DEY
	BNE galian_bullet_nop_loop
	JMP galian_bullet_next

galian_stars
	LDA galian_clock
	AND galian_star_speed ; arbitrary star speed
	BEQ galian_star_start
	JMP galian_enemies
galian_star_start
	LDX #$00
galian_star_move
	LDA #$00
	JSR galian_draw_star
	LDA galian_star_y,X
	CLC	
	ADC #$01 ; arbitrary star speed
	STA galian_star_y,X
	CLC
	CMP #$F8
	BCC galian_star_show
galian_star_destroy
	CLC
	JSR sub_random
	AND #%01111110
	STA galian_star_x,X
	CLC	
	JSR sub_random
	AND #%00000011
	CLC
	ADC #$12
	STA galian_star_y,X
galian_star_show
	LDA #$FF
	JSR galian_draw_star
	INX
	CPX #$10
	BNE galian_star_move


galian_enemies
	LDA galian_clock
	AND galian_enemy_speed ; arbitrary enemy speed limiter
	BEQ galian_enemy_start
	JMP galian_particles
galian_enemy_start
	LDX #$00
galian_enemy_move
	LDA galian_enemy_x,X
	BEQ galian_enemy_nop
	LDA galian_enemy_y,X
	BEQ galian_enemy_nop
	LDA #$00
	JSR galian_draw_enemy
	LDA galian_enemy_x,X
	CLC	
	ADC galian_enemy_dx,X
	STA galian_enemy_x,X
	CLC
	CMP #$04
	BCC galian_enemy_destroy
	CLC
	CMP #$7C
	BCS galian_enemy_destroy
	LDA galian_enemy_y,X
	CLC	
	ADC galian_enemy_dy,X
	STA galian_enemy_y,X
galian_enemy_fall
	LDA galian_enemy_y,X
	CLC	
	ADC #$01 ; arbitrary enemy speed
	STA galian_enemy_y,X
	CLC
	CMP #$F0
	BCC galian_enemy_show
galian_enemy_destroy
	STZ galian_enemy_x,X
	STZ galian_enemy_y,X
	STZ galian_enemy_t,X
	STZ galian_enemy_h,X
	JMP galian_enemy_skip
galian_enemy_show
	LDA #$FF
	JSR galian_draw_enemy
galian_enemy_skip
	INX
	CPX #$10
	BNE galian_enemy_move
	JMP galian_particles
galian_enemy_nop
	CLC	
	CPX #galian_enemy_limit ; only nop the first enemies
	BCC galian_enemy_skip
	LDY #$FF ; arbitrary delay
galian_enemy_nop_loop ; simulates drawing delay
	NOP
	NOP
	NOP
	NOP	
	DEY
	BNE galian_enemy_nop_loop
	JMP galian_enemy_skip

galian_particles
	LDA galian_clock
	AND galian_enemy_speed ; arbitrary particle speed limiter
	BEQ galian_particle_start
	JMP galian_sprites
galian_particle_start
	LDX #$00
galian_particle_move
	LDA galian_particle_x,X
	BEQ galian_particle_nop
	LDA galian_particle_y,X
	BEQ galian_particle_nop
	LDA #$00
	JSR galian_draw_particle
	LDA galian_particle_x,X
	CLC	
	ADC galian_particle_dx,X
	STA galian_particle_x,X
	CLC	
	CMP #$04
	BCC galian_particle_clear
	CLC
	CMP #$7C
	BCS galian_particle_clear

	LDA galian_score_high ; at some point, the speed increases a lot
	CLC
	ROR A
	CLC
	ROR A
	CLC
	ROR A
	CLC
	ROR A
	CLC

	ADC galian_particle_y,X
	INC A
	CLC	
	ADC #$02 ; constant
	STA galian_particle_y,X
	CLC
	CMP #$12
	BCC galian_particle_clear
	CLC
	CMP #$F8
	BCS galian_particle_clear
	LDA #$FF
	JSR galian_draw_particle
galian_particle_skip
	INX
	CPX #$10
	BNE galian_particle_move
	JMP galian_sprites
galian_particle_clear
	STZ galian_particle_x,X
	STZ galian_particle_y,X
	JMP galian_particle_skip
galian_particle_nop
	LDY #$80 ; arbitrary delay
galian_particle_nop_loop ; simulates drawing delay
	NOP
	NOP
	NOP
	NOP	
	DEY
	BNE galian_particle_nop_loop
	JMP galian_particle_skip
	

galian_sprites

	LDA #$FF
	JSR galian_draw_player

	LDA galian_frame
	AND #%00001111
	BNE galian_input
	JSR galian_draw_menu

galian_input
	LDA joy_buttons
	CMP galian_joy_prev
	BEQ galian_input_keys
	
	JSR galian_joy

galian_input_keys
	LDX key_read
	CPX key_write
	BEQ galian_input_exit
	CLC
	JSR sub_random
	LDA key_array,X
	INC key_read
	BPL galian_input_positive
	STZ key_read
galian_input_positive
	CMP #$F0
	BEQ galian_input_release
	CMP #$E0
	BEQ galian_input_exit
	CMP #ps2_escape
	BEQ galian_input_bank
	CMP #ps2_f12
	BEQ galian_input_pause
	CMP #ps2_arrow_up
	BEQ galian_input_up
	CMP #ps2_arrow_down
	BEQ galian_input_down
	CMP #ps2_arrow_left
	BEQ galian_input_left
	CMP #ps2_arrow_right
	BEQ galian_input_right
	CMP #ps2_space
	BEQ galian_input_fire
galian_input_exit
	JMP galian_loop
galian_input_bank
	JMP bank_switch
galian_input_pause
	JSR galian_pause
	JMP galian_loop
galian_input_release
	LDA #$FF
	STA galian_release
	JMP galian_loop
galian_input_up
	LDA galian_release
	EOR #$FF
	STA galian_button_up
	STZ galian_release
	JMP galian_loop
galian_input_down
	LDA galian_release
	EOR #$FF
	STA galian_button_down
	STZ galian_release
	JMP galian_loop
galian_input_left
	LDA galian_release
	EOR #$FF
	STA galian_button_left
	STZ galian_release
	JMP galian_loop
galian_input_right
	LDA galian_release
	EOR #$FF
	STA galian_button_right
	STZ galian_release
	JMP galian_loop
galian_input_fire
	LDA galian_release
	EOR #$FF
	STA galian_button_fire
	STZ galian_release
	JMP galian_loop

galian_joy
	LDA joy_buttons
	AND #%00000001
	BNE galian_joy_next1
	LDA #$FF
	STA galian_button_up
	JMP galian_joy_next2
galian_joy_next1
	LDA galian_joy_prev
	AND #%00000001
	BNE galian_joy_next2
	STZ galian_button_up
galian_joy_next2
	LDA joy_buttons
	AND #%00000010
	BNE galian_joy_next3
	LDA #$FF
	STA galian_button_down
	JMP galian_joy_next4
galian_joy_next3
	LDA galian_joy_prev
	AND #%00000010
	BNE galian_joy_next4
	STZ galian_button_down
galian_joy_next4
	LDA joy_buttons
	AND #%00000100
	BNE galian_joy_next5
	LDA #$FF
	STA galian_button_left
	JMP galian_joy_next6
galian_joy_next5
	LDA galian_joy_prev
	AND #%00000100
	BNE galian_joy_next6
	STZ galian_button_left
galian_joy_next6
	LDA joy_buttons
	AND #%00001000
	BNE galian_joy_next7
	LDA #$FF
	STA galian_button_right
	JMP galian_joy_next8
galian_joy_next7
	LDA galian_joy_prev
	AND #%00001000
	BNE galian_joy_next8
	STZ galian_button_right
galian_joy_next8
	LDA joy_buttons
	AND #%00110000
	CMP #%00110000
	BEQ galian_joy_next9
	LDA #$FF
	STA galian_button_fire
	JMP galian_joy_next10
galian_joy_next9
	LDA galian_joy_prev
	AND #%00110000
	CMP #%00110000
	BEQ galian_joy_next10
	STZ galian_button_fire
galian_joy_next10
	LDA joy_buttons
	STA galian_joy_prev
	RTS



galian_player_collision ; return A as $FF for none, otherwise enemy id
	PHY
	LDY #$00
galian_player_collision_loop
	LDA galian_enemy_x,Y
	BEQ galian_player_collision_increment
	CLC
	ADC #$01
	CLC	
	CMP galian_player_x
	BCC galian_player_collision_increment
	SEC
	SBC #$0B
	CLC
	CMP galian_player_x
	BCS galian_player_collision_increment
	LDA galian_enemy_y,Y
	BEQ galian_player_collision_increment
	SEC
	SBC #$08
	CLC	
	CMP galian_player_y
	BCS galian_player_collision_increment 
	CLC
	ADC #$10
	CLC
	CMP galian_player_y
	BCC galian_player_collision_increment
	TYA
	JMP galian_player_collision_exit
galian_player_collision_increment
	INY
	CPY #$10
	BNE galian_player_collision_loop
	LDA #$FF ; no collision
galian_player_collision_exit
	PLY
	RTS


galian_bullet_collision ; X already set, return A as $FF for none, otherwise enemy id
	PHX
	PHY
	LDY #$00
galian_bullet_collision_loop
	LDA galian_enemy_x,Y
	BEQ galian_bullet_collision_increment
	CLC
	ADC #$01
	CLC	
	CMP galian_bullet_x,X
	BCC galian_bullet_collision_increment
	SEC
	SBC #$05
	CLC
	CMP galian_bullet_x,X
	BCS galian_bullet_collision_increment
	LDA galian_enemy_y,Y
	BEQ galian_bullet_collision_increment
	CLC	
	CMP galian_bullet_y,X
	BCS galian_bullet_collision_increment 
	CLC
	ADC #$08
	CLC
	CMP galian_bullet_y,X
	BCC galian_bullet_collision_increment
	TYA
	JMP galian_bullet_collision_exit
galian_bullet_collision_increment
	INY
	CPY #$10
	BNE galian_bullet_collision_loop
	LDA #$FF ; no collision
galian_bullet_collision_exit
	PLY
	PLX
	RTS

galian_particle_collision ; X already set, return A as $FF for none, otherwise hit player
	PHX
galian_particle_collision_loop
	LDA galian_player_x
	BEQ galian_particle_collision_increment
	CLC
	ADC #$05
	CLC	
	CMP galian_particle_x,X
	BCC galian_particle_collision_increment
	SEC
	SBC #$06
	CLC
	CMP galian_particle_x,X
	BCS galian_particle_collision_increment
	LDA galian_player_y
	BEQ galian_bullet_collision_increment
	CLC	
	CMP galian_particle_y,X
	BCS galian_particle_collision_increment 
	CLC
	ADC #$08
	CLC
	CMP galian_particle_y,X
	BCC galian_particle_collision_increment
	LDA #$00 ; hit
	JMP galian_particle_collision_exit
galian_particle_collision_increment
	LDA #$FF ; miss
galian_particle_collision_exit
	PLX
	RTS

galian_tiny_collision ; X already set, return A as $FF for none, otherwise hit particle
	PHY
	LDY #$00
galian_tiny_collision_loop
	LDA galian_particle_x,Y
	BEQ galian_tiny_collision_skip
	LDA galian_particle_y,Y
	BEQ galian_tiny_collision_skip
	LDA galian_particle_x,Y
	CLC
	ADC #$02
	CMP galian_bullet_x,X
	BCC galian_tiny_collision_skip
	SEC
	SBC #$04
	CMP galian_bullet_x,X
	BCS galian_tiny_collision_skip
	LDA galian_particle_y,Y
	CLC
	ADC #$02
	CMP galian_bullet_y,X
	BCC galian_tiny_collision_skip
	SEC
	SBC #$04
	CMP galian_bullet_y,X
	BCS galian_tiny_collision_skip
	PHX
	TYA
	TAX
	LDA #$00
	JSR galian_draw_particle
	TXA
	TAY
	PLX
	LDA #$00	
	STA galian_particle_x,Y
	STA galian_particle_y,Y
	TYA
	JMP galian_tiny_collision_exit
galian_tiny_collision_skip
	INY
	CPY #$10
	BNE galian_tiny_collision_loop
	LDA #$FF
galian_tiny_collision_exit
	PLY
	RTS

galian_pause
	LDA galian_pause_mode
	BNE galian_pause_unset
	LDA galian_release
	BEQ galian_pause_exit
	JSR galian_draw_pause
	LDA #$FF
	STA galian_pause_mode
	STZ galian_release
	RTS
galian_pause_unset
	LDA galian_release
	BEQ galian_pause_exit
	JSR galian_clear_pause
	STZ galian_pause_mode
	STZ galian_button_up
	STZ galian_button_down
	STZ galian_button_left
	STZ galian_button_right
	STZ galian_button_fire
galian_pause_exit
	STZ galian_release
	RTS

galian_gameover
	JSR galian_draw_gameover
galian_gameover_loop
	LDA joy_buttons
	CMP #$FF
	BNE galian_gameover_loop
	JSR inputchar
	CMP #$00 ; none
	BEQ galian_gameover_reset
	JMP galian_gameover_loop
galian_gameover_reset
	LDA joy_buttons
	AND #%00110000
	CMP #%00110000
	BNE galian_gameover_restart
	JSR inputchar
	CMP #$1B ; escape
	BEQ galian_gameover_quit
	CMP #$20 ; space
	BEQ galian_gameover_restart
	JMP galian_gameover_reset
galian_gameover_quit
	JMP bank_switch
galian_gameover_restart
	JMP galian

	
galian_draw_player ; A already set
	PHX
	PHA
	LDA galian_player_flash
	BEQ galian_draw_player_filter
	LDA galian_frame
	AND #%00001000
	BEQ galian_draw_player_zero
	LDA #%11101110
	JMP galian_draw_player_filter
galian_draw_player_zero
	LDA #%00010001
galian_draw_player_filter
	EOR #$FF
	STA galian_filter
	PLA
	PHA
	AND galian_filter
	STA galian_filter

	LDA #<galian_player_data
	STA sub_index+1
	LDA #>galian_player_data
	STA sub_index+2
	LDA galian_player_y
	AND #%00000001
	CLC
	ROR A
	ROR A
	CLC
	ADC galian_player_x
	STA sub_write+1
	LDA galian_player_y
	CLC
	ROR A
	STA sub_write+2
	LDX #$00
	LDY #$00
galian_draw_player_loop
	JSR sub_index
	AND galian_filter
	JSR sub_write	
	INC sub_write+1
	INX
	INY
	CPY #$08
	BNE galian_draw_player_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$78
	STA sub_write+1
	BCC galian_draw_player_check
	INC sub_write+2
galian_draw_player_check
	CPX #$40
	BNE galian_draw_player_loop

	LDA #<galian_burner_data
	STA sub_index+1
	LDA #>galian_burner_data
	STA sub_index+2
	LDA galian_player_y
	CLC
	ADC #$08
	AND #%00000001
	CLC
	ROR A
	ROR A
	CLC
	ADC galian_player_x
	STA sub_write+1
	LDA galian_player_y
	CLC
	ADC #$08
	CLC
	ROR A
	STA sub_write+2
	LDA galian_frame
	AND #%00001000
	CLC
	ROL A
	ROL A
	TAX
	LDY #$00
galian_draw_player_burner_loop
	JSR sub_index
	AND galian_filter
	JSR sub_write	
	INC sub_write+1
	INX
	INY
	CPY #$08
	BNE galian_draw_player_burner_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$78
	STA sub_write+1
	BCC galian_draw_player_burner_check
	INC sub_write+2
galian_draw_player_burner_check
	TXA
	AND #%00011111
	BNE galian_draw_player_burner_loop
	PLA
	PLX
	RTS

galian_draw_bullet ; A and X already set
	PHX
	PHA
	STA galian_filter
	LDA #<galian_bullet_data
	STA sub_index+1
	LDA #>galian_bullet_data
	STA sub_index+2
	LDA galian_bullet_y,X
	AND #%00000001
	CLC
	ROR A
	ROR A
	CLC
	ADC galian_bullet_x,X
	STA sub_write+1
	LDA galian_bullet_y,X
	CLC
	ROR A
	STA sub_write+2
	LDX #$00
	LDY #$00
galian_draw_bullet_loop
	JSR sub_index
	AND galian_filter
	JSR sub_write	
	INC sub_write+1
	INX
	INY
	CPY #$02
	BNE galian_draw_bullet_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7E
	STA sub_write+1
	BCC galian_draw_bullet_check
	INC sub_write+2
galian_draw_bullet_check
	CPX #$08
	BNE galian_draw_bullet_loop
	PLA
	PLX
	RTS

galian_draw_star ; A and X already set
	PHA
	STA galian_filter
	LDA galian_star_y,X
	AND #%00000001
	CLC
	ROR A
	ROR A
	CLC
	ADC galian_star_x,X
	STA sub_write+1
	LDA galian_star_y,X
	CLC
	ROR A
	STA sub_write+2
	LDA galian_filter
	JSR sub_write
	PLA
	RTS

galian_draw_enemy ; A and X already set
	PHX
	PHA
	STA galian_filter
	LDA galian_enemy_t,X
	BEQ galian_draw_enemy_type1
	CMP #$01
	BEQ galian_draw_enemy_type2
	CMP #$02
	BEQ galian_draw_enemy_type3
	CMP #$03
	BEQ galian_draw_enemy_type4
galian_draw_enemy_type1
	LDA #<galian_enemy_data1
	STA sub_index+1
	LDA #>galian_enemy_data1
	STA sub_index+2
	JMP galian_draw_enemy_ready
galian_draw_enemy_type2
	LDA #<galian_enemy_data2
	STA sub_index+1
	LDA #>galian_enemy_data2
	STA sub_index+2
	JMP galian_draw_enemy_ready
galian_draw_enemy_type3
	LDA #<galian_enemy_data3
	STA sub_index+1
	LDA #>galian_enemy_data3
	STA sub_index+2
	JMP galian_draw_enemy_ready
galian_draw_enemy_type4
	LDA #<galian_enemy_data4
	STA sub_index+1
	LDA #>galian_enemy_data4
	STA sub_index+2
	JMP galian_draw_enemy_ready
	
galian_draw_enemy_ready
	LDA galian_enemy_y,X
	AND #%00000001
	CLC
	ROR A
	ROR A
	CLC
	ADC galian_enemy_x,X
	SEC
	SBC #$02
	STA sub_write+1
	LDA galian_enemy_y,X
	CLC
	ROR A
	STA sub_write+2
	LDX #$00
	LDY #$00
galian_draw_enemy_loop
	JSR sub_index
	AND galian_filter
	JSR sub_write	
	INC sub_write+1
	INX
	INY
	CPY #$04
	BNE galian_draw_enemy_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7C
	STA sub_write+1
	BCC galian_draw_enemy_check
	INC sub_write+2
galian_draw_enemy_check
	CPX #$20
	BNE galian_draw_enemy_loop
	PLA
	PLX
	RTS

galian_draw_particle ; A and X already set
	PHX
	PHA
	STA galian_filter
	LDA #<galian_particle_data
	STA sub_index+1
	LDA #>galian_particle_data
	STA sub_index+2
	LDA galian_particle_y,X
	AND #%00000001
	CLC
	ROR A
	ROR A
	CLC
	ADC galian_particle_x,X
	STA sub_write+1
	LDA galian_particle_y,X
	CLC
	ROR A
	STA sub_write+2
	LDX #$00
	LDY #$00
galian_draw_particle_loop
	JSR sub_index
	AND galian_filter
	JSR sub_write	
	INC sub_write+1
	INX
	INY
	CPY #$02
	BNE galian_draw_particle_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7E
	STA sub_write+1
	BCC galian_draw_particle_check
	INC sub_write+2
galian_draw_particle_check
	CPX #$08
	BNE galian_draw_particle_loop
	PLA
	PLX
	RTS




galian_player_data
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$0E,$E0,$00,$00,$00
	.BYTE $00,$00,$00,$EF,$FE,$00,$00,$00
	.BYTE $00,$00,$00,$EF,$FE,$00,$00,$00
	.BYTE $00,$00,$0E,$FF,$FF,$E0,$00,$00
	.BYTE $00,$0E,$FF,$FF,$FF,$FF,$E0,$00
	.BYTE $00,$EF,$FF,$FF,$FF,$FF,$FE,$00
	.BYTE $00,$0E,$FF,$FF,$FF,$FF,$E0,$00

galian_burner_data
	.BYTE $00,$08,$99,$99,$99,$99,$80,$00
	.BYTE $00,$00,$89,$99,$99,$98,$00,$00
	.BYTE $00,$00,$08,$88,$88,$80,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00

	.BYTE $00,$00,$08,$99,$99,$80,$00,$00
	.BYTE $00,$00,$08,$88,$88,$80,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00

galian_bullet_data
	.BYTE $0E,$E0
	.BYTE $0F,$F0
	.BYTE $EF,$FE
	.BYTE $89,$98

galian_particle_data
	.BYTE $1C,$C1
	.BYTE $CD,$DC
	.BYTE $CD,$DC
	.BYTE $1C,$C1

galian_enemy_data1
	.BYTE $05,$00,$00,$50
	.BYTE $45,$55,$55,$54
	.BYTE $45,$15,$51,$54
	.BYTE $45,$15,$51,$54
	.BYTE $45,$55,$55,$54
	.BYTE $00,$44,$44,$00
	.BYTE $E0,$10,$01,$0E
	.BYTE $EE,$EE,$EE,$EE

galian_enemy_data2
	.BYTE $EE,$99,$99,$EE
	.BYTE $08,$99,$99,$90
	.BYTE $EE,$99,$99,$EE
	.BYTE $08,$19,$91,$80
	.BYTE $EE,$19,$91,$EE
	.BYTE $08,$99,$99,$80
	.BYTE $EE,$99,$99,$EE
	.BYTE $08,$99,$99,$80

galian_enemy_data3
	.BYTE $03,$77,$77,$30
	.BYTE $37,$17,$71,$73
	.BYTE $37,$17,$71,$73
	.BYTE $37,$77,$77,$73
	.BYTE $33,$77,$77,$33
	.BYTE $03,$37,$73,$30
	.BYTE $00,$E3,$3E,$00
	.BYTE $00,$0E,$E0,$00


galian_enemy_data4
	.BYTE $0C,$CC,$CC,$C0
	.BYTE $CD,$DD,$DD,$DC
	.BYTE $CD,$1D,$D1,$DC
	.BYTE $CD,$1D,$D1,$DC
	.BYTE $CD,$DD,$DD,$DC
	.BYTE $0D,$DD,$DD,$D0
	.BYTE $00,$EE,$EE,$00
	.BYTE $00,$EE,$EE,$00

galian_draw_pause
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
galian_draw_pause_loop
	LDA galian_pause_text,Y
	JSR colorchar
	INC printchar_x
	INY
	CPY #$06
	BNE galian_draw_pause_loop
	RTS

galian_clear_pause
	LDA #$0D
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
galian_clear_pause_loop
	LDA #" "
	JSR colorchar
	INC printchar_x
	INY
	CPY #$06
	BNE galian_clear_pause_loop
	RTS

galian_draw_gameover
	LDA #$0C
	STA printchar_x
	LDA #$10
	STA printchar_y	
	LDY #$00
galian_draw_gameover_loop
	LDA galian_gameover_text,Y
	JSR colorchar
	INC printchar_x
	INY
	CPY #$09
	BNE galian_draw_gameover_loop
	RTS

galian_pause_text
	.BYTE "Paused"
galian_gameover_text
	.BYTE "Game "
	.BYTE "Over"

galian_draw_menu
	LDA #$03
	STA printchar_x
	LDA #$00
	STA printchar_y
	LDA galian_score_low ; needs colornum to not display hundreds digit if zero!!!
	JSR colornum
	LDA #$01
	STA printchar_x
	LDA #$00
	STA printchar_y
	LDA galian_score_high
	JSR colornum
	LDA #$3C
	STA printchar_x
	LDA #$00
	STA printchar_y
	LDA galian_player_lives
	JSR colornum
	RTS	




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





; unused space here


; code below is only needed for simulator


setup
	JSR int_init
	JSR via_init
	JSR joy_init

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

;	LDA #$4C ; JMPa
;	STA sub_inputchar+0
;	LDA #<inputchar
;	STA sub_inputchar+1
;	LDA #>inputchar
;	STA sub_inputchar+2

;	LDA #$4C ; JMPa
;	STA sub_printchar+0
;	LDA #<printchar
;	STA sub_printchar+1
;	LDA #>printchar
;	STA sub_printchar+2

;	LDA #$4C ; JMPa
;	STA sub_sdcard_initialize+0
;	LDA #<sdcard_initialize
;	STA sub_sdcard_initialize+1
;	LDA #>sdcard_initialize
;	STA sub_sdcard_initialize+2

;	LDA #$4C ; JMPa
;	STA sub_sdcard_readblock+0
;	LDA #<sdcard_readblock
;	STA sub_sdcard_readblock+1
;	LDA #>sdcard_readblock
;	STA sub_sdcard_readblock+2

;	LDA #$4C ; JMPa
;	STA sub_sdcard_writeblock+0
;	LDA #<sdcard_writeblock
;	STA sub_sdcard_writeblock+1
;	LDA #>sdcard_writeblock
;	STA sub_sdcard_writeblock+2

	STZ sub_random_var

; uses A = A * 3 + 17 + T2rand
	LDX #$00
setup_random_loop
	LDA setup_random_code,X
	STA sub_random,X
	INX
	CPX #$13
	BNE setup_random_loop

;	JSR basic_clear

	RTS

; LDA sub_random_var
; ROL A
; CLC
; ADC sub_random_var ; multiply by 3
; CLC
; ADC #$11 ; add 17
; ADC via_t2cl ; add random value
; STA sub_random_var
; RTS
setup_random_code
	.BYTE $AD
	.WORD sub_random_var
	.BYTE $2A,$18,$6D
	.WORD sub_random_var
	.BYTE $18,$69,$11,$6D
	.WORD via_t2cl
	.BYTE $8D
	.WORD sub_random_var
	.BYTE $60



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
	STZ via_pb ; set output pins to low
	STZ via_da ; PA is all input
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

	LDA #%11010000 ; free run on T1 for audio
	STA via_acr
	
	STZ via_t1cl ; zero out T1 counter to silence
	STZ via_t1ch

	LDA #$FF
	STA via_t2cl ; T2 timer for random numbers
	STA via_t2ch 
	
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

	
; code above is only needed for simulator


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









	
	
