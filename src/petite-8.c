// the main build file

// including libs
#include <stdio.h>
#include <string.h>

// constants for keys
#define KEY_LEFT  37
#define KEY_RIGHT 39
#define KEY_UP    38
#define KEY_DOWN  40
#define KEY_Z     90
#define KEY_X     88

// macros from the library
#define win_init()             mio_window(WIN_TITLE, WIN_WIDTH, WIN_HEIGHT, WIN_SCALE | MIO_FPS30)
#define win_update()           mio_update()
#define win_kill()             mio_die()
#define win_quit               mio_quit
#define win_pixel(x, y, color) set_pixel(x, y, color)
#define key_press(key)         mio_keys[key]

// building miowin sources
#define MIOWIN_C
#include "miowin.h"

// window constants
#define WIN_WIDTH  48
#define WIN_HEIGHT 32
#define WIN_SCALE  16
#define WIN_TITLE  "PETITE-8"

// palette with all colors
const int palette[] = {
  0x2c2137, 0x764462,
  0xa96868, 0xedb4a1,
};

// setting a pixel on screen
void set_pixel(unsigned char x, unsigned char y, unsigned char color) {
  if (x >= 0 && y >= 0 && x < WIN_WIDTH && y < WIN_HEIGHT)
    mio_pixel(x, y) = palette[color];
}

// fully including the interpreter
#define PETITE_BASIC_C
#define PETITE_BASIC_COMMANDS_C
#include "petite-basic.h"

// getting the code
void get_code()
{
  // getting filepath
  char filepath[MAX_PATH];
  GetModuleFileNameA(0, filepath, MAX_PATH);

  /// open itself
  FILE* exe = fopen(filepath, "r");

  // getting the size of the file
  fseek(exe, 0, SEEK_END);
  int len = ftell(exe);
  
  // reading the file until zero
  for (int i = len - 1; i > 0; i--) {
    fseek(exe, i, SEEK_SET);
    char chr;
    fread(&chr, 1, 1, exe);
    if (chr == '\0')
      break;
  }
  
  // getting the position of the code
  int code_len = 0;
  if (len - ftell(exe) > 0)
    code_len = fread(pb_code, 1, PB_CODE_LEN, exe);

  // reading the code from the file passed to the exe
  else {
    FILE* f = fopen("game.pb", "r");
    code_len = fread(pb_code, 1, PB_CODE_LEN, f);
    fclose(f);
  }

  // null character
  pb_code[code_len] = '\0';

  // null character
  pb_code[code_len] = '\0';
}

// setting the keys
void set_keys(void) {
  pb_set("keyl", 4, key_press(KEY_LEFT));
  pb_set("keyr", 4, key_press(KEY_RIGHT));
  pb_set("keyu", 4, key_press(KEY_UP));
  pb_set("keyd", 4, key_press(KEY_DOWN));
  pb_set("keyz", 4, key_press(KEY_Z));
  pb_set("keyx", 4, key_press(KEY_X));
}

// main function
int petite8()
{
  // initializing the window
  win_init();
  
  // initializing and getting the code
  pb_init();
  get_code();
  pb_prep();
  
  // user desided to exit or the interpreter is in the end of the code
  while (!win_quit)
  {
    // pre update of the window
    win_update();
    
    // interpret the code
    set_keys();
    pb_exec();

    // exited without pausing
    if (!pb_pause)
      break;
  }

  // destroying the fc
  win_kill();
  pb_kill();
  ExitProcess(0);
}