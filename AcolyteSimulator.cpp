// Acolyte Simulator

// Uses OpenGL GLFW

// To download required libraries, use:

// sudo apt-get install g++ libglfw3-dev libglu1-mesa-dev

// (and maybe others?  Mesa packages for Linux?  Mingw perhaps?)

// Use this to compile:

// g++ -o AcolyteSimulator.o AcolyteSimulator.cpp -lglfw -lGL -lGLU

// Then to execute:

// ./AcolyteSimulator.o <binary_file>

// The <binary_file> is whatever .bin file would be on the ROM chip.

// For Windows, use Code::Blocks and download the GLFW Pre-Compiled Libraries, and just toss those into the folders needed ("include" and "lib").

// Do not use the GLFW project, but use a blank project, and use the linker to put in all kinds of things.

// Also remember you need <windows.h> for any Windows program!



#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <string.h>

#include <GLFW/glfw3.h>
#include <GL/gl.h>
#include <GL/glu.h>

#include "mos6502/mos6502.cpp" // this is actually Agumander's version

bool verbose = false; // change to display reach read/write action

int open_window_x = 640;
int open_window_y = 480;

int open_cursor_new_x = 0;
int open_cursor_new_y = 0;
int open_cursor_old_x = 0;
int open_cursor_old_y = 0;

int open_keyboard_state[512];
int open_button_state[16];

int open_frames_per_second = 0;
int open_frames_per_second_counter = 0;
int open_frames_per_second_timer = 0;

int open_frames_limit = 120; // this is frames per second, cannot be more than 60 though! (yet, it works best this way)
double open_frames_difference = (1.0f / (double)open_frames_limit) * (double)CLOCKS_PER_SEC;
double open_frames_counter = 0.0f;
double open_frames_previous = 0.0f;
double open_frames_current = 0.0f;
bool open_frames_drawing = true;
int open_frames_drawing_counter = 0;
float open_frames_delta = 0.0f;

clock_t open_clock_previous, open_clock_current;


uint8_t RAM[65536]; // RAM
uint8_t ROM[16384]; // ROM
uint16_t READ_ONLY = 0xC000; // Read-only below this line
uint16_t KEY_ARRAY = 0x0200; // need the location for keyboard buffer
uint16_t KEY_POS_WRITE = 0x0280; // need the location for keyboard buffer
uint16_t VIA_PAGE = 0x0700; // full page of $FF
uint16_t CLOCK_LOW = 0x02FE;
uint16_t CLOCK_HIGH = 0x02FF;

float color[2][3];

bool mono_video = false;
bool joystick = false;

mos6502 *CPU;

