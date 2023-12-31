; Make sure you use the right hard drive location by using

; sudo fdisk -l

; here will assume "sdd"

; First, run
; ~/dev65/bin/as65 SDcardCode.asm

; Second, run
; ./Parser.o SDcardCode.lst SDcardCode.bin 0 16384 32768 0

; This technically starts at $4000 on the SD card!!!

; Third, run
; sudo dd if=SDcardCode.bin of=/dev/sdd bs=1M conv=fsync




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

printchar		.EQU $E2AD
inputchar		.EQU $FE06
sdcard_readblock	.EQU $E0FE






	.ORG $0000 ; this is half-lying, it actually starts at $4000

	LDA #"!"
	JSR printchar

	LDA #$00
	STA $FFFF ; 16 color mode

	LDA #$00
	STA sdcard_block+0
	LDA #$08
	STA sdcard_block+1

	LDX #$42 ; 16KB for user save/load
	LDY #$00

loop
	JSR sdcard_readblock ; sdcard_readblock

	INC sdcard_block+1
	INC sdcard_block+1

	INX
	INX

	CPX #$B8
	BNE loop


	STZ printchar_x
	STZ printchar_y

	LDA #"E"
	JSR printchar
	LDA #"s"
	JSR printchar
	LDA #"c"
	JSR printchar
	LDA #" "
	JSR printchar
	LDA #"t"
	JSR printchar
	LDA #"o"
	JSR printchar
	LDA #" "
	JSR printchar
	LDA #"E"
	JSR printchar
	LDA #"x"
	JSR printchar
	LDA #"i"
	JSR printchar
	LDA #"t"
	JSR printchar


	LDA #%11000000 ; timer control
	STA via+$0B
	
	STZ via+$04
	STZ via+$05

keys
	JSR inputchar
	CMP #$1B
	BNE next

	RTS
next

	CMP #"1"
	BNE check1
	LDA #$04
	STA via+$05
	STZ via+$04
	STZ clock_low
	BNE keys
check1
	CMP #"2"
	BNE check2
	LDA #$06
	STA via+$05
	STZ via+$04
	STZ clock_low
	BNE keys
check2
	CMP #"3"
	BNE check3
	LDA #$08
	STA via+$05
	STZ via+$04
	STZ clock_low
	BNE keys
check3
	CMP #"4"
	BNE check4
	LDA #$0A
	STA via+$05
	STZ via+$04
	STZ clock_low
	BNE keys
check4
	PHA
	LDA #$00
	BEQ check_mid

branch
	LDA #$00
	BEQ keys

check_mid
	PLA

	CMP #"5"
	BNE check5
	LDA #$0C
	STA via+$05
	STZ via+$04
	STZ clock_low
	BNE branch
check5
	CMP #"6"
	BNE check6
	LDA #$0E
	STA via+$05
	STZ via+$04
	STZ clock_low
	BNE branch
check6
	CMP #"7"
	BNE check7
	LDA #$10
	STA via+$05
	STZ via+$04
	STZ clock_low
	BNE branch
check7
	CMP #"8"
	BNE check8
	LDA #$12
	STA via+$05
	STZ via+$04
	STZ clock_low
	BNE branch
check8
	CMP #"9"
	BNE check9
	LDA #$14
	STA via+$05
	STZ via+$04
	STZ clock_low
	BNE branch
check9
	CMP #"0"
	BNE check10
	LDA #$16
	STA via+$05
	STZ via+$04
	STZ clock_low
	BNE branch
check10
	
	LDA #$00
	BEQ clock1

jump	
	LDA #$00
	BEQ branch

clock1
	LDA clock_low
	CLC
	CMP #$10
	BCC jump

	STZ clock_low
	
	STZ via+$05
	STZ via+$04

	LDA #$00
	BEQ jump
	

	.ORG $0200

