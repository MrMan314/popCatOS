#include <all.h>

#define default_color 0x0F
#define error_color 0x04

int main(){
    fill(0x0, default_color);
    move_cursor(0);
    fill_range(0x0, 1, 1, 31, 3, 0x1F);
    move_cursor(xytopos(3, 2));
    print("Welcome to popcatOS v0.0.6!", 0x1F);
    move_cursor(xytopos(0, 5));
    while(true) {
        print(" >", default_color);
        char s[4096] = "";
        readln(s, default_color);
        if(!strcmp(s, "bingus")){
            println("bongus", default_color);
        }else if(!strcmp(s, "bongus")){
            println("bingus", default_color);
        }else if(!strcmp(s, "ver")){
            println("0.0.6", default_color);
        }else if(!strcmp(s, "pop")){
            println("pop", default_color);
        }else if(!strcmp(s, "shutdown")){
            println("Shutting Down...", default_color);
            reboot();
        }else if(!strcmp(s, "clear")){
            fill(0x0, default_color);
            move_cursor(0);
        }else{
            print("Error: Command \"", error_color);
            print(s, error_color);
            println("\" not found", error_color);
        }
    }
    return 0;
}