void WriteFunction(uint16_t address, uint8_t value)
{
	if (verbose) printf("Write %04x %02x\n", address, value);

	if (address < READ_ONLY)
	{
		if ((address&0xFF00) == VIA_PAGE)
		{
			RAM[address] = value;
		}
		else RAM[address] = value;
	}
	else
	{
		// write to ROM
		//printf("Write to ROM\nA=%02x X=%02x Y=%02x S=%02x P=%04x R=%02x\n", CPU->A, CPU->X, CPU->Y, CPU->sp, CPU->pc, CPU->status);

		if (value != 0x00)
		{
			uint8_t bits = value & 0xF0;
	
			if (bits == 0x00) { color[1][0] = 0.0f; color[1][1] = 0.0f; color[1][2] = 0.0f; } // black
			else if (bits == 0x10) { color[1][0] = 200.0f/700.0f; color[1][1] = 200.0f/700.0f; color[1][2] = 200.0f/700.0f; } // dark grey
			else if (bits == 0x20) { color[1][0] = 0.0f; color[1][1] = 0.0f; color[1][2] = 425.0f/700.0f; } // dark blue
			else if (bits == 0x30) { color[1][0] = 200.0f/700.0f; color[1][1] = 200.0f/700.0f; color[1][2] = 625.0f/700.0f; } // bright blue
			else if (bits == 0x40) { color[1][0] = 0.0f; color[1][1] = 425.0f/700.0f; color[1][2] = 0.0f; } // dark green
			else if (bits == 0x50) { color[1][0] = 200.0f/700.0f; color[1][1] = 625.0f/700.0f; color[1][2] = 200.0f/700.0f; } // bright green
			else if (bits == 0x60) { color[1][0] = 0.0f; color[1][1] = 425.0f/700.0f; color[1][2] = 425.0f/700.0f; } // dark cyan
			else if (bits == 0x70) { color[1][0] = 200.0f/700.0f; color[1][1] = 625.0f/700.0f; color[1][2] = 625.0f/700.0f; } // bright cyan

			else if (bits == 0x80) { color[1][0] = 425.0f/700.0f; color[1][1] = 0.0f; color[1][2] = 0.0f; } // dark red
			else if (bits == 0x90) { color[1][0] = 625.0f/700.0f; color[1][1] = 200.0f/700.0f; color[1][2] = 200.0f/700.0f; } // bright red
			else if (bits == 0xA0) { color[1][0] = 425.0f/700.0f; color[1][1] = 0.0f; color[1][2] = 425.0f/700.0f; } // dark magenta
			else if (bits == 0xB0) { color[1][0] = 625.0f/700.0f; color[1][1] = 200.0f/700.0f; color[1][2] = 625.0f/700.0f; } // bright magenta
			else if (bits == 0xC0) { color[1][0] = 425.0f/700.0f; color[1][1] = 425.0f/700.0f; color[1][2] = 0.0f; } // dark yellow
			else if (bits == 0xD0) { color[1][0] = 625.0f/700.0f; color[1][1] = 625.0f/700.0f; color[1][2] = 200.0f/700.0f; } // bright yellow
			else if (bits == 0xE0) { color[1][0] = 425.0f/700.0f; color[1][1] = 425.0f/700.0f; color[1][2] = 425.0f/700.0f; } // bright grey
			else if (bits == 0xF0) { color[1][0] = 625.0f/700.0f; color[1][1] = 625.0f/700.0f; color[1][2] = 625.0f/700.0f; } // white

			bits = value & 0x0F;
	
			if (bits == 0x00) { color[0][0] = 0.0f; color[0][1] = 0.0f; color[0][2] = 0.0f; } // black
			else if (bits == 0x01) { color[0][0] = 200.0f/700.0f; color[0][1] = 200.0f/700.0f; color[0][2] = 200.0f/700.0f; } // dark grey
			else if (bits == 0x02) { color[0][0] = 0.0f; color[0][1] = 0.0f; color[0][2] = 425.0f/700.0f; } // dark blue
			else if (bits == 0x03) { color[0][0] = 200.0f/700.0f; color[0][1] = 200.0f/700.0f; color[0][2] = 625.0f/700.0f; } // bright blue
			else if (bits == 0x04) { color[0][0] = 0.0f; color[0][1] = 425.0f/700.0f; color[0][2] = 0.0f; } // dark green
			else if (bits == 0x05) { color[0][0] = 200.0f/700.0f; color[0][1] = 625.0f/700.0f; color[0][2] = 200.0f/700.0f; } // bright green
			else if (bits == 0x06) { color[0][0] = 0.0f; color[0][1] = 425.0f/700.0f; color[0][2] = 425.0f/700.0f; } // dark cyan
			else if (bits == 0x07) { color[0][0] = 200.0f/700.0f; color[0][1] = 625.0f/700.0f; color[0][2] = 625.0f/700.0f; } // bright cyan

			else if (bits == 0x08) { color[0][0] = 425.0f/700.0f; color[0][1] = 0.0f; color[0][2] = 0.0f; } // dark red
			else if (bits == 0x09) { color[0][0] = 625.0f/700.0f; color[0][1] = 200.0f/700.0f; color[0][2] = 200.0f/700.0f; } // bright red
			else if (bits == 0x0A) { color[0][0] = 425.0f/700.0f; color[0][1] = 0.0f; color[0][2] = 425.0f/700.0f; } // dark magenta
			else if (bits == 0x0B) { color[0][0] = 625.0f/700.0f; color[0][1] = 200.0f/700.0f; color[0][2] = 625.0f/700.0f; } // bright magenta
			else if (bits == 0x0C) { color[0][0] = 425.0f/700.0f; color[0][1] = 425.0f/700.0f; color[0][2] = 0.0f; } // dark yellow
			else if (bits == 0x0D) { color[0][0] = 625.0f/700.0f; color[0][1] = 625.0f/700.0f; color[0][2] = 200.0f/700.0f; } // bright yellow
			else if (bits == 0x0E) { color[0][0] = 425.0f/700.0f; color[0][1] = 425.0f/700.0f; color[0][2] = 425.0f/700.0f; } // bright grey
			else if (bits == 0x0F) { color[0][0] = 625.0f/700.0f; color[0][1] = 625.0f/700.0f; color[0][2] = 625.0f/700.0f; } // white		

			mono_video = true;
		}
		else mono_video = false;
	}
};

