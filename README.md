![banner](./res/design-scaled.png)
# PETITE-8

## About
PETITE-8 is a BASIC driven fantasy console, it's size is only 26(12)KB, and you can build your games with it.

Current version is `Beta 0.1`.

Inspired by
- Dartmouth BASIC
- cel7 by rxi
- REST-6 by Lunaryss

License: Public Domain, no warranty given, use at your own risk

### Specs
Here are specs of the FC:
- Screen: 48x32 pixels, 30fps, 4 colors (RUSTIC GB palette)
- RAM: 256 bytes
- ROM: 4096 bytes of code
- Language: First-generation BASIC dialect - [Petite BASIC](https://github.com/lunar-abyss/PetiteBASIC)
- Input: 6 keys - arrow keys, Z and X
- Sound: Not implemented yet

### Features
Here are special features of the FC:
- Small size, the FC is only 26KB/12KB
- Easy to create standalone builds
- Open source, simple to port
- Simple to create

### Two Versions
Two versions of the FC are in the `bin` folder, here is why:
1. `PETITE-8.exe`: this version is not compressed, and shouldn't have problems with antimalwares.
2. `PETITE-8-C.exe`: this version is compressed with upx tool and it might have problems with antimalvare. Be careful.

### Running the program
Here is an easy way to run your program:
1. Download the repository from GitHub (or only the `/bin` folder).
2. Open `/bin` folder.
3. Create a new file with `.pb` extension.
4. Drag and drop the file onto the executable file (the same as passing it as an argument from cmd).
5. To test, you can use any file from the `/bin/examples` folder.

### Building the project
More on that topic later. Use `build.bat` tool.

### Future Of The Project
The project is still in development, and there will be a lot of new features and improvements.
You will have the ability to build your own games on any version you want.

## Documentation
Make sure to check the [Petite BASIC](https://github.com/lunar-abyss/PetiteBASIC) documentation (in `README.md file`) first.
There are not much changes from the original Petite BASIC:
- Removed `print` and `read` commands
- Added `frame` and `rect` commands

| Command | Arguments | Example | Description |
| :-----: | --------- | ------- | ----------- |
| `frame` | - | `frame` | Pauses execution of a script and waits for a frame to be drawn |
| `rect` | `<x>, <y>, <w>, <h>, <color>` | `rect 0, 0, 48, 32, 0` | Draws a rectangle on screen with specified position, size and color. Color can be only from 0 to 3 | 

The input is inside the memory, so you can get it with `peek` command.
Here are the addresses:
- Left: `250`
- Right: `251`
- Up:`252`
- Down: `253`
- Z: `254`
- X: `255`

Pressed is represented by `1`, not pressed by `0`.

## Build Tool
PETITE-8 comes with a build tool, which is `build.bat` located in the bin folder.
It's a simple windows batch script, which creates a new `.exe` file, your project built. You can the `.exe` standalone, no libs, no source.

By default if you run it without any parameters, it will try to find a file named `game.pb` and build it with the `PETITE-8.exe` version of the FC.

Here are all flags you can pass through the command line:
- `<src>`: source file to build, defaults to `game.pb`
- `-o <out>`: output file name with extension, defaults to `<src-name>.exe`
- `-emioc`: use compressed `miowin` version of the FC
- `-emio`: use non-compressed `miowin` version of the FC (default)
- `-r`: run after build

## Sample Program
Here is the simple program, to test the FC.
```cs
let x: 0
loop:
  let x: x + 1
  rect 0, 0, 48, 32, 0
  rect x, 0, 1,  1,  3
  frame
  goto loop
```
You should see a pixel running from the left top, to the right.
For more examples, check the `/bin/examples` folder.

## Building The Source
You're probably wan't to build the project from source, so here is how to do it.
1. Download the repository from github.
2. Run `build.bat` file.
3. Enjoy the result! Or may be not. Any way, all build flags and stuff are in the `build.bat` file.

## Porting
PETITE-8 works with [miowin](https://github.com/lunar-abyss/miowin) library, which is a minimal window library for windows only.
But if you want to port the FC, there is a simple way.

There are only two files you need to work with: `io.c` and `global.h`, and the only file you'll have to change is `io.c`.
The main thing you need to is to reimplement (change) the functions and constants in `io.c` to work with your platform.
So here is a list of definitions you need to change:
```c
// functions for io
win_init(char* title)          // create a 48x32 30 fps window with the title passed
win_update(void)               // update the window
win_kill(void)                 // destroy the window
win_quit(void)                 // check if the window is running
win_pixel(unsigned char x,
          unsigned char y,
          unsigned int color)  // set a pixel on screen, pixels represented by integers in format 0x00RRGGBB
key_press(int key)             // check if a key is pressed

// also you need to change this constants, they are passed to key_press() function
const int key_left;
const int key_right;
const int key_up;
const int key_down;
const int key_z;
const int key_x;
```
