; Acolyte 3 Computer Code

; First, run
; ~/dev65/bin/as65 Acolyte3Code.asm

; Second, run
; ./Parser.o Acolyte3Code.lst Acolyte3Code.bin 49152 0 16384 0

; Third, run
; ~/dev65/bin/as65 Acolyte3Code-Bank2.asm

; Fourth, run
; ./Parser.o Acolyte3Code-Bank2.lst Acolyte3Code-Bank2.bin 49152 0 16384 0

; Fifth, run
; ./Combiner.o Acolyte3Code.bin Acolyte3Code-Bank2.bin Acolyte3Code-Combined.bin

; Third, run
; minipro -p "SST39SF010" -w Acolyte3Code.bin

; OR
; ./AcolyteSimulator.o Acolyte3Code.bin

; Altogether
; ~/dev65/bin/as65 Acolyte3Code.asm ; ./Parser.o Acolyte3Code.lst Acolyte3Code.bin 49152 0 16384 0 ; ~/dev65/bin/as65 Acolyte3Code-Bank2.asm ; ./Parser.o Acolyte3Code-Bank2.lst Acolyte3Code-Bank2.bin 49152 0 16384 0 ; ./Combiner.o Acolyte3Code.bin Acolyte3Code-Bank2.bin Acolyte3Code-Combined.bin



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
rogue_exp_low		.EQU $0317
rogue_exp_high		.EQU $0318
rogue_exp_level		.EQU $0319
rogue_dist_x		.EQU $031A
rogue_dist_y		.EQU $031B
rogue_text		.EQU $031C ; 2 bytes long
rogue_filter		.EQU $031E
rogue_enemy_x		.EQU $0400 ; 16 bytes long
rogue_enemy_y		.EQU $0410 ; 16 bytes long
rogue_enemy_h		.EQU $0420 ; 16 bytes long
rogue_enemy_t		.EQU $0430 ; 16 bytes long
rogue_enemy_d		.EQU $0440 ; 16 bytes long
rogue_enemy_e		.EQU $0450 ; 16 bytes long
rogue_floor		.EQU $8000 ; 2K
rogue_floor_end		.EQU $8700 ; last 4 lines
rogue_items		.EQU $8800 ; 2K
rogue_digged		.EQU $9000 ; 2K
rogue_digged_end	.EQU $9800 ; end





	
	.ORG $C000 ; start of code

vector_reset

	

	JSR setup

	JSR function_keys_scratchpad
	



rogue
	LDA #$91 ; produces red and dark grey
	STA $FFFF ; write non-$00 to ROM for 64-column 4-color mode

	JMP rogue_init

; change these a bit!
rogue_level_low
	.BYTE $05,$14,$32,$64,$FF
rogue_level_high
	.BYTE $00,$00,$00,$00,$FF

rogue_init
	; setup stats here
	LDA #$02 ; should start with $02
	STA rogue_lamp
	LDA #$01
	STA rogue_pickaxe
	LDA #$02
	STA rogue_potions
	LDA #$02
	STA rogue_bombs
	LDA #$01
	STA rogue_attack
	LDA #$01
	STA rogue_defense
	LDA #$0A ; should start with $0A
	STA rogue_health
	STA rogue_health_max
	LDA #$32
	STA rogue_food_low
	STA rogue_food_high
	LDA #$01 ; should start with $01
	STA rogue_level	
	STZ rogue_gold
	STZ rogue_exp_low
	STZ rogue_exp_high
	STZ rogue_exp_level

rogue_reset
	LDA #$0C ; form feed
	JSR printchar
	JSR rogue_clear
	JSR rogue_walk
	JSR rogue_location
	JSR rogue_populate
	JSR rogue_blast
	JSR rogue_controls


rogue_clear
	PHA
	LDA #<rogue_floor
	STA sub_write+1
	LDA #>rogue_floor
	STA sub_write+2
rogue_clear_loop_floor
	LDA #"#" ; wall value
	JSR sub_write
	INC sub_write+1
	BNE rogue_clear_loop_floor
	INC sub_write+2
	LDA sub_write+2
	CMP #>rogue_items
	BNE rogue_clear_loop_floor
rogue_clear_loop_items
	CLC
	JSR sub_random
	AND #%00111111
	BEQ rogue_clear_loop_items_value
	LDA #$00
	JMP rogue_clear_loop_items_store
rogue_clear_loop_items_value
	CLC
	JSR sub_random
	AND #%00000111 ; change amount here
	BEQ rogue_clear_loop_items_zero
	CMP #$01
	BEQ rogue_clear_loop_items_one
	CMP #$02
	BEQ rogue_clear_loop_items_two
	CMP #$03
	BEQ rogue_clear_loop_items_three
	CMP #$04
	BEQ rogue_clear_loop_items_four
	CMP #$05
	BEQ rogue_clear_loop_items_five
	CMP #$06
	BEQ rogue_clear_loop_items_six
	CMP #$07
	BEQ rogue_clear_loop_items_seven
; put more here
	LDA #$00 ; nothing
	JMP rogue_clear_loop_items_store 
rogue_clear_loop_items_zero
	LDA #"!" ; potion
	JMP rogue_clear_loop_items_store
rogue_clear_loop_items_one
	LDA #"*" ; bomb
	JMP rogue_clear_loop_items_store
rogue_clear_loop_items_two
	LDA #"(" ; attack up
	JMP rogue_clear_loop_items_store
rogue_clear_loop_items_three
	LDA #"[" ; defense up
	JMP rogue_clear_loop_items_store
rogue_clear_loop_items_four
	LDA #"%" ; food
	JMP rogue_clear_loop_items_store
rogue_clear_loop_items_five
	LDA #"i" ; lamp
	JMP rogue_clear_loop_items_store
rogue_clear_loop_items_six
	LDA #"p" ; pickaxe
	JMP rogue_clear_loop_items_store
rogue_clear_loop_items_seven
	LDA #"$" ; gold
	JMP rogue_clear_loop_items_store
; put more here
rogue_clear_loop_items_store
	JSR sub_write
	CMP #$00
	BEQ rogue_clear_loop_items_skip
	LDA sub_write+1
	STA sub_read+1
	LDA sub_write+2
	PHA
	SEC
	SBC #$08 ; now in 'floor' memory
	STA sub_write+2
	STA sub_read+2
	JSR sub_read
	CMP #"#" ; wall
	BNE rogue_clear_loop_items_floor
	LDA #$3A ; colon
	JSR sub_write