uint8_t ReadFunction(uint16_t address)
{
	if (address < READ_ONLY)
	{
		if (verbose) printf("Read %04x %02x\n", address, RAM[address]);	

		if ((address&0xFF00) == VIA_PAGE)
		{
			if (address == (VIA_PAGE + 0x000D))
			{
				return 0x00;
			}
			else if (address == (VIA_PAGE + 0x0000))
			{
				return RAM[address];
			}
			else if (address == (VIA_PAGE + 0x0001))
			{
				if ((RAM[(VIA_PAGE+0x0000)]&0x08) == 0x00 && joystick == true) return 0xF3;
				else return 0xFF;
			}
			else if (address == (VIA_PAGE + 0x0008))
			{
				return rand() % 256;
			}
			else return 0xFF;	
		}
		else return RAM[address];
	}
	else 
	{
		if (verbose) printf("Read %04x %02x\n", address, ROM[address-READ_ONLY]);
		
		return ROM[address-READ_ONLY];
	}
};


uint8_t PS2KeyCode(int key)
{
	switch (key)
	{
		case GLFW_KEY_UNKNOWN:
		{
			return 0x00;
		}
 
		case GLFW_KEY_SPACE:
		{
			return 0x29;
		}
 
		case GLFW_KEY_APOSTROPHE:
		{
			return 0x52;
		}
 
		case GLFW_KEY_COMMA:
		{
			return 0x41;
		}
 
		case GLFW_KEY_MINUS:
		{
			return 0x4E;
		}
 
		case GLFW_KEY_PERIOD:
		{
			return 0x49;
		}
 
		case GLFW_KEY_SLASH:
		{
			return 0x4A;
		}

		case GLFW_KEY_0:
		{
			return 0x45;
		}
 
		case GLFW_KEY_1:
		{
			return 0x16;
		}
 
		case GLFW_KEY_2:
		{
			return 0x1E;
		}
 
		case GLFW_KEY_3:
		{
			return 0x26;
		}
 
		case GLFW_KEY_4:
		{
			return 0x25;
		}
 
		case GLFW_KEY_5:
		{
			return 0x2E;
		}
 
		case GLFW_KEY_6:
		{
			return 0x36;
		}
 
		case GLFW_KEY_7:
		{
			return 0x3D;
		}
 
		case GLFW_KEY_8:
		{
			return 0x3E;
		}
 
		case GLFW_KEY_9:
		{
			return 0x46;
		}
 
		case GLFW_KEY_SEMICOLON:
		{
			return 0x4C;
		}
 
		case GLFW_KEY_EQUAL:
		{
			return 0x55;
		}
 
		case GLFW_KEY_A:
		{
			return 0x1C;
		}
 
		case GLFW_KEY_B:
		{
			return 0x32;
		}

		case GLFW_KEY_C:
		{
			return 0x21;
		}

		case GLFW_KEY_D:
		{
			return 0x23;
		}

		case GLFW_KEY_E:
		{
			return 0x24;
		}

		case GLFW_KEY_F:
		{
			return 0x2B;
		}

		case GLFW_KEY_G:
		{
			return 0x34;
		}
	
		case GLFW_KEY_H:
		{
			return 0x33;
		}

		case GLFW_KEY_I:
		{
			return 0x43;
		}

		case GLFW_KEY_J:
		{
			return 0x3B;
		}

		case GLFW_KEY_K:
		{
			return 0x42;
		}

		case GLFW_KEY_L:
		{
			return 0x4B;
		}

		case GLFW_KEY_M:
		{
			return 0x3A;
		}

		case GLFW_KEY_N:
		{
			return 0x31;
		}

		case GLFW_KEY_O:
		{
			return 0x44;
		}

		case GLFW_KEY_P:
		{
			return 0x4D;
		}

		case GLFW_KEY_Q:
		{
			return 0x15;
		}

		case GLFW_KEY_R:
		{
			return 0x2D;
		}

		case GLFW_KEY_S:
		{
			return 0x1B;
		}

		case GLFW_KEY_T:
		{
			return 0x2C;
		}

		case GLFW_KEY_U:
		{
			return 0x3C;
		}
		
		case GLFW_KEY_V:
		{
			return 0x2A;
		}

		case GLFW_KEY_W:
		{
			return 0x1D;
		}

		case GLFW_KEY_X:
		{
			return 0x22;	
		}
		
		case GLFW_KEY_Y:
		{
			return 0x35;
		}

		case GLFW_KEY_Z:
		{
			return 0x1A;
		}

		case GLFW_KEY_LEFT_BRACKET:
		{
			return 0x54;
		}
 
		case GLFW_KEY_BACKSLASH:
		{
			return 0x5D;
		}
 
		case GLFW_KEY_RIGHT_BRACKET:
		{
			return 0x5B;
		}
 
		case GLFW_KEY_GRAVE_ACCENT:
		{
			return 0x0E;
		}
 
		case GLFW_KEY_WORLD_1:
		{
			return 0x00;
		}
 
		case GLFW_KEY_WORLD_2:
		{
			return 0x00;
		}
 
		case GLFW_KEY_ESCAPE:
		{
			return 0x76;
		}
 
		case GLFW_KEY_ENTER:
		{
			return 0x5A;
		}

		case GLFW_KEY_TAB:
		{
			return 0x0D;
		}
 
		case GLFW_KEY_BACKSPACE:
		{
			return 0x66;
		}
 
		case GLFW_KEY_CAPS_LOCK:
		{
			return 0x58;
		}
 
		case GLFW_KEY_SCROLL_LOCK:
		{
			return 0x7E;
		}
 
		case GLFW_KEY_NUM_LOCK:
		{
			return 0x77;
		}
 
		case GLFW_KEY_F1:
		{
			return 0x05;
		}

		case GLFW_KEY_F2:
		{
			return 0x06;
		}

		case GLFW_KEY_F3:
		{
			return 0x04;
		}

		case GLFW_KEY_F4:
		{
			return 0x0C;
		}

		case GLFW_KEY_F5:
		{
			return 0x03;
		}

		case GLFW_KEY_F6:
		{
			return 0x0B;
		}

		case GLFW_KEY_F7:
		{
			return 0x83;
		}

		case GLFW_KEY_F8:
		{
			return 0x0A;
		}

		case GLFW_KEY_F9:
		{
			return 0x01;
		}

		case GLFW_KEY_F10:
		{
			return 0x09;
		}

		case GLFW_KEY_F11:
		{
			return 0x78;
		}

		case GLFW_KEY_F12:
		{
			return 0x07;
		}
 
		case GLFW_KEY_KP_0:
		{
			return 0x70;
		}
 
		case GLFW_KEY_KP_1:
		{
			return 0x69;
		}
 
		case GLFW_KEY_KP_2:
		{
			return 0x72;
		}
 
		case GLFW_KEY_KP_3:
		{
			return 0x7A;
		}
 
		case GLFW_KEY_KP_4:
		{
			return 0x6B;
		}
 
		case GLFW_KEY_KP_5:
		{
			return 0x73;
		}
 
		case GLFW_KEY_KP_6:
		{
			return 0x74;
		}
 
		case GLFW_KEY_KP_7:
		{
			return 0x6C;
		}
 
		case GLFW_KEY_KP_8:
		{
			return 0x75;
		}
 
		case GLFW_KEY_KP_9:
		{
			return 0x7D;
		}
 
		case GLFW_KEY_KP_DECIMAL:
		{
			return 0x71;
		}

		case GLFW_KEY_KP_MULTIPLY:
		{
			return 0x7C;
		}
 
		case GLFW_KEY_KP_SUBTRACT:
		{
			return 0x7B;
		}
 
		case GLFW_KEY_KP_ADD:
		{
			return 0x79;
		}
 
		case GLFW_KEY_LEFT_SHIFT:
		{
			return 0x12;
		}

		case GLFW_KEY_LEFT_CONTROL:
		{
			return 0x14;
		}
 
		case GLFW_KEY_LEFT_ALT:
		{
			return 0x11;
		}
 
		case GLFW_KEY_RIGHT_SHIFT:
		{
			return 0x59;
		}

		case GLFW_KEY_INSERT:
		{
			return 0xE0;
		}
 
		case GLFW_KEY_DELETE:
		{
			return 0xE0;
		}
 
		case GLFW_KEY_RIGHT:
		{
			return 0xE0;
		}
 
		case GLFW_KEY_LEFT:
		{
			return 0xE0;
		}
 
		case GLFW_KEY_DOWN:
		{
			return 0xE0;
		}
 
		case GLFW_KEY_UP:
		{
			return 0xE0;
		}
 
		case GLFW_KEY_PAGE_UP:
		{
			return 0xE0;
		}
 
		case GLFW_KEY_PAGE_DOWN:
		{
			return 0xE0;
		}
 
		case GLFW_KEY_HOME:
		{
			return 0xE0;
		}
 
		case GLFW_KEY_END:
		{
			return 0xE0;
		}

		case GLFW_KEY_KP_DIVIDE:
		{
			return 0xE0;
		}

		case GLFW_KEY_KP_ENTER:
		{
			return 0xE0;
		}

		case GLFW_KEY_RIGHT_CONTROL:
		{
			return 0xE0;
		}
 
		case GLFW_KEY_RIGHT_ALT:
		{
			return 0xE0;
		}

		case GLFW_KEY_PRINT_SCREEN:
		{
			return 0x00;
		}
 
		case GLFW_KEY_PAUSE:
		{
			return 0x00;
		}

		default:
		{
			return 0x00;
		}
	}

	return 0x00;
};

