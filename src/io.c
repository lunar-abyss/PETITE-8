// all io stuff here for you making a port easier
#include "global.h"

// building miowin sources
#define MIOWIN_C
#include "miowin.h"

// constants for keys
const int key_left = VK_LEFT;
const int key_right = VK_RIGHT;
const int key_up = VK_UP;
const int key_down = VK_DOWN;
const int key_z = 'Z';
const int key_x = 'X';

// creating a window
void win_init(char* title)
  { mio_window(title, WIN_WIDTH, WIN_HEIGHT, WIN_SCALE | MIO_FPS30); }

// preupdate the window
void win_update(void)
  { mio_update(); }

// closing the window
void win_kill(void)
  { mio_die(); }

// setting a pixel on screen
void win_pixel(unsigned char x, unsigned char y, unsigned int color)
  { if (x >= 0 && y >= 0 && x < WIN_WIDTH && y < WIN_HEIGHT) mio_pixel(x, y) = color; }

// checking if the window is running
char win_quit(void)
  { return mio_quit; }

// checking if a key is press
char key_press(int key)
  { return mio_keys[key]; }