rogue_clear_loop_items_floor
	PLA
	STA sub_write+2
rogue_clear_loop_items_skip
	INC sub_write+1
	BNE rogue_clear_loop_items_jump
	INC sub_write+2
	LDA sub_write+2
	CMP #>rogue_digged
	BNE rogue_clear_loop_items_jump
	JMP rogue_clear_loop_digged
rogue_clear_loop_items_jump
	JMP rogue_clear_loop_items
rogue_clear_loop_digged
	LDA #$10 ; arbitrary hardness of stone
	JSR sub_write
	INC sub_write+1
	BNE rogue_clear_loop_digged
	INC sub_write+2
	LDA sub_write+2
	CMP #>rogue_digged_end
	BNE rogue_clear_loop_digged
	PLA
	RTS


rogue_walk
	PHA
	STZ rogue_walk_low
	STZ rogue_walk_high
	CLC
	JSR sub_random
	AND #%00111111
	STA rogue_player_x
	STA rogue_stairs_x
rogue_walk_random
	CLC
	JSR sub_random
	AND #%00011111
	CLC
	CMP #$1C
	BCS rogue_walk_random
	STA rogue_player_y
	STA rogue_stairs_y
	JMP rogue_walk_loop
rogue_walk_direction
	CLC
	JSR sub_random
	AND #%00000011
	BEQ rogue_walk_move_up
	CMP #$01
	BEQ rogue_walk_move_down
	CMP #$02
	BEQ rogue_walk_move_left	
	BNE rogue_walk_move_right
rogue_walk_move_up
	LDA rogue_stairs_y
	BEQ rogue_walk_direction
	DEC rogue_stairs_y
	JMP rogue_walk_loop
rogue_walk_move_down
	LDA rogue_stairs_y
	CMP #$1B
	BEQ rogue_walk_direction
	INC rogue_stairs_y
	JMP rogue_walk_loop
rogue_walk_move_left
	LDA rogue_stairs_x
	CMP #$00
	BEQ rogue_walk_direction
	DEC rogue_stairs_x
	JMP rogue_walk_loop
rogue_walk_move_right
	LDA rogue_stairs_x
	CMP #$3F
	BEQ rogue_walk_direction
	INC rogue_stairs_x
rogue_walk_loop
	LDA rogue_stairs_y
	AND #%00000011
	CLC
	ROR A
	ROR A
	ROR A
	CLC
	ADC rogue_stairs_x
	STA sub_read+1
	STA sub_write+1
	LDA rogue_stairs_y
	AND #%00011100
	CLC
	ROR A
	ROR A
	CLC
	ADC #>rogue_floor
	STA sub_read+2
	STA sub_write+2
	JSR sub_read
	PHA
	LDA #$3A ; colon
	JSR sub_write
	PLA
	CMP #$3A ; colon
	BEQ rogue_walk_increment
	INC rogue_walk_low
	BNE rogue_walk_increment
	INC rogue_walk_high
	LDA rogue_walk_high
	CLC
	CMP #$02
	BCS rogue_walk_exit
rogue_walk_increment
	JMP rogue_walk_direction
rogue_walk_exit
	LDA #$3C
	JSR sub_write
	PLA
	RTS



rogue_location
	PHA
	PHX
	PHY
	LDA #<rogue_location_data
	STA sub_index+1
	LDA #>rogue_location_data
	STA sub_index+2
	CLC
	JSR sub_random
	AND #%01000000 ; change to #%11000000 for 4 chunks of data
	CLC
	ADC sub_index+1
	STA sub_index+1
	BCC rogue_location_random
	INC sub_index+2
rogue_location_random
	CLC
	JSR sub_random
	AND #%00111111
	CLC
	CMP #$38
	BCS rogue_location_random
	STA rogue_location_x
	STA rogue_check_x
	CLC
	JSR sub_random
	AND #%00011111
	STA rogue_location_y
	STA rogue_check_y
	CLC
	CMP #$14
	BCS rogue_location_random
	LDX #$00
	LDY #$00
rogue_location_player
	LDA rogue_check_x
	CMP rogue_player_x
	BNE rogue_location_stairs
	LDA rogue_check_y
	CMP rogue_player_y
	BNE rogue_location_stairs
	JMP rogue_location_random
rogue_location_stairs
	LDA rogue_check_x
	CMP rogue_stairs_x
	BNE rogue_location_increment
	LDA rogue_check_y
	CMP rogue_stairs_y
	BNE rogue_location_increment
	JMP rogue_location_random
rogue_location_increment
	INC rogue_check_x
	INX
	INY
	CPX #$40
	BEQ rogue_location_ready
	CPY #$08
	BNE rogue_location_player
	LDY #$00
	LDA rogue_check_x
	SEC
	SBC #$08
	STA rogue_check_x
	INC rogue_check_y
	JMP rogue_location_player
rogue_location_ready
	LDA rogue_location_x
	STA rogue_check_x
	LDA rogue_location_y
	STA rogue_check_y
	LDX #$00
	LDY #$00
rogue_location_loop
	LDA rogue_check_y
	AND #%00000011
	CLC
	ROR A
	ROR A
	ROR A
	CLC
	ADC rogue_check_x
	STA sub_write+1
	STA sub_read+1
	LDA rogue_check_y
	AND #%00011100
	CLC
	ROR A
	ROR A
	CLC
	ADC #>rogue_floor
	STA sub_write+2
	CLC
	ADC #$08 ; now in 'items' memory
	STA sub_read+2
	JSR sub_read
	BEQ rogue_location_write
	LDA sub_write+2
	PHA
	CLC
	ADC #$08 ; now in 'items' memory
	STA sub_write+2
	LDA #$00
	JSR sub_write
	PLA
	STA sub_write+2
rogue_location_write
	JSR sub_index
	JSR sub_write
	INC rogue_check_x
	INX
	INY
	CPX #$40
	BEQ rogue_location_exit
	CPY #$08
	BNE rogue_location_loop
	LDY #$00
	LDA rogue_check_x
	SEC
	SBC #$08
	STA rogue_check_x
	INC rogue_check_y
	JMP rogue_location_loop
rogue_location_exit
	LDA rogue_player_x ; just in case
	STA rogue_check_x
	LDA rogue_player_y
	STA rogue_check_y
	PLY
	PLX
	PLA
	RTS