uint8_t PS2ExtendedKeyCode(int key)
{
	switch (key)
	{
		case GLFW_KEY_INSERT:
		{
			return 0x70;
		}
 
		case GLFW_KEY_DELETE:
		{
			return 0x71;
		}
 
		case GLFW_KEY_RIGHT:
		{
			return 0x74;
		}
 
		case GLFW_KEY_LEFT:
		{
			return 0x6B;
		}
 
		case GLFW_KEY_DOWN:
		{
			return 0x72;
		}
 
		case GLFW_KEY_UP:
		{
			return 0x75;
		}
 
		case GLFW_KEY_PAGE_UP:
		{
			return 0x7D;
		}
 
		case GLFW_KEY_PAGE_DOWN:
		{
			return 0x7A;
		}
 
		case GLFW_KEY_HOME:
		{
			return 0x6C;
		}
 
		case GLFW_KEY_END:
		{
			return 0x69;
		}

		case GLFW_KEY_KP_DIVIDE:
		{
			return 0x4A;
		}

		case GLFW_KEY_KP_ENTER:
		{
			return 0x5A;
		}

		case GLFW_KEY_RIGHT_CONTROL:
		{
			return 0x14;
		}
 
		case GLFW_KEY_RIGHT_ALT:
		{
			return 0x11;
		}

		default:
		{
			return 0x00;
		}
	}

	return 0x00;
};


