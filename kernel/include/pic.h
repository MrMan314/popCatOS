#ifndef POPCATOS_PIC_H
#define POPCATOS_PIC_H
#endif

#define PIC1_CMD    0x0020
#define PIC1_DAT    0x0021
#define PIC2_CMD    0x00A0
#define PIC2_DAT    0x00A1
#define PIC_EOI     0x0020

void PIC_sendEOI(uint8 irq) {
    if(irq >= 0x08)outb(PIC2_CMD, PIC_EOI);
    outb(PIC1_CMD, PIC_EOI);
}