rogue_location_data
	.BYTE "--------"
	.BYTE $7C,"......",$7C
	.BYTE $7C,"......",$7C
	.BYTE "---++---"
	.BYTE $7C,"......",$7C
	.BYTE $7C,"......",$7C
	.BYTE "+......+"
	.BYTE "--------"

	.BYTE "^^....^^"
	.BYTE "^......^"
	.BYTE "........"
	.BYTE "...^^..."
	.BYTE "...^^..."
	.BYTE "........"
	.BYTE "^......^"
	.BYTE "^^....^^"

;	.BYTE "---++---"
;	.BYTE $7C,"......",$7C
;	.BYTE $7C,"......",$7C
;	.BYTE $7C,"......",$7C
;	.BYTE $7C,"......",$7C
;	.BYTE $7C,"......",$7C
;	.BYTE $7C,"......",$7C
;	.BYTE "---++---"

;	.BYTE $3A,$3A,$3A,"..",$3A,$3A,$3A
;	.BYTE $3A,$3A,"0..0",$3A,$3A
;	.BYTE $3A,"0....0",$3A
;	.BYTE "........"
;	.BYTE "........"
;	.BYTE $3A,"0....0",$3A
;	.BYTE $3A,$3A,"0..0",$3A,$3A
;	.BYTE $3A,$3A,$3A,"..",$3A,$3A,$3A


rogue_populate
	PHA
	PHX
	LDX #$00
rogue_populate_loop
	CLC
	JSR sub_random
	AND #%00111111
	STA rogue_enemy_x,X
	CLC
	JSR sub_random
	AND #%00011111
	STA rogue_enemy_y,X
	CLC
	CMP #$1C
	BCS rogue_populate_loop
	LDA rogue_enemy_y,X
	AND #%00000011
	CLC
	ROR A
	ROR A
	ROR A
	CLC
	ADC rogue_enemy_x,X
	STA sub_read+1
	LDA rogue_enemy_y,X
	AND #%00011100
	CLC
	ROR A
	ROR A
	CLC
	ADC #>rogue_floor
	STA sub_read+2
	JSR sub_read
	CMP #$3A ; colon
	BEQ rogue_populate_finalize
	CMP #"."
	BEQ rogue_populate_finalize
	JMP rogue_populate_loop
rogue_populate_finalize
	CLC
	JSR sub_random
	AND #%00110000 ; change for more here
	CLC
	ROR A
	ROR A
	ROR A
	ROR A
	CLC
	CMP rogue_level
	BCS rogue_populate_finalize
	CMP #$01
	BEQ rogue_populate_bat
	CMP #$02
	BEQ rogue_populate_goblin
	CMP #$03
	BEQ rogue_populate_hob
; put more here
	LDA #"F" ; fungus
	STA rogue_enemy_t,X
	LDA #$02
	STA rogue_enemy_h,X
	LDA #$00
	STA rogue_enemy_d,X
	LDA #$01
	STA rogue_enemy_e,X
	JMP rogue_populate_increment
rogue_populate_bat
	LDA #"B" ; bat
	STA rogue_enemy_t,X
	LDA #$03
	STA rogue_enemy_h,X
	LDA #$02
	STA rogue_enemy_d,X
	LDA #$03
	STA rogue_enemy_e,X
	JMP rogue_populate_increment
rogue_populate_goblin
	LDA #"G" ; goblin
	STA rogue_enemy_t,X
	LDA #$05
	STA rogue_enemy_h,X
	LDA #$05
	STA rogue_enemy_d,X
	LDA #$07
	STA rogue_enemy_e,X
	JMP rogue_populate_increment
rogue_populate_hob
	LDA #"H" ; hob
	STA rogue_enemy_t,X
	LDA #$08
	STA rogue_enemy_h,X
	LDA #$08
	STA rogue_enemy_d,X
	LDA #$0C
	STA rogue_enemy_e,X
	JMP rogue_populate_increment
; put more here
rogue_populate_increment
	INX
	CPX #$10
	BEQ rogue_populate_exit
	JMP rogue_populate_loop
rogue_populate_exit
	PLX
	PLA
	RTS



rogue_controls
	JSR rogue_menu
	JMP rogue_controls_move
rogue_controls_start
	CLC
	JSR sub_random ; for more randomization
	JSR inputchar
	CMP #$00
	BEQ rogue_controls_start
	PHA
	LDA rogue_player_y
	AND #%00000011
	CLC
	ROR A
	ROR A
	ROR A
	CLC
	ADC rogue_player_x
	STA sub_read+1
	LDA rogue_player_y
	AND #%00011100
	CLC
	ROR A
	ROR A
	CLC
	ADC #>rogue_floor
	STA sub_read+2
	LDA rogue_player_x
	STA rogue_check_x
	STA printchar_x
	LDA rogue_player_y
	STA rogue_check_y
	STA printchar_y
	LDA rogue_food_low
	SEC
	SBC #$04 ; arbitrary hunger amount
	STA rogue_food_low
	BCS rogue_controls_food
	DEC rogue_food_high
	BNE rogue_controls_food
	JMP rogue_gameover
rogue_controls_food
	PLA
	CMP #$11 ; arrow up
	BEQ rogue_controls_up
	CMP #"W"
	BEQ rogue_controls_up
	CMP #"w"
	BEQ rogue_controls_up
	CMP #$12 ; arrow down
	BEQ rogue_controls_down
	CMP #"S"
	BEQ rogue_controls_down
	CMP #"s"
	BEQ rogue_controls_down	
	CMP #$13 ; arrow left
	BEQ rogue_controls_left
	CMP #"A"
	BEQ rogue_controls_left
	CMP #"a"
	BEQ rogue_controls_left
	CMP #$14 ; arrow right
	BEQ rogue_controls_right
	CMP #"D"
	BEQ rogue_controls_right
	CMP #"d"
	BEQ rogue_controls_right
	CMP #$20 ; space
	BEQ rogue_controls_bomb
	CMP #"Q"
	BEQ rogue_controls_bomb
	CMP #"q"
	BEQ rogue_controls_bomb
	CMP #"0" ; zero
	BEQ rogue_controls_potion
	CMP #"E"
	BEQ rogue_controls_potion
	CMP #"e"
	BEQ rogue_controls_potion
	CMP #$1B ; escape
	BEQ rogue_controls_escape
	CMP #$15 ; F12
	BEQ rogue_controls_move
; put more here
	JMP rogue_controls_move