void InitializeOpenGLSettings()
{
	// set up the init settings
	glViewport(0, 0, open_window_x, open_window_y);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	// glOrtho() uses the orthographic projection.
	// Basically it makes the shapes not distort as you go near the edges of the screen.
	// This is very unnatural, but is useful when your 3D objects should actually be displayed as 2D objects.
	glOrtho(0, open_window_x, 0, open_window_y, -1000.0f, 1000.0f);
	
	// gluPerspective() uses the perspective projection.
	// Basically this makes the shapes distort as they go near the edges of the screen.
	// This is most natural, especially for 3D environments.
	//gluPerspective(45.0f, (GLfloat)open_window_x / (GLfloat)open_window_y, 0.05f, 500.0f);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity(); 
	//glEnable(GL_TEXTURE_2D);  
	//glShadeModel(GL_SMOOTH);
	glClearColor(0.1f, 0.1f, 0.1f, 0.5f);
	glClearDepth(1.0f);
	//glEnable(GL_DEPTH_TEST);
	//glDepthFunc(GL_LEQUAL);					
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	
	glAlphaFunc(GL_GREATER, 0.9f);									
	glEnable(GL_ALPHA_TEST);

	//glDisable(GL_ALPHA_TEST);
	//glEnable(GL_BLEND);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE);

	// more stuff for lighting                                  
	glFrontFace(GL_CCW);
	glEnable(GL_NORMALIZE);     
	glCullFace(GL_FRONT);                   

	// allows colors to be still lit up      
	glEnable(GL_COLOR_MATERIAL);

	return;
};

