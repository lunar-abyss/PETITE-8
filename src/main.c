// including libs
#include <stdio.h>
#include <string.h>
#include "global.h"

// fully including the interpreter
#define PETITE_BASIC_C
#define PETITE_BASIC_COMMANDS_C
#include "petite-basic.h"

// palette with all the 4 colors
const int palette[] = { 0x2c2137, 0x764462, 0xa96868, 0xedb4a1 };

// code position
int code_pos = 0;

// functions
void get_code(int argc, char* argv[]);
void set_keys();

// main function
int main(int argc, char* argv[])
{
  // initializing the window
  char* title = strrchr(argv[0], '\\');
  win_init(title ? title + 1 : argv[0]);
  
  // getting the code
  get_code(argc, argv);

  // initializing the interpreter
  pb_init();

  // user desided to exit or the interpreter is in the end of the code
  while (!win_quit())
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
}

// getting the code
void get_code(int argc, char* argv[])
{
  // open itself
  FILE* exe = fopen(argv[0], "r");

  // getting the size of the file
  fseek(exe, 0, SEEK_END);
  int len = ftell(exe);
  fseek(exe, 0, SEEK_SET);
  
  // reading the file until zero
  for (int i = len - 1; i > 0; i--) {
    fseek(exe, i, SEEK_SET);
    int chr = fgetc(exe);
    if (chr == '\0')
      break;
  }

  // getting the size of the code
  
  // getting the position of the code
  if (len - ftell(exe) > 0)
  fread(pb_code, 1, PB_CODE_LEN, exe);
  
  // reading the code from the file passed to the exe
  else if (argc > 1) {
    FILE* f = fopen(argv[1], "r");
    fread(pb_code, 1, PB_CODE_LEN, f);
    fclose(f);
  }
  
  // close itself
  fclose(exe);
}

// setting the keys
void set_keys() {
  pb_mem[PB_MEMORY_SIZE - 6] = key_press(key_left);
  pb_mem[PB_MEMORY_SIZE - 5] = key_press(key_right);
  pb_mem[PB_MEMORY_SIZE - 4] = key_press(key_up);
  pb_mem[PB_MEMORY_SIZE - 3] = key_press(key_down);
  pb_mem[PB_MEMORY_SIZE - 2] = key_press(key_z);
  pb_mem[PB_MEMORY_SIZE - 1] = key_press(key_x);
}