rogue_controls_up
	LDA rogue_player_y
	BEQ rogue_controls_move
	DEC rogue_player_y
	JMP rogue_controls_move
rogue_controls_down
	LDA rogue_player_y
	CMP #$1B
	BEQ rogue_controls_move
	INC rogue_player_y
	JMP rogue_controls_move
rogue_controls_left
	LDA rogue_player_x
	BEQ rogue_controls_move
	DEC rogue_player_x
	JMP rogue_controls_move
rogue_controls_right
	LDA rogue_player_x
	CMP #$3F
	BEQ rogue_controls_move
	INC rogue_player_x
	JMP rogue_controls_move
rogue_controls_bomb
	LDA rogue_bombs
	BEQ rogue_controls_move
	DEC rogue_bombs
	JSR rogue_blast
	JMP rogue_controls_move
rogue_controls_potion
	LDA rogue_potions
	BEQ rogue_controls_move
	DEC rogue_potions
	LDA rogue_health_max
	CLC
	ROR A
	CLC
	ADC rogue_health
	STA rogue_health
	CLC
	CMP rogue_health_max
	BCC rogue_controls_move
	LDA rogue_health_max
	STA rogue_health
	JMP rogue_controls_move
rogue_controls_escape
	JMP rogue_gameover_exit ; exit
; put more here
rogue_controls_move
	LDA rogue_player_y
	AND #%00000011
	CLC
	ROR A
	ROR A
	ROR A
	CLC
	ADC rogue_player_x
	STA sub_read+1
	LDA rogue_player_y
	AND #%00011100
	CLC
	ROR A
	ROR A
	CLC
	ADC #>rogue_floor
	STA sub_read+2
	JSR sub_read
	CMP #$3C ; less than
	BEQ rogue_controls_descend
	CMP #$3A ; colon
	BEQ rogue_controls_redraw
	CMP #"."
	BEQ rogue_controls_redraw
	CMP #"+"
	BEQ rogue_controls_redraw
	CMP #"#"
	BEQ rogue_controls_dig
	JMP rogue_controls_bounds
rogue_controls_redraw
	JSR rogue_collide
	CMP #$00
	BEQ rogue_controls_unbounded
rogue_controls_bounds
	LDA rogue_check_x
	STA rogue_player_x
	LDA rogue_check_y
	STA rogue_player_y
rogue_controls_unbounded
	JSR rogue_pickup
	JSR rogue_ai
	JSR rogue_light
	LDA rogue_player_x
	STA printchar_x
	LDA rogue_player_y
	STA printchar_y
	LDA #"@"
	JSR printchar
	JSR rogue_menu
	JMP rogue_controls_start
rogue_controls_descend
	INC rogue_level
	JMP rogue_reset
rogue_controls_dig
	LDA rogue_player_y
	AND #%00000011
	CLC
	ROR A
	ROR A
	ROR A
	CLC
	ADC rogue_player_x
	STA sub_read+1
	STA sub_write+1
	LDA rogue_player_y
	AND #%00011100
	CLC
	ROR A
	ROR A
	CLC
	ADC #>rogue_digged
	STA sub_read+2
	STA sub_write+2
	JSR sub_read
	SEC
	SBC rogue_pickaxe
	JSR sub_write
	BEQ rogue_controls_hole
	CLC
	CMP #$80
	BCS rogue_controls_hole
	JMP rogue_controls_bounds
rogue_controls_hole
	LDA #$00
	JSR sub_write
	LDA rogue_player_y
	AND #%00000011
	CLC
	ROR A
	ROR A
	ROR A
	CLC
	ADC rogue_player_x
	STA sub_write+1
	LDA rogue_player_y
	AND #%00011100
	CLC
	ROR A
	ROR A
	CLC
	ADC #>rogue_floor
	STA sub_write+2
	LDA #$3A ; colon
	JSR sub_write
	LDA rogue_player_x
	STA printchar_x
	LDA rogue_player_y
	STA printchar_y
	LDA #$3A ; colon
	JSR printchar
	JMP rogue_controls_bounds



rogue_pickup
	PHA
	LDA rogue_player_y
	AND #%00000011
	CLC
	ROR A
	ROR A
	ROR A
	CLC
	ADC rogue_player_x
	STA sub_read+1
	LDA rogue_player_y
	AND #%00011100
	CLC
	ROR A
	ROR A
	CLC
	ADC #>rogue_items
	STA sub_read+2
	JSR sub_read
	CMP #"!" ; potion
	BEQ rogue_pickup_zero
	CMP #"*" ; bomb
	BEQ rogue_pickup_one
	CMP #"(" ; attack up
	BEQ rogue_pickup_two
	CMP #"[" ; defense up
	BEQ rogue_pickup_three
	CMP #"%" ; food
	BEQ rogue_pickup_four
	CMP #"i" ; lamp
	BEQ rogue_pickup_five
	CMP #"p" ; pickaxe
	BEQ rogue_pickup_six
	CMP #"$" ; gold
	BEQ rogue_pickup_seven
; put more here
	JMP rogue_pickup_clear
rogue_pickup_zero
	INC rogue_potions
	JMP rogue_pickup_zero_check
rogue_pickup_one
	INC rogue_bombs
	JMP rogue_pickup_one_check
rogue_pickup_two
	INC rogue_attack
	JMP rogue_pickup_two_check
rogue_pickup_three
	INC rogue_defense
	JMP rogue_pickup_three_check
rogue_pickup_four
	LDA rogue_food_high
	CLC
	ADC #$0A
	STA rogue_food_high
	JMP rogue_pickup_clear
rogue_pickup_five
	INC rogue_lamp
	JMP rogue_pickup_five_check
rogue_pickup_six
	INC rogue_pickaxe
	JMP rogue_pickup_six_check
rogue_pickup_seven
	INC rogue_gold
	JMP rogue_pickup_clear
; put more here
rogue_pickup_zero_check
	LDA rogue_potions
	CLC
	CMP #$09 ; max potions
	BCC rogue_pickup_zero_skip
	LDA #$09
	STA rogue_potions
	INC rogue_gold
rogue_pickup_zero_skip
	JMP rogue_pickup_clear
rogue_pickup_one_check
	LDA rogue_bombs
	CLC
	CMP #$09 ; max bombs
	BCC rogue_pickup_one_skip
	LDA #$09
	STA rogue_bombs
	INC rogue_gold
rogue_pickup_one_skip
	JMP rogue_pickup_clear