void handleKeys(GLFWwindow *window, int key, int scancode, int action, int mods)
{
	if (action == GLFW_PRESS)
	{
		open_keyboard_state[key] = 1;

		RAM[KEY_ARRAY+RAM[KEY_POS_WRITE]] = (uint8_t)PS2KeyCode(key); 

		RAM[KEY_POS_WRITE]++;
	
		if (RAM[KEY_POS_WRITE] >= 0x80) RAM[KEY_POS_WRITE] = 0x00;

		if (PS2KeyCode(key) == 0xE0) // extended
		{
			RAM[KEY_ARRAY+RAM[KEY_POS_WRITE]] = (uint8_t)PS2ExtendedKeyCode(key);
		
			RAM[KEY_POS_WRITE]++;
	
			if (RAM[KEY_POS_WRITE] >= 0x80) RAM[KEY_POS_WRITE] = 0x00;
		}	

		if (key == GLFW_KEY_PAUSE)
		{
			glfwSetWindowShouldClose(window, GLFW_TRUE);
		}
		
/*
		switch (key)
		{
			case GLFW_KEY_ESCAPE:
			{
				glfwSetWindowShouldClose(window, GLFW_TRUE);
			
				break;
			}
	
			case GLFW_KEY_F1:
			{
				const GLFWvidmode* mode = glfwGetVideoMode(glfwGetPrimaryMonitor());

				glfwSetWindowMonitor(window, glfwGetPrimaryMonitor(), 0, 0, mode->width, mode->height, mode->refreshRate);

				open_window_x = mode->width;
				open_window_y = mode->height;

				break;
			}

			case GLFW_KEY_F2:
			{
				const GLFWvidmode* mode = glfwGetVideoMode(glfwGetPrimaryMonitor());

				glfwSetWindowMonitor(window, NULL, 0, 0, 640, 480, mode->refreshRate);

				open_window_x = 640;
				open_window_y = 480;

				break;
			}

			default: {}
		}
*/
	}
	else if (action == GLFW_RELEASE)
	{
		open_keyboard_state[key] = 0;

		if (PS2KeyCode(key) == 0xE0) // extended
		{
			RAM[KEY_ARRAY+RAM[KEY_POS_WRITE]] = (uint8_t)0xE0;
		
			RAM[KEY_POS_WRITE]++;

			if (RAM[KEY_POS_WRITE] >= 0x80) RAM[KEY_POS_WRITE] = 0x00;
		}	

		RAM[KEY_ARRAY+RAM[KEY_POS_WRITE]] = (uint8_t)0xF0;

		RAM[KEY_POS_WRITE]++;

		if (RAM[KEY_POS_WRITE] >= 0x80) RAM[KEY_POS_WRITE] = 0x00;

		if (PS2KeyCode(key) == 0xE0) // extended
		{
			RAM[KEY_ARRAY+RAM[KEY_POS_WRITE]] = (uint8_t)PS2ExtendedKeyCode(key);
		}
		else
		{
			RAM[KEY_ARRAY+RAM[KEY_POS_WRITE]] = (uint8_t)PS2KeyCode(key);
		}

		RAM[KEY_POS_WRITE]++;

		if (RAM[KEY_POS_WRITE] >= 0x80) RAM[KEY_POS_WRITE] = 0x00;
	}

	return;
};

void handleButtons(GLFWwindow *window, int button, int action, int mods)
{
	if (action == GLFW_PRESS)
	{
		open_button_state[button] = 1;
	}
	else if (action == GLFW_RELEASE)
	{
		open_button_state[button] = 0;
	}

	return;	
};