picture_data
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $7F,$7F,$FF,$7F,$F7,$F7,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$F6
	.BYTE $F7,$E7,$E7,$E7,$E7,$EF,$6E,$7E
	.BYTE $6E,$7E,$6E,$7E,$7E,$7E,$7E,$6F
	.BYTE $E7,$7F,$FF,$FF,$6F,$F7,$FE,$7F
	.BYTE $F7,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$77,$67,$76
	.BYTE $77,$67,$76,$77,$67,$76,$77,$67
	.BYTE $76,$77,$67,$67,$67,$67,$6F,$7E
	.BYTE $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FE,$7F,$E7
	.BYTE $EF,$7E,$7E,$F7,$E7,$E6,$F6,$E7
	.BYTE $E7,$E7,$E6,$E7,$E7,$E6,$F6,$FE
	.BYTE $7F,$E7,$E7,$E7,$E7,$E7,$E7,$E7
	.BYTE $E7,$F7,$EF,$7F,$FF,$FF,$FF,$F6
	.BYTE $FF,$F7,$FF,$FF,$FF,$FF,$7F,$7F
	.BYTE $7F,$7F,$FF,$FF,$7F,$7F,$EF,$7E
	.BYTE $F7,$F6,$FE,$7E,$7E,$67,$F6,$E7
	.BYTE $EE,$7E,$7E,$6E,$7E,$6F,$E7,$E7
	.BYTE $FE,$FF,$7E,$7F,$E7,$EF,$7F,$F6
	.BYTE $FE,$7E,$7F,$FE,$F6,$FF,$FE,$7F
	.BYTE $FF,$F7,$FF,$F7,$FF,$FF,$7F,$FF
	.BYTE $FF,$FF,$FF,$FF,$77,$67,$76,$77
	.BYTE $67,$76,$77,$67,$76,$77,$67,$76
	.BYTE $77,$67,$76,$7F,$67,$67,$76,$F7
	.BYTE $F6,$7F,$7F,$F7,$FF,$FF,$7F,$FF
	.BYTE $7F,$F7,$FF,$F7,$F7,$FE,$F7,$EF
	.BYTE $7E,$FE,$7E,$7E,$F6,$F6,$6F,$67
	.BYTE $E6,$E7,$E7,$E7,$E6,$F6,$F7,$F6
	.BYTE $F6,$F6,$FE,$7E,$7E,$7E,$7E,$7E
	.BYTE $7E,$F7,$FF,$E7,$E7,$FF,$7F,$FE
	.BYTE $FF,$FF,$FF,$FF,$FF,$F7,$FF,$F7
	.BYTE $FF,$FF,$7F,$FF,$7F,$6F,$7E,$7F
	.BYTE $6F,$E7,$7E,$F7,$E6,$F6,$E6,$F6
	.BYTE $E7,$EE,$7E,$7E,$F6,$F6,$F6,$FE
	.BYTE $7F,$76,$F7,$F7,$FF,$7F,$E7,$F7
	.BYTE $F7,$FF,$E7,$F7,$FF,$F7,$EF,$FF
	.BYTE $FE,$FF,$FF,$FF,$F7,$FF,$FF,$FF
	.BYTE $F7,$FF,$F7,$FF,$76,$7E,$77,$67
	.BYTE $7E,$77,$67,$67,$67,$EF,$7E,$FF
	.BYTE $FF,$F7,$E7,$67,$7E,$76,$7E,$7E
	.BYTE $7F,$6F,$7F,$FF,$FF,$7F,$FF,$FF
	.BYTE $FF,$FF,$F7,$FF,$FF,$7F,$EF,$7E
	.BYTE $7E,$7F,$E7,$E7,$FE,$7E,$7E,$E7
	.BYTE $E7,$E7,$E7,$E6,$F6,$F6,$FE,$F7
	.BYTE $E7,$EE,$7E,$E7,$E7,$E7,$6F,$6F
	.BYTE $6F,$7E,$F7,$FF,$FF,$FE,$F7,$E7
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$F7
	.BYTE $F7,$7F,$F7,$FF,$7F,$7E,$7E,$F7
	.BYTE $E7,$EF,$7E,$7E,$7E,$7E,$7E,$6F
	.BYTE $6E,$7E,$7E,$7E,$7E,$7E,$7E,$7F
	.BYTE $FF,$FE,$7E,$7E,$7F,$6F,$7E,$FE
	.BYTE $FE,$7F,$FE,$FF,$7E,$FF,$7E,$7F
	.BYTE $F7,$FF,$F7,$FF,$FF,$FF,$F7,$FF
	.BYTE $FF,$FF,$F7,$F7,$E7,$77,$6F,$76
	.BYTE $76,$7E,$77,$E7,$7F,$7F,$77,$76
	.BYTE $76,$F7,$F7,$F6,$7F,$F7,$F7,$F7
	.BYTE $E7,$7F,$F7,$FF,$FF,$FF,$F7,$FF
	.BYTE $7F,$7F,$FF,$FE,$FF,$F7,$E7,$FE
	.BYTE $F7,$E7,$E7,$E7,$FF,$7E,$6F,$6E
	.BYTE $7E,$7E,$6E,$7E,$7E,$7E,$7E,$7E
	.BYTE $F6,$F7,$E7,$EF,$6F,$6F,$67,$E7
	.BYTE $6F,$E7,$FE,$F7,$FF,$7F,$FF,$FE
	.BYTE $FF,$FF,$FF,$F7,$F7,$F7,$7E,$F7
	.BYTE $EF,$FF,$FF,$F7,$EF,$7E,$7F,$6E
	.BYTE $7F,$6F,$6F,$E7,$E7,$E6,$F6,$E7
	.BYTE $E7,$EE,$7E,$7E,$7E,$7E,$7E,$F7
	.BYTE $E7,$F7,$E7,$F7,$EF,$7F,$E7,$F7
	.BYTE $FF,$F7,$E7,$FF,$FF,$7E,$FF,$FF
	.BYTE $FF,$C7,$FF,$CF,$FF,$7F,$FF,$FF
	.BYTE $7F,$7F,$FF,$77,$76,$76,$77,$67
	.BYTE $77,$77,$67,$7F,$FF,$FF,$FF,$F7
	.BYTE $FF,$F7,$F6,$77,$E7,$E7,$E7,$E7
	.BYTE $FE,$7E,$7F,$FF,$FF,$7F,$FF,$FF
	.BYTE $FF,$FF,$F7,$FF,$7F,$FF,$FF,$6F
	.BYTE $7E,$FF,$E7,$EE,$FF,$E7,$E7,$E7
	.BYTE $E6,$E7,$F6,$FE,$7E,$E7,$FE,$7E
	.BYTE $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
	.BYTE $F6,$7E,$F7,$FF,$EF,$FE,$76,$7F
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$7F,$7F
	.BYTE $7F,$7F,$F7,$F7,$E7,$FE,$7E,$7F
	.BYTE $E7,$E7,$E7,$F7,$E7,$E7,$E7,$E7
	.BYTE $E7,$E7,$EE,$7E,$E7,$E7,$E6,$E7
	.BYTE $FE,$7F,$7E,$7F,$7E,$7F,$F6,$F6
	.BYTE $F6,$FF,$7F,$C7,$EF,$FF,$E7,$FE
	.BYTE $7F,$FF,$F7,$FF,$FF,$FF,$77,$77
	.BYTE $7F,$FF,$77,$67,$67,$77,$67,$76
	.BYTE $76,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FF,$FF,$7F,$7F,$7E,$7F,$7E
	.BYTE $7F,$7F,$7F,$7F,$FF,$F7,$F7,$FF
	.BYTE $F7,$FF,$FF,$FF,$FF,$7E,$F7,$FE
	.BYTE $7E,$76,$FF,$F7,$6F,$FF,$6E,$7E
	.BYTE $7E,$7E,$F6,$FF,$7F,$FF,$6F,$7E
	.BYTE $F6,$F6,$FE,$7E,$7E,$7E,$F6,$F6
	.BYTE $FF,$6F,$FE,$7F,$7E,$7F,$FE,$7E
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$E7,$FE
	.BYTE $7E,$7F,$7E,$F6,$F6,$F6,$F6,$F6
	.BYTE $E7,$E7,$F6,$EE,$7E,$7E,$7E,$E7
	.BYTE $E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7
	.BYTE $E7,$E7,$F7,$EF,$7F,$F6,$F7,$FF
	.BYTE $7F,$6F,$FF,$7F,$F7,$E7,$FF,$FF
	.BYTE $FF,$7F,$FF,$FF,$7F,$E7,$67,$6F
	.BYTE $77,$76,$76,$77,$E7,$E7,$76,$F7
	.BYTE $FF,$FF,$FF,$F7,$FF,$FF,$FF,$FF
	.BYTE $FF,$7E,$7E,$76,$7E,$7F,$7E,$77
	.BYTE $EF,$7E,$F7,$FF,$FF,$7F,$FF,$FF
	.BYTE $FF,$F7,$FF,$F7,$FE,$FF,$FE,$7E
	.BYTE $F7,$FF,$E7,$EF,$FE,$7F,$FF,$6F
	.BYTE $EF,$FF,$FF,$FF,$FF,$6E,$7E,$F6
	.BYTE $F6,$F7,$E7,$EF,$6E,$7E,$7E,$7E
	.BYTE $7E,$F7,$EF,$FE,$FF,$F6,$7F,$6F
	.BYTE $FF,$FF,$FF,$FF,$FF,$F7,$FF,$7F
	.BYTE $7F,$7E,$F7,$F7,$E7,$F6,$FE,$7E
	.BYTE $F7,$EE,$7E,$7F,$6F,$6F,$6F,$6F
	.BYTE $6E,$F6,$F6,$F6,$FE,$7F,$6F,$6F
	.BYTE $7F,$6F,$6F,$7F,$E7,$F7,$FE,$7E
	.BYTE $7F,$E7,$EF,$7E,$7F,$FF,$F6,$F7
	.BYTE $EF,$EF,$FF,$FF,$F7,$E7,$77,$76
	.BYTE $76,$77,$7E,$77,$77,$76,$77,$67
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F
	.BYTE $7F,$F7,$F7,$FF,$77,$F6,$F6,$F7
	.BYTE $E7,$F6,$F7,$F7,$FF,$FF,$7F,$7F
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$7F,$F7
	.BYTE $EE,$7F,$FF,$F7,$FF,$FF,$FF,$F7
	.BYTE $FF,$7F,$FF,$FF,$FF,$F7,$E7,$E7
	.BYTE $FE,$7E,$7F,$6F,$7E,$7E,$6E,$7E
	.BYTE $76,$FF,$67,$F7,$E7,$F6,$F7,$E7
	.BYTE $FF,$FF,$FF,$FF,$F7,$F7,$F7,$EF
	.BYTE $6F,$F7,$FE,$7E,$7E,$7F,$67,$F6
	.BYTE $7E,$7E,$7E,$7E,$7E,$7E,$7E,$E7
	.BYTE $E7,$E7,$E7,$E7,$E7,$E7,$E7,$F6
	.BYTE $F6,$F7,$E7,$F7,$F6,$F6,$F7,$FE
	.BYTE $F7,$FF,$7E,$FF,$7E,$F6,$FF,$FF
	.BYTE $F7,$F7,$E7,$F6,$F7,$77,$E7,$67
	.BYTE $77,$7E,$77,$76,$76,$77,$67,$7F
	.BYTE $FF,$FF,$FF,$FF,$FF,$F7,$FF,$FF
	.BYTE $F7,$F7,$67,$E7,$E7,$E7,$F7,$E7
	.BYTE $7E,$F7,$EF,$F7,$FF,$F7,$FF,$FF
	.BYTE $FF,$FF,$7F,$FF,$FF,$FE,$FE,$7E
	.BYTE $7F,$FF,$7F,$FF,$F7,$FF,$7F,$FF
	.BYTE $FF,$FF,$F7,$FF,$7F,$F6,$F6,$FF
	.BYTE $6F,$7E,$7E,$7E,$F6,$F6,$F6,$E7
	.BYTE $EF,$FF,$FF,$EF,$F7,$E7,$F6,$F7
	.BYTE $FF,$FF,$FF,$FF,$F7,$F7,$FF,$7F
	.BYTE $7E,$7F,$7F,$FF,$7E,$F6,$FE,$7E
	.BYTE $7F,$E7,$E7,$EE,$7E,$E7,$E7,$EE
	.BYTE $7E,$7E,$F6,$F7,$E7,$FE,$7E,$7E
	.BYTE $76,$F6,$F7,$E7,$F7,$F7,$FE,$7F
	.BYTE $6F,$6F,$F7,$EF,$7F,$FF,$7E,$7E
	.BYTE $FE,$7F,$FE,$77,$76,$76,$77,$77
	.BYTE $E7,$77,$76,$77,$77,$67,$7F,$7F
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$7F,$F7
	.BYTE $F6,$FF,$7E,$7F,$7F,$7E,$7F,$6F
	.BYTE $7E,$7F,$77,$EF,$7F,$F7,$F7,$FF
	.BYTE $F7,$FF,$FF,$F7,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$F7,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$E7,$FF,$7F
	.BYTE $7F,$E7,$EF,$7E,$7E,$7F,$6F,$6F
	.BYTE $6E,$7E,$7F,$7E,$F7,$F6,$F7,$E7
	.BYTE $FF,$FF,$FF,$F7,$FE,$7F,$7E,$7F
	.BYTE $FF,$F7,$FE,$7E,$7F,$7E,$7E,$7E
	.BYTE $7E,$7E,$F6,$F7,$E7,$E7,$E7,$E7
	.BYTE $EE,$6F,$6F,$6E,$7E,$7E,$7E,$7F
	.BYTE $7E,$7E,$7E,$7F,$6F,$E7,$F7,$EF
	.BYTE $7F,$7F,$6F,$7F,$F6,$F6,$FF,$F7
	.BYTE $FF,$76,$77,$76,$77,$77,$E7,$E7
	.BYTE $76,$76,$7F,$67,$E7,$76,$7F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$6F,$7F,$76,$F6,$7F,$6F,$7E
	.BYTE $7E,$7E,$7E,$7F,$7F,$7E,$F7,$FF
	.BYTE $FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $F7,$FF,$FF,$FF,$F7,$FF,$FF,$FF
	.BYTE $7F,$FF,$FF,$FF,$7F,$7F,$E7,$FE
	.BYTE $F6,$F7,$E7,$E7,$F6,$E7,$E7,$E6
	.BYTE $FF,$FF,$F6,$F7,$F6,$F7,$E7,$F6
	.BYTE $FF,$FF,$F7,$F7,$F7,$EF,$7F,$F7
	.BYTE $F7,$EF,$FF,$FE,$7E,$7E,$7F,$6F
	.BYTE $6E,$F6,$F6,$F6,$FE,$7E,$E7,$E7
	.BYTE $E7,$E7,$E7,$F6,$FE,$7F,$7E,$7E
	.BYTE $7F,$7E,$7F,$6F,$77,$EF,$E7,$F7
	.BYTE $EF,$EF,$FF,$E7,$FF,$FF,$F6,$FE
	.BYTE $7E,$FF,$76,$77,$F6,$77,$77,$67
	.BYTE $77,$76,$77,$77,$76,$77,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF
	.BYTE $F7,$E7,$E7,$E7,$F7,$E7,$7E,$7E
	.BYTE $7F,$7E,$7E,$7E,$7E,$7E,$7F,$FF
	.BYTE $FF,$7F,$FF,$FF,$7F,$FF,$F7,$FF
	.BYTE $FF,$7F,$F7,$FF,$FF,$FF,$F7,$FF
	.BYTE $FF,$7F,$F7,$F7,$FF,$F7,$FF,$F7
	.BYTE $F7,$FF,$E7,$FE,$7E,$7F,$6F,$E7
	.BYTE $6F,$E7,$F6,$F6,$F7,$E7,$F7,$E7
	.BYTE $FF,$FF,$FF,$7F,$7F,$F7,$FF,$7E
	.BYTE $FF,$7F,$7F,$7F,$F7,$E7,$E7,$E7
	.BYTE $E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7
	.BYTE $E7,$E7,$E6,$F6,$F7,$E7,$E7,$E7
	.BYTE $E7,$E7,$E7,$F6,$FF,$7F,$FE,$FE
	.BYTE $7F,$7E,$7E,$7F,$F6,$F6,$FF,$7F
	.BYTE $F7,$77,$67,$76,$77,$7E,$77,$7E
	.BYTE $77,$F7,$67,$67,$77,$67,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$F7,$FF,$FF,$7F
	.BYTE $7F,$7F,$7F,$7E,$76,$F7,$6F,$7F
	.BYTE $66,$F7,$7E,$7E,$7E,$7F,$6F,$7F
	.BYTE $7E,$FF,$F7,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FF,$7F,$FF,$7E,$FF,$7F,$7E
	.BYTE $FF,$67,$E7,$E7,$E7,$E7,$E7,$FE
	.BYTE $F7,$FF,$F6,$F7,$E7,$F6,$F6,$F7
	.BYTE $7F,$7F,$FF,$FF,$7F,$7F,$FF,$7F
	.BYTE $7E,$FE,$FF,$F7,$EF,$F7,$F6,$F6
	.BYTE $F6,$FE,$F6,$FE,$7E,$FE,$7E,$E7
	.BYTE $E6,$FE,$7E,$7E,$7E,$F6,$F7,$E7
	.BYTE $F7,$E7,$F6,$7E,$7E,$F6,$F7,$F7
	.BYTE $FE,$F7,$FF,$FF,$7F,$7F,$6F,$7E
	.BYTE $76,$77,$7F,$77,$67,$77,$67,$77
	.BYTE $76,$77,$77,$76,$77,$77,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$EF
	.BYTE $7E,$7E,$7E,$7F,$7E,$7E,$77,$E7
	.BYTE $F6,$7E,$7F,$67,$F6,$7E,$7F,$6F
	.BYTE $F7,$F7,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$F7,$FF,$F7,$FF,$7F,$7F
	.BYTE $FF,$7F,$F7,$FF,$7F,$7F,$EF,$7F
	.BYTE $7F,$7E,$7E,$7E,$7E,$7E,$7E,$7F
	.BYTE $FF,$EF,$F6,$F7,$E7,$E7,$7E,$7E
	.BYTE $F7,$FF,$FF,$FF,$7F,$FF,$FF,$FF
	.BYTE $F7,$F7,$FF,$FF,$F7,$EF,$E7,$FE
	.BYTE $7F,$67,$E7,$E7,$E7,$E7,$E7,$E7
	.BYTE $E7,$E7,$EE,$7E,$F7,$E7,$E6,$F6
	.BYTE $7E,$7E,$7F,$7F,$7F,$7F,$EF,$EF
	.BYTE $7F,$6F,$E7,$E7,$EF,$E7,$FF,$67
	.BYTE $77,$67,$67,$67,$F7,$67,$7E,$76
	.BYTE $77,$67,$E7,$77,$67,$67,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$F7
	.BYTE $F7,$E7,$F7,$E7,$E7,$F7,$E7,$F7
	.BYTE $6F,$76,$F6,$F6,$7F,$6F,$7E,$F7
	.BYTE $E7,$FE,$FF,$FF,$FF,$FF,$F7,$F7
	.BYTE $F7,$FF,$FF,$FF,$FF,$F7,$FF,$F7
	.BYTE $FF,$F7,$FF,$FF,$FF,$F7,$FF,$F6
	.BYTE $6F,$67,$7E,$77,$E7,$F6,$F6,$F7
	.BYTE $EF,$7F,$F7,$E7,$F7,$E7,$F7,$F7
	.BYTE $FF,$FF,$7F,$7F,$FF,$F7,$F7,$E7
	.BYTE $FF,$EF,$FF,$7E,$FF,$7F,$F7,$EF
	.BYTE $6F,$EF,$E7,$FE,$F6,$FE,$7E,$7E
	.BYTE $F6,$F6,$F7,$E7,$E7,$E7,$E7,$F6
	.BYTE $F7,$F6,$F6,$E7,$E7,$E7,$7F,$6F
	.BYTE $6F,$F7,$FF,$77,$7F,$76,$77,$7E
	.BYTE $77,$F7,$77,$76,$77,$77,$77,$F6
	.BYTE $7F,$77,$77,$67,$77,$7F,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE
	.BYTE $FF,$7F,$6F,$7F,$6F,$67,$67,$E7
	.BYTE $E7,$E7,$77,$E7,$E7,$F6,$F7,$7F
	.BYTE $7F,$7F,$7F,$FF,$7F,$77,$FF,$FF
	.BYTE $FF,$FF,$FF,$7F,$7F,$FF,$7F,$FF
	.BYTE $7F,$FF,$7F,$7F,$7F,$6F,$7F,$7E
	.BYTE $7E,$7E,$7E,$7E,$76,$F6,$F7,$EF
	.BYTE $FF,$7F,$EF,$7E,$7F,$7E,$7E,$7E
	.BYTE $F7,$7F,$7F,$FF,$F7,$FF,$FF,$FF
	.BYTE $6F,$7F,$6F,$FF,$FF,$E7,$EF,$7E
	.BYTE $7E,$7E,$7E,$7E,$7E,$7E,$F6,$F6
	.BYTE $E7,$E7,$E7,$FE,$7E,$7E,$F6,$F7
	.BYTE $E7,$E7,$E7,$F6,$F7,$E7,$FE,$FF
	.BYTE $F7,$EF,$67,$7E,$77,$7F,$77,$77
	.BYTE $F6,$76,$FF,$F7,$FF,$F6,$77,$F7
	.BYTE $76,$76,$7E,$77,$67,$6F,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FF,$F7,$F7,$F6,$F7,$F6,$F7
	.BYTE $7E,$7E,$7E,$7E,$7E,$77,$EF,$6F
	.BYTE $6F,$E7,$FF,$7F,$6F,$EF,$F7,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$7F,$FF,$7F
	.BYTE $F7,$FF,$FF,$FF,$F7,$FF,$6F,$67
	.BYTE $E7,$E7,$E7,$67,$E7,$6F,$6F,$7F
	.BYTE $6F,$E7,$F7,$E7,$E7,$E7,$E7,$F7
	.BYTE $F7,$FF,$7F,$7F,$FF,$F7,$E7,$F7
	.BYTE $FF,$EF,$7E,$F7,$6F,$F7,$EF,$7E
	.BYTE $F7,$E7,$EF,$7E,$7F,$E7,$E7,$E7
	.BYTE $EF,$7E,$7E,$7F,$E7,$E7,$E6,$F6
	.BYTE $E7,$F7,$F6,$F7,$E7,$EF,$7F,$7E
	.BYTE $F7,$F7,$E7,$77,$76,$7F,$E7,$67
	.BYTE $FF,$FF,$FF,$FF,$DF,$DF,$FF,$FF
	.BYTE $F7,$77,$77,$77,$77,$7F,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$FF,$FF,$FF
	.BYTE $FF,$7F,$FE,$7E,$7E,$7E,$7E,$7E
	.BYTE $77,$7E,$7F,$7E,$7F,$6F,$77,$F7
	.BYTE $F7,$FF,$7F,$E7,$F7,$E7,$FF,$7F
	.BYTE $FF,$FF,$7F,$7F,$FE,$FF,$7F,$FF
	.BYTE $F7,$F7,$E7,$F7,$E7,$E7,$F6,$F6
	.BYTE $F6,$7E,$7E,$7E,$7E,$7E,$76,$E7
	.BYTE $F7,$EF,$EF,$7F,$7E,$7F,$7F,$6F
	.BYTE $7F,$F7,$FF,$FF,$7F,$7F,$7F,$EF
	.BYTE $7F,$7F,$FF,$7F,$F7,$EF,$7E,$7E
	.BYTE $7E,$FE,$7E,$F6,$F6,$FF,$7E,$F6
	.BYTE $F6,$F7,$FE,$7E,$7E,$F7,$E7,$E7
	.BYTE $E7,$E6,$F7,$E7,$F7,$F6,$F6,$F7
	.BYTE $E7,$F7,$77,$E7,$E7,$7F,$F7,$77
	.BYTE $74,$CC,$CC,$CC,$DC,$DD,$DC,$FC
	.BYTE $DE,$76,$7E,$76,$76,$7F,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$EF
	.BYTE $FF,$EF,$7F,$7F,$7F,$7F,$7F,$7E
	.BYTE $7F,$6F,$7E,$7F,$6F,$7E,$F6,$F6
	.BYTE $F7,$E7,$F7,$FF,$6F,$7E,$7F,$FF
	.BYTE $FF,$FF,$FE,$F7,$F7,$FF,$FF,$7F
	.BYTE $EF,$F7,$FF,$FE,$7F,$F6,$7E,$76
	.BYTE $7E,$7E,$7E,$7F,$67,$E7,$E7,$FE
	.BYTE $7E,$77,$6F,$6E,$7E,$7E,$6F,$6F
	.BYTE $F7,$F7,$F7,$FF,$F7,$EF,$7F,$7F
	.BYTE $EF,$E7,$FE,$FE,$FF,$7F,$FE,$7F
	.BYTE $E7,$E7,$F6,$FE,$7E,$7E,$F7,$E7
	.BYTE $F6,$FE,$7F,$7F,$F7,$EF,$7E,$7E
	.BYTE $F6,$F7,$E7,$F6,$F6,$F7,$F6,$F7
	.BYTE $F6,$7E,$77,$77,$76,$77,$CF,$FF
	.BYTE $FD,$FC,$9C,$9C,$9C,$EC,$CC,$DE
	.BYTE $CD,$F7,$77,$7F,$77,$7F,$7F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FE,$FE,$7E,$7E,$E7,$E7,$F7
	.BYTE $E7,$E7,$6F,$6F,$7E,$77,$E7,$F6
	.BYTE $F7,$FF,$E7,$F7,$FF,$7F,$FF,$FF
	.BYTE $FF,$F7,$F7,$FE,$FF,$FF,$7F,$F7
	.BYTE $F7,$EF,$E7,$F7,$E6,$F7,$E7,$E7
	.BYTE $E7,$E7,$6F,$67,$E7,$7E,$76,$76
	.BYTE $F7,$EF,$7E,$7F,$7E,$77,$E7,$6F
	.BYTE $7F,$FF,$7F,$7F,$7F,$F7,$EF,$FF
	.BYTE $7F,$FE,$7F,$7F,$7E,$F7,$E7,$E7
	.BYTE $F7,$E7,$E7,$E7,$EF,$6F,$7E,$F6
	.BYTE $F7,$F7,$EF,$6E,$7E,$7F,$E7,$F6
	.BYTE $F6,$F6,$F6,$F7,$E7,$F6,$F7,$F6
	.BYTE $77,$77,$7E,$77,$F7,$77,$EC,$DD
	.BYTE $FC,$9C,$9C,$1E,$C1,$C1,$CC,$9C
	.BYTE $CD,$DE,$76,$76,$76,$77,$FF,$FF
	.BYTE $FF,$FF,$FF,$F7,$FF,$FF,$C7,$FF
	.BYTE $FF,$7F,$7F,$E7,$F7,$F6,$F7,$E7
	.BYTE $F7,$E7,$F6,$F7,$E7,$EF,$7E,$7F
	.BYTE $6F,$7F,$7F,$E7,$E6,$FF,$FF,$FF
	.BYTE $FF,$FF,$FE,$7F,$7F,$F7,$F7,$FF
	.BYTE $E7,$F6,$FF,$6F,$7E,$7E,$7E,$7E
	.BYTE $76,$E7,$E7,$E7,$E7,$E7,$F6,$F6
	.BYTE $F6,$7E,$76,$7E,$7E,$7E,$7F,$67
	.BYTE $7F,$7F,$FF,$7F,$F7,$FF,$F7,$EF
	.BYTE $7F,$7F,$FF,$E7,$F6,$F7,$E7,$FE
	.BYTE $6F,$E7,$FE,$F7,$E7,$F6,$F7,$E7
	.BYTE $F6,$F7,$E7,$FE,$7F,$E7,$FE,$7E
	.BYTE $7E,$7F,$6F,$6F,$7E,$F7,$F6,$FF
	.BYTE $7F,$77,$77,$67,$76,$77,$FF,$FF
	.BYTE $EC,$11,$1C,$1C,$18,$1C,$11,$CE
	.BYTE $CF,$DF,$77,$77,$77,$77,$7F,$FF
	.BYTE $FF,$FF,$FF,$FC,$FF,$FF,$FF,$CF
	.BYTE $FF,$F7,$E7,$FE,$7E,$F7,$EF,$7E
	.BYTE $7F,$67,$E7,$E7,$F7,$6F,$7E,$7F
	.BYTE $7F,$7F,$F7,$F7,$FF,$FF,$FF,$FF
	.BYTE $FF,$F7,$FF,$FF,$FF,$7E,$7E,$7F
	.BYTE $7E,$7E,$7F,$E7,$E7,$67,$E7,$F6
	.BYTE $F7,$67,$E7,$67,$E7,$E7,$67,$E7
	.BYTE $EF,$76,$FE,$76,$F7,$E7,$6F,$7E
	.BYTE $F7,$F7,$F7,$F7,$EF,$7F,$7F,$F7
	.BYTE $EF,$E7,$E7,$FF,$7F,$FE,$7F,$6F
	.BYTE $7F,$6F,$67,$EF,$7E,$F7,$EF,$7E
	.BYTE $7F,$7E,$7F,$6F,$6F,$6F,$6F,$7E
	.BYTE $F7,$EF,$7E,$7E,$F7,$EF,$6F,$7E
	.BYTE $76,$7F,$77,$F7,$7F,$7F,$FC,$C9
	.BYTE $C8,$11,$11,$01,$11,$11,$11,$8C
	.BYTE $8C,$DE,$FF,$6F,$67,$67,$F7,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$FF,$FF,$FF
	.BYTE $FF,$FE,$F7,$E7,$F7,$EF,$7E,$7E
	.BYTE $76,$F7,$E7,$E7,$E7,$F7,$E7,$F6
	.BYTE $FE,$F7,$E7,$FF,$F7,$FF,$FF,$FF
	.BYTE $FF,$FF,$7F,$7F,$76,$F7,$F7,$EE
	.BYTE $7E,$F7,$E7,$F6,$F6,$F6,$76,$E7
	.BYTE $E7,$E7,$6F,$6F,$67,$E7,$F6,$7E
	.BYTE $76,$F6,$7E,$7F,$6F,$6F,$6F,$6F
	.BYTE $7F,$F7,$F7,$FF,$7E,$7F,$E7,$FF
	.BYTE $F7,$FF,$FF,$7E,$F6,$F7,$EF,$6F
	.BYTE $6F,$7E,$FF,$6F,$E7,$E7,$E7,$FE
	.BYTE $FE,$7F,$E7,$F7,$F7,$E7,$EF,$6F
	.BYTE $6F,$6F,$E7,$E7,$EF,$7F,$EF,$F7
	.BYTE $F7,$76,$77,$67,$67,$FF,$9D,$CC
	.BYTE $11,$11,$8C,$CC,$C1,$C1,$C1,$11
	.BYTE $18,$CC,$CD,$DF,$7F,$77,$77,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FC
	.BYTE $FF,$FE,$F7,$FE,$F7,$E7,$FE,$7F
	.BYTE $7E,$7E,$7F,$6F,$7E,$7F,$7F,$7F
	.BYTE $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FE,$7F,$F6,$FF,$FF,$7E,$7F,$7F
	.BYTE $E7,$EF,$F6,$F6,$7E,$7E,$F7,$E7
	.BYTE $6F,$6F,$67,$E7,$E7,$E7,$6F,$7E
	.BYTE $7E,$7E,$7E,$7E,$7F,$7E,$7E,$76
	.BYTE $7F,$7F,$EF,$7F,$FF,$7F,$FF,$7E
	.BYTE $7F,$E7,$F7,$FF,$7F,$E7,$F7,$EF
	.BYTE $7E,$7F,$67,$F7,$EF,$7F,$E7,$F7
	.BYTE $7F,$E7,$FE,$7E,$E7,$FE,$7E,$7F
	.BYTE $6F,$7E,$7F,$E7,$F6,$F7,$7F,$7F
	.BYTE $7E,$7F,$77,$F7,$7F,$FD,$DF,$C1
	.BYTE $11,$1C,$1C,$11,$11,$11,$01,$11
	.BYTE $11,$C9,$EF,$C7,$67,$6F,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$F7,$FE,$7F,$6F,$7E,$7F,$6E
	.BYTE $7F,$67,$E7,$F6,$F7,$E7,$EF,$7F
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $F7,$FF,$FF,$7F,$F7,$E7,$7E,$7E
	.BYTE $7F,$6F,$6F,$7E,$7E,$76,$7E,$7E
	.BYTE $76,$76,$F6,$7E,$76,$7E,$76,$F6
	.BYTE $7E,$7E,$7E,$76,$F6,$7F,$67,$E7
	.BYTE $FF,$7F,$7F,$7F,$7F,$7E,$7F,$FF
	.BYTE $FF,$7F,$E7,$EF,$EF,$7E,$F7,$E7
	.BYTE $EF,$6F,$EF,$6F,$7E,$E7,$F6,$FE
	.BYTE $7F,$6F,$7E,$F7,$FE,$7F,$7F,$E7
	.BYTE $F6,$FE,$7E,$7E,$FF,$EF,$EF,$6F
	.BYTE $7F,$76,$77,$E7,$7F,$FC,$D9,$11
	.BYTE $10,$1C,$9C,$C8,$01,$11,$11,$10
	.BYTE $11,$1C,$8E,$DE,$F7,$7F,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FC,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$F6,$F6,$F7,$E7,$FE
	.BYTE $7E,$7F,$E7,$E7,$E7,$F7,$7F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$7F,$7F,$F6
	.BYTE $F6,$F6,$F6,$F6,$7E,$7E,$7E,$76
	.BYTE $F6,$F6,$6F,$67,$E7,$E7,$E7,$E7
	.BYTE $E7,$6F,$67,$E7,$E7,$E7,$E7,$E7
	.BYTE $7F,$7F,$F7,$F7,$FF,$7F,$F7,$E7
	.BYTE $FE,$F7,$FF,$7F,$7F,$FE,$7F,$F7
	.BYTE $F7,$E7,$F6,$F7,$E7,$FE,$7F,$6F
	.BYTE $7E,$7F,$6F,$7E,$7E,$F6,$E7,$EF
	.BYTE $6F,$7E,$F7,$FF,$7E,$7F,$7F,$77
	.BYTE $F7,$F7,$7F,$7F,$FF,$DF,$11,$11
	.BYTE $01,$8C,$CC,$E1,$10,$18,$1C,$81
	.BYTE $11,$11,$1E,$ED,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FE,$7F,$7E,$7E,$F6,$F6,$7E
	.BYTE $7E,$7E,$7E,$7F,$7E,$7E,$F7,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$76,$F6,$F6,$FE,$7F
	.BYTE $E7,$FE,$7E,$7E,$7E,$7E,$76,$F6
	.BYTE $7E,$67,$E7,$E7,$E7,$7E,$76,$7E
	.BYTE $7E,$76,$F6,$7E,$7E,$7E,$7E,$7E
	.BYTE $7F,$7F,$7F,$F7,$FF,$7F,$7F,$FF
	.BYTE $7F,$FE,$FF,$EF,$E7,$FF,$7F,$E7
	.BYTE $EF,$E7,$FF,$6F,$FE,$7F,$6F,$6F
	.BYTE $7E,$F7,$E7,$EF,$7E,$7F,$EF,$7E
	.BYTE $F6,$F7,$EF,$E7,$FF,$6F,$EF,$FF
	.BYTE $7F,$F7,$F7,$7F,$FF,$D1,$8E,$11
	.BYTE $11,$CE,$CC,$C0,$11,$11,$11,$18
	.BYTE $C1,$81,$1C,$1C,$DF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$DF
	.BYTE $FF,$FF,$FF,$7E,$76,$F6,$FE,$7F
	.BYTE $E7,$E7,$E7,$E7,$E7,$F6,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$7E,$7F,$7E,$7F,$E7
	.BYTE $EF,$6F,$7E,$F7,$F6,$7E,$7E,$7E
	.BYTE $7E,$7E,$76,$76,$7E,$7E,$7E,$76
	.BYTE $F7,$E7,$6F,$67,$E7,$E7,$F7,$E7
	.BYTE $7F,$7F,$F7,$FF,$7F,$FE,$F7,$F7
	.BYTE $F7,$F7,$F7,$FF,$FF,$6F,$E7,$FF
	.BYTE $7F,$7E,$7E,$F7,$E7,$EF,$7E,$F7
	.BYTE $E7,$FE,$7F,$7E,$F7,$E7,$F6,$F7
	.BYTE $EF,$6F,$7E,$FE,$7E,$F7,$F7,$FF
	.BYTE $F7,$F7,$FF,$FF,$FD,$9C,$EE,$10
	.BYTE $18,$C8,$10,$11,$01,$01,$1C,$11
	.BYTE $1C,$11,$18,$1C,$DF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$CF,$FF,$FF,$FF,$FF
	.BYTE $FC,$7F,$F6,$F7,$FE,$7E,$7E,$7E
	.BYTE $7E,$7E,$7E,$F6,$F6,$E7,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$7F,$7E,$7F,$6F,$7F
	.BYTE $7E,$F6,$F7,$EE,$7E,$7E,$7E,$76
	.BYTE $7E,$66,$E7,$EF,$67,$E7,$E7,$E7
	.BYTE $6F,$6F,$67,$E7,$E7,$E7,$E6,$7E
	.BYTE $F7,$F7,$FF,$7F,$F7,$F7,$FE,$FF
	.BYTE $EF,$FE,$FF,$7E,$7F,$F7,$F7,$E7
	.BYTE $EF,$7E,$F7,$E7,$FE,$7E,$7E,$7F
	.BYTE $E7,$F6,$FE,$7F,$6F,$E7,$F6,$FE
	.BYTE $7F,$EF,$7F,$7F,$7F,$FF,$FF,$FF
	.BYTE $7F,$7E,$7F,$7F,$FF,$CF,$E1,$11
	.BYTE $0E,$CC,$CC,$11,$11,$01,$01,$11
	.BYTE $10,$10,$11,$11,$DF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$6F,$7F,$E7,$E7,$F7,$E7,$E7
	.BYTE $E7,$FE,$F7,$E6,$F7,$F6,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$77,$E7,$E7,$F7,$EF,$6E
	.BYTE $F7,$FF,$EF,$7F,$7E,$7E,$76,$FE
	.BYTE $6F,$67,$E6,$7E,$7E,$76,$7E,$7E
	.BYTE $7E,$76,$F6,$F6,$7E,$76,$F7,$E7
	.BYTE $FF,$FF,$7F,$F7,$FF,$F7,$F7,$F7
	.BYTE $F7,$F7,$FE,$7F,$7E,$7F,$EF,$FF
	.BYTE $7F,$E7,$EF,$E7,$E7,$FE,$7E,$F6
	.BYTE $F6,$F7,$E7,$EF,$7F,$7E,$FF,$7E
	.BYTE $F7,$FE,$FE,$7F,$FF,$FF,$FF,$F7
	.BYTE $FF,$7F,$7F,$7F,$FC,$FF,$81,$01
	.BYTE $0C,$D9,$D1,$81,$81,$10,$10,$10
	.BYTE $10,$11,$01,$1C,$CF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$DD,$DF,$FF,$FF,$FF
	.BYTE $7F,$F6,$FE,$7F,$7E,$7E,$7F,$6F
	.BYTE $7E,$F7,$F6,$E7,$E6,$F6,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$7F,$7E,$7F,$7F,$F7
	.BYTE $EF,$6F,$7E,$EE,$7E,$7E,$7F,$67
	.BYTE $7E,$7E,$76,$F6,$76,$F6,$F6,$7E
	.BYTE $76,$F6,$7E,$7E,$7E,$7E,$7E,$7E
	.BYTE $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$F7,$F7,$FF,$FF,$7F,$7E,$7E
	.BYTE $F7,$F7,$F7,$EF,$7E,$7E,$F7,$E7
	.BYTE $F7,$E7,$EF,$7F,$EF,$7F,$7E,$F7
	.BYTE $EF,$7F,$7E,$FF,$FF,$FF,$FF,$FF
	.BYTE $EF,$7E,$7F,$FF,$FC,$FE,$11,$01
	.BYTE $1C,$CC,$CC,$11,$18,$11,$11,$01
	.BYTE $01,$01,$10,$11,$CF,$FF,$FF,$CF
	.BYTE $FF,$FF,$DF,$DD,$DC,$DF,$CF,$FF
	.BYTE $EF,$7F,$7F,$E7,$EF,$6F,$6F,$7E
	.BYTE $7E,$FE,$6E,$6F,$6E,$7F,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$F7,$F6,$F6,$F6,$F7
	.BYTE $F6,$FE,$7F,$7E,$F7,$E7,$E7,$EF
	.BYTE $66,$7E,$67,$E6,$E7,$E6,$7E,$76
	.BYTE $F6,$7E,$76,$7E,$7E,$7E,$7E,$7E
	.BYTE $F7,$FF,$FF,$F7,$FF,$7F,$F7,$F7
	.BYTE $F7,$FF,$FF,$FF,$7E,$F7,$FF,$7F
	.BYTE $7E,$F6,$F7,$F6,$FE,$7F,$6F,$7E
	.BYTE $7E,$FF,$7F,$E7,$F7,$EF,$E7,$FF
	.BYTE $F7,$EF,$FF,$FF,$FF,$FF,$FF,$7F
	.BYTE $7F,$FF,$7F,$FF,$DF,$EC,$11,$11
	.BYTE $19,$DC,$C8,$1C,$11,$18,$10,$11
	.BYTE $01,$01,$01,$11,$CE,$CF,$C9,$ED
	.BYTE $FD,$CC,$FD,$FC,$DF,$FF,$F7,$E7
	.BYTE $F6,$FE,$7F,$6F,$7E,$7E,$7E,$7F
	.BYTE $FF,$E6,$16,$6E,$7E,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$F7,$FE,$7F,$7F,$7F,$E7
	.BYTE $FF,$7F,$E7,$F7,$E7,$EF,$6F,$6E
	.BYTE $7E,$76,$F6,$7E,$76,$7E,$7E,$7E
	.BYTE $6F,$6E,$7E,$7E,$7E,$76,$E7,$E7
	.BYTE $77,$FF,$7F,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$7F,$F7,$EF,$7E,$FE
	.BYTE $7F,$7E,$FE,$F7,$EF,$6F,$7E,$FE
	.BYTE $7F,$7E,$7F,$7E,$F6,$F7,$F7,$E7
	.BYTE $EF,$F6,$F7,$FF,$FF,$FF,$FF,$EF
	.BYTE $E7,$FF,$FF,$FF,$FF,$19,$11,$01
	.BYTE $E9,$EF,$EC,$CC,$8C,$11,$11,$11
	.BYTE $11,$01,$01,$11,$9C,$91,$1E,$E1
	.BYTE $C9,$C9,$CC,$DF,$DD,$DF,$FF,$F7
	.BYTE $F6,$F7,$E7,$F6,$F7,$FF,$6F,$EF
	.BYTE $EE,$6E,$61,$66,$E7,$E6,$EE,$EF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$7F,$7F,$7F,$7F,$7F,$7F,$F6
	.BYTE $F7,$E7,$F6,$F6,$F7,$E7,$E7,$E7
	.BYTE $E7,$E6,$7E,$76,$F6,$F6,$E7,$6F
	.BYTE $67,$7E,$67,$E6,$7E,$7E,$7E,$67
	.BYTE $7F,$7F,$F7,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$77,$E7,$E7,$F7,$F7,$EF,$7F
	.BYTE $FE,$F7,$F7,$E7,$F7,$EF,$6F,$7F
	.BYTE $FE,$7F,$FE,$F7,$FF,$EF,$EF,$FF
	.BYTE $7F,$7F,$FE,$F7,$FF,$7F,$7F,$7F
	.BYTE $FE,$FF,$7F,$FF,$FC,$9C,$11,$18
	.BYTE $CE,$C9,$C9,$1C,$11,$1C,$81,$11
	.BYTE $01,$10,$10,$18,$E1,$11,$8C,$C8
	.BYTE $1C,$1C,$8C,$8D,$C8,$CD,$FF,$FE
	.BYTE $7F,$E7,$E7,$E7,$F6,$E7,$F7,$FE
	.BYTE $66,$16,$E6,$E1,$16,$16,$16,$61
	.BYTE $6E,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FC,$7F,$7E,$7E,$7F,$7F,$7F
	.BYTE $7F,$7E,$7E,$7F,$4F,$6F,$E7,$E7
	.BYTE $E6,$7E,$6E,$7E,$67,$67,$E7,$E7
	.BYTE $EE,$7E,$7E,$7E,$7E,$76,$F6,$E7
	.BYTE $7F,$7F,$7F,$F7,$77,$F7,$FF,$7F
	.BYTE $7F,$F7,$F7,$FE,$7E,$F7,$F6,$F7
	.BYTE $F7,$EF,$7F,$FE,$F7,$F7,$FF,$6F
	.BYTE $7E,$F7,$F7,$F7,$E7,$F7,$E7,$F6
	.BYTE $FE,$7E,$77,$FF,$FF,$FF,$FF,$7F
	.BYTE $F7,$FF,$FF,$FF,$FE,$C9,$11,$1C
	.BYTE $9E,$EE,$C9,$18,$C8,$11,$1C,$11
	.BYTE $11,$11,$18,$11,$10,$11,$11,$11
	.BYTE $18,$11,$1C,$1C,$CC,$CC,$DC,$FF
	.BYTE $6F,$7F,$E7,$F6,$F7,$E7,$EF,$FE
	.BYTE $16,$6E,$66,$16,$11,$16,$11,$11
	.BYTE $61,$6E,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$7F,$FF,$F7,$F7,$FF,$F7,$FF
	.BYTE $7E,$F6,$F6,$F6,$F6,$F4,$F7,$E7
	.BYTE $E7,$E7,$67,$E7,$E6,$F6,$7E,$66
	.BYTE $7E,$67,$E6,$7E,$6F,$6F,$67,$E6
	.BYTE $7F,$77,$77,$77,$F7,$F7,$7F,$FF
	.BYTE $F7,$7F,$7E,$7F,$7E,$7F,$E7,$FE
	.BYTE $7F,$7F,$F7,$F7,$FE,$FE,$7F,$FF
	.BYTE $F7,$FE,$FE,$FF,$7F,$6F,$7F,$6F
	.BYTE $7E,$F7,$EF,$FF,$7F,$7E,$FE,$FF
	.BYTE $EF,$FF,$FF,$FF,$FC,$EC,$18,$9C
	.BYTE $9C,$C9,$CE,$01,$01,$1C,$18,$1C
	.BYTE $11,$11,$11,$11,$E1,$8C,$11,$10
	.BYTE $11,$18,$11,$81,$C1,$8C,$CD,$F6
	.BYTE $F7,$E7,$E7,$E7,$F6,$FF,$FE,$7E
	.BYTE $6E,$61,$6E,$16,$16,$11,$61,$61
	.BYTE $11,$61,$6E,$FF,$FF,$FF,$F7,$FE
	.BYTE $F7,$FF,$77,$FF,$7F,$7F,$7E,$7E
	.BYTE $F7,$E7,$F6,$F6,$F7,$E7,$EF,$6F
	.BYTE $67,$6E,$7E,$76,$F6,$E7,$E7,$E7
	.BYTE $E7,$E7,$E7,$E7,$6E,$76,$E7,$E7
	.BYTE $77,$F7,$F7,$F7,$F7,$7F,$F7,$77
	.BYTE $FF,$FF,$F7,$E7,$FE,$7F,$6F,$7F
	.BYTE $EF,$F6,$FE,$FE,$F7,$FF,$7E,$7E
	.BYTE $F7,$F7,$F7,$E7,$EF,$7E,$F7,$EF
	.BYTE $7E,$6F,$77,$F7,$FF,$F7,$F7,$FF
	.BYTE $F6,$FF,$FF,$FF,$FF,$EC,$1E,$FF
	.BYTE $CE,$E9,$10,$11,$18,$10,$11,$1C
	.BYTE $18,$11,$C1,$81,$11,$11,$1E,$EE
	.BYTE $1E,$E1,$EC,$19,$CE,$EE,$CD,$DE
	.BYTE $F7,$E7,$E7,$E6,$FF,$EF,$E6,$E6
	.BYTE $6E,$61,$61,$61,$11,$61,$16,$16
	.BYTE $16,$11,$11,$EF,$FF,$FF,$6F,$5F
	.BYTE $FF,$5F,$FE,$7F,$6F,$7F,$F7,$F7
	.BYTE $6F,$7E,$7E,$7F,$6F,$E7,$E7,$E7
	.BYTE $E7,$E7,$66,$E7,$67,$6E,$76,$7E
	.BYTE $67,$E6,$7E,$7E,$7E,$7E,$7E,$6E
	.BYTE $77,$77,$77,$F7,$F7,$F7,$7F,$F7
	.BYTE $7F,$77,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7E,$7F,$7F,$7F,$7E,$F7,$FF,$7F
	.BYTE $FE,$F7,$FF,$E7,$F7,$E7,$FE,$7F
	.BYTE $7F,$7E,$FF,$F7,$E7,$EF,$FE,$FF
	.BYTE $F1,$1E,$61,$EF,$FF,$9F,$8E,$F9
	.BYTE $C9,$C1,$19,$18,$11,$08,$10,$01
	.BYTE $1C,$11,$01,$11,$18,$E1,$11,$11
	.BYTE $66,$EF,$FF,$EE,$CC,$FF,$EE,$DF
	.BYTE $E7,$E7,$F7,$FE,$66,$66,$6E,$61
	.BYTE $61,$61,$16,$11,$60,$61,$61,$16
	.BYTE $06,$16,$61,$6E,$FF,$F7,$FF,$F7
	.BYTE $FF,$F7,$F7,$F7,$F7,$F7,$F7,$FE
	.BYTE $7E,$F6,$F7,$E7,$E7,$F7,$E7,$C7
	.BYTE $E4,$7E,$7E,$7E,$6F,$67,$EE,$76
	.BYTE $F6,$7E,$7E,$76,$E7,$E7,$67,$E7
	.BYTE $7F,$77,$7F,$7F,$7F,$7F,$7F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FF,$EF,$7E,$F7,$F6,$FF,$E7
	.BYTE $F7,$F6,$F7,$FE,$7F,$E7,$F7,$FE
	.BYTE $7E,$77,$7F,$F7,$FF,$6F,$7F,$7F
	.BYTE $E1,$EE,$11,$EF,$FF,$EF,$CF,$FF
	.BYTE $C9,$11,$EC,$10,$11,$11,$81,$11
	.BYTE $01,$C0,$10,$81,$11,$11,$06,$11
	.BYTE $16,$16,$6E,$61,$EC,$6F,$7E,$7C
	.BYTE $FE,$7E,$6E,$66,$E6,$16,$11,$11
	.BYTE $11,$11,$11,$61,$61,$61,$16,$16
	.BYTE $16,$11,$11,$1E,$6F,$FE,$F7,$CF
	.BYTE $7F,$F7,$FF,$7F,$F7,$FE,$7F,$6F
	.BYTE $76,$F7,$E7,$E7,$E7,$E7,$EF,$6F
	.BYTE $7E,$67,$E6,$7E,$76,$E7,$67,$E6
	.BYTE $F6,$E7,$E7,$E7,$6F,$6E,$7E,$67
	.BYTE $77,$F7,$77,$77,$7F,$F7,$FF,$7F
	.BYTE $F7,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$F7,$F7,$E7,$FE,$F7,$F7,$F7
	.BYTE $EF,$F7,$FF,$7F,$E7,$F7,$E7,$E7
	.BYTE $F7,$EF,$E7,$FF,$E7,$FF,$EF,$FF
	.BYTE $FE,$EE,$31,$1F,$FF,$FF,$CF,$C9
	.BYTE $CE,$11,$10,$01,$11,$81,$11,$81
	.BYTE $10,$01,$11,$18,$C1,$01,$00,$16
	.BYTE $11,$11,$11,$11,$1E,$E6,$F7,$F7
	.BYTE $E7,$E6,$E6,$E1,$61,$11,$16,$16
	.BYTE $06,$16,$06,$01,$10,$61,$61,$11
	.BYTE $11,$60,$61,$61,$16,$E5,$FF,$FF
	.BYTE $7F,$7F,$7F,$F7,$EF,$7F,$7E,$7E
	.BYTE $F7,$E7,$EF,$7E,$7E,$F6,$F7,$E6
	.BYTE $E7,$E6,$7E,$7E,$6F,$6E,$7E,$76
	.BYTE $E7,$E7,$6E,$7E,$76,$F6,$E7,$E6
	.BYTE $77,$77,$77,$F7,$77,$F7,$F7,$FF
	.BYTE $7F,$FF,$FF,$FF,$FF,$FF,$F7,$77
	.BYTE $FF,$FF,$FF,$FF,$F7,$F6,$FE,$F7
	.BYTE $F7,$EF,$7E,$F7,$FF,$EF,$FF,$7E
	.BYTE $F7,$F7,$F7,$F7,$FF,$EF,$F7,$EF
	.BYTE $FF,$E0,$13,$1E,$FF,$FF,$CE,$CF
	.BYTE $8C,$E1,$0E,$01,$EE,$C1,$81,$C1
	.BYTE $11,$01,$1C,$18,$10,$00,$60,$01
	.BYTE $61,$61,$61,$01,$11,$6E,$EE,$F7
	.BYTE $FE,$E6,$E6,$66,$16,$16,$11,$11
	.BYTE $60,$61,$16,$16,$61,$16,$06,$16
	.BYTE $06,$16,$06,$16,$1F,$EF,$7F,$FF
	.BYTE $FF,$FF,$E7,$F7,$F7,$E7,$FF,$76
	.BYTE $F6,$F7,$E7,$EF,$67,$E7,$E7,$E7
	.BYTE $67,$6F,$66,$7E,$76,$7E,$67,$E7
	.BYTE $67,$E7,$E7,$E6,$F6,$F6,$7E,$7E
	.BYTE $F7,$77,$F7,$77,$77,$7F,$7F,$77
	.BYTE $FF,$7F,$FF,$FF,$FF,$77,$77,$F7
	.BYTE $FF,$7F,$FF,$F7,$FF,$FF,$7F,$7F
	.BYTE $EF,$7F,$F7,$FF,$7F,$77,$E7,$FF
	.BYTE $7E,$FF,$EF,$EF,$E7,$F7,$EF,$F7
	.BYTE $FF,$EE,$36,$11,$EF,$FF,$CF,$1F
	.BYTE $C1,$E1,$13,$66,$EE,$EE,$11,$C1
	.BYTE $18,$11,$E1,$81,$00,$10,$00,$61
	.BYTE $11,$11,$01,$01,$06,$E6,$F7,$FF
	.BYTE $FF,$7E,$61,$61,$61,$10,$61,$61
	.BYTE $16,$16,$11,$11,$16,$16,$16,$06
	.BYTE $16,$06,$11,$61,$66,$FE,$FF,$F7
	.BYTE $F7,$F7,$F7,$F7,$F7,$F7,$E7,$EF
	.BYTE $7E,$7E,$7F,$67,$EF,$6F,$6F,$6F
	.BYTE $6E,$76,$F6,$E7,$E7,$E7,$E6,$F6
	.BYTE $E7,$E6,$7E,$76,$7E,$7E,$67,$E7
	.BYTE $77,$77,$77,$77,$F7,$77,$77,$F7
	.BYTE $77,$7F,$7F,$77,$77,$7F,$77,$77
	.BYTE $77,$77,$77,$77,$77,$77,$F7,$F7
	.BYTE $7F,$7F,$FF,$F7,$EF,$F7,$FF,$6F
	.BYTE $7E,$77,$F7,$F7,$FE,$FF,$FF,$EF
	.BYTE $FF,$FF,$16,$11,$1E,$FF,$FF,$EF
	.BYTE $F8,$EE,$EE,$1C,$9E,$9C,$18,$C1
	.BYTE $11,$91,$66,$00,$10,$01,$00,$16
	.BYTE $16,$01,$16,$10,$11,$E7,$FF,$FF
	.BYTE $E6,$E6,$16,$11,$61,$61,$61,$16
	.BYTE $11,$E1,$61,$61,$60,$60,$61,$61
	.BYTE $11,$16,$16,$EE,$EE,$F4,$FF,$EF
	.BYTE $4F,$C7,$CF,$CE,$7C,$7E,$7E,$76
	.BYTE $F7,$EF,$4F,$7E,$7E,$7E,$7E,$7E
	.BYTE $76,$F6,$67,$66,$7E,$67,$E7,$6F
	.BYTE $66,$F6,$F4,$F6,$E7,$6F,$6E,$76
	.BYTE $F7,$F7,$77,$77,$77,$77,$77,$77
	.BYTE $F7,$F7,$77,$77,$F7,$77,$77,$F7
	.BYTE $77,$77,$77,$F7,$77,$77,$77,$7F
	.BYTE $7F,$E7,$F7,$EF,$7F,$EF,$7E,$7F
	.BYTE $6F,$7E,$FE,$FF,$7F,$FF,$7F,$F7
	.BYTE $EF,$FF,$FE,$11,$11,$1E,$FF,$EF
	.BYTE $FC,$C8,$C8,$D9,$EC,$EC,$91,$C1
	.BYTE $8C,$18,$13,$00,$00,$10,$16,$11
	.BYTE $11,$61,$00,$01,$11,$6F,$FF,$F6
	.BYTE $6E,$61,$11,$E1,$61,$16,$16,$61
	.BYTE $6E,$6E,$16,$06,$01,$11,$06,$16
	.BYTE $6E,$6E,$EF,$E7,$C7,$EF,$C7,$FE
	.BYTE $EE,$61,$61,$61,$11,$11,$11,$11
	.BYTE $6E,$67,$EF,$6F,$67,$E7,$E6,$76
	.BYTE $E7,$6E,$7E,$7E,$76,$F6,$7E,$7E
	.BYTE $7E,$76,$F6,$7E,$7E,$7E,$7E,$6F
	.BYTE $77,$77,$F7,$77,$7F,$7F,$77,$77
	.BYTE $77,$77,$7F,$77,$7F,$77,$F7,$77
	.BYTE $7F,$7F,$77,$F7,$7F,$77,$F7,$7F
	.BYTE $7F,$FF,$FF,$7E,$F7,$7F,$7F,$E7
	.BYTE $F7,$F7,$7F,$6F,$EF,$6F,$EF,$EF
	.BYTE $F7,$FF,$FF,$F1,$61,$11,$EF,$FF
	.BYTE $C8,$E9,$C9,$CC,$CE,$1C,$E8,$C8
	.BYTE $1C,$11,$16,$01,$00,$00,$21,$11
	.BYTE $11,$06,$01,$00,$11,$EF,$FE,$6E
	.BYTE $61,$61,$61,$61,$16,$16,$11,$E1
	.BYTE $E1,$6E,$16,$11,$60,$61,$11,$11
	.BYTE $11,$6E,$EF,$EF,$E6,$1E,$11,$01
	.BYTE $01,$10,$11,$10,$10,$10,$01,$01
	.BYTE $11,$11,$E7,$E7,$E6,$F6,$F4,$E7
	.BYTE $E7,$E7,$6E,$7E,$7E,$7E,$6F,$67
	.BYTE $E7,$E7,$E7,$E7,$E7,$F6,$F7,$FF
	.BYTE $77,$F7,$77,$77,$77,$77,$F7,$77
	.BYTE $77,$F7,$77,$77,$77,$77,$77,$F7
	.BYTE $77,$77,$7F,$7F,$77,$F7,$FF,$FE
	.BYTE $F7,$F7,$F7,$FF,$7E,$EF,$E7,$F7
	.BYTE $E7,$EF,$7F,$F7,$F7,$FF,$7F,$FF
	.BYTE $EF,$FF,$7F,$FF,$E1,$11,$1E,$FF
	.BYTE $8C,$CE,$C9,$CE,$9C,$91,$11,$CC
	.BYTE $18,$C8,$11,$10,$10,$01,$66,$10
	.BYTE $60,$10,$10,$61,$11,$E6,$66,$11
	.BYTE $11,$11,$61,$16,$11,$11,$61,$61
	.BYTE $11,$11,$61,$11,$16,$11,$61,$61
	.BYTE $11,$01,$10,$EF,$E1,$01,$01,$11
	.BYTE $01,$06,$01,$06,$01,$11,$10,$11
	.BYTE $01,$16,$06,$E7,$6F,$6F,$67,$E7
	.BYTE $67,$E7,$E7,$6F,$67,$E7,$7E,$7E
	.BYTE $7F,$7E,$FF,$FF,$FD,$FF,$FF,$DF
	.BYTE $77,$7F,$7F,$77,$77,$77,$7F,$7F
	.BYTE $77,$77,$F7,$77,$77,$FF,$77,$77
	.BYTE $F7,$FF,$FF,$FF,$FF,$FF,$7F,$7F
	.BYTE $7F,$FE,$F7,$EF,$7F,$77,$FE,$7F
	.BYTE $EF,$7F,$E7,$F6,$FE,$FE,$7E,$7F
	.BYTE $FF,$EF,$FF,$FE,$F6,$11,$1E,$EF
	.BYTE $18,$C9,$C9,$CE,$CE,$CC,$81,$8C
	.BYTE $CC,$CC,$11,$01,$06,$00,$11,$11
	.BYTE $10,$10,$11,$CE,$C1,$E1,$E6,$61
	.BYTE $61,$60,$61,$E1,$61,$61,$11,$16
	.BYTE $16,$E1,$16,$1E,$11,$11,$10,$11
	.BYTE $11,$10,$11,$01,$11,$06,$01,$01
	.BYTE $11,$01,$01,$06,$01,$01,$06,$01
	.BYTE $11,$1E,$11,$6F,$67,$E7,$E6,$E7
	.BYTE $E7,$67,$E7,$E7,$E7,$E6,$F7,$FF
	.BYTE $FD,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $77,$77,$77,$77,$77,$77,$77,$77
	.BYTE $77,$77,$7F,$7F,$7F,$7F,$FF,$FF
	.BYTE $FF,$FF,$FF,$7F,$F7,$EF,$F7,$FF
	.BYTE $E7,$F7,$EF,$7F,$EF,$EF,$E7,$F6
	.BYTE $7F,$E7,$FE,$FF,$7E,$7F,$FF,$E7
	.BYTE $F7,$FF,$E7,$F7,$EF,$EF,$60,$E9
	.BYTE $9C,$EC,$EE,$8C,$91,$8E,$11,$18
	.BYTE $C9,$EC,$CC,$11,$11,$11,$11,$61
	.BYTE $06,$0E,$EC,$E1,$CE,$CE,$11,$11
	.BYTE $61,$11,$61,$61,$11,$11,$06,$11
	.BYTE $11,$11,$11,$16,$16,$10,$11,$10
	.BYTE $1E,$C1,$11,$10,$10,$10,$10,$60
	.BYTE $06,$01,$11,$01,$06,$01,$01,$01
	.BYTE $06,$16,$E1,$16,$E7,$E7,$E7,$7E
	.BYTE $7E,$FF,$FF,$FF,$FF,$FD,$FF,$FF
	.BYTE $FF,$FF,$FF,$D7,$FF,$FF,$FF,$FF
	.BYTE $77,$77,$7F,$7F,$77,$77,$77,$77
	.BYTE $7F,$7F,$77,$7F,$F7,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$F7,$F7,$FE,$F7
	.BYTE $F6,$FF,$6F,$E7,$F7,$F7,$FE,$FF
	.BYTE $7F,$E7,$F7,$6F,$7F,$E7,$E7,$FE
	.BYTE $FE,$F7,$EF,$EF,$7F,$7F,$E1,$1F
	.BYTE $E9,$C8,$CE,$EC,$EC,$18,$11,$11
	.BYTE $CC,$FC,$FC,$CC,$C1,$11,$01,$10
	.BYTE $10,$11,$C1,$81,$9C,$1E,$EE,$11
	.BYTE $61,$61,$10,$60,$60,$61,$11,$11
	.BYTE $01,$10,$11,$11,$10,$31,$10,$11
	.BYTE $18,$11,$11,$60,$11,$01,$10,$11
	.BYTE $01,$01,$06,$01,$01,$01,$00,$10
	.BYTE $10,$11,$61,$11,$EF,$7D,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$DF,$DF,$DF,$DD
	.BYTE $F7,$77,$77,$77,$77,$77,$77,$7F
	.BYTE $77,$77,$F7,$F7,$FF,$7F,$FF,$FF
	.BYTE $FF,$FF,$7F,$7E,$FF,$E7,$F7,$FE
	.BYTE $F7,$F7,$F7,$FE,$FE,$7E,$7F,$7E
	.BYTE $F7,$F7,$E7,$F7,$E7,$7F,$7F,$7F
	.BYTE $7F,$7F,$F7,$F7,$E7,$77,$FF,$1E
	.BYTE $FF,$CE,$C1,$91,$9C,$1E,$11,$01
	.BYTE $8C,$9F,$DF,$EC,$81,$11,$11,$11
	.BYTE $01,$01,$1C,$EC,$1C,$11,$1C,$1E
	.BYTE $11,$11,$11,$11,$01,$01,$11,$CE
	.BYTE $11,$60,$60,$11,$11,$01,$06,$01
	.BYTE $11,$19,$C1,$01,$10,$60,$10,$60
	.BYTE $11,$11,$01,$01,$06,$01,$06,$00
	.BYTE $11,$06,$1E,$11,$1D,$FF,$FC,$FD
	.BYTE $7D,$7D,$FF,$D7,$FF,$FF,$FF,$FF
	.BYTE $5F,$FF,$FD,$FF,$DF,$DF,$CF,$DF
	.BYTE $77,$77,$77,$7F,$77,$7F,$77,$77
	.BYTE $77,$7F,$77,$F7,$7F,$FF,$FF,$FF
	.BYTE $F7,$FF,$FF,$7F,$7F,$FF,$E7,$F7
	.BYTE $FE,$FE,$FE,$7F,$7F,$FF,$E7,$E7
	.BYTE $F6,$F7,$F6,$F7,$FF,$7E,$7E,$7E
	.BYTE $FE,$7E,$7E,$77,$F7,$FE,$77,$FF
	.BYTE $F9,$E9,$CE,$CE,$1C,$11,$11,$10
	.BYTE $11,$CC,$9D,$EC,$18,$11,$10,$10
	.BYTE $11,$19,$1C,$E1,$18,$1C,$11,$EC
	.BYTE $EE,$E1,$60,$11,$16,$01,$1C,$11
	.BYTE $10,$10,$10,$11,$06,$01,$01,$01
	.BYTE $01,$01,$11,$10,$10,$11,$01,$01
	.BYTE $06,$01,$06,$01,$00,$10,$00,$60
	.BYTE $01,$01,$16,$61,$1C,$ED,$FD,$FC
	.BYTE $FD,$EF,$C7,$FD,$FD,$7D,$FD,$FF
	.BYTE $FD,$CD,$FD,$CD,$CF,$CD,$FC,$FD
	.BYTE $77,$77,$77,$77,$F7,$77,$77,$77
	.BYTE $F7,$77,$F7,$F7,$F7,$FF,$FF,$FF
	.BYTE $FF,$7F,$EF,$FE,$7F,$7F,$FE,$FE
	.BYTE $7F,$7F,$7F,$F6,$F7,$E7,$F7,$F7
	.BYTE $E7,$F6,$F7,$F6,$F7,$E7,$7F,$77
	.BYTE $7F,$77,$F7,$77,$F7,$F7,$FF,$FF
	.BYTE $DF,$FC,$CE,$8E,$9E,$11,$10,$00
	.BYTE $10,$11,$CC,$9C,$11,$11,$11,$01
	.BYTE $01,$1E,$11,$81,$C1,$11,$1C,$1C
	.BYTE $E1,$E1,$11,$10,$10,$10,$10,$10
	.BYTE $10,$11,$11,$06,$01,$06,$01,$10
	.BYTE $60,$11,$11,$11,$01,$06,$01,$06
	.BYTE $00,$11,$00,$10,$60,$10,$60,$01
	.BYTE $06,$01,$11,$11,$06,$CF,$CF,$CF
	.BYTE $CF,$7C,$FF,$C7,$FF,$DF,$CD,$CD
	.BYTE $CF,$DE,$DC,$FD,$FD,$CF,$DD,$CF
	.BYTE $7F,$7F,$7F,$77,$77,$77,$77,$77
	.BYTE $77,$77,$77,$7F,$7F,$7F,$FF,$F7
	.BYTE $FF,$7F,$7F,$7F,$FE,$F7,$F7,$F7
	.BYTE $FF,$FF,$F7,$FF,$E7,$F6,$FE,$7E
	.BYTE $7F,$7F,$6F,$7E,$7F,$7F,$67,$F6
	.BYTE $77,$77,$7E,$77,$FF,$FF,$77,$FF
	.BYTE $DF,$F9,$C9,$CE,$1E,$11,$11,$01
	.BYTE $10,$10,$1C,$C8,$C8,$11,$11,$01
	.BYTE $11,$11,$1E,$10,$11,$11,$18,$E1
	.BYTE $1C,$EE,$10,$06,$06,$01,$10,$11
	.BYTE $06,$01,$01,$00,$10,$10,$10,$10
	.BYTE $11,$01,$11,$10,$60,$10,$10,$10
	.BYTE $11,$01,$11,$10,$10,$10,$10,$10
	.BYTE $01,$01,$01,$16,$01,$C6,$C7,$CF
	.BYTE $CE,$DE,$7F,$DD,$FD,$CD,$FC,$FD
	.BYTE $FC,$DC,$FD,$CC,$FD,$DE,$DF,$CD
	.BYTE $77,$77,$77,$77,$77,$77,$F7,$7F
	.BYTE $77,$7F,$7F,$77,$77,$77,$F7,$FF
	.BYTE $FF,$FF,$EF,$F7,$F7,$FF,$FF,$EF
	.BYTE $7E,$76,$FE,$7F,$7F,$E7,$F7,$F7
	.BYTE $E7,$E7,$F7,$F7,$F7,$77,$F7,$77
	.BYTE $F6,$F7,$77,$FF,$FF,$7F,$FE,$FF
	.BYTE $DC,$EF,$E8,$C1,$E1,$10,$00,$11
	.BYTE $60,$01,$10,$1C,$11,$81,$10,$11
	.BYTE $01,$10,$11,$11,$11,$10,$11,$10
	.BYTE $11,$EC,$EE,$60,$01,$01,$01,$01
	.BYTE $00,$10,$60,$11,$01,$01,$06,$01
	.BYTE $01,$01,$01,$11,$01,$00,$10,$00
	.BYTE $00,$10,$00,$01,$06,$00,$00,$01
	.BYTE $00,$10,$11,$06,$01,$6F,$CF,$6C
	.BYTE $7C,$F6,$DE,$EC,$CF,$CF,$DD,$FC
	.BYTE $DF,$CF,$DC,$FD,$CC,$FD,$DF,$FD
	.BYTE $7F,$7F,$77,$77,$77,$F7,$77,$77
	.BYTE $F7,$77,$77,$77,$7F,$77,$77,$77
	.BYTE $F7,$77,$77,$F7,$FF,$7F,$7F,$7F
	.BYTE $FF,$F7,$7F,$7E,$7F,$7E,$7E,$7F
	.BYTE $7F,$7E,$7F,$67,$E7,$E7,$7E,$77
	.BYTE $77,$77,$F7,$7F,$FF,$FF,$7F,$FF
	.BYTE $D8,$EF,$C9,$11,$11,$10,$01,$06
	.BYTE $13,$00,$11,$01,$81,$11,$11,$11
	.BYTE $11,$11,$11,$11,$11,$11,$10,$11
	.BYTE $11,$1E,$EE,$11,$00,$00,$00,$01
	.BYTE $00,$00,$00,$01,$00,$10,$00,$10
	.BYTE $10,$01,$00,$00,$00,$10,$00,$60
	.BYTE $10,$01,$01,$00,$00,$06,$01,$00
	.BYTE $06,$00,$01,$01,$10,$11,$7C,$FE
	.BYTE $F7,$CE,$F4,$F7,$CF,$CC,$EC,$DE
	.BYTE $DC,$DC,$FC,$CF,$CC,$EC,$EC,$CF
	.BYTE $77,$F7,$7F,$77,$77,$77,$F7,$77
	.BYTE $77,$77,$7F,$77,$77,$7F,$7F,$77
	.BYTE $77,$7F,$7F,$7E,$77,$F7,$F7,$F7
	.BYTE $E7,$FF,$E7,$F7,$F7,$F7,$F7,$F6
	.BYTE $7F,$77,$77,$F7,$7F,$77,$F7,$77
	.BYTE $F7,$77,$77,$FF,$FF,$FF,$EF,$FF
	.BYTE $CE,$CF,$FF,$E1,$00,$01,$16,$60
	.BYTE $06,$01,$11,$10,$10,$C8,$11,$11
	.BYTE $11,$10,$11,$C1,$C0,$18,$11,$11
	.BYTE $C1,$EE,$10,$10,$10,$60,$60,$11
	.BYTE $61,$11,$11,$01,$06,$00,$10,$00
	.BYTE $06,$00,$10,$10,$60,$06,$00,$00
	.BYTE $10,$60,$00,$10,$10,$00,$00,$10
	.BYTE $00,$06,$00,$11,$10,$01,$E7,$C7
	.BYTE $CF,$E5,$FE,$CF,$CE,$CF,$CE,$CC
	.BYTE $FC,$EC,$CF,$CC,$FC,$DC,$CF,$CC
	.BYTE $77,$77,$77,$77,$77,$77,$77,$77
	.BYTE $F7,$F7,$77,$77,$F7,$77,$77,$77
	.BYTE $F7,$77,$77,$F7,$F7,$F7,$E7,$F7
	.BYTE $F7,$77,$F7,$7F,$7E,$7F,$77,$77
	.BYTE $77,$77,$77,$7E,$77,$E7,$7F,$77
	.BYTE $67,$F7,$F7,$FF,$F7,$FF,$7F,$FF
	.BYTE $C1,$CF,$FE,$61,$01,$66,$60,$61
	.BYTE $60,$31,$61,$11,$10,$10,$11,$11
	.BYTE $11,$1C,$18,$10,$11,$11,$00,$11
	.BYTE $11,$16,$06,$01,$00,$10,$01,$11
	.BYTE $16,$11,$60,$60,$00,$10,$00,$60
	.BYTE $00,$10,$00,$00,$00,$00,$10,$10
	.BYTE $00,$10,$10,$00,$60,$10,$10,$00
	.BYTE $00,$00,$10,$00,$61,$01,$CF,$CE
	.BYTE $7C,$FE,$5E,$7C,$7C,$7C,$CF,$CC
	.BYTE $FC,$CF,$C4,$FC,$EC,$7F,$CC,$FD
	.BYTE $77,$77,$F7,$F7,$F7,$77,$F7,$77
	.BYTE $77,$77,$F7,$F7,$77,$F7,$7F,$77
	.BYTE $77,$F7,$F7,$7F,$77,$F7,$F7,$7F
	.BYTE $7F,$F7,$7F,$77,$F7,$77,$7F,$77
	.BYTE $F7,$77,$77,$F7,$7F,$77,$77,$6F
	.BYTE $77,$77,$7F,$FF,$FF,$EF,$FF,$FD
	.BYTE $C9,$CE,$FF,$61,$00,$10,$16,$00
	.BYTE $66,$66,$01,$11,$01,$01,$11,$11
	.BYTE $11,$18,$10,$11,$80,$10,$11,$11
	.BYTE $16,$11,$63,$66,$01,$16,$06,$11
	.BYTE $11,$61,$1E,$16,$11,$06,$00,$00
	.BYTE $10,$06,$06,$00,$10,$10,$00,$60
	.BYTE $10,$01,$01,$00,$00,$10,$01,$01
	.BYTE $00,$01,$06,$00,$01,$01,$67,$FC
	.BYTE $F6,$CF,$EC,$FE,$FC,$FC,$FC,$CE
	.BYTE $CC,$FC,$EC,$F6,$CF,$CE,$7F,$CE
	.BYTE $77,$F7,$77,$77,$77,$77,$77,$F7
	.BYTE $7F,$77,$77,$7F,$77,$77,$77,$F7
	.BYTE $77,$77,$7F,$77,$F7,$F7,$7F,$7F
	.BYTE $77,$F7,$F7,$F7,$F7,$F7,$77,$77
	.BYTE $77,$7E,$77,$77,$77,$E7,$7F,$77
	.BYTE $77,$F7,$7F,$F7,$F7,$FE,$7F,$FF
	.BYTE $CC,$EC,$FE,$E6,$00,$10,$60,$61
	.BYTE $16,$63,$06,$06,$01,$01,$11,$11
	.BYTE $1C,$11,$18,$11,$11,$10,$01,$13
	.BYTE $03,$61,$63,$63,$61,$11,$01,$16
	.BYTE $10,$01,$01,$11,$16,$16,$16,$10
	.BYTE $60,$00,$01,$01,$00,$06,$00,$00
	.BYTE $00,$60,$00,$10,$10,$10,$60,$00
	.BYTE $10,$00,$00,$60,$01,$10,$C6,$F4
	.BYTE $FF,$4F,$7C,$7C,$7E,$7C,$CF,$CF
	.BYTE $CE,$4F,$7C,$FC,$7E,$7C,$C7,$CF
	.BYTE $7F,$77,$F7,$F7,$F7,$F7,$77,$7F
	.BYTE $77,$F7,$77,$77,$7F,$77,$F7,$77
	.BYTE $F7,$F7,$F7,$7F,$7F,$7F,$7F,$77
	.BYTE $F7,$7F,$77,$77,$77,$77,$E7,$77
	.BYTE $7F,$77,$77,$77,$77,$77,$77,$7F
	.BYTE $77,$7F,$FF,$FF,$FE,$7F,$EF,$FD
	.BYTE $FC,$8E,$EE,$61,$01,$00,$10,$61
	.BYTE $61,$16,$11,$03,$06,$06,$11,$1E
	.BYTE $C9,$1C,$11,$11,$01,$01,$11,$30
	.BYTE $60,$06,$36,$66,$66,$36,$11,$11
	.BYTE $16,$10,$10,$01,$00,$11,$11,$11
	.BYTE $16,$10,$00,$10,$10,$00,$01,$06
	.BYTE $00,$00,$60,$06,$00,$00,$00,$60
	.BYTE $00,$10,$10,$01,$06,$00,$EC,$EE
	.BYTE $4E,$FC,$EF,$CE,$CF,$C7,$CC,$CC
	.BYTE $CF,$CE,$C7,$EC,$FC,$FE,$FC,$7C
	.BYTE $7F,$77,$7F,$77,$77,$77,$F7,$77
	.BYTE $77,$7F,$7F,$77,$7F,$77,$77,$77
	.BYTE $77,$77,$7F,$77,$7F,$7F,$77,$F7
	.BYTE $F7,$E7,$F7,$F7,$F7,$F7,$77,$E7
	.BYTE $77,$77,$E7,$7F,$77,$F7,$77,$77
	.BYTE $7F,$77,$FF,$FF,$FF,$7F,$7F,$FF
	.BYTE $FE,$CC,$11,$16,$11,$06,$01,$0E
	.BYTE $66,$10,$60,$60,$00,$01,$EC,$EE
	.BYTE $EC,$91,$81,$C8,$10,$01,$31,$03
	.BYTE $03,$03,$13,$63,$66,$66,$16,$06
	.BYTE $11,$60,$60,$10,$10,$00,$01,$01
	.BYTE $11,$6E,$61,$60,$06,$01,$00,$00
	.BYTE $60,$10,$01,$00,$11,$11,$10,$00
	.BYTE $60,$00,$01,$00,$01,$10,$07,$CF
	.BYTE $6C,$7E,$47,$E7,$C6,$FE,$7C,$FC
	.BYTE $EC,$7E,$FC,$7C,$7C,$7C,$7C,$FE
	.BYTE $77,$77,$77,$77,$F7,$F7,$77,$7F
	.BYTE $77,$77,$77,$7F,$77,$7F,$7F,$7F
	.BYTE $7F,$7F,$77,$F7,$F7,$7F,$7F,$77
	.BYTE $F7,$F7,$77,$77,$77,$77,$77,$77
	.BYTE $77,$77,$77,$77,$77,$77,$F7,$7E
	.BYTE $7F,$FF,$FF,$7F,$FE,$FE,$F4,$FF
	.BYTE $DF,$FC,$11,$11,$01,$00,$11,$66
	.BYTE $16,$13,$01,$01,$06,$01,$1F,$CE
	.BYTE $CE,$E1,$C1,$81,$10,$11,$10,$10
	.BYTE $60,$30,$36,$36,$13,$00,$01,$11
	.BYTE $16,$11,$10,$10,$60,$11,$01,$01
	.BYTE $00,$01,$11,$16,$11,$10,$01,$00
	.BYTE $00,$00,$10,$06,$00,$00,$10,$10
	.BYTE $00,$10,$00,$60,$06,$00,$11,$6C
	.BYTE $F4,$EC,$FC,$E4,$FC,$6C,$EC,$CE
	.BYTE $CF,$CC,$EC,$EE,$C6,$CE,$EF,$4E
	.BYTE $F7,$7F,$77,$77,$77,$77,$77,$77
	.BYTE $7F,$77,$F7,$77,$F7,$77,$77,$77
	.BYTE $77,$77,$F7,$7F,$7F,$77,$F7,$F7
	.BYTE $77,$F7,$F7,$F7,$F7,$7F,$77,$F7
	.BYTE $7F,$77,$F7,$77,$F7,$77,$77,$7F
	.BYTE $7F,$7F,$FF,$FF,$7F,$7F,$F7,$FF
	.BYTE $DF,$DF,$DE,$11,$61,$10,$00,$11
	.BYTE $61,$01,$10,$10,$01,$00,$11,$FD
	.BYTE $E9,$C1,$9C,$E6,$10,$10,$33,$02
	.BYTE $60,$33,$26,$30,$60,$16,$00,$01
	.BYTE $11,$16,$16,$60,$10,$10,$10,$10
	.BYTE $10,$10,$01,$01,$06,$16,$16,$10
	.BYTE $10,$10,$00,$00,$10,$60,$10,$01
	.BYTE $00,$06,$00,$00,$01,$60,$11,$E4
	.BYTE $FE,$7C,$6F,$C6,$EC,$7C,$7E,$7C
	.BYTE $6C,$6C,$EC,$CC,$FC,$E4,$CE,$CC
	.BYTE $77,$F7,$7F,$7F,$77,$77,$F7,$77
	.BYTE $77,$77,$77,$F7,$77,$F7,$F7,$F7
	.BYTE $F7,$F7,$7F,$77,$F7,$F7,$77,$F7
	.BYTE $F7,$77,$77,$77,$77,$77,$77,$77
	.BYTE $77,$77,$77,$F7,$77,$7E,$77,$FF
	.BYTE $7F,$FF,$7F,$7F,$FE,$F6,$FE,$FF
	.BYTE $FF,$DD,$DD,$E1,$11,$61,$01,$66
	.BYTE $11,$01,$00,$10,$11,$10,$11,$0E
	.BYTE $EC,$E9,$E1,$11,$01,$11,$31,$30
	.BYTE $33,$36,$61,$00,$01,$61,$66,$01
	.BYTE $11,$61,$11,$16,$16,$16,$06,$01
	.BYTE $06,$00,$60,$01,$00,$01,$01,$16
	.BYTE $11,$00,$60,$00,$10,$00,$10,$10
	.BYTE $10,$10,$00,$10,$10,$10,$61,$1E
	.BYTE $4E,$C7,$C6,$CF,$4F,$EE,$CE,$C6
	.BYTE $FC,$EC,$7C,$EC,$CC,$EC,$EC,$E4
	.BYTE $77,$77,$77,$77,$77,$77,$77,$F7
	.BYTE $7F,$7F,$77,$7F,$77,$77,$77,$77
	.BYTE $7F,$7F,$77,$F7,$77,$F7,$F7,$77
	.BYTE $77,$F7,$F7,$F7,$7F,$77,$F7,$7F
	.BYTE $77,$F7,$77,$77,$F7,$77,$77,$7F
	.BYTE $F7,$FF,$FF,$EF,$7F,$7F,$E7,$FF
	.BYTE $FF,$EF,$CD,$DC,$E1,$16,$30,$11
	.BYTE $61,$01,$11,$01,$60,$11,$11,$01
	.BYTE $01,$11,$60,$31,$11,$10,$33,$33
	.BYTE $02,$63,$06,$16,$61,$10,$11,$60
	.BYTE $01,$06,$16,$10,$61,$06,$06,$16
	.BYTE $01,$10,$06,$01,$10,$10,$10,$00
	.BYTE $06,$10,$06,$00,$00,$60,$06,$00
	.BYTE $10,$01,$01,$00,$00,$10,$11,$1E
	.BYTE $C7,$CE,$FC,$6E,$C6,$C6,$F4,$EC
	.BYTE $6C,$6C,$EC,$EC,$EC,$EC,$CC,$EC
	.BYTE $77,$77,$F7,$F7,$F7,$77,$77,$77
	.BYTE $77,$77,$7F,$77,$7F,$7F,$7F,$F7
	.BYTE $F7,$7F,$7F,$7F,$7F,$77,$7F,$7F
	.BYTE $7F,$77,$77,$77,$77,$77,$77,$77
	.BYTE $77,$77,$F7,$77,$77,$F7,$F7,$FF
	.BYTE $7F,$F7,$FF,$7F,$EF,$E7,$FE,$7F
	.BYTE $FF,$FE,$EE,$EE,$E6,$16,$11,$11
	.BYTE $10,$E1,$11,$61,$06,$06,$11,$10
	.BYTE $10,$01,$01,$11,$C9,$16,$63,$03
	.BYTE $36,$00,$61,$61,$66,$10,$10,$06
	.BYTE $01,$01,$11,$61,$06,$11,$11,$06
	.BYTE $16,$16,$01,$01,$06,$01,$06,$01
	.BYTE $00,$01,$00,$01,$00,$00,$00,$06
	.BYTE $00,$10,$01,$06,$00,$10,$01,$61
	.BYTE $EE,$4E,$4E,$F7,$FC,$7C,$EE,$C7
	.BYTE $EE,$C7,$C6,$C6,$CC,$CE,$CE,$CE
	.BYTE $77,$7F,$77,$77,$77,$F7,$77,$F7
	.BYTE $7F,$7F,$77,$F7,$77,$7F,$77,$F7
	.BYTE $F7,$F7,$F7,$F7,$77,$7F,$77,$77
	.BYTE $77,$F7,$F7,$F7,$F7,$7F,$77,$F7
	.BYTE $7F,$77,$77,$7F,$77,$77,$7F,$7F
	.BYTE $FF,$F7,$FF,$EF,$7F,$7F,$7F,$FF
	.BYTE $FF,$EE,$F6,$E6,$E6,$EC,$E6,$10
	.BYTE $11,$1E,$11,$11,$13,$03,$11,$10
	.BYTE $10,$10,$00,$11,$CE,$16,$76,$60
	.BYTE $33,$06,$16,$61,$61,$60,$11,$16
	.BYTE $01,$10,$11,$61,$61,$66,$16,$06
	.BYTE $01,$06,$16,$16,$06,$01,$00,$10
	.BYTE $60,$10,$06,$00,$00,$10,$10,$01
	.BYTE $00,$60,$10,$01,$01,$06,$00,$01
	.BYTE $4E,$FE,$F4,$EC,$FF,$EF,$4F,$C7
	.BYTE $C6,$EC,$E7,$CE,$EE,$CC,$EC,$CC
	.BYTE $F7,$77,$7F,$77,$77,$77,$F7,$77
	.BYTE $77,$77,$F7,$7F,$7F,$77,$F7,$77
	.BYTE $F7,$F7,$F7,$7F,$7F,$77,$7F,$7F
	.BYTE $77,$77,$77,$77,$77,$77,$77,$77
	.BYTE $77,$7F,$77,$F7,$7F,$7F,$77,$FF
	.BYTE $FF,$FE,$F7,$F7,$EF,$67,$E7,$7F
	.BYTE $FF,$76,$EF,$6E,$6E,$EC,$CE,$01
	.BYTE $11,$01,$11,$63,$60,$61,$11,$01
	.BYTE $01,$01,$03,$01,$E8,$16,$76,$73
	.BYTE $36,$06,$16,$16,$10,$01,$01,$01
	.BYTE $61,$06,$06,$11,$61,$11,$61,$11
	.BYTE $61,$11,$10,$60,$61,$61,$61,$10
	.BYTE $01,$01,$00,$06,$00,$00,$00,$00
	.BYTE $01,$00,$01,$01,$00,$00,$10,$11
	.BYTE $7C,$7C,$EC,$7E,$4F,$4F,$EE,$6C
	.BYTE $FF,$4F,$EC,$F4,$EC,$EC,$CE,$C1
	.BYTE $77,$77,$77,$F7,$F7,$77,$7F,$7F
	.BYTE $F7,$F7,$77,$77,$77,$77,$F7,$F7
	.BYTE $F7,$F7,$7F,$7F,$7F,$7F,$77,$77
	.BYTE $F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7
	.BYTE $F7,$77,$77,$77,$7F,$77,$F7,$FF
	.BYTE $7F,$F7,$FF,$EF,$7F,$FF,$7E,$FF
	.BYTE $FF,$7E,$6E,$6E,$E6,$FE,$E1,$61
	.BYTE $66,$36,$31,$66,$13,$61,$11,$10
	.BYTE $10,$10,$00,$31,$CE,$16,$77,$76
	.BYTE $26,$06,$16,$16,$06,$36,$01,$60
	.BYTE $11,$61,$01,$11,$66,$61,$66,$61
	.BYTE $66,$61,$61,$61,$16,$16,$16,$66
	.BYTE $61,$60,$11,$00,$06,$06,$06,$06
	.BYTE $00,$10,$10,$01,$06,$01,$01,$00
	.BYTE $E1,$11,$6E,$FC,$FE,$F5,$FC,$F6
	.BYTE $DE,$FC,$7F,$FC,$FC,$6E,$CE,$CC
	.BYTE $77,$7F,$77,$77,$F7,$77,$F7,$77
	.BYTE $7F,$77,$F7,$F7,$F7,$F7,$77,$F7
	.BYTE $F7,$FF,$7F,$77,$F7,$77,$F7,$F7
	.BYTE $77,$77,$77,$77,$77,$77,$77,$77
	.BYTE $77,$F7,$F7,$7F,$77,$F7,$7F,$FF
	.BYTE $FF,$FF,$F7,$FE,$F6,$77,$EF,$FF
	.BYTE $FF,$76,$E6,$EE,$61,$16,$16,$66
	.BYTE $66,$11,$61,$63,$66,$31,$11,$10
	.BYTE $10,$01,$10,$01,$31,$1E,$67,$77
	.BYTE $11,$6E,$6E,$11,$10,$01,$06,$01
	.BYTE $63,$61,$11,$61,$61,$66,$16,$16
	.BYTE $16,$16,$11,$16,$16,$16,$16,$16
	.BYTE $16,$66,$6E,$11,$00,$10,$10,$01
	.BYTE $06,$01,$06,$01,$00,$10,$10,$10
	.BYTE $10,$11,$11,$6E,$C7,$CF,$E5,$FC
	.BYTE $F4,$FE,$CF,$4F,$6D,$CC,$EC,$CE
	.BYTE $7F,$77,$FF,$77,$77,$F7,$F7,$F7
	.BYTE $7F,$77,$77,$77,$77,$F7,$F7,$F7
	.BYTE $F7,$77,$F7,$F7,$F7,$F7,$77,$77
	.BYTE $7F,$7F,$7F,$7F,$7F,$77,$F7,$7F
	.BYTE $77,$77,$7F,$77,$7F,$7F,$7F,$7F
	.BYTE $7F,$7F,$EF,$7F,$7F,$F7,$FF,$FF
	.BYTE $FF,$76,$63,$EF,$16,$66,$E7,$66
	.BYTE $16,$62,$63,$61,$66,$13,$11,$01
	.BYTE $01,$00,$60,$10,$01,$01,$36,$77
	.BYTE $16,$EE,$16,$66,$61,$66,$61,$60
	.BYTE $60,$16,$60,$11,$E6,$E6,$E6,$61
	.BYTE $61,$61,$66,$61,$61,$61,$61,$6E
	.BYTE $61,$EE,$EF,$7F,$F6,$10,$11,$01
	.BYTE $00,$10,$10,$10,$60,$10,$60,$10
	.BYTE $60,$11,$01,$16,$EF,$ED,$EF,$6F
	.BYTE $EF,$C7,$DE,$FC,$FC,$FC,$FC,$CE
	.BYTE $F7,$F7,$77,$F7,$7F,$77,$77,$7F
	.BYTE $77,$F7,$F7,$F7,$F7,$77,$7F,$7F
	.BYTE $F7,$F7,$F7,$77,$77,$77,$F7,$7F
	.BYTE $77,$77,$77,$77,$77,$F7,$7F,$77
	.BYTE $F7,$F7,$77,$F7,$7F,$77,$FF,$FF
	.BYTE $FF,$FF,$7F,$F7,$E7,$EF,$7F,$FF
	.BYTE $FF,$77,$31,$6F,$E1,$67,$7F,$77
	.BYTE $66,$36,$36,$13,$13,$06,$11,$11
	.BYTE $10,$10,$10,$10,$10,$06,$06,$77
	.BYTE $6E,$7E,$6E,$E7,$11,$EE,$10,$16
	.BYTE $11,$61,$60,$61,$6E,$F6,$E6,$E6
	.BYTE $61,$61,$11,$16,$16,$16,$1E,$16
	.BYTE $16,$E6,$FF,$FF,$FF,$F7,$E6,$11
	.BYTE $06,$00,$10,$10,$10,$10,$01,$01
	.BYTE $06,$16,$E4,$FD,$F4,$F7,$CF,$CF
	.BYTE $4F,$FC,$7F,$C7,$EC,$FC,$CE,$CC
	.BYTE $7F,$77,$F7,$7F,$7F,$7F,$77,$7F
	.BYTE $77,$F7,$77,$77,$F7,$F7,$F7,$F7
	.BYTE $F7,$F7,$7F,$7F,$7F,$77,$F7,$77
	.BYTE $F7,$F7,$F7,$F7,$F7,$77,$77,$77
	.BYTE $77,$7F,$77,$7F,$77,$F7,$F7,$F7
	.BYTE $F7,$FF,$FF,$7F,$7F,$7F,$77,$FF
	.BYTE $FF,$76,$30,$1F,$FE,$77,$7F,$F7
	.BYTE $76,$61,$13,$63,$66,$13,$E1,$01
	.BYTE $10,$11,$01,$06,$01,$01,$00,$67
	.BYTE $6E,$61,$6E,$6E,$FE,$16,$03,$01
	.BYTE $11,$63,$60,$11,$1E,$7F,$6E,$6E
	.BYTE $61,$66,$61,$61,$6E,$61,$61,$61
	.BYTE $E6,$EE,$7F,$FF,$7F,$FF,$FF,$F7
	.BYTE $EF,$F7,$E7,$6E,$66,$6E,$66,$F6
	.BYTE $FE,$FD,$FE,$7C,$FF,$CF,$C7,$DE
	.BYTE $F4,$FC,$7C,$FC,$F4,$FC,$CE,$CC
	.BYTE $7F,$F7,$F7,$FF,$7F,$F7,$F7,$77
	.BYTE $F7,$7F,$7F,$F7,$F7,$F7,$F7,$F7
	.BYTE $7F,$7F,$7F,$77,$77,$77,$77,$F7
	.BYTE $7F,$77,$7F,$77,$7F,$7F,$7F,$7F
	.BYTE $7F,$77,$F7,$F7,$F7,$F7,$FF,$7F
	.BYTE $7F,$7F,$77,$77,$77,$77,$F7,$FF
	.BYTE $76,$E6,$63,$6E,$FE,$FF,$7F,$77
	.BYTE $77,$36,$36,$06,$63,$16,$11,$11
	.BYTE $11,$10,$16,$03,$06,$00,$10,$16
	.BYTE $EE,$FE,$6E,$CD,$C1,$10,$16,$06
	.BYTE $01,$16,$10,$16,$1E,$F7,$F7,$F6
	.BYTE $E6,$E6,$E6,$16,$11,$6E,$61,$61
	.BYTE $6E,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$F7,$FF,$FF,$FC,$FC
	.BYTE $7C,$7E,$FC,$F7,$CF,$7F,$EF,$6D
	.BYTE $EF,$EF,$FC,$FC,$CF,$CD,$CC,$CE
	.BYTE $7F,$7F,$F7,$FF,$7F,$7F,$7F,$7F
	.BYTE $7F,$77,$F7,$77,$F7,$77,$F7,$F7
	.BYTE $F7,$77,$F7,$7F,$7F,$7F,$7F,$7F
	.BYTE $77,$F7,$7F,$7F,$77,$F7,$7F,$77
	.BYTE $7F,$77,$F7,$77,$77,$FF,$7F,$7F
	.BYTE $F7,$F7,$F7,$F7,$7F,$77,$7F,$FF
	.BYTE $6E,$11,$61,$1E,$FF,$EF,$7F,$F6
	.BYTE $77,$66,$63,$EE,$61,$31,$E1,$11
	.BYTE $10,$11,$11,$10,$01,$00,$10,$00
	.BYTE $06,$F1,$FF,$E9,$11,$10,$00,$11
	.BYTE $60,$16,$10,$01,$61,$FF,$F6,$F7
	.BYTE $F7,$E6,$E6,$E6,$61,$61,$61,$6E
	.BYTE $EF,$FF,$F7,$FF,$FF,$7F,$7F,$F7
	.BYTE $FF,$7F,$E7,$EE,$7E,$6C,$F7,$EF
	.BYTE $FD,$FC,$7F,$CF,$FC,$E5,$FC,$F7
	.BYTE $C7,$C7,$CF,$CC,$CF,$CC,$FC,$CC
	.BYTE $7F,$FF,$FF,$F7,$F7,$77,$F7,$77
	.BYTE $F7,$F7,$7F,$77,$7F,$7F,$7F,$7F
	.BYTE $7F,$F7,$7F,$77,$7F,$77,$F7,$F7
	.BYTE $7F,$7F,$77,$7F,$7F,$77,$F7,$7F
	.BYTE $77,$7F,$7F,$7F,$F7,$F7,$F7,$F7
	.BYTE $F7,$F7,$77,$77,$F7,$7F,$7F,$77
	.BYTE $EE,$13,$11,$11,$EF,$EF,$FF,$F7
	.BYTE $77,$77,$76,$73,$63,$61,$E1,$10
	.BYTE $11,$01,$01,$00,$10,$01,$00,$10
	.BYTE $10,$1F,$DF,$CC,$11,$11,$16,$06
	.BYTE $60,$61,$01,$11,$16,$FF,$FF,$6F
	.BYTE $6F,$6F,$7E,$6E,$E6,$E6,$EE,$FF
	.BYTE $F7,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$7F,$F7,$E4,$FE,$4F,$C7
	.BYTE $C7,$EF,$C7,$F4,$F7,$DE,$F4,$FC
	.BYTE $FC,$FC,$CD,$CF,$CC,$CC,$CC,$FC
	.BYTE $7F,$F7,$F7,$F7,$F7,$F7,$F7,$F7
	.BYTE $77,$7F,$77,$F7,$F7,$7F,$7F,$7F
	.BYTE $77,$7F,$77,$F7,$7F,$F7,$F7,$F7
	.BYTE $F7,$7F,$7F,$77,$7F,$77,$7F,$77
	.BYTE $7F,$77,$7F,$77,$7F,$77,$F7,$F7
	.BYTE $F7,$7F,$7F,$77,$77,$77,$FF,$6E
	.BYTE $16,$13,$16,$01,$EF,$FF,$FF,$FF
	.BYTE $FF,$67,$76,$76,$16,$1E,$11,$11
	.BYTE $10,$60,$10,$10,$60,$00,$10,$00
	.BYTE $11,$EF,$EE,$EE,$11,$01,$01,$21
	.BYTE $16,$16,$10,$01,$16,$EF,$FF,$FF
	.BYTE $7E,$7E,$6F,$76,$E6,$E6,$F7,$FF
	.BYTE $FF,$FF,$FF,$F5,$FF,$FF,$F7,$E7
	.BYTE $E7,$DE,$F7,$EF,$7F,$FF,$FF,$FE
	.BYTE $FF,$5E,$FC,$EF,$CF,$CF,$CF,$6F
	.BYTE $CC,$FC,$FC,$DC,$DC,$FC,$CC,$CC
	.BYTE $FF,$FF,$FF,$7F,$7F,$77,$7F,$77
	.BYTE $F7,$F7,$F7,$7F,$7F,$77,$F7,$F7
	.BYTE $F7,$F7,$7F,$7F,$F7,$7F,$77,$7F
	.BYTE $77,$F7,$77,$F7,$77,$F7,$F7,$7F
	.BYTE $77,$F7,$7F,$7F,$77,$F7,$7F,$77
	.BYTE $F7,$77,$77,$77,$F7,$77,$FE,$E6
	.BYTE $11,$10,$63,$10,$EE,$FE,$FF,$F7
	.BYTE $7F,$77,$67,$EF,$61,$E1,$11,$12
	.BYTE $01,$00,$10,$10,$00,$10,$01,$06
	.BYTE $00,$FF,$EC,$E8,$11,$11,$10,$60
	.BYTE $61,$16,$06,$01,$11,$E7,$FF,$FF
	.BYTE $FF,$F7,$F6,$E7,$EF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF
	.BYTE $7F,$F7,$FE,$7F,$CF,$4F,$C7,$FD
	.BYTE $FF,$FD,$CD,$CD,$CC,$DC,$DC,$DC
	.BYTE $FC,$EC,$CC,$EC,$CC,$DC,$FC,$CE
	.BYTE $F7,$F7,$F7,$F7,$FF,$7F,$77,$F7
	.BYTE $F7,$F7,$7F,$77,$F7,$F7,$7F,$77
	.BYTE $F7,$7F,$7F,$77,$F7,$F7,$F7,$7F
	.BYTE $77,$F7,$F7,$7F,$7F,$77,$F7,$7F
	.BYTE $77,$F7,$7F,$7F,$7F,$7F,$77,$F7
	.BYTE $77,$F7,$7F,$77,$7F,$77,$7E,$11
	.BYTE $61,$61,$01,$10,$6E,$FF,$EF,$FF
	.BYTE $7F,$F7,$37,$6F,$11,$11,$11,$11
	.BYTE $01,$01,$01,$01,$00,$01,$00,$00
	.BYTE $61,$DF,$FE,$E1,$11,$10,$60,$31
	.BYTE $16,$16,$00,$11,$16,$EF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$FF,$FF,$FF
	.BYTE $FF,$FF,$F7,$F7,$F7,$D7,$FE,$7E
	.BYTE $F6,$FE,$7F,$E7,$FF,$EF,$CF,$FE
	.BYTE $FF,$FF,$FF,$FC,$DF,$CC,$FC,$CC
	.BYTE $CC,$EC,$EC,$CC,$FC,$CC,$CC,$DC
	.BYTE $7F,$7F,$FF,$F7,$F7,$F7,$F7,$77
	.BYTE $77,$FF,$7F,$7F,$77,$F7,$F7,$F7
	.BYTE $F7,$F7,$F7,$F7,$77,$7F,$7F,$77
	.BYTE $F7,$77,$F7,$F7,$7F,$7F,$77,$F7
	.BYTE $7F,$77,$F7,$7F,$77,$F7,$F7,$77
	.BYTE $F7,$77,$77,$77,$77,$77,$6E,$6E
	.BYTE $61,$11,$13,$01,$11,$ED,$FE,$FF
	.BYTE $77,$F7,$76,$E1,$11,$11,$11,$11
	.BYTE $10,$10,$10,$06,$00,$10,$01,$00
	.BYTE $16,$FF,$DE,$11,$11,$10,$10,$60
	.BYTE $61,$61,$11,$60,$61,$EF,$F7,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF
	.BYTE $FF,$FF,$DF,$FE,$7F,$EF,$7F,$7F
	.BYTE $7E,$7F,$6F,$DF,$F4,$E7,$C7,$C7
	.BYTE $C7,$CE,$4F,$CC,$CC,$CC,$CE,$EE
	.BYTE $6E,$CE,$CE,$EC,$CD,$CD,$CF,$CF
	.BYTE $7F,$F7,$FF,$FF,$F7,$77,$F7,$FF
	.BYTE $F7,$F7,$F7,$7F,$7F,$77,$F7,$F7
	.BYTE $F7,$F7,$F7,$7F,$7F,$77,$77,$F7
	.BYTE $F7,$F7,$77,$7F,$77,$77,$F7,$7F
	.BYTE $77,$F7,$7F,$77,$F7,$77,$77,$F7
	.BYTE $77,$F7,$F7,$F7,$7F,$7F,$6F,$FE
	.BYTE $E6,$61,$61,$10,$11,$1F,$DE,$E7
	.BYTE $F7,$76,$EE,$E1,$10,$11,$10,$10
	.BYTE $10,$10,$10,$00,$00,$10,$01,$01
	.BYTE $0E,$FF,$E1,$11,$11,$60,$31,$06
	.BYTE $01,$66,$00,$11,$11,$6F,$FF,$7F
	.BYTE $FF,$7F,$FF,$FF,$F7,$FF,$FF,$F7
	.BYTE $F5,$FF,$7F,$DF,$6F,$7E,$FE,$7E
	.BYTE $F7,$E7,$E7,$FF,$FC,$FE,$FE,$CF
	.BYTE $CE,$7C,$FC,$EF,$EC,$EC,$CC,$EC
	.BYTE $C6,$C6,$EC,$DC,$CC,$FC,$CC,$CE
	.BYTE $FF,$FF,$FF,$77,$7F,$F7,$F7,$F7
	.BYTE $F7,$7F,$F7,$F7,$F7,$F7,$FF,$7F
	.BYTE $7F,$77,$F7,$F7,$7F,$7F,$7F,$77
	.BYTE $F7,$7F,$7F,$77,$FF,$7F,$7F,$77
	.BYTE $F7,$7F,$77,$F7,$7F,$7F,$77,$7F
	.BYTE $77,$77,$77,$77,$77,$77,$FF,$6E
	.BYTE $EE,$10,$60,$10,$60,$6E,$DF,$CE
	.BYTE $FF,$FE,$E1,$11,$11,$11,$61,$36
	.BYTE $06,$01,$10,$10,$10,$01,$00,$01
	.BYTE $1F,$FC,$EC,$11,$11,$00,$06,$01
	.BYTE $16,$10,$10,$61,$61,$1F,$FF,$FF
	.BYTE $FF,$FF,$7F,$FF,$FF,$FF,$FF,$F7
	.BYTE $FF,$EF,$FF,$7F,$FE,$7F,$7F,$E7
	.BYTE $F6,$F7,$FF,$CF,$4F,$6D,$6C,$7C
	.BYTE $7C,$F4,$E4,$FC,$CC,$EC,$E6,$C6
	.BYTE $EC,$6C,$1C,$ED,$CC,$CC,$FF,$E6
	.BYTE $FF,$FF,$7F,$F7,$F7,$F7,$F7,$F7
	.BYTE $7F,$F7,$F7,$F7,$F7,$F7,$F7,$F7
	.BYTE $77,$F7,$77,$7F,$77,$77,$7F,$77
	.BYTE $F7,$F7,$F7,$F7,$77,$F7,$7F,$7F
	.BYTE $7F,$7F,$77,$F7,$F7,$77,$F7,$77
	.BYTE $F7,$7F,$77,$F7,$7F,$77,$7C,$6C
	.BYTE $EE,$C1,$01,$10,$10,$11,$ED,$FC
	.BYTE $C1,$1C,$1E,$11,$66,$66,$60,$03
	.BYTE $02,$60,$10,$10,$10,$01,$01,$00
	.BYTE $6F,$FE,$EC,$11,$10,$10,$11,$61
	.BYTE $16,$60,$10,$11,$16,$17,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$FE
	.BYTE $7F,$7F,$EF,$F7,$FF,$6F,$6F,$7E
	.BYTE $7F,$E6,$7F,$FF,$EC,$FF,$7C,$EE
	.BYTE $C6,$CF,$EE,$4F,$EE,$CC,$E4,$EC
	.BYTE $6C,$EE,$CD,$CF,$CC,$CC,$EC,$C6
	.BYTE $FF,$7F,$F7,$F7,$F7,$FF,$7F,$F7
	.BYTE $F7,$7F,$F7,$F7,$77,$77,$7F,$77
	.BYTE $F7,$77,$F7,$77,$F7,$F7,$77,$F7
	.BYTE $77,$77,$7F,$7F,$7F,$7F,$7F,$77
	.BYTE $F7,$77,$F7,$77,$7F,$7F,$77,$F7
	.BYTE $77,$77,$77,$77,$77,$7F,$66,$EF
	.BYTE $CF,$C9,$E1,$01,$11,$10,$6E,$FD
	.BYTE $1E,$11,$16,$63,$6E,$36,$36,$60
	.BYTE $60,$30,$63,$01,$01,$00,$60,$16
	.BYTE $EF,$CC,$9E,$11,$01,$16,$06,$01
	.BYTE $61,$01,$06,$16,$11,$6F,$FF,$F7
	.BYTE $FF,$F7,$FF,$F7,$FF,$7F,$FF,$7F
	.BYTE $E7,$FF,$FF,$CF,$F7,$FE,$7E,$7E
	.BYTE $7E,$7F,$EF,$FC,$7C,$7C,$EC,$7C
	.BYTE $6E,$C6,$C7,$CE,$4E,$C6,$CF,$4E
	.BYTE $1C,$6C,$CC,$CC,$FF,$FE,$C7,$EC
	.BYTE $7F,$FF,$7F,$7F,$7F,$7F,$7F,$7F
	.BYTE $F7,$F7,$F7,$F7,$F7,$F7,$7F,$77
	.BYTE $7F,$77,$7F,$77,$7F,$7F,$77,$7F
	.BYTE $7F,$F7,$F7,$77,$F7,$7F,$77,$F7
	.BYTE $F7,$F7,$7F,$7F,$77,$77,$F7,$77
	.BYTE $7F,$7F,$77,$F7,$F7,$77,$67,$7E
	.BYTE $FF,$C1,$11,$06,$02,$11,$1E,$FC
	.BYTE $CC,$16,$E6,$76,$67,$66,$61,$63
	.BYTE $06,$30,$60,$36,$06,$10,$10,$1E
	.BYTE $FF,$E1,$C1,$01,$00,$06,$11,$61
	.BYTE $66,$11,$00,$11,$61,$1F,$FF,$FF
	.BYTE $FF,$FF,$FF,$F7,$FF,$EF,$7F,$E7
	.BYTE $FE,$7F,$FF,$FF,$FC,$FF,$7E,$F7
	.BYTE $F7,$E7,$7F,$FF,$EE,$FD,$6C,$FC
	.BYTE $6C,$F4,$EC,$EE,$C6,$CE,$EC,$EC
	.BYTE $6C,$1E,$EC,$FC,$EC,$7C,$E6,$61
	.BYTE $FF,$7F,$FF,$77,$F7,$F7,$F7,$F7
	.BYTE $F7,$F7,$F7,$7F,$77,$F7,$77,$F7
	.BYTE $77,$7F,$77,$7F,$77,$F7,$F7,$F7
	.BYTE $77,$F7,$7F,$F7,$F7,$F7,$F7,$77
	.BYTE $F7,$7F,$77,$F7,$7F,$77,$77,$F7
	.BYTE $F7,$77,$77,$77,$77,$F7,$7F,$FF
	.BYTE $FF,$C1,$11,$11,$11,$06,$1E,$DE
	.BYTE $11,$11,$16,$7F,$66,$63,$61,$06
	.BYTE $30,$63,$06,$06,$20,$36,$36,$6E
	.BYTE $FD,$9C,$10,$10,$10,$60,$16,$16
	.BYTE $00,$01,$11,$61,$16,$1F,$FF,$FF
	.BYTE $F7,$FF,$7F,$FF,$7F,$7F,$EF,$7E
	.BYTE $7F,$6F,$FF,$FF,$F7,$F7,$F7,$E7
	.BYTE $E7,$E7,$ED,$6C,$4E,$6E,$C6,$EC
	.BYTE $6C,$EE,$4E,$4E,$6C,$E4,$E4,$E4
	.BYTE $E6,$CC,$EC,$DF,$EC,$F4,$16,$16
	.BYTE $FF,$77,$7F,$F7,$77,$7F,$7F,$7F
	.BYTE $F7,$F7,$F7,$7F,$77,$F7,$F7,$7F
	.BYTE $7F,$77,$7F,$7F,$F7,$7F,$7F,$7F
	.BYTE $7F,$7F,$7F,$77,$F7,$F7,$F7,$F7
	.BYTE $7F,$77,$F7,$7F,$77,$F7,$F7,$77
	.BYTE $77,$7F,$7F,$7F,$77,$77,$77,$7F
	.BYTE $FF,$FE,$01,$11,$62,$11,$7C,$FD
	.BYTE $E1,$11,$1E,$7F,$7F,$76,$61,$61
	.BYTE $60,$06,$30,$10,$60,$60,$36,$EF
	.BYTE $FE,$E1,$10,$36,$01,$61,$11,$11
	.BYTE $01,$06,$00,$11,$61,$6F,$FF,$FF
	.BYTE $FF,$7F,$FE,$7F,$E7,$FF,$FF,$F7
	.BYTE $E7,$F7,$7F,$FF,$FF,$FC,$F7,$FE
	.BYTE $7C,$FF,$7C,$FE,$7C,$CE,$E4,$EC
	.BYTE $6E,$4E,$E4,$1C,$6C,$6C,$EE,$CE
	.BYTE $C1,$6C,$FE,$CE,$4E,$66,$16,$41
	.BYTE $7F,$7F,$77,$F7,$FF,$F7,$FF,$7F
	.BYTE $7F,$7F,$7F,$7F,$F7,$7F,$77,$F7
	.BYTE $77,$F7,$F7,$77,$F7,$F7,$77,$F7
	.BYTE $F7,$F7,$77,$FF,$7F,$77,$7F,$7F
	.BYTE $7F,$7F,$77,$F7,$77,$77,$77,$F7
	.BYTE $F7,$F7,$77,$77,$7F,$77,$F7,$FE
	.BYTE $EF,$C1,$10,$16,$06,$16,$7E,$FF
	.BYTE $1E,$01,$11,$7F,$67,$F7,$63,$63
	.BYTE $63,$60,$06,$36,$03,$60,$61,$FF
	.BYTE $DE,$CE,$11,$01,$61,$06,$11,$01
	.BYTE $01,$00,$11,$61,$16,$1F,$FF,$FF
	.BYTE $7F,$FF,$F7,$FE,$7F,$6F,$76,$7E
	.BYTE $7F,$6F,$FF,$FF,$FF,$F7,$FE,$7F
	.BYTE $FF,$FC,$E7,$CE,$C7,$E4,$FC,$E6
	.BYTE $CE,$C6,$CE,$C6,$EC,$E6,$C6,$C6
	.BYTE $C6,$C6,$CE,$4E,$CE,$14,$16,$14
	.BYTE $FF,$FF,$F7,$F7,$FF,$7F,$7F,$7F
	.BYTE $7F,$F7,$FF,$77,$F7,$77,$F7,$77
	.BYTE $F7,$77,$F7,$F7,$7F,$7F,$7F,$77
	.BYTE $F7,$F7,$F7,$F7,$F7,$F7,$F7,$77
	.BYTE $F7,$7F,$77,$F7,$F7,$F7,$F7,$7F
	.BYTE $77,$77,$77,$F7,$7F,$77,$77,$FF
	.BYTE $FE,$11,$11,$01,$10,$11,$7F,$FC
	.BYTE $6F,$E1,$11,$E6,$E6,$E7,$66,$61
	.BYTE $60,$63,$60,$00,$60,$63,$6E,$FC
	.BYTE $E9,$E1,$10,$30,$61,$16,$01,$11
	.BYTE $01,$06,$00,$11,$6E,$7F,$FF,$FF
	.BYTE $E7,$6F,$F7,$F7,$EF,$7E,$F7,$F7
	.BYTE $E7,$E7,$F7,$FF,$FF,$FF,$F7,$FF
	.BYTE $CF,$7F,$CF,$FF,$FF,$FE,$7C,$FE
	.BYTE $C6,$CE,$CE,$CE,$4E,$CC,$EC,$EC
	.BYTE $EC,$EC,$6C,$E4,$E4,$CE,$4C,$16
	.BYTE $F7,$F7,$FF,$FF,$F7,$FF,$FF,$FF
	.BYTE $7F,$7F,$7F,$7F,$77,$F7,$7F,$77
	.BYTE $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
	.BYTE $7F,$7F,$77,$7F,$7F,$77,$F7,$F7
	.BYTE $7F,$77,$F7,$77,$F7,$77,$7F,$77
	.BYTE $7F,$7F,$7F,$77,$77,$7F,$7F,$FF
	.BYTE $DF,$11,$10,$30,$31,$31,$7F,$FE
	.BYTE $7F,$F7,$11,$E6,$E1,$66,$76,$16
	.BYTE $11,$60,$60,$61,$13,$60,$6F,$FE
	.BYTE $EC,$CE,$01,$06,$06,$10,$00,$10
	.BYTE $11,$01,$06,$16,$6E,$ED,$7F,$F7
	.BYTE $FF,$E7,$EF,$6F,$7F,$F7,$E7,$E7
	.BYTE $E7,$F6,$F7,$FD,$7F,$D7,$FC,$FF
	.BYTE $7F,$FF,$F7,$CF,$CF,$CF,$FE,$5E
	.BYTE $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
	.BYTE $CC,$CC,$EC,$CC,$EC,$EC,$EE,$46
	.BYTE $FF,$7F,$FF,$FF,$FF,$F7,$F7,$7F
	.BYTE $F7,$FF,$F7,$F7,$F7,$7F,$77,$F7
	.BYTE $7F,$77,$F7,$77,$7F,$7F,$F7,$F7
	.BYTE $F7,$77,$7F,$77,$F7,$F7,$F7,$7F
	.BYTE $77,$F7,$F7,$F7,$77,$F7,$77,$F7
	.BYTE $F7,$77,$77,$7F,$7F,$7F,$7F,$FC
	.BYTE $EE,$10,$61,$60,$10,$11,$7F,$F1
	.BYTE $6F,$FF,$7E,$E6,$11,$11,$66,$66
	.BYTE $16,$16,$11,$60,$61,$1E,$ED,$EC
	.BYTE $E9,$C1,$11,$01,$11,$60,$10,$01
	.BYTE $01,$10,$10,$11,$66,$FF,$FF,$FF
	.BYTE $6F,$F7,$F7,$F7,$E7,$E7,$E7,$E7
	.BYTE $6F,$7E,$7E,$7F,$FF,$FC,$F7,$CF
	.BYTE $FC,$7C,$FF,$F7,$F7,$C7,$CF,$FF
	.BYTE $FF,$FF,$FD,$CD,$DD,$CD,$CC,$DC
	.BYTE $CD,$CD,$CC,$CC,$CC,$CC,$EC,$E1
	.BYTE $FF,$FF,$7F,$FF,$F7,$FF,$FF,$F7
	.BYTE $FF,$F7,$FF,$7F,$7F,$77,$F7,$F7
	.BYTE $77,$F7,$7F,$F7,$7F,$77,$F7,$77
	.BYTE $7F,$7F,$77,$F7,$77,$F7,$7F,$F7
	.BYTE $F7,$77,$F7,$7F,$7F,$7F,$F7,$77
	.BYTE $7F,$7F,$77,$7F,$7F,$F7,$FF,$FC
	.BYTE $FC,$E0,$61,$11,$61,$66,$77,$C1
	.BYTE $EF,$F7,$7F,$61,$1E,$11,$E1,$66
	.BYTE $10,$10,$61,$16,$03,$6F,$FF,$E9
	.BYTE $EC,$11,$06,$06,$06,$00,$06,$00
	.BYTE $10,$11,$11,$61,$7E,$F7,$FF,$7F
	.BYTE $7E,$7E,$7E,$F6,$FF,$7F,$7E,$7F
	.BYTE $7E,$7F,$6F,$FF,$7F,$7E,$CF,$EF
	.BYTE $CF,$FF,$C7,$CF,$CE,$CE,$EF,$CF
	.BYTE $FC,$FC,$FF,$DC,$CD,$CD,$DC,$DC
	.BYTE $DC,$CD,$CD,$CC,$FC,$FE,$F6,$66
	.BYTE $7F,$F7,$F7,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FF,$FF,$FF,$F7,$F7,$77,$7F
	.BYTE $77,$F7,$F7,$7F,$7F,$F7,$7F,$7F
	.BYTE $77,$7F,$7F,$7F,$77,$F7,$F7,$77
	.BYTE $FF,$77,$F7,$77,$F7,$F7,$7F,$7F
	.BYTE $77,$77,$F7,$7F,$7F,$7F,$FF,$F9
	.BYTE $CE,$11,$06,$11,$11,$E7,$77,$D1
	.BYTE $17,$7F,$77,$E1,$1E,$11,$11,$16
	.BYTE $36,$03,$03,$01,$61,$FE,$EE,$EC
	.BYTE $11,$11,$00,$11,$11,$66,$00,$10
	.BYTE $00,$01,$00,$1E,$7E,$F7,$FF,$E7
	.BYTE $F7,$EF,$7E,$7F,$7E,$7E,$F7,$E7
	.BYTE $E7,$E7,$E7,$FC,$FF,$FF,$6F,$C6
	.BYTE $E4,$E4,$EE,$C6,$C7,$CF,$4E,$6C
	.BYTE $E7,$FC,$FE,$DC,$FD,$CF,$CD,$FC
	.BYTE $DD,$CD,$CD,$DF,$CF,$DE,$CC,$14
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$F7,$FF,$7F,$7F,$F7
	.BYTE $F7,$7F,$77,$F7,$77,$F7,$F7,$77
	.BYTE $FF,$7F,$77,$7F,$7F,$7F,$7F,$7F
	.BYTE $77,$F7,$7F,$FF,$FF,$FF,$FF,$7F
	.BYTE $7F,$77,$77,$F7,$FF,$FF,$FC,$CE
	.BYTE $E1,$11,$10,$11,$16,$67,$F7,$7E
	.BYTE $C1,$7E,$77,$76,$61,$61,$E1,$11
	.BYTE $01,$60,$60,$61,$EF,$EE,$C1,$11
	.BYTE $10,$10,$60,$61,$66,$66,$66,$01
	.BYTE $01,$01,$11,$16,$E7,$FE,$7F,$FE
	.BYTE $7F,$7E,$7F,$6F,$7F,$7F,$6F,$6F
	.BYTE $6F,$6F,$7F,$FF,$7F,$FF,$C7,$EC
	.BYTE $EE,$CE,$C6,$CF,$FE,$F4,$EC,$C6
	.BYTE $CE,$C6,$CE,$EC,$CC,$DD,$CD,$CD
	.BYTE $C9,$DC,$DC,$DC,$FF,$FF,$7E,$61
	.BYTE $F7,$FF,$7F,$7F,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$7F,$7F,$77
	.BYTE $F7,$77,$F7,$F7,$F7,$77,$7F,$7F
	.BYTE $77,$7F,$7F,$7F,$7F,$7F,$7F,$77
	.BYTE $F7,$7F,$7F,$FF,$FF,$FF,$FF,$FF
	.BYTE $77,$F7,$F7,$F7,$F7,$FF,$FE,$CC
	.BYTE $10,$11,$10,$30,$11,$67,$77,$77
	.BYTE $E1,$6E,$67,$73,$66,$61,$11,$11
	.BYTE $60,$36,$EE,$FF,$EE,$C8,$11,$01
	.BYTE $10,$10,$10,$11,$66,$60,$66,$06
	.BYTE $00,$00,$00,$11,$CF,$FF,$EF,$7E
	.BYTE $7E,$F7,$F7,$E7,$E7,$EF,$7F,$6F
	.BYTE $67,$FF,$F7,$FC,$F7,$F7,$FF,$7C
	.BYTE $6C,$6E,$4E,$E4,$E4,$1C,$1C,$1C
	.BYTE $1C,$C1,$CC,$CE,$CE,$C9,$CE,$CE
	.BYTE $CC,$CE,$C9,$CC,$C7,$CE,$CC,$E4
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$F7,$FF,$FF,$FF
	.BYTE $77,$F7,$77,$F7,$7F,$F7,$F7,$F7
	.BYTE $FF,$7F,$7F,$7F,$7F,$F7,$F7,$FF
	.BYTE $7F,$F7,$FF,$FF,$FF,$FF,$FF,$7F
	.BYTE $7F,$7F,$FF,$FF,$FF,$FF,$C9,$FC
	.BYTE $11,$10,$11,$01,$31,$67,$77,$77
	.BYTE $77,$67,$37,$16,$61,$16,$11,$61
	.BYTE $16,$FF,$FE,$F1,$C9,$E1,$11,$10
	.BYTE $10,$10,$11,$06,$01,$60,$66,$11
	.BYTE $00,$06,$01,$01,$6F,$77,$F6,$F6
	.BYTE $F7,$EF,$6F,$F7,$FF,$7E,$F6,$F7
	.BYTE $FF,$7E,$7F,$F7,$FF,$FE,$F7,$FF
	.BYTE $EE,$CE,$C6,$CE,$C6,$CE,$C1,$CE
	.BYTE $C1,$CC,$EC,$EC,$C1,$CC,$1C,$CC
	.BYTE $1C,$EC,$EC,$EE,$CE,$C6,$C6,$C1
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F
	.BYTE $F7,$7F,$77,$7F,$77,$7F,$77,$7F
	.BYTE $7F,$7F,$7F,$F7,$F7,$7F,$7F,$77
	.BYTE $F7,$F7,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FF,$FF,$F7,$FF,$FE,$C9,$CE
	.BYTE $11,$11,$10,$10,$11,$E7,$F7,$F7
	.BYTE $FF,$FF,$6E,$11,$61,$16,$11,$16
	.BYTE $1F,$FC,$E1,$1E,$1C,$11,$11,$10
	.BYTE $10,$10,$60,$10,$60,$16,$11,$EC
	.BYTE $10,$00,$00,$10,$1E,$FE,$7F,$6F
	.BYTE $E7,$F7,$F6,$FE,$7E,$F7,$7E,$6F
	.BYTE $6F,$FF,$FF,$FF,$CF,$7F,$FF,$FF
	.BYTE $FF,$7E,$EC,$6C,$E1,$CE,$4E,$41
	.BYTE $CE,$1C,$1C,$C1,$CC,$1C,$C1,$C1
	.BYTE $CC,$1C,$1C,$C1,$C6,$C1,$C1,$41
	.BYTE $F7,$F7,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF
	.BYTE $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
	.BYTE $7F,$7F,$77,$F7,$FF,$7F,$7F,$7F
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$7F,$77
	.BYTE $FF,$FF,$FF,$FF,$F7,$F1,$EE,$E1
	.BYTE $11,$10,$11,$13,$11,$67,$77,$FF
	.BYTE $FF,$FF,$EE,$11,$11,$11,$10,$61
	.BYTE $F1,$D1,$E8,$E0,$11,$01,$01,$06
	.BYTE $01,$01,$06,$11,$16,$16,$66,$5E
	.BYTE $11,$00,$10,$60,$01,$6E,$7E,$7E
	.BYTE $7E,$7E,$7F,$7E,$7F,$7E,$F7,$E7
	.BYTE $FF,$76,$F7,$F7,$FF,$F7,$FF,$7F
	.BYTE $FF,$FF,$7C,$E6,$C6,$CE,$CE,$C6
	.BYTE $CE,$CE,$C1,$EC,$1C,$C1,$C8,$C1
	.BYTE $C1,$CC,$C1,$CC,$1C,$6C,$6C,$16
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF
	.BYTE $F7,$7F,$7F,$77,$F7,$F7,$F7,$F7
	.BYTE $FF,$7F,$F7,$F7,$F7,$FF,$7F,$77
	.BYTE $FF,$FF,$FF,$FF,$7F,$F7,$F7,$FF
	.BYTE $FF,$FF,$FF,$7F,$FF,$E1,$1E,$E0
	.BYTE $11,$11,$06,$11,$11,$6F,$F7,$7F
	.BYTE $FD,$EC,$11,$1C,$16,$16,$11,$EE
	.BYTE $EE,$81,$1C,$11,$01,$06,$01,$00
	.BYTE $30,$60,$01,$1C,$C6,$61,$67,$66
	.BYTE $16,$00,$00,$10,$00,$11,$7E,$7F
	.BYTE $E7,$F6,$FE,$7F,$E6,$F6,$F6,$FF
	.BYTE $7F,$F7,$FE,$FF,$F7,$CF,$FF,$FF
	.BYTE $F7,$FF,$F6,$CF,$CF,$C7,$EF,$FC
	.BYTE $7C,$FE,$DE,$CC,$CC,$CC,$CC,$CC
	.BYTE $CC,$1C,$C1,$C1,$C6,$14,$14,$14
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$7F,$F7
	.BYTE $F7,$F7,$7F,$7F,$7F,$7F,$F7,$F7
	.BYTE $F7,$F7,$F7,$F7,$F7,$F7,$F7,$FF
	.BYTE $7F,$FF,$FF,$FF,$FF,$7F,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$11,$E6,$11
	.BYTE $01,$01,$30,$61,$1E,$7F,$7F,$FF
	.BYTE $FD,$E9,$ED,$CC,$E1,$11,$06,$FC
	.BYTE $EC,$11,$11,$11,$11,$01,$06,$01
	.BYTE $01,$00,$10,$10,$46,$46,$6C,$71
	.BYTE $16,$01,$00,$00,$10,$11,$1E,$7E
	.BYTE $7F,$6F,$7E,$F7,$F7,$E7,$F6,$7F
	.BYTE $EF,$6F,$7F,$F7,$FF,$F7,$F7,$FF
	.BYTE $FF,$FF,$CF,$C7,$F7,$CF,$CC,$FC
	.BYTE $FE,$5F,$ED,$FF,$EC,$CC,$9C,$C9
	.BYTE $CC,$CC,$CC,$CC,$CE,$CE,$CE,$E1
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$F7,$F7,$FF,$7F,$7F,$7F,$F7
	.BYTE $F7,$F7,$F7,$F7,$FF,$7F,$F7,$F7
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FE,$1E,$F6,$11
	.BYTE $11,$10,$12,$16,$7F,$F7,$F7,$FF
	.BYTE $EF,$CF,$CC,$81,$11,$16,$1F,$CF
	.BYTE $18,$11,$11,$11,$13,$10,$03,$06
	.BYTE $01,$01,$0C,$01,$16,$46,$16,$61
	.BYTE $C6,$16,$10,$60,$00,$00,$10,$E7
	.BYTE $E7,$FE,$76,$F6,$F6,$F6,$FE,$7F
	.BYTE $7F,$F6,$FF,$FF,$7F,$FF,$FF,$F7
	.BYTE $FF,$7F,$7F,$CE,$CF,$C7,$F4,$FC
	.BYTE $FC,$F5,$EF,$CF,$CC,$CC,$CC,$CC
	.BYTE $9C,$CC,$CC,$EC,$CC,$FE,$DE,$41
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF
	.BYTE $F7,$7F,$7F,$7F,$F7,$F7,$F7,$F7
	.BYTE $FF,$7F,$F7,$FF,$7F,$7F,$7F,$7F
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FE,$16,$F1,$10
	.BYTE $10,$60,$10,$11,$F7,$F7,$FF,$FF
	.BYTE $CF,$9D,$FD,$E1,$11,$11,$EF,$EF
	.BYTE $CC,$C8,$11,$CE,$10,$06,$00,$10
	.BYTE $01,$00,$10,$1C,$C6,$7C,$66,$11
	.BYTE $6C,$10,$60,$01,$01,$00,$10,$11
	.BYTE $E7,$E7,$FE,$7E,$7F,$7E,$7E,$7F
	.BYTE $E7,$EF,$F7,$FF,$EF,$5F,$F7,$FF
	.BYTE $FE,$FF,$CE,$5F,$ED,$FC,$FF,$DF
	.BYTE $4F,$EC,$FC,$FC,$CC,$CC,$CF,$CC
	.BYTE $DC,$D9,$DC,$DE,$FC,$F4,$FE,$16
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7
	.BYTE $FF,$7F,$F7,$F7,$F7,$FF,$F7,$FF
	.BYTE $7F,$7F,$F7,$F7,$7F,$7F,$F7,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F
	.BYTE $F7,$FF,$FF,$FF,$C1,$CF,$71,$11
	.BYTE $03,$06,$11,$11,$F7,$FF,$FF,$FC
	.BYTE $FC,$F9,$DC,$11,$11,$11,$1F,$FD
	.BYTE $E9,$CC,$11,$CE,$61,$00,$60,$00
	.BYTE $60,$10,$10,$00,$C6,$61,$61,$67
	.BYTE $46,$10,$10,$61,$11,$60,$10,$01
	.BYTE $16,$E7,$E7,$FE,$7E,$7F,$6F,$7E
	.BYTE $7F,$7F,$EF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$F7,$CF,$ED,$E7,$CF,$4F,$DC
	.BYTE $FC,$FF,$4F,$CF,$D9,$CF,$CF,$FC
	.BYTE $CD,$CD,$CC,$DC,$7C,$FC,$F4,$14
	.BYTE $FF,$FF,$7F,$F7,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $F7,$F7,$FF,$F7,$FF,$7F,$7F,$7F
	.BYTE $F7,$F7,$FF,$7F,$7F,$7F,$FF,$7F
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$F7,$FF,$FC,$FC,$EC,$E0,$10
	.BYTE $11,$01,$61,$16,$FF,$7F,$FF,$FD
	.BYTE $FC,$EE,$C9,$C1,$11,$60,$0D,$E9
	.BYTE $C9,$CE,$1E,$E1,$00,$01,$00,$60
	.BYTE $00,$10,$01,$01,$1C,$C6,$41,$4C
	.BYTE $66,$C0,$10,$01,$11,$C1,$00,$10
	.BYTE $11,$E7,$E7,$E7,$E7,$FF,$7E,$FF
	.BYTE $EF,$FF,$F7,$F7,$F7,$FC,$7F,$7F
	.BYTE $FF,$FC,$FC,$7F,$CF,$CF,$CF,$CF
	.BYTE $5F,$C7,$FC,$FC,$CC,$FC,$FC,$FF
	.BYTE $EC,$CF,$CF,$EF,$CF,$5F,$CF,$16
	.BYTE $7F,$FF,$7F,$FF,$7F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$F7,$F7,$FF,$7F,$F7,$FF,$F7
	.BYTE $FF,$F7,$F7,$F7,$F7,$F7,$F7,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F
	.BYTE $F7,$F7,$FF,$FE,$CF,$9C,$11,$06
	.BYTE $01,$21,$11,$6F,$7F,$F7,$FF,$FC
	.BYTE $FC,$9F,$EC,$11,$10,$61,$1F,$CE
	.BYTE $CE,$81,$1C,$81,$11,$00,$10,$06
	.BYTE $01,$06,$01,$01,$00,$CE,$54,$11
	.BYTE $46,$16,$06,$00,$60,$10,$60,$00
	.BYTE $00,$11,$7E,$7E,$7E,$6F,$7E,$7F
	.BYTE $7F,$7F,$FF,$FC,$FF,$7F,$FC,$FF
	.BYTE $F7,$F7,$EF,$C7,$CF,$7D,$7C,$FC
	.BYTE $FC,$FC,$FC,$FC,$CF,$CF,$CF,$CD
	.BYTE $FF,$CD,$ED,$CF,$FC,$FC,$F4,$14
	.BYTE $F7,$FF,$FF,$7F,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$7F,$F7,$FF,$7F,$FF,$7F,$7F
	.BYTE $7F,$7F,$F7,$FF,$7F,$F7,$7F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$7F,$F7
	.BYTE $FF,$F7,$FF,$FF,$CF,$FE,$11,$12
	.BYTE $01,$06,$6E,$F7,$FF,$FF,$FD,$F9
	.BYTE $F9,$FC,$E1,$11,$11,$10,$11,$D9
	.BYTE $CE,$C1,$1E,$11,$01,$60,$10,$30
	.BYTE $16,$01,$01,$01,$11,$C1,$47,$41
	.BYTE $6E,$7E,$11,$06,$01,$10,$00,$10
	.BYTE $10,$01,$1E,$C6,$F6,$F6,$FF,$7E
	.BYTE $FE,$FF,$7F,$F7,$FF,$FF,$7F,$7F
	.BYTE $FF,$FC,$F4,$FE,$FC,$DF,$CF,$DD
	.BYTE $FD,$7C,$7F,$CD,$CF,$F4,$FC,$FE
	.BYTE $CF,$EF,$CF,$7C,$7D,$7C,$FE,$61
	.BYTE $F7,$F7,$FF,$FF,$7F,$FF,$FF,$FF
	.BYTE $FF,$FF,$7F,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$7F,$F7,$F7,$F7,$F7,$FF
	.BYTE $7F,$F7,$7F,$7F,$F7,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$F7,$F7,$FF
	.BYTE $F7,$F7,$7F,$FF,$CC,$E1,$10,$11
	.BYTE $03,$06,$F7,$FF,$7F,$FF,$FF,$CF
	.BYTE $CE,$11,$11,$10,$60,$11,$11,$C9
	.BYTE $C1,$11,$1C,$11,$60,$11,$60,$63
	.BYTE $06,$16,$11,$10,$C0,$1C,$66,$16
	.BYTE $6C,$E6,$F6,$11,$11,$11,$60,$00
	.BYTE $01,$00,$11,$EC,$E6,$F7,$6F,$F7
	.BYTE $F7,$FE,$FF,$FF,$F7,$CF,$FF,$F7
	.BYTE $FF,$7F,$CF,$C6,$C6,$ED,$FC,$ED
	.BYTE $ED,$FC,$FC,$FF,$CF,$CF,$FC,$7D
	.BYTE $ED,$FC,$FC,$FC,$FC,$7D,$EC,$64
	.BYTE $FF,$FF,$F7,$FF,$FF,$FF,$FF,$FF
	.BYTE $F7,$FF,$FF,$7F,$FF,$FF,$FF,$FF
	.BYTE $F7,$7F,$7F,$F7,$FF,$FF,$7F,$7F
	.BYTE $7F,$7F,$F7,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7
	.BYTE $F7,$FF,$7F,$FF,$C9,$C1,$10,$11
	.BYTE $01,$1F,$7F,$FF,$FF,$FE,$E6,$EC
	.BYTE $E9,$11,$11,$11,$01,$00,$11,$EE
	.BYTE $E9,$1C,$1C,$E1,$11,$61,$61,$60
	.BYTE $61,$11,$06,$01,$11,$C0,$11,$C4
	.BYTE $6C,$C7,$EF,$E6,$01,$00,$01,$06
	.BYTE $00,$01,$01,$11,$EE,$7E,$7F,$EF
	.BYTE $FF,$F7,$F4,$F7,$FF,$F7,$FF,$FF
	.BYTE $FF,$FC,$6C,$EC,$EC,$C4,$DC,$DD
	.BYTE $CC,$E4,$EC,$6C,$E4,$E4,$FC,$EC
	.BYTE $7C,$6C,$7C,$FC,$FF,$CF,$4E,$66
	.BYTE $7F,$7F,$F7,$FF,$7F,$FF,$FF,$F7
	.BYTE $FF,$F7,$FF,$FF,$FF,$FF,$FF,$F7
	.BYTE $7F,$F7,$F7,$F7,$F7,$7F,$FF,$7F
	.BYTE $7F,$F7,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$FF,$FF
	.BYTE $F7,$FF,$FF,$FC,$CC,$11,$11,$03
	.BYTE $11,$6F,$F7,$FF,$F7,$DF,$E1,$9F
	.BYTE $CE,$C1,$11,$10,$60,$60,$10,$FF
	.BYTE $FE,$C1,$C1,$C6,$11,$10,$61,$61
	.BYTE $60,$66,$01,$10,$00,$10,$C1,$CC
	.BYTE $66,$61,$76,$F7,$E6,$06,$01,$00
	.BYTE $01,$00,$11,$11,$1E,$CE,$67,$F7
	.BYTE $E7,$FF,$FF,$EF,$7F,$FF,$7F,$FF
	.BYTE $FF,$7F,$EC,$6C,$6C,$EE,$CD,$CD
	.BYTE $CD,$EC,$EC,$CE,$CE,$CE,$4E,$4E
	.BYTE $CE,$CE,$C7,$C6,$C6,$CE,$CE,$41
	.BYTE $FF,$F7,$FF,$FF,$FF,$FF,$7F,$FF
	.BYTE $7F,$7F,$F7,$F7,$F7,$FF,$77,$7F
	.BYTE $77,$F7,$FF,$7F,$F7,$F7,$F7,$FF
	.BYTE $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$FF,$FF,$F7
	.BYTE $FF,$7F,$FF,$FF,$FE,$11,$01,$01
	.BYTE $06,$FF,$7F,$FF,$7E,$E6,$E1,$CE
	.BYTE $EE,$11,$11,$01,$03,$00,$61,$FF
	.BYTE $FF,$EC,$EC,$E1,$16,$16,$11,$61
	.BYTE $16,$10,$60,$60,$10,$10,$10,$1C
	.BYTE $16,$43,$6E,$7E,$FE,$11,$06,$06
	.BYTE $00,$10,$01,$11,$01,$1E,$F6,$F6
	.BYTE $FF,$6F,$7F,$F7,$CF,$FF,$FF,$7F
	.BYTE $FF,$F7,$C6,$CE,$C6,$CD,$ED,$DD
	.BYTE $CD,$C6,$C6,$C6,$CE,$4E,$CE,$CE
	.BYTE $4E,$CE,$CE,$CE,$CE,$C6,$CF,$EE
	.BYTE $7F,$F7,$F7,$FF,$F7,$FF,$F7,$F7
	.BYTE $FF,$F7,$FF,$FF,$FF,$7F,$7F,$F7
	.BYTE $F7,$F7,$F7,$F7,$F7,$F7,$FF,$7F
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7
	.BYTE $FF,$F7,$FF,$F9,$C1,$01,$10,$31
	.BYTE $21,$7F,$FF,$FF,$EE,$11,$11,$1E
	.BYTE $6E,$61,$11,$10,$60,$62,$1E,$FF
	.BYTE $CF,$FF,$EC,$11,$11,$11,$61,$16
	.BYTE $06,$11,$10,$60,$10,$10,$C1,$01
	.BYTE $16,$6E,$73,$67,$E7,$F6,$10,$10
	.BYTE $60,$10,$10,$1C,$01,$11,$CE,$7F
	.BYTE $7F,$FF,$CF,$FF,$7F,$F7,$FF,$FF
	.BYTE $7F,$FF,$FE,$DE,$C6,$CD,$EC,$DD
	.BYTE $CD,$CE,$CE,$C6,$CE,$CE,$C6,$CE
	.BYTE $CE,$4E,$4E,$4E,$4E,$CE,$CC,$FF
	.BYTE $F7,$FF,$7F,$7F,$FF,$7F,$7F,$FF
	.BYTE $7F,$7F,$F7,$F7,$FF,$7F,$F7,$7F
	.BYTE $7F,$7F,$F7,$FF,$7F,$F7,$F7,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF
	.BYTE $7F,$7F,$FF,$CC,$E1,$11,$06,$01
	.BYTE $16,$FF,$7F,$F5,$FF,$6C,$EC,$11
	.BYTE $11,$11,$60,$63,$01,$00,$6E,$FF
	.BYTE $FF,$CF,$CF,$CE,$11,$60,$61,$61
	.BYTE $16,$00,$61,$01,$00,$60,$01,$C1
	.BYTE $11,$64,$E6,$36,$6F,$EF,$F1,$10
	.BYTE $10,$10,$01,$00,$10,$10,$1E,$CE
	.BYTE $7F,$7F,$7F,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$F7,$FC,$CE,$CE,$CD,$CF,$DC
	.BYTE $DC,$6C,$6C,$EC,$C6,$C6,$CC,$E4
	.BYTE $EC,$EC,$EC,$EC,$EE,$FF,$FF,$FC
	.BYTE $FF,$7F,$FF,$FF,$7F,$FF,$7F,$7F
	.BYTE $FF,$7F,$F7,$FF,$7F,$F7,$FF,$77
	.BYTE $7F,$77,$7F,$7F,$7F,$7F,$7F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F
	.BYTE $FF,$FF,$CE,$FE,$10,$31,$26,$16
	.BYTE $EF,$FF,$FF,$7F,$76,$66,$1C,$EC
	.BYTE $11,$11,$10,$60,$36,$01,$0F,$FF
	.BYTE $CF,$FF,$FC,$C1,$10,$11,$10,$61
	.BYTE $11,$60,$01,$60,$10,$01,$00,$11
	.BYTE $CC,$C6,$6C,$36,$36,$36,$7F,$E1
	.BYTE $06,$01,$10,$10,$10,$11,$01,$1C
	.BYTE $EF,$EF,$D7,$FF,$7F,$F7,$FF,$C7
	.BYTE $FF,$FF,$7C,$DE,$DD,$CC,$EC,$DD
	.BYTE $DF,$CE,$C6,$CE,$DC,$EC,$E4,$EC
	.BYTE $EE,$FE,$C6,$CE,$CF,$CF,$EF,$FF
	.BYTE $F7,$F7,$F7,$7F,$F7,$FF,$FF,$F7
	.BYTE $FF,$F7,$FF,$F7,$F7,$F7,$77,$F7
	.BYTE $F7,$FF,$7F,$F7,$FF,$F7,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FC,$11,$C1,$11,$01,$16,$FF
	.BYTE $F7,$FF,$FF,$77,$FF,$37,$36,$11
	.BYTE $11,$60,$61,$06,$00,$30,$6F,$FF
	.BYTE $FF,$CC,$FC,$E1,$10,$10,$60,$10
	.BYTE $60,$11,$01,$00,$60,$10,$60,$01
	.BYTE $0C,$11,$46,$61,$66,$66,$37,$FE
	.BYTE $10,$10,$60,$01,$00,$01,$01,$11
	.BYTE $EC,$7F,$DD,$FF,$FF,$FF,$CC,$FF
	.BYTE $FF,$FF,$FF,$CE,$DD,$DE,$CF,$CD
	.BYTE $DC,$FF,$CF,$F4,$FC,$FF,$FF,$FF
	.BYTE $FD,$FF,$EF,$FF,$FF,$ED,$FF,$FF
	.BYTE $EF,$E7,$FF,$F7,$FF,$7F,$7F,$EF
	.BYTE $7F,$F7,$F7,$FF,$FF,$7F,$7F,$77
	.BYTE $F7,$7F,$7F,$7F,$77,$F7,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$7F,$7F
	.BYTE $7F,$C1,$EE,$11,$01,$12,$EF,$7F
	.BYTE $FF,$FF,$F7,$E7,$73,$66,$31,$31
	.BYTE $11,$61,$30,$11,$66,$11,$FF,$FF
	.BYTE $FF,$FD,$9D,$11,$06,$03,$01,$01
	.BYTE $06,$06,$06,$10,$00,$60,$01,$0C
	.BYTE $01,$11,$66,$60,$11,$16,$6E,$7E
	.BYTE $E1,$10,$10,$60,$11,$01,$01,$0C
	.BYTE $1E,$EE,$FD,$DF,$7F,$FC,$DF,$FF
	.BYTE $FF,$7F,$FE,$DE,$DD,$DF,$CF,$CD
	.BYTE $FD,$FF,$FC,$FF,$FD,$FC,$FD,$FF
	.BYTE $FE,$FF,$FC,$FF,$CF,$FE,$DC,$DF
	.BYTE $F7,$FF,$7E,$7F,$F7,$FE,$F7,$FF
	.BYTE $7F,$EF,$FF,$77,$77,$F7,$F7,$7F
	.BYTE $7F,$7F,$7F,$F7,$FF,$7F,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$7F,$7F,$FF,$FF,$FF
	.BYTE $FF,$E1,$EC,$11,$06,$11,$6F,$FF
	.BYTE $FF,$7F,$67,$F7,$E7,$36,$36,$13
	.BYTE $61,$10,$66,$16,$01,$01,$EF,$FF
	.BYTE $DF,$EF,$CC,$11,$10,$10,$61,$10
	.BYTE $10,$00,$10,$06,$01,$00,$60,$10
	.BYTE $1C,$16,$16,$11,$61,$66,$E7,$FE
	.BYTE $EC,$E1,$10,$10,$10,$01,$01,$18
	.BYTE $11,$CE,$CC,$DF,$FF,$CE,$CD,$F7
	.BYTE $FF,$FF,$7C,$CF,$DD,$FF,$CF,$CD
	.BYTE $DF,$FF,$DF,$FF,$FF,$FF,$FE,$FC
	.BYTE $FF,$CF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $F6,$F7,$FF,$7F,$7F,$77,$FF,$7E
	.BYTE $FF,$7F,$7F,$F7,$F7,$77,$7F,$7F
	.BYTE $77,$F7,$F7,$F7,$F7,$F7,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$7F,$FF,$F7,$FF,$7F,$7F
	.BYTE $FE,$CE,$FE,$03,$02,$11,$E7,$FF
	.BYTE $FF,$FF,$EE,$73,$36,$66,$63,$63
	.BYTE $63,$63,$13,$16,$16,$13,$6F,$FF
	.BYTE $CF,$CF,$D1,$11,$16,$01,$01,$61
	.BYTE $60,$60,$11,$00,$60,$10,$60,$11
	.BYTE $01,$10,$11,$60,$16,$E6,$F6,$F7
	.BYTE $FE,$16,$06,$06,$06,$01,$00,$0C
	.BYTE $18,$1E,$EE,$DD,$FF,$DC,$DF,$FF
	.BYTE $FF,$CF,$FF,$CC,$CD,$CF,$CD,$ED
	.BYTE $DC,$FF,$FF,$FC,$FF,$FF,$DF,$FC
	.BYTE $FF,$FF,$EF,$CF,$FC,$FF,$EF,$FF
	.BYTE $F7,$F7,$F7,$F7,$F7,$FF,$7F,$FF
	.BYTE $77,$77,$F7,$7F,$77,$FF,$77,$F7
	.BYTE $F7,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$7F,$FF,$7F,$FF,$FF
	.BYTE $FF,$C9,$C1,$11,$06,$16,$FF,$FF
	.BYTE $FF,$FE,$6F,$E7,$63,$31,$66,$61
	.BYTE $13,$06,$06,$36,$23,$63,$37,$FF
	.BYTE $FF,$FC,$91,$11,$01,$11,$10,$10
	.BYTE $11,$03,$06,$01,$00,$10,$06,$06
	.BYTE $06,$10,$62,$16,$66,$F6,$FE,$DE
	.BYTE $7F,$EE,$E0,$10,$10,$01,$10,$11
	.BYTE $C0,$C8,$1E,$CD,$FC,$CC,$DC,$DD
	.BYTE $CC,$FF,$DC,$CE,$DC,$FC,$CF,$CD
	.BYTE $DF,$CF,$FC,$FF,$FC,$FF,$FF,$FF
	.BYTE $FF,$FC,$FF,$FF,$FF,$FF,$FF,$EF
	.BYTE $7E,$F6,$F7,$E7,$F7,$7F,$7F,$7F
	.BYTE $7F,$7F,$7F,$FF,$FF,$FF,$F7,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$F7,$FF,$FF,$FF,$F7,$FF,$FF
	.BYTE $F9,$CC,$E1,$01,$11,$1F,$FF,$FF
	.BYTE $FF,$EF,$6F,$E6,$16,$13,$31,$36
	.BYTE $66,$26,$30,$36,$06,$37,$3E,$FF
	.BYTE $FC,$FC,$C4,$16,$06,$06,$10,$60
	.BYTE $10,$60,$10,$60,$60,$60,$00,$10
	.BYTE $01,$60,$66,$6E,$7E,$7E,$7F,$ED
	.BYTE $CF,$FF,$EE,$10,$60,$60,$10,$00
	.BYTE $11,$1C,$81,$EE,$DF,$CD,$DD,$DC
	.BYTE $CD,$CF,$FC,$D9,$CC,$FD,$CF,$CF
	.BYTE $CD,$EF,$FF,$CE,$FF,$CD,$CD,$CD
	.BYTE $CD,$FF,$FF,$FC,$FC,$DE,$DE,$DF
	.BYTE $7F,$7F,$77,$F7,$7F,$77,$77,$7F
	.BYTE $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$F7,$F7,$FF,$FF,$7F,$FE
	.BYTE $DC,$D9,$11,$12,$16,$FF,$FF,$FF
	.BYTE $EE,$6E,$EE,$E1,$11,$60,$61,$63
	.BYTE $63,$61,$66,$36,$33,$63,$66,$FF
	.BYTE $FF,$CE,$E1,$11,$11,$11,$01,$00
	.BYTE $60,$01,$11,$10,$00,$06,$06,$06
	.BYTE $16,$16,$6E,$7F,$7E,$7E,$7E,$ED
	.BYTE $CF,$EC,$FE,$EE,$11,$06,$01,$10
	.BYTE $00,$00,$1C,$81,$EC,$CD,$CF,$CC
	.BYTE $CD,$FD,$FC,$CC,$CC,$CC,$FC,$FF
	.BYTE $CD,$FF,$EF,$FF,$DF,$FF,$FC,$DC
	.BYTE $FF,$FF,$FF,$DC,$DD,$CD,$CC,$FF
	.BYTE $FF,$7F,$77,$F7,$7F,$7F,$7F,$77
	.BYTE $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF
	.BYTE $7F,$7F,$FF,$FF,$F7,$FF,$FF,$FC
	.BYTE $E9,$CC,$13,$01,$1E,$FF,$FF,$EE
	.BYTE $EE,$EE,$61,$66,$11,$16,$31,$06
	.BYTE $06,$36,$31,$66,$36,$36,$31,$EF
	.BYTE $FF,$C1,$11,$11,$11,$16,$06,$00
	.BYTE $01,$01,$01,$16,$16,$00,$00,$00
	.BYTE $11,$11,$7E,$7E,$7F,$6F,$C7,$FE
	.BYTE $CD,$FE,$CD,$EE,$EC,$E1,$61,$11
	.BYTE $11,$10,$01,$C8,$EE,$EC,$CF,$DF
	.BYTE $D6,$EE,$FF,$FF,$FC,$FD,$CF,$CF
	.BYTE $FC,$EF,$DF,$FF,$FF,$FF,$FE,$FE
	.BYTE $1F,$FF,$FF,$DC,$DC,$DC,$CC,$EF
	.BYTE $77,$77,$F7,$77,$77,$77,$77,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$7F,$F7,$FF,$F7,$FF,$EC
	.BYTE $FF,$E1,$10,$13,$6F,$FF,$FE,$E6
	.BYTE $EE,$1E,$11,$11,$16,$10,$61,$13
	.BYTE $63,$06,$03,$63,$66,$36,$01,$1E
	.BYTE $DE,$EE,$C1,$40,$41,$11,$01,$06
	.BYTE $01,$11,$10,$10,$10,$16,$06,$61
	.BYTE $66,$11,$6F,$7F,$6F,$6F,$EC,$EF
	.BYTE $CC,$DC,$EC,$CF,$CE,$CC,$06,$06
	.BYTE $01,$01,$10,$1C,$1E,$9D,$FF,$CF
	.BYTE $EE,$7E,$DC,$CC,$EF,$CC,$CC,$EE
	.BYTE $CE,$FC,$FF,$FF,$DD,$FE,$E6,$E6
	.BYTE $CE,$FC,$FC,$CE,$EE,$EE,$1C,$6F
	.BYTE $7F,$77,$7F,$7F,$7F,$F7,$F7,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$F7,$FF
	.BYTE $F7,$FF,$FF,$F7,$FF,$FF,$FF,$FF
	.BYTE $DE,$E1,$11,$01,$EF,$FE,$EE,$E1
	.BYTE $61,$11,$13,$03,$01,$10,$06,$01
	.BYTE $06,$31,$60,$00,$36,$01,$11,$11
	.BYTE $FF,$C1,$11,$11,$11,$11,$11,$01
	.BYTE $11,$11,$01,$01,$01,$01,$00,$01
	.BYTE $06,$11,$6F,$6F,$6F,$E7,$EF,$EC
	.BYTE $FF,$CC,$CC,$CF,$DE,$61,$11,$06
	.BYTE $16,$01,$01,$01,$CE,$EE,$CF,$FC
	.BYTE $4E,$6E,$EE,$FE,$FE,$FF,$CF,$EE
	.BYTE $EE,$EE,$FF,$EE,$FF,$C6,$E6,$61
	.BYTE $6E,$FD,$EC,$C1,$11,$1E,$1C,$6E
	.BYTE $F7,$7F,$7F,$77,$77,$7F,$77,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7
	.BYTE $FF,$FF,$7F,$FF,$F7,$F7,$FF,$FD
	.BYTE $C1,$10,$11,$6E,$FF,$E6,$11,$61
	.BYTE $11,$11,$01,$06,$03,$01,$30,$61
	.BYTE $60,$10,$11,$60,$60,$01,$60,$1E
	.BYTE $FF,$CE,$CC,$CC,$C1,$10,$10,$1E
	.BYTE $C0,$10,$10,$10,$16,$06,$61,$06
	.BYTE $11,$60,$7E,$F7,$FF,$FF,$DF,$FC
	.BYTE $CF,$FC,$FC,$DF,$CF,$FE,$E1,$60
	.BYTE $10,$60,$60,$11,$1E,$EE,$EE,$EE
	.BYTE $EE,$E7,$E6,$EE,$FF,$EF,$FF,$FE
	.BYTE $FE,$EE,$FF,$FE,$CE,$E6,$16,$16
	.BYTE $EE,$DD,$EC,$16,$66,$61,$61,$E6
	.BYTE $7F,$F7,$77,$7F,$F7,$77,$F7,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF
	.BYTE $F7,$FF,$F7,$F7,$FF,$FF,$FF,$FD
	.BYTE $E1,$03,$11,$FF,$EE,$E6,$11,$11
	.BYTE $11,$10,$60,$10,$60,$10,$10,$02
	.BYTE $60,$60,$10,$10,$11,$01,$11,$01
	.BYTE $FF,$FC,$11,$11,$CC,$E1,$11,$CC
	.BYTE $11,$01,$10,$10,$01,$01,$60,$11
	.BYTE $61,$EF,$DF,$FF,$FD,$FF,$FF,$FF
	.BYTE $FD,$FF,$CF,$CC,$CC,$CF,$EE,$16
	.BYTE $16,$11,$11,$01,$CE,$CE,$C6,$EE
	.BYTE $6E,$EF,$FF,$FF,$FF,$FE,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FE,$C1,$61,$11,$16,$16,$E6
	.BYTE $77,$7F,$F7,$F7,$7F,$7F,$7F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$FF,$F7
	.BYTE $FF,$F7,$FF,$FF,$F7,$FF,$FF,$11
	.BYTE $11,$10,$11,$6E,$E1,$11,$11,$11
	.BYTE $06,$11,$03,$01,$01,$06,$03,$60
	.BYTE $01,$30,$61,$61,$11,$10,$10,$10
	.BYTE $1F,$FC,$EC,$DC,$E1,$00,$1C,$11
	.BYTE $11,$01,$01,$11,$16,$11,$16,$11
	.BYTE $16,$EF,$FF,$DF,$FF,$FD,$FF,$FF
	.BYTE $FF,$FF,$FF,$FC,$FF,$E6,$EF,$E1
	.BYTE $10,$61,$60,$11,$01,$EE,$EE,$EE
	.BYTE $EC,$6E,$FE,$FF,$CF,$FF,$FF,$FF
	.BYTE $FF,$FF,$DF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FC,$16,$16,$66,$16,$16,$E6
	.BYTE $7F,$7F,$7F,$7F,$F7,$FF,$7F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$F7,$FF,$FF,$7F,$FF
	.BYTE $F7,$FF,$FF,$7F,$FF,$FF,$FE,$FF
	.BYTE $16,$11,$11,$11,$11,$10,$60,$61
	.BYTE $10,$16,$01,$06,$03,$06,$00,$01
	.BYTE $06,$03,$00,$10,$00,$10,$60,$10
	.BYTE $0E,$E1,$11,$11,$11,$11,$01,$01
	.BYTE $01,$10,$10,$06,$01,$16,$01,$61
	.BYTE $EF,$FD,$FF,$FF,$DF,$FF,$FD,$FF
	.BYTE $DF,$DF,$DF,$FD,$EF,$FC,$EF,$EF
	.BYTE $61,$11,$11,$C1,$C1,$8E,$CE,$C7
	.BYTE $EE,$EE,$FC,$FF,$FF,$FC,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$F1,$61,$61,$16,$16,$16,$E6
	.BYTE $F7,$FF,$FF,$F7,$FF,$7F,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F
	.BYTE $FF,$F7,$FF,$FF,$7F,$FF,$1F,$FE
	.BYTE $61,$16,$01,$11,$06,$01,$11,$01
	.BYTE $06,$01,$11,$30,$10,$60,$16,$01
	.BYTE $10,$11,$60,$36,$06,$01,$00,$60
	.BYTE $06,$FC,$11,$01,$11,$11,$10,$11
	.BYTE $10,$10,$11,$11,$61,$61,$6E,$EE
	.BYTE $DF,$FF,$CF,$DF,$FF,$DF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FD,$CD,$CE,$11,$11,$11,$EE,$EE
	.BYTE $FE,$FC,$EE,$FF,$EF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$C6,$16,$16,$E1,$6E,$61,$6E
	.BYTE $77,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FF,$7F,$7F,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$F7,$FF,$FF
	.BYTE $7F,$FF,$F7,$FF,$FF,$FE,$CF,$EE
	.BYTE $6E,$61,$30,$11,$01,$03,$10,$31
	.BYTE $11,$30,$60,$16,$11,$11,$11,$60
	.BYTE $61,$10,$60,$10,$30,$60,$10,$00
	.BYTE $11,$FF,$C1,$10,$01,$00,$10,$01
	.BYTE $11,$11,$01,$16,$EE,$EF,$FD,$FF
	.BYTE $FC,$FF,$FF,$FF,$FF,$FF,$FF,$DF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FC,$1C,$0C,$1E,$CE
	.BYTE $CF,$FF,$FF,$EF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$DF,$FF,$FF,$FF
	.BYTE $FE,$E6,$E6,$E6,$61,$61,$61,$16
	.BYTE $FF,$FF,$7F,$F7,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF
	.BYTE $FF,$FF,$FF,$F7,$FF,$0F,$FF,$FF
	.BYTE $FF,$FF,$F7,$FF,$FF,$FF,$FF,$7F
	.BYTE $FF,$F7,$FF,$F7,$F7,$FC,$EF,$61
	.BYTE $EF,$E1,$06,$01,$30,$60,$11,$00
	.BYTE $10,$10,$11,$11,$16,$06,$11,$01
	.BYTE $01,$01,$10,$60,$60,$01,$06,$06
	.BYTE $01,$FF,$C1,$11,$01,$01,$01,$00
	.BYTE $11,$01,$11,$11,$FD,$FD,$FF,$CF
	.BYTE $FF,$FD,$FF,$DF,$FF,$FD,$FF,$FF
	.BYTE $FD,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FE,$1C,$08,$EE
	.BYTE $EE,$FF,$EF,$FF,$FF,$CF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$CE,$E6,$11,$16,$11,$61,$61
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $F7,$FF,$FF,$FF,$FF,$F7,$FF,$FF
	.BYTE $7F,$FF,$FF,$FF,$FF,$9C,$CE,$61
	.BYTE $EF,$71,$26,$01,$03,$01,$06,$30
	.BYTE $60,$61,$60,$61,$11,$11,$11,$16
	.BYTE $06,$11,$11,$10,$11,$11,$01,$01
	.BYTE $EF,$FF,$D1,$1E,$10,$10,$10,$10
	.BYTE $11,$11,$01,$11,$FF,$FF,$DF,$DD
	.BYTE $FD,$FF,$DF,$DF,$DF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$DF,$DF
	.BYTE $DD,$DD,$FD,$FF,$FF,$E1,$C0,$C1
	.BYTE $EC,$FC,$FF,$CF,$FF,$FF,$FD,$FD
	.BYTE $FF,$FF,$FF,$FF,$FF,$FC,$FF,$CE
	.BYTE $CE,$EF,$EE,$F6,$16,$16,$16,$16
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $F7,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$F7,$FF,$FF,$F7,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$CC,$E1,$11
	.BYTE $6C,$F1,$11,$01,$01,$03,$01,$01
	.BYTE $01,$10,$11,$10,$60,$60,$60,$11
	.BYTE $03,$06,$01,$60,$10,$60,$11,$01
	.BYTE $0E,$FF,$DE,$E1,$E1,$01,$01,$01
	.BYTE $01,$11,$16,$16,$CD,$CF,$FF,$FF
	.BYTE $FF,$FF,$FD,$FD,$FD,$DF,$FD,$FF
	.BYTE $FF,$DF,$FD,$FF,$FD,$FF,$FF,$DF
	.BYTE $FF,$FD,$FD,$FC,$DF,$FF,$E1,$1C
	.BYTE $11,$CC,$DC,$DC,$DC,$DF,$CF,$FF
	.BYTE $FF,$FD,$FF,$DC,$FC,$FF,$FF,$FF
	.BYTE $FF,$FF,$DF,$FF,$FE,$FE,$EE,$E1
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$FF,$FF
	.BYTE $FF,$F7,$FF,$7F,$FF,$FF,$FF,$FF
	.BYTE $FF,$F7,$FF,$FF,$F7,$7F,$FF,$7F
	.BYTE $FF,$FF,$FF,$FF,$FD,$91,$11,$10
	.BYTE $1F,$FF,$16,$01,$06,$06,$01,$11
	.BYTE $11,$16,$11,$11,$11,$11,$16,$01
	.BYTE $11,$06,$10,$60,$30,$60,$26,$01
	.BYTE $1E,$FF,$CC,$1E,$E6,$10,$01,$01
	.BYTE $01,$00,$01,$11,$FF,$DF,$DF,$DF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$DD
	.BYTE $DF,$DF,$FF,$FD,$FF,$DD,$FD,$FD
	.BYTE $DF,$CF,$DF,$DF,$DF,$DF,$FF,$11
	.BYTE $81,$EC,$DC,$DF,$FF,$FF,$FD,$FD
	.BYTE $DD,$DF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$DC,$DD,$DD,$FD,$FD,$CD,$CD
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$7F,$7F,$FF,$F7,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FC,$E1,$10,$11
	.BYTE $16,$FF,$11,$13,$03,$01,$06,$10
	.BYTE $11,$01,$01,$10,$10,$11,$01,$16
	.BYTE $01,$10,$10,$30,$60,$30,$60,$10
	.BYTE $6E,$DF,$FF,$CE,$DE,$E1,$01,$00
	.BYTE $10,$11,$06,$11,$EF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$DF,$FF
	.BYTE $FC,$FD,$DC,$DF,$DF,$DF,$DF,$FF
	.BYTE $DF,$DF,$DF,$FF,$DF,$DF,$DF,$FF
	.BYTE $C1,$CC,$DD,$CD,$DD,$DD,$CD,$CF
	.BYTE $CF,$FF,$FF,$FF,$FF,$DF,$DF,$DD
	.BYTE $DC,$FF,$FF,$CF,$FF,$FF,$FF,$FD
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $F7,$FF,$FF,$FF,$7F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FE,$11,$10,$10
	.BYTE $1E,$FF,$11,$06,$01,$11,$11,$61
	.BYTE $61,$61,$61,$61,$61,$11,$11,$01
	.BYTE $01,$01,$06,$00,$60,$10,$26,$01
	.BYTE $0E,$FF,$DF,$DF,$FE,$E6,$10,$10
	.BYTE $10,$01,$01,$11,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$DF,$FD,$FD
	.BYTE $FD,$FF,$FC,$DC,$DC,$FD,$FD,$DF
	.BYTE $DF,$FD,$FD,$DC,$DC,$DC,$DC,$DC
	.BYTE $FF,$CF,$CD,$DC,$CC,$CD,$FF,$FF
	.BYTE $FF,$FF,$FF,$FD,$DC,$DD,$CD,$FF
	.BYTE $FF,$FF,$FF,$FD,$CD,$CC,$CF,$CE
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$7F,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$7F,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$11,$11,$01
	.BYTE $01,$FE,$11,$01,$11,$11,$11,$11
	.BYTE $11,$11,$11,$11,$10,$01,$01,$06
	.BYTE $01,$60,$10,$11,$00,$60,$60,$10
	.BYTE $1C,$DF,$DC,$FD,$FF,$DE,$10,$10
	.BYTE $11,$06,$06,$11,$EF,$FF,$FF,$FF
	.BYTE $FF,$FD,$FD,$FD,$FD,$FD,$FD,$FD
	.BYTE $FF,$DF,$DF,$FF,$FD,$FC,$DC,$CD
	.BYTE $FD,$CF,$CD,$CD,$CD,$CF,$DF,$FF
	.BYTE $DF,$FC,$FD,$FD,$DD,$DC,$DD,$DD
	.BYTE $FD,$DD,$DC,$DF,$CF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FC,$CF,$DF,$FE
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$F7,$FF,$FF,$FF
	.BYTE $7F,$FF,$FF,$FF,$FE,$10,$11,$01
	.BYTE $10,$F0,$16,$01,$01,$01,$01,$11
	.BYTE $11,$16,$11,$10,$10,$60,$01,$00
	.BYTE $10,$11,$06,$01,$10,$10,$60,$11
	.BYTE $1F,$CF,$FF,$CF,$DF,$FF,$61,$60
	.BYTE $01,$00,$10,$61,$EF,$FF,$FF,$FF
	.BYTE $DF,$DF,$DF,$FD,$FF,$FF,$DF,$FF
	.BYTE $DF,$DF,$FD,$FD,$FD,$FF,$DF,$DF
	.BYTE $DF,$DF,$DF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$DF,$CD
	.BYTE $CC,$DC,$DC,$DD,$FD,$FF,$FF,$FF
	.BYTE $DD,$FD,$FF,$FF,$FD,$CD,$CC,$DF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$7F,$FF,$FF,$7F,$7F
	.BYTE $FF,$FF,$FF,$FF,$FC,$11,$01,$10
	.BYTE $01,$71,$10,$11,$06,$06,$11,$11
	.BYTE $61,$11,$01,$11,$01,$00,$60,$11
	.BYTE $11,$10,$10,$10,$60,$60,$30,$60
	.BYTE $1D,$CD,$CF,$DF,$FF,$FF,$C1,$11
	.BYTE $10,$10,$11,$11,$6E,$FF,$FF,$FF
	.BYTE $FF,$FF,$FD,$FD,$FD,$FD,$FF,$DF
	.BYTE $FD,$FD,$FD,$CD,$FC,$FD,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF
	.BYTE $DF,$DD,$FD,$FD,$FD,$DD,$DD,$DD
	.BYTE $DD,$DD,$DD,$FC,$F9,$DC,$DC,$CC
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$F7,$FF,$7F,$F7,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FC,$11,$01,$01
	.BYTE $01,$EE,$16,$03,$01,$11,$06,$10
	.BYTE $11,$16,$01,$10,$11,$10,$11,$11
	.BYTE $01,$E1,$16,$01,$11,$60,$60,$11
	.BYTE $CF,$FD,$FC,$FD,$CD,$CF,$FE,$11
	.BYTE $01,$10,$10,$11,$1F,$FF,$FD,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD
	.BYTE $DF,$DC,$DF,$DF,$FF,$FF,$DF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FC,$FC,$FF,$FF,$FD,$FC
	.BYTE $DD,$CD,$CD,$CD,$CC,$9C,$8C,$81
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$F7,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F
	.BYTE $FF,$FF,$FF,$FF,$C9,$11,$01,$01
	.BYTE $01,$6F,$E0,$61,$61,$16,$10,$11
	.BYTE $01,$10,$11,$01,$11,$01,$11,$1C
	.BYTE $EC,$C1,$10,$16,$16,$06,$10,$1F
	.BYTE $DF,$CF,$DC,$FD,$FF,$FF,$FF,$E1
	.BYTE $10,$10,$10,$11,$6F,$DF,$FF,$FD
	.BYTE $FD,$FF,$FF,$FF,$FD,$FD,$DC,$DC
	.BYTE $DC,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $DD,$DD,$DD,$FF,$DF,$FF,$FC,$DD
	.BYTE $CC,$D9,$C8,$C1,$EE,$16,$11,$EC
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$7F,$FF,$F7,$F7,$FF
	.BYTE $F7,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$7F,$7F,$7F,$7F,$F7,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$CE,$11,$10,$10
	.BYTE $10,$06,$E1,$11,$11,$16,$03,$06
	.BYTE $01,$10,$11,$10,$11,$10,$1C,$DF
	.BYTE $EE,$EE,$11,$10,$11,$60,$61,$ED
	.BYTE $CF,$DF,$DF,$CF,$CD,$CD,$FF,$F1
	.BYTE $11,$01,$01,$01,$1F,$DF,$DF,$DF
	.BYTE $FD,$FD,$DD,$DD,$FD,$CF,$CD,$DC
	.BYTE $FD,$DD,$CD,$DD,$DF,$DF,$DF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$DC,$DD,$DD,$CD,$CD,$CD,$8D
	.BYTE $CC,$CD,$CC,$FF,$FC,$EE,$CE,$CF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$7F,$7F,$FF,$F7,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FE,$01,$30,$01
	.BYTE $01,$10,$E6,$16,$11,$11,$16,$11
	.BYTE $11,$11,$10,$11,$11,$EC,$FC,$FD
	.BYTE $FF,$FF,$C9,$11,$61,$11,$01,$EF
	.BYTE $FF,$FF,$FD,$FF,$FF,$FF,$FF,$F1
	.BYTE $10,$10,$10,$61,$6E,$FF,$FD,$FD
	.BYTE $CD,$CF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FC,$DC,$CC,$DC,$DD,$DD,$DD
	.BYTE $DF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FD,$FF,$FF,$DF,$FF,$FF
	.BYTE $FF,$DE,$8C,$CC,$C9,$DD,$CD,$DC
	.BYTE $FF,$CC,$D9,$DD,$DD,$DD,$FD,$CF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7
	.BYTE $F7,$FF,$7F,$FF,$7F,$FF,$FD,$FF
	.BYTE $FF,$FF,$DF,$FF,$FF,$60,$16,$11
	.BYTE $01,$11,$11,$11,$61,$11,$11,$16
	.BYTE $11,$11,$11,$11,$11,$CD,$FD,$DD
	.BYTE $DF,$FF,$CC,$11,$16,$16,$01,$EF
	.BYTE $DD,$CD,$FD,$FF,$FF,$DF,$DF,$FE
	.BYTE $60,$10,$10,$01,$1E,$DD,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$CF,$CC,$CC,$CC
	.BYTE $DC,$DD,$FD,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FD,$FD,$FD,$DD,$DD,$DD,$DD
	.BYTE $DC,$DD,$CD,$CD,$DF,$FF,$FF,$DD
	.BYTE $D9,$DC,$DF,$FF,$FC,$FD,$FD,$FD
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$FF,$7F,$FF
	.BYTE $FF,$FF,$FF,$DF,$FD,$FD,$FF,$FF
	.BYTE $FF,$DF,$DF,$DD,$FF,$11,$36,$E1
	.BYTE $60,$60,$61,$11,$16,$16,$11,$11
	.BYTE $C1,$11,$11,$1C,$1E,$FF,$FF,$FF
	.BYTE $CD,$F9,$11,$11,$16,$01,$11,$CD
	.BYTE $CF,$DF,$CF,$FD,$FF,$FF,$FD,$FE
	.BYTE $11,$10,$10,$11,$01,$EF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$DD,$DF,$FF,$FD
	.BYTE $CD,$CC,$DD,$DD,$DC,$DF,$DF,$FD
	.BYTE $FD,$FF,$FF,$FD,$DD,$DD,$C9,$D9
	.BYTE $CF,$FF,$CC,$CC,$CC,$CD,$CD,$CF
	.BYTE $DC,$DC,$FD,$DD,$DF,$DF,$DF,$DC
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$F7
	.BYTE $F7,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$FF,$F7,$FF
	.BYTE $7F,$7F,$7F,$FF,$FF,$FF,$FF,$FF
	.BYTE $DF,$DF,$DF,$FD,$FF,$71,$03,$1E
	.BYTE $11,$11,$11,$61,$61,$1C,$14,$1E
	.BYTE $1C,$11,$C1,$11,$1C,$FF,$FF,$DF
	.BYTE $FF,$FE,$C1,$11,$11,$61,$0E,$DC
	.BYTE $DC,$CD,$DC,$DD,$DC,$DD,$FC,$FF
	.BYTE $E1,$10,$11,$06,$11,$1F,$FF,$FF
	.BYTE $FF,$DD,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FD,$DD,$DF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$EF,$FC,$FD,$FC,$DC,$DD
	.BYTE $CD,$FD,$FF,$DF,$D9,$DD,$DC,$CE
	.BYTE $FF,$FF,$DF,$CF,$CF,$DF,$CD,$DC
	.BYTE $CD,$CD,$CF,$FC,$DC,$ED,$FD,$D9
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7
	.BYTE $FF,$FF,$FF,$F7,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F
	.BYTE $FF,$FF,$FD,$FF,$FF,$FD,$DD,$DF
	.BYTE $DF,$DF,$DF,$DF,$FF,$FE,$16,$1F
	.BYTE $E6,$16,$61,$61,$E6,$16,$1E,$1C
	.BYTE $E1,$11,$CC,$EC,$8F,$FF,$DF,$DC
	.BYTE $DF,$FF,$11,$11,$60,$01,$1E,$FF
	.BYTE $FD,$FC,$DC,$DC,$DC,$DF,$CF,$FF
	.BYTE $EE,$16,$01,$01,$10,$1F,$FF,$DD
	.BYTE $DD,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $DD,$CF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$DD,$FD,$FC
	.BYTE $DC,$DC,$DD,$DC,$CE,$EE,$FF,$FF
	.BYTE $FF,$FF,$FD,$DD,$DD,$DD,$DC,$CD
	.BYTE $9D,$CF,$CF,$DE,$CC,$CF,$CF,$DF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF
	.BYTE $FF,$7F,$7F,$FF,$FF,$F7,$FF,$7F
	.BYTE $FF,$FF,$FF,$7F,$FF,$F7,$FF,$FF
	.BYTE $7F,$F7,$FF,$DF,$DE,$EE,$ED,$FC
	.BYTE $CF,$CE,$CF,$FF,$FD,$FF,$11,$1F
	.BYTE $EE,$11,$11,$E6,$EE,$61,$EE,$EE
	.BYTE $C1,$CC,$9F,$DE,$CF,$DF,$FF,$FF
	.BYTE $FE,$FF,$C6,$11,$16,$10,$EF,$DF
	.BYTE $FF,$FD,$FD,$CD,$FF,$FF,$FF,$FF
	.BYTE $E1,$E0,$10,$10,$11,$1E,$DC,$DF
	.BYTE $CF,$DF,$FF,$FF,$FF,$DC,$DF,$CF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$CD,$CD,$DD,$DC,$DC,$DD
	.BYTE $FD,$FD,$FF,$FF,$FF,$FD,$CD,$CD
	.BYTE $CD,$CD,$FC,$CF,$CC,$8C,$CD,$CD
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7
	.BYTE $FF,$F7,$FF,$F7,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$FF,$F7,$FF
	.BYTE $FF,$FF,$FF,$CC,$EE,$EE,$EE,$CF
	.BYTE $EE,$EE,$EF,$FD,$CF,$CF,$F1,$6E
	.BYTE $FF,$FE,$7E,$61,$C6,$EC,$6E,$CE
	.BYTE $CF,$CF,$FF,$DF,$FF,$FF,$FF,$FF
	.BYTE $FC,$CC,$C1,$01,$10,$1E,$CD,$FD
	.BYTE $CF,$FF,$CF,$FF,$FF,$FF,$FF,$FC
	.BYTE $E1,$01,$01,$01,$00,$1E,$FF,$FF
	.BYTE $FF,$FF,$FD,$FD,$DC,$DF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$DF,$DC,$CD,$CD,$CD,$CD
	.BYTE $CD,$DC,$DD,$DD,$DD,$DD,$DD,$DC
	.BYTE $D9,$DF,$DF,$CC,$CC,$CC,$9F,$DF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FF,$FF,$FF,$F7,$FF,$FF,$F7
	.BYTE $FF,$7F,$FF,$FF,$FF,$7F,$FF,$F7
	.BYTE $F7,$F7,$FF,$DC,$DE,$EC,$EE,$EE
	.BYTE $EE,$CE,$CF,$CF,$DC,$FD,$FF,$FD
	.BYTE $FF,$DF,$CD,$FC,$EC,$EC,$FC,$EC
	.BYTE $FD,$FD,$FC,$FD,$FD,$FD,$FF,$CD
	.BYTE $9C,$9C,$E1,$01,$11,$EC,$DC,$CD
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$DD,$FF
	.BYTE $E1,$11,$10,$10,$11,$1E,$CD,$DD
	.BYTE $CD,$DD,$CD,$CD,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FD,$FD,$FF,$DF,$FF,$DF,$DF,$DC
	.BYTE $DC,$CD,$CC,$DC,$DC,$D9,$CC,$DC
	.BYTE $DC,$CD,$CD,$FC,$9E,$CC,$CF,$CD
	.BYTE $FF,$FF,$FF,$FF,$FF,$F7,$FF,$FF
	.BYTE $FF,$F7,$FF,$FF,$FF,$F7,$FF,$FF
	.BYTE $FF,$FF,$F7,$FF,$7F,$FF,$7F,$FF
	.BYTE $FF,$FF,$FF,$CF,$CE,$EE,$EC,$EC
	.BYTE $EE,$FE,$DF,$FD,$FF,$FC,$FD,$CF
	.BYTE $DF,$CF,$DF,$DF,$DF,$DF,$CF,$DF
	.BYTE $CF,$CF,$FD,$FF,$FF,$FF,$FE,$9C
	.BYTE $CF,$C1,$C1,$11,$11,$CF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FD,$DF,$DF,$FF,$FF
	.BYTE $FE,$10,$10,$01,$01,$11,$EF,$FC
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FD,$FD
	.BYTE $DF,$DF,$DC,$FD,$DC,$FD,$FD,$FD
	.BYTE $FD,$DD,$CD,$CD,$CD,$CD,$DC,$DC
	.BYTE $DC,$DD,$DF,$DF,$CC,$CC,$9C,$DC
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF
	.BYTE $FF,$FF,$FF,$7F,$FF,$FF,$F7,$FF
	.BYTE $7F,$FF,$FF,$FF,$F7,$FF,$F7,$F7
	.BYTE $F7,$F7,$FF,$CE,$DE,$CE,$EE,$EE
	.BYTE $CF,$FF,$DF,$CD,$FF,$FD,$FD,$FD
	.BYTE $FD,$FD,$FC,$FC,$FC,$FD,$FD,$FD
	.BYTE $FD,$FD,$FD,$FD,$FF,$FF,$FF,$9C
	.BYTE $81,$10,$10,$1C,$1F,$FF,$FF,$FF
	.BYTE $FD,$FF,$DF,$FF,$FF,$FF,$FF,$FF
	.BYTE $EE,$E0,$11,$01,$01,$11,$1F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FD,$FF,$FF,$FF,$FF,$FF
	.BYTE $FD,$CF,$DF,$DF,$DF,$CD,$FC,$DC
	.BYTE $DF,$DF,$DF,$DF,$DD,$CD,$DC,$DD
	.BYTE $CD,$DD,$CD,$CC,$C9,$CC,$CC,$CD
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$F7,$FF,$F7,$FF,$F7,$FF,$FF
	.BYTE $FF,$FF,$FF,$FC,$CE,$EE,$EF,$FF
	.BYTE $FF,$FF,$FF,$FF,$DF,$DF,$DF,$DF
	.BYTE $DF,$DF,$DF,$DF,$DF,$CF,$CF,$CF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FE,$11
	.BYTE $11,$11,$11,$C0,$6E,$FF,$CD,$DD
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$DF,$FF
	.BYTE $9C,$10,$10,$11,$01,$01,$EF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$DF,$FD,$FD,$DF,$DF,$DF
	.BYTE $DF,$FD,$CF,$DF,$DD,$FD,$FD,$FF
	.BYTE $DC,$FD,$CD,$CD,$FC,$FD,$FD,$FD
	.BYTE $CC,$9E,$1C,$CD,$DD,$CC,$9C,$CD
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$FF,$FF
	.BYTE $F7,$FF,$7F,$FF,$FF,$7F,$F7,$FF
	.BYTE $FF,$FF,$7F,$FF,$7F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FC,$FE,$EE,$DF,$FF
	.BYTE $FF,$FD,$FF,$FD,$FD,$FF,$DF,$DF
	.BYTE $DF,$DF,$CD,$FC,$DF,$DF,$FF,$FF
	.BYTE $FF,$CF,$FC,$FD,$FD,$CD,$FC,$C1
	.BYTE $10,$10,$11,$11,$16,$66,$EE,$FF
	.BYTE $FF,$FF,$FF,$DF,$DD,$CD,$FD,$FD
	.BYTE $C9,$10,$10,$06,$01,$11,$1E,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$DD,$DD,$CD,$CE,$CD,$FF,$DF
	.BYTE $FF,$FD,$FF,$FF,$FF,$DF,$DF,$DF
	.BYTE $CD,$FF,$DF,$CD,$FC,$FD,$FD,$DF
	.BYTE $DF,$DF,$DF,$DF,$DD,$DF,$DC,$DF
	.BYTE $DF,$DF,$DD,$DD,$CC,$DD,$DC,$EC
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF
	.BYTE $FF,$FF,$FF,$7F,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FE,$EC,$EF,$DF,$FF
	.BYTE $DF,$DF,$DD,$DF,$DF,$DF,$CF,$DF
	.BYTE $CF,$DF,$FF,$FF,$FD,$FD,$FD,$DD
	.BYTE $DD,$DD,$CF,$DF,$FF,$FF,$E1,$01
	.BYTE $01,$11,$61,$66,$6E,$6E,$66,$66
	.BYTE $66,$E7,$EE,$CC,$CF,$DF,$FF,$FF
	.BYTE $9E,$10,$01,$00,$10,$10,$1E,$EF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$DF,$FF,$E6,$FF,$FD,$FF
	.BYTE $FF,$DF,$FF,$DD,$FD,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$DF,$DC,$DF,$DD
	.BYTE $CF,$DF,$DF,$DC,$FC,$FD,$FD,$FD
	.BYTE $FD,$DD,$DC,$9D,$DF,$DC,$DD,$DC
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F
	.BYTE $FF,$7F,$FF,$FF,$7F,$FF,$FF,$FF
	.BYTE $F7,$FF,$F7,$F7,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$DE,$FF,$FC,$EC,$CF
	.BYTE $CD,$CF,$CF,$CF,$CF,$DF,$FF,$FD
	.BYTE $FF,$FD,$FF,$FC,$DC,$DC,$DC,$CC
	.BYTE $D9,$FF,$FF,$FF,$FF,$FF,$FF,$E1
	.BYTE $11,$11,$61,$61,$66,$66,$6E,$6E
	.BYTE $76,$E6,$76,$7E,$EF,$EE,$FF,$FF
	.BYTE $C1,$01,$00,$60,$60,$11,$11,$EE
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD
	.BYTE $FD,$FF,$FF,$FD,$FE,$ED,$DC,$EF
	.BYTE $FF,$CF,$FF,$DF,$FC,$FD,$CD,$FD
	.BYTE $FD,$FD,$FD,$FC,$DD,$CD,$CC,$FF
	.BYTE $FF,$DF,$CD,$FD,$FD,$CD,$CF,$DC
	.BYTE $FD,$CD,$DF,$DF,$EC,$DD,$9C,$EC
	.BYTE $FF,$FF,$FF,$FF,$F7,$FF,$FF,$FF
	.BYTE $F7,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$CF,$FF,$FE,$C1,$E1,$CE
	.BYTE $EC,$FD,$DF,$DF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$DF,$DF,$DC,$FF,$FF,$FF
	.BYTE $FF,$DF,$FF,$FF,$FF,$FF,$FF,$FC
	.BYTE $66,$66,$16,$16,$6E,$6E,$66,$66
	.BYTE $E6,$66,$E6,$E6,$66,$6E,$FF,$FD
	.BYTE $F1,$10,$10,$10,$10,$10,$10,$1E
	.BYTE $EE,$FF,$FF,$FD,$DD,$DD,$DF,$DF
	.BYTE $FD,$FD,$DD,$FD,$E1,$6D,$DD,$EE
	.BYTE $EE,$EF,$DD,$FC,$DD,$FD,$FD,$FC
	.BYTE $DC,$FD,$CD,$DD,$FF,$FF,$FF,$FF
	.BYTE $FD,$FD,$FD,$FD,$CF,$DF,$DC,$FF
	.BYTE $DF,$FF,$FF,$FF,$FF,$FF,$FE,$ED
	.BYTE $FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FE,$C1,$E1,$C1,$EC
	.BYTE $1C,$EE,$CE,$CD,$EF,$EF,$DF,$FF
	.BYTE $FD,$FF,$FF,$FF,$FF,$DF,$FF,$CF
	.BYTE $CF,$FF,$FF,$FF,$FE,$E6,$6E,$6E
	.BYTE $EE,$EE,$E6,$E6,$16,$6E,$6E,$66
	.BYTE $6E,$7E,$66,$67,$E7,$EF,$FF,$EC
	.BYTE $11,$01,$00,$10,$11,$01,$11,$01
	.BYTE $1C,$FF,$FF,$FF,$DF,$CD,$DF,$DC
	.BYTE $DF,$FC,$CD,$CE,$EE,$ED,$C1,$6E
	.BYTE $EE,$EF,$DC,$FD,$FC,$EE,$EC,$DC
	.BYTE $DD,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$CF,$DC,$FD,$FD,$FD,$FD,$CD
	.BYTE $FD,$FF,$DF,$FD,$FF,$FD,$FD,$DC
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD
	.BYTE $FF,$FF,$FF,$CE,$EC,$1C,$EC,$1C
	.BYTE $EE,$CE,$CE,$CE,$CC,$DC,$FF,$DF
	.BYTE $FF,$FF,$FF,$FF,$FD,$FC,$FF,$FF
	.BYTE $CF,$DC,$FE,$E6,$E6,$EF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FE,$E6,$66,$6E,$66
	.BYTE $66,$66,$E7,$E6,$FF,$FF,$FC,$91
	.BYTE $10,$10,$01,$06,$01,$10,$10,$10
	.BYTE $16,$1E,$CE,$EC,$FD,$DF,$CF,$FF
	.BYTE $FF,$EC,$DE,$1E,$FE,$6E,$EE,$16
	.BYTE $E6,$FC,$FE,$EE,$DC,$FC,$FD,$FF
	.BYTE $FF,$FF,$FF,$DF,$FF,$DF,$FD,$FF
	.BYTE $FF,$FF,$FF,$FC,$FF,$DF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FD,$FF,$FF,$FD,$DF
	.BYTE $FF,$FF,$FF,$FF,$7F,$FF,$7F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FE,$EC,$6C,$1E,$1C,$E1
	.BYTE $C1,$CE,$C1,$EC,$EF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$F9,$FF,$FD,$EC,$D9
	.BYTE $FE,$1C,$CE,$EE,$FD,$FF,$CF,$CF
	.BYTE $FD,$FF,$FF,$F6,$FE,$EE,$66,$E6
	.BYTE $E6,$E6,$66,$6F,$FF,$FC,$11,$01
	.BYTE $01,$01,$01,$01,$10,$10,$11,$11
	.BYTE $01,$16,$1E,$E1,$E1,$EE,$FF,$FF
	.BYTE $FE,$1F,$E1,$6F,$DE,$EE,$61,$61
	.BYTE $EE,$FC,$EE,$CE,$FC,$DC,$DC,$DF
	.BYTE $DF,$FD,$FF,$FF,$FD,$FD,$FF,$FD
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$DF,$FF
	.BYTE $FD,$FF,$DF,$FD,$FF,$ED,$9D,$FC
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$CE,$EE,$C1,$C1,$C1
	.BYTE $CE,$EC,$EC,$EE,$FF,$FF,$FF,$FF
	.BYTE $FF,$DE,$FE,$DF,$CE,$C8,$18,$CC
	.BYTE $C8,$C8,$EC,$FF,$FF,$FD,$FC,$FD
	.BYTE $EF,$FC,$FC,$FF,$E6,$E6,$FE,$FE
	.BYTE $66,$6E,$6E,$FE,$10,$11,$11,$10
	.BYTE $11,$01,$01,$01,$10,$11,$01,$06
	.BYTE $06,$01,$61,$11,$EC,$E1,$E1,$1E
	.BYTE $E6,$E1,$EE,$EF,$DE,$6E,$16,$36
	.BYTE $6E,$EE,$EE,$FF,$DF,$FD,$FD,$FF
	.BYTE $FF,$FF,$FF,$FD,$D9,$FF,$FF,$FF
	.BYTE $FF,$DF,$FD,$FD,$FF,$CF,$FF,$DE
	.BYTE $FF,$FF,$CF,$DF,$DF,$CF,$DD,$FD
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF
	.BYTE $CE,$FE,$EF,$FE,$6C,$11,$C1,$6C
	.BYTE $EC,$1C,$EE,$FF,$FF,$FF,$FF,$FE
	.BYTE $E1,$11,$11,$11,$11,$0C,$1C,$18
	.BYTE $1C,$EF,$FF,$FF,$FC,$FF,$FF,$FF
	.BYTE $FC,$FD,$FF,$DF,$DF,$FE,$EF,$FF
	.BYTE $FF,$F7,$66,$F1,$01,$00,$01,$01
	.BYTE $01,$10,$10,$10,$10,$60,$10,$10
	.BYTE $10,$11,$61,$61,$61,$61,$E6,$1E
	.BYTE $16,$11,$6E,$FE,$EE,$E6,$16,$11
	.BYTE $11,$6E,$EF,$EF,$FF,$FF,$FF,$FD
	.BYTE $FF,$FF,$FF,$FF,$DF,$FF,$FF,$FF
	.BYTE $FF,$DF,$FC,$ED,$CC,$CC,$FF,$FC
	.BYTE $FF,$FC,$9D,$DF,$DE,$DD,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$7F,$F7,$FF,$FF,$FF,$FF
	.BYTE $FC,$EC,$6C,$1C,$E1,$CE,$1C,$E1
	.BYTE $CE,$FF,$FF,$FF,$FD,$FE,$CE,$16
	.BYTE $16,$16,$11,$60,$01,$01,$11,$1E
	.BYTE $FF,$FF,$FF,$FD,$FF,$FF,$FD,$FD
	.BYTE $FD,$FE,$DF,$CF,$FD,$FD,$FF,$FF
	.BYTE $FF,$FF,$FE,$F0,$10,$11,$01,$01
	.BYTE $01,$01,$01,$01,$01,$01,$06,$06
	.BYTE $06,$16,$16,$11,$61,$11,$61,$61
	.BYTE $11,$36,$01,$66,$61,$01,$01,$16
	.BYTE $11,$EE,$EF,$FF,$FF,$FF,$FF,$FF
	.BYTE $EF,$DF,$FF,$DD,$EF,$EF,$FF,$FD
	.BYTE $DF,$DF,$DF,$CF,$9C,$CC,$CC,$CC
	.BYTE $FC,$CF,$DD,$FC,$FE,$DF,$DF,$DF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF
	.BYTE $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $E1,$1C,$11,$1C,$16,$CE,$DE,$FF
	.BYTE $FF,$FF,$FF,$CF,$FF,$FF,$EE,$CE
	.BYTE $CE,$16,$00,$60,$60,$61,$1E,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FD,$FC,$FC
	.BYTE $FC,$FC,$FF,$DF,$CF,$FD,$FF,$FF
	.BYTE $FF,$FF,$DE,$F1,$11,$01,$01,$01
	.BYTE $01,$01,$00,$10,$60,$60,$11,$11
	.BYTE $61,$61,$16,$16,$16,$61,$11,$06
	.BYTE $06,$01,$00,$00,$06,$03,$10,$11
	.BYTE $6E,$6E,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $CF,$FE,$FF,$CF,$DE,$DF,$DD,$CD
	.BYTE $CD,$CF,$CD,$FC,$FC,$EC,$8C,$9C
	.BYTE $CC,$CC,$DF,$DF,$ED,$EF,$FF,$EC
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$7F,$EF,$FF,$7F,$FF,$FF
	.BYTE $EC,$11,$14,$11,$CE,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FE,$FC,$ED,$ED,$EE
	.BYTE $E0,$10,$60,$10,$60,$60,$6F,$FF
	.BYTE $FF,$FF,$FF,$FF,$DC,$FC,$FD,$FC
	.BYTE $FD,$FD,$FC,$EE,$CE,$EF,$CC,$FD
	.BYTE $FC,$C1,$EE,$F8,$11,$10,$11,$10
	.BYTE $10,$10,$00,$60,$11,$61,$61,$60
	.BYTE $11,$61,$61,$10,$11,$06,$06,$01
	.BYTE $00,$60,$11,$01,$12,$06,$06,$26
	.BYTE $16,$16,$16,$EF,$FF,$FF,$FF,$DE
	.BYTE $9E,$EE,$EC,$EE,$EE,$CE,$CF,$DF
	.BYTE $FF,$FD,$FD,$FD,$FF,$DF,$FF,$DF
	.BYTE $FC,$FC,$D8,$CC,$CC,$CF,$CF,$1C
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$7F,$EF
	.BYTE $FE,$FF,$FF,$F7,$EF,$FF,$FF,$FF
	.BYTE $E1,$C1,$1C,$11,$1C,$FC,$CE,$EE
	.BYTE $CE,$EC,$1E,$CF,$FC,$FE,$FC,$60
	.BYTE $60,$60,$60,$60,$10,$10,$1C,$EF
	.BYTE $EE,$EE,$6E,$FF,$FF,$FD,$9F,$DF
	.BYTE $9F,$FF,$FF,$DF,$DF,$FF,$FC,$FF
	.BYTE $FF,$DF,$DE,$C1,$11,$01,$10,$10
	.BYTE $11,$01,$00,$60,$61,$60,$61,$16
	.BYTE $10,$00,$10,$61,$60,$10,$11,$61
	.BYTE $61,$16,$06,$06,$06,$01,$06,$01
	.BYTE $16,$11,$16,$11,$EF,$CD,$FF,$FC
	.BYTE $EC,$61,$EE,$66,$6E,$EF,$DD,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FD,$FD,$FD
	.BYTE $FD,$FD,$DF,$EE,$DE,$CE,$CC,$EC
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $EC,$11,$11,$1C,$1E,$DF,$FC,$CF
	.BYTE $11,$11,$41,$EC,$E6,$CE,$11,$01
	.BYTE $00,$60,$16,$06,$06,$06,$01,$0C
	.BYTE $01,$1E,$FF,$CF,$DF,$DF,$FC,$FF
	.BYTE $FF,$FC,$CF,$FC,$FF,$FF,$FF,$FE
	.BYTE $EE,$E1,$16,$FE,$F6,$10,$11,$10
	.BYTE $10,$60,$11,$11,$60,$16,$01,$01
	.BYTE $06,$16,$06,$11,$06,$61,$61,$11
	.BYTE $06,$16,$16,$16,$16,$16,$61,$61
	.BYTE $11,$61,$61,$16,$11,$E8,$C9,$6E
	.BYTE $1C,$11,$66,$16,$EE,$FF,$FF,$DF
	.BYTE $FF,$FF,$FF,$FF,$FD,$FF,$DE,$DF
	.BYTE $DF,$DD,$FD,$EC,$EC,$FD,$E1,$1C
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FF,$7F,$FF,$FF,$FF,$FF,$FF
	.BYTE $61,$41,$C1,$1C,$1F,$CF,$EE,$C1
	.BYTE $11,$11,$11,$1C,$E1,$16,$06,$06
	.BYTE $00,$60,$00,$10,$06,$00,$11,$10
	.BYTE $C1,$1C,$FF,$FF,$CE,$EE,$11,$CE
	.BYTE $DC,$FF,$FC,$FF,$FD,$FF,$E1,$EE
	.BYTE $EE,$FF,$FF,$FF,$FF,$FE,$01,$11
	.BYTE $10,$10,$61,$61,$11,$06,$06,$01
	.BYTE $10,$10,$16,$66,$11,$61,$66,$61
	.BYTE $61,$16,$11,$61,$06,$11,$11,$61
	.BYTE $61,$61,$16,$11,$1C,$1C,$1C,$11
	.BYTE $11,$11,$36,$E6,$6E,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$DF,$FD,$FC,$FC,$FF
	.BYTE $CF,$DC,$FC,$EE,$CF,$DC,$6C,$1C
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$EF,$FF,$FF,$FF,$FF
	.BYTE $EC,$11,$14,$11,$CF,$FD,$EC,$11
	.BYTE $10,$41,$01,$11,$11,$11,$01,$06
	.BYTE $06,$00,$60,$60,$00,$16,$01,$11
	.BYTE $01,$C1,$C1,$C1,$18,$CE,$C1,$C1
	.BYTE $1E,$FF,$FF,$FE,$CE,$16,$1F,$FF
	.BYTE $FE,$C1,$EF,$FF,$EC,$EE,$CE,$16
	.BYTE $61,$61,$10,$00,$60,$11,$11,$61
	.BYTE $60,$61,$61,$16,$16,$16,$11,$61
	.BYTE $61,$61,$16,$11,$61,$66,$66,$16
	.BYTE $11,$61,$61,$61,$61,$18,$1C,$11
	.BYTE $61,$61,$66,$6E,$E1,$11,$E1,$EC
	.BYTE $FD,$FD,$FF,$DF,$FF,$FF,$C9,$CF
	.BYTE $DF,$DF,$DE,$E1,$DD,$C1,$16,$EF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$F7,$FF,$7F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $E1,$1C,$11,$11,$CF,$CF,$F4,$11
	.BYTE $11,$11,$11,$04,$11,$06,$06,$00
	.BYTE $01,$01,$00,$60,$60,$00,$10,$1C
	.BYTE $16,$EC,$11,$1C,$EC,$11,$11,$11
	.BYTE $1E,$FF,$FE,$EE,$61,$61,$EE,$C0
	.BYTE $C0,$1E,$EF,$CE,$CE,$C1,$EC,$E1
	.BYTE $11,$01,$61,$61,$61,$61,$61,$16
	.BYTE $16,$16,$16,$16,$11,$61,$61,$61
	.BYTE $61,$61,$61,$61,$61,$11,$11,$61
	.BYTE $66,$16,$16,$11,$11,$E1,$18,$11
	.BYTE $63,$11,$01,$11,$11,$1E,$C1,$EE
	.BYTE $11,$1E,$EC,$FF,$FF,$FF,$CE,$CF
	.BYTE $FD,$FD,$FD,$CF,$FF,$E6,$1C,$EF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$7F,$FF,$FF,$FF,$FF,$FC
	.BYTE $1C,$1C,$1C,$14,$EF,$CF,$CE,$11
	.BYTE $01,$10,$11,$10,$11,$01,$00,$60
	.BYTE $60,$10,$60,$01,$00,$60,$60,$11
	.BYTE $C1,$C6,$C1,$11,$11,$1C,$0C,$01
	.BYTE $01,$1C,$11,$16,$E6,$10,$C0,$11
	.BYTE $01,$0C,$11,$11,$11,$1C,$11,$91
	.BYTE $11,$61,$1E,$EE,$EE,$61,$61,$61
	.BYTE $11,$61,$16,$11,$61,$61,$61,$61
	.BYTE $66,$61,$61,$61,$66,$61,$61,$16
	.BYTE $11,$61,$61,$66,$61,$61,$1E,$11
	.BYTE $16,$61,$61,$11,$61,$11,$11,$11
	.BYTE $1E,$16,$11,$11,$1C,$EC,$11,$81
	.BYTE $EE,$CF,$EF,$CF,$FF,$16,$16,$E1
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$DF,$FC
	.BYTE $E1,$14,$E1,$1C,$EC,$FE,$EC,$04
	.BYTE $10,$41,$10,$41,$11,$60,$60,$60
	.BYTE $01,$00,$60,$10,$60,$00,$11,$11
	.BYTE $EE,$EE,$C0,$C0,$40,$10,$11,$40
	.BYTE $11,$11,$11,$01,$01,$10,$11,$01
	.BYTE $01,$00,$C1,$10,$11,$1C,$1C,$1C
	.BYTE $11,$11,$1E,$EC,$EE,$EE,$EE,$E1
	.BYTE $61,$61,$61,$61,$61,$61,$61,$61
	.BYTE $16,$16,$16,$16,$16,$16,$66,$16
	.BYTE $16,$11,$16,$11,$61,$61,$61,$11
	.BYTE $11,$61,$16,$60,$61,$60,$61,$11
	.BYTE $11,$11,$61,$61,$61,$11,$1C,$1E
	.BYTE $11,$1E,$11,$EE,$F1,$61,$14,$1C
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FE,$E4
	.BYTE $E1,$C1,$1C,$1E,$FC,$FC,$EE,$11
	.BYTE $01,$10,$11,$10,$40,$01,$01,$06
	.BYTE $01,$01,$00,$60,$01,$10,$01,$41
	.BYTE $CE,$CE,$C1,$11,$01,$41,$40,$11
	.BYTE $04,$01,$40,$16,$01,$00,$10,$10
	.BYTE $10,$01,$00,$11,$11,$C1,$E1,$11
	.BYTE $01,$11,$41,$CC,$CC,$1C,$CC,$1C
	.BYTE $16,$11,$16,$16,$16,$16,$16,$16
	.BYTE $16,$16,$61,$61,$61,$61,$61,$61
	.BYTE $61,$66,$11,$61,$61,$61,$66,$16
	.BYTE $16,$16,$61,$61,$66,$66,$16,$61
	.BYTE $60,$60,$11,$61,$11,$61,$11,$11
	.BYTE $61,$61,$61,$61,$61,$11,$C1,$1E
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$DE,$1C
	.BYTE $E1,$1C,$1C,$1C,$EC,$F1,$C1,$01
	.BYTE $41,$14,$11,$11,$11,$11,$06,$00
	.BYTE $60,$10,$10,$10,$10,$06,$01,$11
	.BYTE $6C,$EE,$41,$04,$11,$01,$11,$41
	.BYTE $01,$11,$60,$06,$06,$06,$01,$06
	.BYTE $06,$00,$60,$01,$01,$01,$10,$10
	.BYTE $10,$00,$16,$11,$01,$11,$9C,$1E
	.BYTE $E6,$66,$11,$61,$61,$16,$16,$16
	.BYTE $16,$16,$16,$16,$16,$16,$16,$16
	.BYTE $16,$16,$16,$16,$11,$61,$16,$16
	.BYTE $16,$61,$61,$66,$16,$16,$66,$16
	.BYTE $66,$16,$61,$16,$61,$11,$C1,$61
	.BYTE $61,$11,$60,$61,$66,$11,$1C,$C1
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$F7,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FE,$EE
	.BYTE $6C,$61,$E1,$6C,$EE,$DE,$61,$C1
	.BYTE $11,$10,$14,$01,$40,$11,$10,$06
	.BYTE $00,$10,$10,$10,$60,$10,$06,$1C
	.BYTE $EF,$CE,$11,$C0,$0C,$0C,$01,$01
	.BYTE $14,$01,$11,$01,$01,$00,$60,$60
	.BYTE $00,$06,$01,$60,$10,$10,$01,$01
	.BYTE $01,$01,$61,$01,$10,$11,$EF,$FF
	.BYTE $F6,$EF,$7E,$61,$16,$11,$61,$61
	.BYTE $61,$61,$61,$61,$61,$66,$66,$16
	.BYTE $61,$61,$61,$16,$16,$16,$16,$16
	.BYTE $16,$16,$61,$61,$66,$66,$16,$61
	.BYTE $61,$61,$66,$61,$61,$61,$11,$16
	.BYTE $16,$61,$61,$16,$01,$61,$11,$11
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$F7,$FF,$FF,$FF,$FD,$FC,$1C
	.BYTE $1C,$CC,$1C,$11,$1F,$EC,$10,$C1
	.BYTE $C1,$C1,$01,$11,$11,$11,$06,$01
	.BYTE $01,$01,$06,$00,$01,$01,$0C,$6E
	.BYTE $C7,$C1,$C0,$14,$01,$10,$C0,$41
	.BYTE $01,$16,$06,$06,$06,$10,$10,$06
	.BYTE $10,$01,$00,$10,$60,$10,$00,$10
	.BYTE $10,$00,$01,$01,$01,$1E,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$EF,$EE,$11,$61
	.BYTE $61,$16,$11,$61,$16,$11,$16,$11
	.BYTE $61,$61,$61,$61,$16,$11,$61,$61
	.BYTE $61,$6E,$61,$66,$16,$16,$61,$66
	.BYTE $16,$66,$16,$16,$61,$66,$66,$66
	.BYTE $16,$16,$66,$66,$16,$11,$01,$0C
	.BYTE $FF,$FF,$FF,$FF,$7F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$7F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$6C,$6C
	.BYTE $16,$11,$41,$1C,$6C,$E1,$11,$11
	.BYTE $11,$01,$1C,$01,$14,$01,$10,$01
	.BYTE $06,$00,$10,$11,$06,$01,$06,$1C
	.BYTE $FF,$F1,$40,$11,$14,$04,$01,$10
	.BYTE $14,$0C,$01,$00,$60,$06,$06,$00
	.BYTE $00,$00,$60,$60,$06,$00,$60,$06
	.BYTE $00,$00,$10,$00,$60,$EF,$FF,$FF
	.BYTE $FF,$DF,$CF,$FF,$FD,$FE,$FE,$E6
	.BYTE $16,$11,$61,$16,$11,$61,$16,$16
	.BYTE $16,$16,$16,$16,$16,$16,$11,$61
	.BYTE $61,$61,$61,$6E,$66,$E6,$66,$61
	.BYTE $61,$16,$16,$16,$16,$16,$16,$16
	.BYTE $61,$61,$16,$16,$66,$66,$66,$61
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$7F,$7F,$FF,$FF,$FF,$E1,$C6
	.BYTE $CC,$E1,$C1,$C1,$EE,$D1,$41,$14
	.BYTE $14,$11,$11,$40,$11,$06,$06,$01
	.BYTE $00,$60,$10,$10,$00,$60,$0E,$E4
	.BYTE $EC,$E1,$C0,$C1,$01,$11,$C0,$41
	.BYTE $01,$11,$60,$60,$06,$01,$06,$06
	.BYTE $00,$00,$10,$06,$01,$00,$00,$00
	.BYTE $60,$10,$06,$00,$0F,$FF,$FF,$FF
	.BYTE $FE,$EF,$DD,$FF,$FF,$DF,$EF,$EE
	.BYTE $E1,$66,$16,$16,$66,$61,$61,$61
	.BYTE $11,$61,$16,$16,$11,$61,$61,$16
	.BYTE $16,$16,$16,$61,$66,$16,$16,$16
	.BYTE $66,$61,$66,$16,$66,$16,$16,$16
	.BYTE $16,$61,$61,$61,$16,$16,$E6,$16
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$DF,$CE,$1C
	.BYTE $14,$1C,$E1,$C1,$CE,$F1,$11,$C0
	.BYTE $11,$14,$01,$11,$11,$10,$01,$06
	.BYTE $06,$00,$60,$10,$60,$01,$61,$CE
	.BYTE $FD,$61,$11,$0C,$0C,$01,$11,$11
	.BYTE $11,$11,$01,$01,$10,$60,$60,$00
	.BYTE $01,$06,$06,$00,$10,$60,$10,$60
	.BYTE $00,$00,$00,$06,$FF,$FF,$FF,$FD
	.BYTE $F0,$EE,$EC,$CC,$EE,$EE,$EE,$EE
	.BYTE $E6,$E1,$16,$11,$16,$E6,$61,$16
	.BYTE $16,$16,$11,$61,$61,$61,$61,$61
	.BYTE $61,$61,$61,$61,$61,$66,$E6,$61
	.BYTE $16,$16,$16,$61,$61,$66,$16,$61
	.BYTE $61,$16,$11,$61,$61,$61,$10,$10
	.BYTE $FF,$FF,$7F,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $7F,$FF,$FF,$FF,$FF,$FC,$6C,$6C
	.BYTE $E1,$CF,$C1,$11,$CE,$C4,$11,$C1
	.BYTE $11,$11,$41,$10,$41,$11,$16,$00
	.BYTE $00,$60,$06,$10,$60,$60,$16,$EC
	.BYTE $EF,$C0,$41,$01,$10,$40,$C0,$40
	.BYTE $41,$16,$06,$06,$00,$10,$06,$10
	.BYTE $60,$00,$00,$60,$60,$00,$00,$06
	.BYTE $06,$10,$60,$EF,$FD,$DF,$FF,$FE
	.BYTE $01,$00,$10,$10,$10,$11,$11,$11
	.BYTE $11,$11,$11,$11,$61,$61,$66,$16
	.BYTE $16,$16,$16,$11,$61,$61,$61,$61
	.BYTE $61,$61,$61,$61,$61,$61,$61,$66
	.BYTE $66,$66,$16,$16,$16,$16,$61,$61
	.BYTE $66,$61,$61,$11,$61,$11,$0C,$0C
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