rogue_pickup_two_check
	LDA rogue_attack
	CLC
	CMP #$09 ; max attack power
	BCC rogue_pickup_two_skip
	LDA #$09
	STA rogue_attack
	INC rogue_gold
rogue_pickup_two_skip
	JMP rogue_pickup_clear
rogue_pickup_three_check
	LDA rogue_defense
	CLC
	CMP #$09 ; max defense power
	BCC rogue_pickup_three_skip
	LDA #$09
	STA rogue_defense
	INC rogue_gold
rogue_pickup_three_skip
	JMP rogue_pickup_clear
rogue_pickup_five_check
	LDA rogue_lamp
	CLC
	CMP #$06 ; max lamp power
	BCC rogue_pickup_five_skip
	LDA #$06
	STA rogue_lamp
	INC rogue_gold
rogue_pickup_five_skip
	JMP rogue_pickup_clear
rogue_pickup_six_check
	LDA rogue_pickaxe
	CLC
	CMP #$10 ; max pickaxe power
	BCC rogue_pickup_six_skip
	LDA #$10
	STA rogue_pickaxe
	INC rogue_gold
rogue_pickup_six_skip
	JMP rogue_pickup_clear
rogue_pickup_clear
	LDA sub_read+1
	STA sub_write+1
	LDA sub_read+2
	STA sub_write+2
	LDA #$00
	JSR sub_write
	JSR rogue_menu
	PLA
	RTS


rogue_collide ; returns A = $00 no collision
	PHX
	PHY
	LDX #$00
	LDY #$00
rogue_collide_loop 
	LDA rogue_enemy_h,X
	BEQ rogue_collide_increment
	LDA rogue_player_x
	CMP rogue_enemy_x,X
	BNE rogue_collide_increment 
	LDA rogue_player_y
	CMP rogue_enemy_y,X
	BNE rogue_collide_increment
	INY
	LDA rogue_enemy_h,X
	SEC
	SBC rogue_attack
	STA rogue_enemy_h,X
	BCS rogue_collide_check
	STZ rogue_enemy_h,X
rogue_collide_check
	LDA rogue_enemy_h,X
	BNE rogue_collide_increment
	JSR rogue_collide_drop
	LDA rogue_exp_low
	CLC	
	ADC rogue_enemy_e,X
	STA rogue_exp_low
	BCC rogue_collide_levelup
	INC rogue_exp_high
rogue_collide_levelup
	PHX
	LDX rogue_exp_level
	LDA rogue_exp_high
	CLC
	CMP rogue_level_high,X
	BCC rogue_collide_levelup_none
	LDA rogue_exp_low
	CLC
	CMP rogue_level_low,X
	BCC rogue_collide_levelup_none
	INC rogue_exp_level
	LDA rogue_health_max
	CLC
	ADC #$0A
	STA rogue_health_max
	STA rogue_health ; full heal on level up
rogue_collide_levelup_none
	PLX
rogue_collide_increment
	INX
	CPX #$10
	BNE rogue_collide_loop
	TYA
	PLY
	PLX
	RTS
rogue_collide_drop
	LDA rogue_enemy_y,X
	AND #%00000011
	CLC
	ROR A
	ROR A
	ROR A
	CLC
	ADC rogue_enemy_x,X
	STA sub_write+1
	LDA rogue_enemy_y,X
	AND #%00011100
	CLC
	ROR A
	ROR A
	CLC
	ADC #>rogue_items
	STA sub_write+2
	CLC
	JSR sub_random
	AND #%11110000
	CLC
	ROR A
	ROR A
	ROR A
	ROR A
	BEQ rogue_collide_drop_zero
	CMP #$01
	BEQ rogue_collide_drop_one
	CMP #$02
	BEQ rogue_collide_drop_two
	CMP #$03
	BEQ rogue_collide_drop_three
rogue_collide_drop_none
	LDA #$00 ; nothing
	JMP rogue_collide_drop_exit
rogue_collide_drop_zero
	LDA #"!" ; potion
	JMP rogue_collide_drop_exit
rogue_collide_drop_one
	LDA #"*" ; bomb
	JMP rogue_collide_drop_exit
rogue_collide_drop_two
	LDA #"%" ; food
	JMP rogue_collide_drop_exit
rogue_collide_drop_three
	LDA #"$" ; gold
rogue_collide_drop_exit
	JSR sub_write
	RTS
	



rogue_ai
	PHA
	PHX
	PHY
	LDX #$00
rogue_ai_loop
	LDA rogue_enemy_h,X
	BEQ rogue_ai_increment
	LDA rogue_enemy_t,X
	CMP #"B" ; bat
	BEQ rogue_ai_random
	CMP #"G" ; goblin
	BEQ rogue_ai_follow
	CMP #"H" ; hob
	BEQ rogue_ai_follow
; put more here
rogue_ai_increment
	INX
	CPX #$10
	BNE rogue_ai_loop
	PLY
	PLX
	PLA
	RTS

rogue_ai_random
	STZ rogue_dist_x
	STZ rogue_dist_y
	CLC
	JSR sub_random
	CLC
	CMP #$80
	BCC rogue_ai_random_vert
rogue_ai_random_horz
	CLC
	JSR sub_random
	CLC
	CMP #$20 ; arbitrary movement prob
	BCS rogue_ai_random_width
	CLC
	JSR sub_random
	CLC
	CMP #$80
	BCC rogue_ai_random_left
	LDA rogue_enemy_x,X
	CMP #$3F
	BCS rogue_ai_random_right
	LDA #$01
	JMP rogue_ai_random_right
rogue_ai_random_left
	LDA rogue_enemy_x,X
	BEQ rogue_ai_random_right
	LDA #$FF
rogue_ai_random_right
	STA rogue_dist_x
rogue_ai_random_width
	JMP rogue_ai_collide
rogue_ai_random_vert
	CLC
	JSR sub_random
	CLC
	CMP #$20 ; arbitrary movement prob
	BCS rogue_ai_random_length
	CLC
	JSR sub_random
	CLC
	CMP #$80
	BCC rogue_ai_random_up
	LDA rogue_enemy_y,X
	CMP #$1B
	BCS rogue_ai_random_down
	LDA #$01
	JMP rogue_ai_random_down
rogue_ai_random_up
	LDA rogue_enemy_y,X
	BEQ rogue_ai_random_down
	LDA #$FF