void handleResize(GLFWwindow *window, int width, int height)
{
	glfwGetWindowSize(window, &width, &height);	

	open_window_x = width;
	open_window_y = height;
	
	glViewport(0, 0, width, height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	// glOrtho() uses the orthographic projection.
	// Basically it makes the shapes not distort as you go near the edges of the screen.
	// This is very unnatural, but is useful when your 3D objects should actually be displayed as 2D objects.
	glOrtho(0, open_window_x, 0, open_window_y, -1000.0f, 1000.0f);
	
	// gluPerspective() uses the perspective projection.
	// Basically this makes the shapes distort as they go near the edges of the screen.
	// This is most natural, especially for 3D environments.
	//gluPerspective(45.0f, (GLfloat)open_window_x / (GLfloat)open_window_y, 0.05f, 500.0f);

	InitializeOpenGLSettings();

	return;
};

void handleCursor(GLFWwindow *window, double xpos, double ypos)
{
	glfwGetCursorPos(window, &xpos, &ypos);

	open_cursor_new_x = xpos;
	open_cursor_new_y = ypos;

	return;
};

void Draw(unsigned char C, unsigned char J, unsigned char K)
{
	int coord_x = 4 * (int)(J%128) + 1 + 64;
	int coord_y = 480 - 4 * (int)(K - 0x08) - 2 * (int)(J/128);

	int mode = 0;

	unsigned char bits;

	glBegin(GL_LINES);
	
	if (mono_video == false)
	{	
		for (int Q=0; Q<4; Q+=2)
		{
			bits = C & 0xF0;

			if (bits == 0x00) glColor3f(0.0f, 0.0f, 0.0f); // black
			else if (bits == 0x10) glColor3f(200.0f/700.0f, 200.0f/700.0f, 200.0f/700.0f); // dark grey
			else if (bits == 0x20) glColor3f(0.0f, 0.0f, 425.0f/700.0f); // dark blue
			else if (bits == 0x30) glColor3f(200.0f/700.0f, 200.0f/700.0f, 625.0f/700.0f); // bright blue
			else if (bits == 0x40) glColor3f(0.0f, 425.0f/700.0f, 0.0f); // dark green
			else if (bits == 0x50) glColor3f(200.0f/700.0f, 625.0f/700.0f, 200.0f/700.0f); // bright green
			else if (bits == 0x60) glColor3f(0.0f, 425.0f/700.0f, 425.0f/700.0f); // dark cyan
			else if (bits == 0x70) glColor3f(200.0f/700.0f, 625.0f/700.0f, 625.0f/700.0f); // bright cyan

			else if (bits == 0x80) glColor3f(425.0f/700.0f, 0.0f, 0.0f); // dark red
			else if (bits == 0x90) glColor3f(625.0f/700.0f, 200.0f/700.0f, 200.0f/700.0f); // bright red
			else if (bits == 0xA0) glColor3f(425.0f/700.0f, 0.0f, 425.0f/700.0f); // dark magenta
			else if (bits == 0xB0) glColor3f(625.0f/700.0f, 200.0f/700.0f, 625.0f/700.0f); // bright magenta
			else if (bits == 0xC0) glColor3f(425.0f/700.0f, 425.0f/700.0f, 0.0f); // dark yellow
			else if (bits == 0xD0) glColor3f(625.0f/700.0f, 625.0f/700.0f, 200.0f/700.0f); // bright yellow
			else if (bits == 0xE0) glColor3f(425.0f/700.0f, 425.0f/700.0f, 425.0f/700.0f); // bright grey
			else if (bits == 0xF0) glColor3f(625.0f/700.0f, 625.0f/700.0f, 625.0f/700.0f); // white

			//if (bits == 0x00) glColor3f(0.0f,0.0f,0.0f); // black
			//else if (bits == 0x01) glColor3f(0.0f,308.0f/700.0f,618.0f/700.0f); // blue
			//else if (bits == 0x02) glColor3f(618.0f/700.0f,308.0f/700.0f,0.0f); // orange
			//else if (bits == 0x03) glColor3f(618.0f/700.0f,615.0f/700.0f,618.0f/700.0f); // white
			//if (bits == 0x00) glColor3f(0.0f,0.0f,0.0f); // black
			//else if (bits == 0x01) glColor3f(0.0f,0.85f,0.82f); // cyan
			//else if (bits == 0x02) glColor3f(0.85f,0.0f,0.82f); // magenta
			//else if (bits == 0x03) glColor3f(0.94f,0.94f,0.93f); // white
			//if (bits == 0x00) glColor3f(0.0f,0.0f,0.31f); // blue
			//else if (bits == 0x01) glColor3f(0.0f,0.67f,0.02f); // green
			//else if (bits == 0x02) glColor3f(0.67f,0.0f,0.02f); // red
			//else if (bits == 0x03) glColor3f(0.80f,0.80f,0.02f); // yellow
	
			glVertex3f((float)(coord_x+Q),(float)coord_y,0.0f);
			glVertex3f((float)(coord_x+Q),(float)(coord_y-2),0.0f);
			glVertex3f((float)(coord_x+Q+1),(float)coord_y,0.0f);
			glVertex3f((float)(coord_x+Q+1),(float)(coord_y-2),0.0f);
	
			C = C << 4;
		}
	}
	else if (mono_video == true)
	{
		for (int Q=0; Q<4; Q+=1)
		{
			bits = C & 0xC0;
	
			if (bits == 0x00) glColor3f(0.0f,0.0f,0.0f); // black
			else if (bits == 0x40) glColor3f(color[0][0], color[0][1], color[0][2]); // color[0]
			else if (bits == 0x80) glColor3f(color[1][0], color[1][1], color[1][2]); // color[1]
			else if (bits == 0xC0) glColor3f(625.0f/700.0f, 625.0f/700.0f, 625.0f/700.0f); // white
	
			glVertex3f((float)(coord_x+Q),(float)coord_y,0.0f);
			glVertex3f((float)(coord_x+Q),(float)(coord_y-2),0.0f);
			//glVertex3f((float)(coord_x+Q+1),(float)coord_y,0.0f);
			//glVertex3f((float)(coord_x+Q+1),(float)(coord_y-2),0.0f);
	
			C = C << 2;
		}
	}

	glEnd();	

	return;
};

int Load(const char *filename) // loads a 16KB ROM
{
	FILE *input = NULL;

	input = fopen(filename, "rb");
	if (!input) return 0;

	uint8_t buffer, bytes = 0;

	for (int i=0; i<16384; i++)
	{
		bytes = fscanf(input, "%c", &buffer);

		if (bytes > 0)
		{
			ROM[i] = buffer;
		}
	}

	fclose(input);

	return 1;
};

void Stop()
{
	printf("Stopped\nA=%02x X=%02x Y=%02x S=%02x P=%04x R=%02x\n", CPU->A, CPU->X, CPU->Y, CPU->sp, CPU->pc, CPU->status);

	return;
};
		
int main(const int argc, const char **argv)
{
	if (argc < 2)
	{
		printf("Acolyte 6502 Computer - Simulator\n");
		printf("Argument is a 16KB binary file used for ROM\n");
		
		return 0;
	}

	int temp;

	for (int i=0; i<(int)(time(0)%1000); i++)
	{
		temp = rand() % 1000;
	}

	int random_value = 0;

	for (long unsigned random_counter=0; random_counter<(time(0) % 1000); random_counter++)
	{
		random_value = rand() % 1000;
	}

	GLFWwindow* window;

	// Init library
	if (!glfwInit())
	{
		return 0;
	}

	// create windowed mode
	window = glfwCreateWindow(open_window_x, open_window_y, "Acolyte Computer", NULL, NULL);
	if (!window)
	{
		glfwTerminate();
		return 0;
	}

	// make windows context current
	glfwMakeContextCurrent(window);

	// all of the settings needed for typical 3D graphics
	InitializeOpenGLSettings();

	// set keyboard state to 0
	for (int i=0; i<512; i++) open_keyboard_state[i] = 0;

	// set cursor to middle of window
	open_cursor_new_x = (int)(open_window_x/2);
	open_cursor_new_y = (int)(open_window_y/2);
	open_cursor_old_x = (int)(open_window_x/2);
	open_cursor_old_y = (int)(open_window_y/2);
	glfwSetCursorPos(window, (int)(open_window_x/2), (int)(open_window_y/2));

	// modes
	glfwSetInputMode(window, GLFW_STICKY_KEYS, GLFW_TRUE);

	// callbacks
	glfwSetKeyCallback(window, handleKeys);
	glfwSetWindowSizeCallback(window, handleResize);
	glfwSetCursorPosCallback(window, handleCursor);
	glfwSetMouseButtonCallback(window, handleButtons);

	// INITIALIZE HERE!

	if (!Load(argv[1]))
	{
		printf("Error in Load()\n");
		
		return 0;
	}

	CPU = new mos6502(ReadFunction, WriteFunction, Stop);

	CPU->Reset();

	// loop until closed
	while (!glfwWindowShouldClose(window))
	{
		open_clock_previous = open_clock_current;
		open_clock_current = clock();

		open_frames_counter += (double)(open_clock_current - open_clock_previous);

		if (open_frames_counter >= open_frames_difference)
		{
			open_frames_previous = open_frames_current;
			open_frames_current = clock();

			while (open_frames_counter >= open_frames_difference)
			{
				open_frames_counter -= open_frames_difference;
			}

			open_frames_drawing = true;

			open_frames_per_second_counter++;
		}

		if (open_frames_per_second_timer != time(0))
		{
			open_frames_per_second = open_frames_per_second_counter;
			open_frames_per_second_counter = 0;
			open_frames_per_second_timer = time(0);

			// once per second...
		}

		open_frames_delta = ((double)(open_clock_current - open_clock_previous) / (double)CLOCKS_PER_SEC);

		uint64_t counter = 0;

		CPU->Run(52500*2, counter); // 52500*2 clock cycles per one screen refresh at 60 Hz

		if (open_frames_drawing == true)
		{
			RAM[CLOCK_LOW]++;
			if (RAM[CLOCK_LOW] == 0x00) RAM[CLOCK_HIGH]++;

			open_frames_drawing = false;

			glViewport(0, 0, open_window_x, open_window_y);
			glClear(GL_COLOR_BUFFER_BIT);

			// DRAW HERE!	

			for (unsigned char K = 0x08; K < 0x80; K++)
			{
				for (unsigned int J = 0x0000; J <= 0x00FF; J++)
				{
					Draw(RAM[(unsigned int)(K*256+(unsigned char)J)], (unsigned char)J, K);
				}
			}

			// make sure V-Sync is on
			glfwSwapInterval(1);

			// swap front and back buffers
			glfwSwapBuffers(window);
		}

		// poll for and process events
		glfwPollEvents();
	}

	printf("Exited\nA=%02x X=%02x Y=%02x S=%02x P=%04x R=%02x\n", CPU->A, CPU->X, CPU->Y, CPU->sp, CPU->pc, CPU->status);

	delete CPU;

	glfwDestroyWindow(window);

	glfwTerminate();

	return 1;
}


