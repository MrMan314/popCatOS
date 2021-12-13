#ifndef POPCATOS_IO_H
#define POPCATOS_IO_H
#endif

//#define outb(port, data) asm volatile ( "outb %0, %1" : : "a"(data), "Nd"(port));
//#define outw(port, data) asm volatile ( "outw %0, %1" : : "a"(data), "Nd"(port));
//#define outl(port, data) asm volatile ( "outl %0, %1" : : "a"(data), "Nd"(port));

static inline void outb(const uint16 port, const uint8 data) {
    asm volatile ( "outb %0, %1" : : "a"(data), "Nd"(port));
}

static inline void outw(const uint16 port, const uint16 data) {
    asm volatile ( "outw %0, %1" : : "a"(data), "Nd"(port));
}

static inline void outl(const uint16 port, const uint32 data) {
    asm volatile ( "outl %0, %1" : : "a"(data), "Nd"(port));
}

static inline void iowait(void) {
    outb(0x80, 0x00);
}

uint8 inb(const uint16 port) {
    uint8 ret;
    asm volatile ( "inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

uint16 inw(const uint16 port) {
    uint16 ret;
    asm volatile ( "inw %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

uint32 inl(const uint16 port) {
    uint32 ret;
    asm volatile ( "inl %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}