rogue_ai_random_down
	STA rogue_dist_y
rogue_ai_random_length
	JMP rogue_ai_collide

rogue_ai_follow
	STZ rogue_dist_x
	STZ rogue_dist_y
	CLC
	JSR sub_random
	CLC
	CMP #$20 ; arbitrary move prob
	BCS rogue_ai_follow_calculate
	JMP rogue_ai_follow_move
rogue_ai_follow_calculate
	LDA rogue_enemy_x,X
	SEC
	SBC rogue_player_x
	BCS rogue_ai_follow_dist_x
	EOR #$FF
	INC A
rogue_ai_follow_dist_x
	STA rogue_distance
	LDA rogue_enemy_y,X
	SEC
	SBC rogue_player_y
	BCS rogue_ai_follow_dist_y
	EOR #$FF
	INC A
rogue_ai_follow_dist_y
	CLC
	ADC rogue_distance
	CLC
	CMP #$10 ; arbitrary follow dist
	BCC rogue_ai_follow_continue
	JMP rogue_ai_follow_move
rogue_ai_follow_continue
	CLC
	JSR sub_random
	CLC
	CMP #$80
	BCC rogue_ai_follow_vert
	LDA rogue_enemy_x,X
	SEC
	SBC rogue_player_x
	BEQ rogue_ai_follow_equal_x
	BCC rogue_ai_follow_right
rogue_ai_follow_left
	LDA #$FF
	STA rogue_dist_x
	JMP rogue_ai_follow_move
rogue_ai_follow_right
	LDA #$01
	STA rogue_dist_x
	JMP rogue_ai_follow_move
rogue_ai_follow_vert
	LDA rogue_enemy_y,X
	SEC
	SBC rogue_player_y
	BEQ rogue_ai_follow_equal_y
	BCC rogue_ai_follow_down
rogue_ai_follow_up
	LDA #$FF
	STA rogue_dist_y
	JMP rogue_ai_follow_move
rogue_ai_follow_down
	LDA #$01
	STA rogue_dist_y
	JMP rogue_ai_follow_move
rogue_ai_follow_equal_y
	LDA rogue_enemy_x,X
	SEC
	SBC rogue_player_x
	CMP #$01
	BEQ rogue_ai_follow_left
	CMP #$FF
	BEQ rogue_ai_follow_right
	JMP rogue_ai_follow_move
rogue_ai_follow_equal_x
	LDA rogue_enemy_y,X
	SEC
	SBC rogue_player_y
	CMP #$01
	BEQ rogue_ai_follow_up
	CMP #$FF
	BEQ rogue_ai_follow_down
	JMP rogue_ai_follow_move
rogue_ai_follow_move
	JMP rogue_ai_collide

rogue_ai_collide
	LDA rogue_enemy_x,X
	CLC
	ADC rogue_dist_x
	CMP rogue_player_x
	BNE rogue_ai_friends
	LDA rogue_enemy_y,X
	CLC
	ADC rogue_dist_y
	CMP rogue_player_y
	BNE rogue_ai_friends
	CLC
	JSR sub_random
	AND #%00111100
	CLC
	ROR A
	ROR A
	CLC
	CMP rogue_defense
	BCS rogue_ai_damage
	JMP rogue_ai_increment
rogue_ai_damage	
	LDA rogue_enemy_d,X
	CLC
	ROR A
	INC A
	STA rogue_filter
rogue_ai_damage_lesser
	CLC
	JSR sub_random
	CLC
	CMP rogue_filter
	BCS rogue_ai_damage_lesser
	CLC
	ADC rogue_filter
	STA rogue_filter
	LDA rogue_health
	SEC
	SBC rogue_filter
	STA rogue_health
	BEQ rogue_ai_damage_dead
	BCC rogue_ai_damage_dead
	JMP rogue_ai_increment
rogue_ai_damage_dead
	STZ rogue_health
	JMP rogue_gameover
rogue_ai_friends
	STX rogue_filter
	LDY #$00
rogue_ai_friends_loop
	CPY rogue_filter
	BEQ rogue_ai_friends_increment
	LDA rogue_enemy_x,X
	CLC
	ADC rogue_dist_x
	CMP rogue_enemy_x,Y
	BNE rogue_ai_friends_increment
	LDA rogue_enemy_y,X
	CLC
	ADC rogue_dist_y
	CMP rogue_enemy_y,Y
	BNE rogue_ai_friends_increment
	JMP rogue_ai_increment
rogue_ai_friends_increment
	INY
	CPY #$10
	BNE rogue_ai_friends_loop
rogue_ai_bounds
	LDA rogue_enemy_y,X
	CLC
	ADC rogue_dist_y
	AND #%00000011
	CLC
	ROR A
	ROR A
	ROR A
	CLC
	ADC rogue_enemy_x,X
	CLC
	ADC rogue_dist_x
	STA sub_read+1
	LDA rogue_enemy_y,X
	CLC
	ADC rogue_dist_y
	AND #%00011100
	CLC
	ROR A
	ROR A
	CLC
	ADC #>rogue_floor
	STA sub_read+2
	JSR sub_read
	CMP #$3A ; colon
	BEQ rogue_ai_move
	CMP #"."
	BEQ rogue_ai_move
	CMP #"+"
	BEQ rogue_ai_move
	JMP rogue_ai_increment
rogue_ai_move
	LDA rogue_enemy_x,X
	CLC
	ADC rogue_dist_x
	STA rogue_enemy_x,X
	LDA rogue_enemy_y,X
	CLC
	ADC rogue_dist_y
	STA rogue_enemy_y,X
	JMP rogue_ai_increment



rogue_light
	PHA
	PHX
	STZ printchar_x
	STZ printchar_y
rogue_light_loop
	LDA rogue_player_x
	CMP printchar_x
	BNE rogue_light_calculate
	LDA rogue_player_y
	CMP printchar_y
	BNE rogue_light_calculate
	JMP rogue_light_increment
rogue_light_calculate
	LDA rogue_player_x
	SEC
	SBC printchar_x
	BCS rogue_light_x
	EOR #$FF
	INC A
rogue_light_x
	STA rogue_distance
	LDA rogue_player_y
	SEC
	SBC printchar_y
	BCS rogue_light_y
	EOR #$FF
	INC A
rogue_light_y
	CLC
	ADC rogue_distance
	CMP rogue_lamp
	BEQ rogue_light_dark
	BCC rogue_light_bright
	JMP rogue_light_increment
