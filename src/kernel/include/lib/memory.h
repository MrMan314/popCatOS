#ifndef POPCATOS_MEMORY_H
#define POPCATOS_MEMORY_H
#endif

void memcpy(uint8 *dest, const uint8 *src, uint32 n) {
    for (uint32 i = 0; i < n; i++)
        dest[i] = src[i];
}