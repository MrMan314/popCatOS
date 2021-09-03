#ifndef POPCATOS_IO_H
#define POPCATOS_IO_H
#endif
void outb(const uint16 port, const unsigned char data){
	asm volatile ( "outb %0, %1" : : "a"(data), "Nd"(port) );
}
unsigned char inb(const uint16 port){
	char ret;
    asm volatile ( "inb %1, %0" : "=a"(ret) : "Nd"(port) );
    return ret;
}