rogue_light_bright
	LDA #$FF
	STA rogue_filter
	JMP rogue_light_continue
rogue_light_dark
	LDA #$55
	STA rogue_filter
rogue_light_continue

	LDX #$00
rogue_light_enemies
	LDA rogue_enemy_h,X
	BEQ rogue_light_enemies_increment
	LDA rogue_enemy_t,X
	CLC
	CMP #$41
	BCC rogue_light_enemies_increment
	CLC
	CMP #$5B
	BCS rogue_light_enemies_increment
	LDA rogue_enemy_x,X
	CMP printchar_x
	BNE rogue_light_enemies_increment
	LDA rogue_enemy_y,X
	CMP printchar_y
	BNE rogue_light_enemies_increment
	LDA rogue_filter
	CMP #$FF
	BNE rogue_light_enemies_increment
	LDA #$AA
rogue_light_enemies_print
	STA printchar_foreground
	LDA rogue_enemy_t,X
	JSR printchar
	LDA #$FF
	STA printchar_foreground
	JMP rogue_light_check
rogue_light_enemies_increment
	INX
	CPX #$10
	BNE rogue_light_enemies

	LDA printchar_y
	AND #%00000011
	CLC
	ROR A
	ROR A
	ROR A
	CLC
	ADC printchar_x
	STA sub_read+1
	LDA printchar_y
	AND #%00011100
	CLC
	ROR A
	ROR A
	CLC
	ADC #>rogue_floor
	STA sub_read+2
	LDA rogue_filter
	STA printchar_foreground
	JSR sub_read
	PHA
	LDA sub_read+2
	CLC
	ADC #$08 ; now in 'items' memory
	STA sub_read+2
	JSR sub_read
	CMP #$00
	BEQ rogue_light_floor
	PLA
	LDA rogue_filter
	CMP #$FF
	BNE rogue_light_grey
	LDA #$AA ; red
	STA printchar_foreground
rogue_light_grey
	JSR sub_read
	JSR printchar
	LDA #$FF
	STA printchar_foreground
	JMP rogue_light_check
rogue_light_floor
	PLA
	JSR printchar
	LDA #$FF
	STA printchar_foreground
	JMP rogue_light_check
rogue_light_increment
	LDA printchar_x
	AND #%00111111
	CMP #%00111111
	BEQ rogue_light_return
	INC printchar_x
	JMP rogue_light_check
rogue_light_return
	STZ printchar_x
	INC printchar_y
rogue_light_check
	LDA printchar_y
	CMP #$1C
	BCS rogue_light_exit
	JMP rogue_light_loop
rogue_light_exit
	PLX
	PLA
	RTS


rogue_blast
	PHA
	PHX
	STZ printchar_x
	STZ printchar_y
rogue_blast_loop
	LDA rogue_player_x
	CMP printchar_x
	BNE rogue_blast_calculate
	LDA rogue_player_y
	CMP printchar_y
	BNE rogue_blast_calculate
	JMP rogue_blast_increment
rogue_blast_calculate
	LDA rogue_player_x
	SEC
	SBC printchar_x
	BCS rogue_blast_x
	EOR #$FF
	INC A
rogue_blast_x
	STA rogue_distance
	LDA rogue_player_y
	SEC
	SBC printchar_y
	BCS rogue_blast_y
	EOR #$FF
	INC A
rogue_blast_y
	CLC
	ADC rogue_distance
	CMP #$03 ; arbitrary blast radius
	BCS rogue_blast_increment

	LDA rogue_player_x
	PHA
	LDA rogue_player_y
	PHA
	LDA printchar_x
	STA rogue_player_x
	LDA printchar_y
	STA rogue_player_y
	JSR rogue_collide
	PLA
	STA rogue_player_y
	PLA
	STA rogue_player_x

	LDA printchar_y
	AND #%00000011
	CLC
	ROR A
	ROR A
	ROR A
	CLC
	ADC printchar_x
	STA sub_write+1
	STA sub_read+1
	LDA printchar_y
	AND #%00011100
	CLC
	ROR A
	ROR A
	CLC
	ADC #>rogue_floor
	STA sub_write+2
	STA sub_read+2
	JSR sub_read
	CMP #"#"
	BNE rogue_blast_items
	LDA #$3A
	JSR sub_write
rogue_blast_items	
	LDA sub_write+2
	CLC
	ADC #$08 ; now in 'items' memory
	STA sub_write+2
	LDA #$00
	JSR sub_write
rogue_blast_increment
	LDA printchar_x
	AND #%00111111
	CMP #%00111111
	BEQ rogue_blast_return
	INC printchar_x
	JMP rogue_blast_check
rogue_blast_return
	STZ printchar_x
	INC printchar_y
rogue_blast_check
	LDA printchar_y
	CMP #$1C
	BCS rogue_blast_exit
	JMP rogue_blast_loop
rogue_blast_exit
	PLX
	PLA
	RTS


rogue_enemy_draw ; X already loaded
	PHA
	PHX
	LDA rogue_enemy_h,X
	BEQ rogue_enemy_draw_exit
	LDA rogue_player_x
	SEC
	SBC rogue_enemy_x,X
	BCS rogue_enemy_draw_x
	EOR #$FF
	INC A
rogue_enemy_draw_x
	STA rogue_distance
	LDA rogue_player_y
	SEC
	SBC rogue_enemy_y,X
	BCS rogue_enemy_draw_y
	EOR #$FF
	INC A
rogue_enemy_draw_y
	CLC
	ADC rogue_distance
	CMP rogue_lamp
	BEQ rogue_enemy_draw_dark
	BCS rogue_enemy_draw_exit
	LDA #$AA
	STA printchar_foreground
	JMP rogue_enemy_draw_bright
rogue_enemy_draw_dark
	LDA #$55
	STA printchar_foreground
rogue_enemy_draw_bright
	LDA rogue_enemy_x,X
	STA printchar_x
	LDA rogue_enemy_y,X
	STA printchar_y
	LDA rogue_enemy_t,X
	JSR printchar
	LDA #$FF
	STA printchar_foreground
rogue_enemy_draw_exit
	PLX
	PLA
	RTS



rogue_menu
	PHA
	PHX
	PHY
	STZ printchar_x
	LDA #$1C
	STA printchar_y
	
	LDX #$00
