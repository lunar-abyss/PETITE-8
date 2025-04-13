// some consts
#define WIN_WIDTH  48
#define WIN_HEIGHT 32
#define WIN_SCALE  16

// palette var
extern const int palette[4];

// key constants
extern const int key_left;
extern const int key_right;
extern const int key_up;
extern const int key_down;
extern const int key_z;
extern const int key_x;

// functions
void win_init(char* title);
void win_update(void);
void win_kill(void);
void win_pixel(unsigned char x, unsigned char y, unsigned int color);
char win_quit(void);
char key_press(int key);
