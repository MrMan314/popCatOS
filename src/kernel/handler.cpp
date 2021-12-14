typedef unsigned short uint16;
extern void clear();
extern void move_cursor(const uint16 pos);
extern void print(const char *s, const char color);
extern void fill(const char c, const char color);

extern "C" void handler(int code) {
    switch(code){
        case 0:
            clear();
            move_cursor(0);
            print("OK", 0x0F);
            break;
        case 0x7FFFFFFF:
            fill(0x00, 0x4F);
            move_cursor(0);
            print("ERROR 0x7FFFFFFF - DEATH", 0x4F);
            break;
        case 0x7FFFFFFE:
            fill(0x00, 0x4F);
            move_cursor(0);
            print("ERROR 0x7FFFFFFE - DIED OF DEATH", 0x4F);
            break;
        default:
            fill(0x00, 0x4F);
            move_cursor(0);
            print("IDK WHAT HAPPENED", 0x4F);
            break;
    }
}