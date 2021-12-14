#include <all.h>

#define default_color 0x0F
#define error_color 0x04

// shift: 42, 54

int main() {
    fill(0x0, default_color);
    move_cursor(0);
    fill_range(0x0, 1, 1, 31, 3, 0x1F);
    move_cursor(xytopos(3, 2));
    print("Welcome to popcatOS v0.0.7!", 0x1F);
    move_cursor(xytopos(0, 5));
    while (true) {
        print(" >", default_color);
        char *s = readln(default_color);
        if (!strcmp(s, "bingus")) {
            println("bongus", default_color);
        } else if (!strcmp(s, "bongus")) {
            println("bingus", default_color);
        } else if (!strcmp(s, "ver")) {
            println("0.0.7", default_color);
        } else if (!strcmp(s, "pop")) {
            println("pop", default_color);
        } else if (!strcmp(s, "shutdown")) {
            println("Shutting Down...", default_color);
            break;
        } else if (!strcmp(s, "clear")) {
            fill(0x0, default_color);
            move_cursor(0);
        } else if (!strcmp(s, "die")) {
            return 0x7FFFFFFF;
        } else if (!strcmp(s, "unknowndeath")) {
            return 0x12345678;
        } else if (!strcmp(s, "dieofdeathplsdontdothisplsplsplsplspls")) {
            return (int)0x80000000;
        } else {
            print("Error: Command \"", error_color);
            print(s, error_color);
            println("\" not found", error_color);
        }
    }
    return 0x00000000;
}