rogue_menu_loop
	LDA rogue_menu_text,X
	CMP #$00
	BEQ rogue_menu_exit
	CMP #$20 ; space
	BEQ rogue_menu_skip
	JSR printchar
	JMP rogue_menu_increment
rogue_menu_skip
	INC printchar_x
rogue_menu_increment
	INX
	BNE rogue_menu_loop
rogue_menu_exit
	LDA #$02
	STA printchar_x
	LDA rogue_level
	JSR rogue_menu_number
	LDA #$09
	STA printchar_x
	LDA rogue_attack
	JSR rogue_menu_number
	LDA #$10
	STA printchar_x
	LDA rogue_defense
	JSR rogue_menu_number
	LDA #$18
	STA printchar_x
	LDA rogue_health
	JSR rogue_menu_number_zeros
	LDA #$1C
	STA printchar_x
	LDA rogue_health_max
	JSR rogue_menu_number_zeros
	LDA #$23
	STA printchar_x
	LDA rogue_potions
	JSR rogue_menu_number
	LDA #$2A
	STA printchar_x
	LDA rogue_bombs
	JSR rogue_menu_number
	LDA #$34
	STA printchar_x
	LDA rogue_food_high
	JSR rogue_menu_number_zeros
	LDA #$3A
	STA printchar_x
	LDA rogue_gold
	JSR rogue_menu_number

	PLY
	PLX
	PLA
	RTS
rogue_menu_text
	.BYTE "Lvl  , "
	.BYTE "Atk  , "
	.BYTE "Def  , "
	.BYTE "HP    /"
	.BYTE "   , "
	.BYTE "Ptn  , "
	.BYTE "Bmb  , "
	.BYTE "Food    "
	.BYTE ", $"
	.BYTE $00

rogue_menu_number_zeros
	STZ basic_value1_high
	STA basic_value1_low
	CLC
	CMP #$64
	BCS rogue_menu_number_print
	PHA
	LDA #"0"
	JSR printchar
	PLA
	CLC
	CMP #$0A
	BCS rogue_menu_number_print
	PHA
	LDA #"0"
	JSR printchar
	PLA
	JMP rogue_menu_number_print
rogue_menu_number
	STZ basic_value1_high
	STA basic_value1_low
	CLC
	CMP #$64
	BCS rogue_menu_number_print
	INC printchar_x
	CLC
	CMP #$0A
	BCS rogue_menu_number_print
	INC printchar_x
rogue_menu_number_print
	PHY
	JSR basic_print_unsigned
	PLY
	RTS

rogue_message ; 'rogue_text' already loaded with message location
	PHA
	PHX
	STZ sub_write+1
	LDA #$7C
	STA sub_write+2
rogue_message_clear
	LDA #$00
	JSR sub_write
	INC sub_write+1
	BNE rogue_message_clear
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BCC rogue_message_clear
	STZ printchar_x
	LDA #$1D
	STA printchar_y
	LDX #$00
	LDA rogue_text+0
	STA sub_index+1
	LDA rogue_text+1
	STA sub_index+2
rogue_message_loop
	JSR sub_index
	BEQ rogue_message_break
	JSR printchar
	INX
	CPX #$3F
	BCS rogue_message_break
	JMP rogue_message_loop
rogue_message_break
	PLX
	PLA
	RTS
	

rogue_gameover
	JSR rogue_menu
	LDA #<rogue_gameover_text
	STA rogue_text+0
	LDA #>rogue_gameover_text
	STA rogue_text+1
	JSR rogue_message
rogue_gameover_clear
	JSR inputchar
	CMP #$00
	BNE rogue_gameover_clear
rogue_gameover_wait
	JSR inputchar
	CMP #$00
	BEQ rogue_gameover_wait
	CMP #$1B ; escape
	BEQ rogue_gameover_exit
	CMP #$20 ; space
	BEQ rogue_gameover_restart
	CMP #"0"
	BEQ rogue_gameover_restart
	CMP #"Q"
	BEQ rogue_gameover_restart
	CMP #"q"
	BEQ rogue_gameover_restart
	CMP #"E"
	BEQ rogue_gameover_restart
	CMP #"e"
	BEQ rogue_gameover_restart
	JMP rogue_gameover_wait
rogue_gameover_restart
	JMP rogue
rogue_gameover_exit
	JMP function_keys_scratchpad ; exit

rogue_gameover_text
	.BYTE "Game "
	.BYTE "Over",$00

	



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
	JSR sub_random
	STA basic_value4_high
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

	JSR scratchpad_joy

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

scratchpad_joy
	PHA
	LDA joy_buttons
	AND #%00110000
	CMP #%00110000
	BEQ scratchpad_joy_exit
	PLA
	JMP bank_switch
scratchpad_joy_exit
	PLA
	RTS

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
	.BYTE "ch, F2=M"
	.BYTE "on, F3=B"
	.BYTE "ASIC, F4"
	.BYTE "=Games, "
	.BYTE "F9=SDcar"
	.BYTE "d",$0D
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
	.BYTE "k, F10=<"
	.BYTE "Save/Loa"
	.BYTE "d>, F12="
	.BYTE "Help",$0D
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
	CMP #$1F ; F4, games on other bank
	BNE function_keys_next4
	LDA #$02
	STA function_mode
	PLA
	PLA
	JMP bank_switch
function_keys_next4
	CMP #$0E ; F5, rogue
	BNE function_keys_next5
	LDA #$02
	STA function_mode
	PLA
	PLA
	JMP rogue
function_keys_next5
	CMP #$16 ; F9, sdcard_bootloader
	BNE function_keys_next6
	LDA function_mode
	CMP #$FF
	BNE function_keys_exit
	JSR sdcard_bootloader
	CMP #$00
	BNE function_keys_exit ; successful exit
	BEQ function_keys_exit ; error	
	;JMP vector_reset ; error exit
function_keys_next6
	CMP #$18 ; F10, save/load (or bell)
	BNE function_keys_next7
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
	BNE function_keys_exit
function_keys_next7
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

	STZ sub_random_var

; uses A = A * 3 + 17 + T2rand
	LDX #$12
setup_random_loop
	LDA setup_random_code,X
	STA sub_random,X
	DEX
	CPX #$FF
	BNE setup_random_loop

	JSR basic_clear

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
	ORA #%00100000
	STA via_pb
	NOP
	NOP
	JMP function_keys_scratchpad


	.ORG $FFFA ; vectors

	.WORD vector_nmi
	.WORD vector_reset
	.WORD vector_irq









	
	
