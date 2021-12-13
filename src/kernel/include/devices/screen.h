#ifndef POPCATOS_SCREEN_H
#define POPCATOS_SCREEN_H
#endif

// Define screen dimensions
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25
#define SCREEN_DEPTH 2

// Display Frame Buffer
volatile char*fb = (char *) 0xB8000;

// Cursor position
uint32 cx = 0, cy = 0, cpos=0;

// Default QWERTY Keyboard layout
const char kbd_US [128] = {
        0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b','\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n', 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '-', 0, 0, 0, '+', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

// Move cursor to set position
void move_cursor(const uint16 pos) {
    outb(0x3D4, 14);
    outb(0x3D5, ((pos >> 8) & 0x00FF));
    outb(0x3D4, 15);
    outb(0x3D5, pos & 0x00FF);
    cx = pos % SCREEN_WIDTH;
    cy = pos / SCREEN_WIDTH;
    cpos = pos;
}

// Enable/show cursor with a size
void enable_cursor(const char start, char const end) {
    outb(0x3D4, 0x0A);
    outb(0x3D5, (inb(0x3D5) & 0xC0) | start);
    outb(0x3D4, 0x0B);
    outb(0x3D5, (inb(0x3D5) & 0xE0) | end);
}

// Disable/hide cursor
void disable_cursor() {
    outb(0x3D4, 0x0A);
    outb(0x3D5, 0x20);
}

// Converts the x/y to raw position on framebuffer
uint32 xytopos(const uint32 x, const uint32 y) {
    return y*SCREEN_WIDTH+x;
}

// Scrolls framebuffer
void scroll(){
    for(uint32 i=SCREEN_WIDTH*2;i<SCREEN_WIDTH*SCREEN_HEIGHT*2+SCREEN_WIDTH*2;i++) {
        fb[i-SCREEN_WIDTH*2] = fb[i];
    }move_cursor(SCREEN_WIDTH*(SCREEN_HEIGHT-2));
}

// Writes to a certain cell in framebuffer
void write_cell(const uint32 i, const char c, const char color) {
    fb[i] = c;
    fb[i + 1] = color;
}

// Clears the framebuffer with the color of 0x0F
void clear() {
    for(uint32 i=0;i<SCREEN_WIDTH*SCREEN_HEIGHT*SCREEN_DEPTH;i+=SCREEN_DEPTH) {
        write_cell(i, 0x0, 0x0F);
    }
}

// Fills the framebuffer with a certain char and color
void fill(const char c, const char color) {
    for(uint32 i=0;i<SCREEN_WIDTH*SCREEN_HEIGHT*SCREEN_DEPTH;i+=SCREEN_DEPTH) {
        write_cell(i, c, color);
    }
}

// Fills a range in the framebuffer using xytopos function
void fill_range(const char c, const uint32 x, const uint32 y, const uint32 w, const uint32 h, const char color) {
    for(uint32 i=x;i<x+w;i++) {
        for(uint32 j=y;j<y+h;j++) {
            write_cell(xytopos(i*SCREEN_DEPTH,j*SCREEN_DEPTH), c, color);
            move_cursor(xytopos(i, j));
        }
    }
}

// Creates a newline
void endl() {
    if(cpos+SCREEN_WIDTH-(cpos%SCREEN_WIDTH) > 1999) {
        scroll();
    }
    move_cursor(cpos+SCREEN_WIDTH-(cpos%SCREEN_WIDTH));
}

// Writes char to next cell
void putch(const char c, const char color) {
    if(c == '\n')
        endl();
    else{
        fb[cpos*SCREEN_DEPTH] = c;
        fb[cpos*SCREEN_DEPTH + 1] = color;
        move_cursor(cpos+1);
    }
}

// Reads input

char* readln(const uint8 color) {
    uint32 i = 0;
    char *s = {};
    while (true) {
        if (inb(0x64) & 0x1) {
            char c = inb(0x60);
            if (c < 0) continue;
            else if (kbd_US[(uint32) c] == '\n') {
                s[i] = 0;
                endl();
                return s;
            } else if (kbd_US[(uint32) c] == '\b') {
                if (i == 0) continue;
                move_cursor(cpos - 1);
                putch(0x0, color);
                move_cursor(cpos - 1);
                i--;
                s[i] = 0;
            } else if (kbd_US[(uint32) c]) {
                putch(kbd_US[(uint32) c], color);
                s[i] = kbd_US[(uint32) c];
                i++;
            }
        }
    }
}

// Prints to the frame buffer at current position
void print(const char *s, const char color){
    uint32 i=0;
    while(s[i]!=0){
        if(s[i]=='\n')endl();
        else{
            write_cell((cpos)*SCREEN_DEPTH, s[i], color);
            move_cursor(cpos+1);
            if(cpos > 1999) {
                scroll();
                endl();
            }
        }
        i++;
    }
}

// Prints to the frame buffer at current position with a newline
void println(const char *s, const char color) {
    uint32 i = 0;
    while (s[i] != 0) {
        if (s[i] == '\n')endl();
        else {
            write_cell((cpos) * SCREEN_DEPTH, s[i], color);
            move_cursor(cpos + 1);
        }
        i++;
    }
    endl();
}
