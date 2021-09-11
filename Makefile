CXX_SOURCES =	$(wildcard	kernel/*.cpp)
CXX_OBJECTS =	objects/${CXX_SOURCES:.cpp=.o}
ASM_SOURCES =	$(wildcard	boot/*.asm)
ASM_OBJECTS =	objects/${ASM_SOURCES:.asm=.o}

QEMU =			qemu-system-i386
AS =			nasm
CC =			i686-elf-g++
LD =			i686-elf-ld

CXX_FLAGS =		-ffreestanding -c $< -o $@ -I kernel/include -Wall -Wextra -Werror
QEMU_FLAGS =	-drive file=$<,index=0,media=disk,format=raw -serial stdio

run:					output/floppy.img
	$(QEMU) $(QEMU_FLAGS)

${ASM_OBJECTS}:			${ASM_SOURCES}
	mkdir -p $(@D)
	$(AS) $^ -fbin -o $@

objects/entry.o:		kernel/entry.asm
	mkdir -p $(@D)
	$(AS) $^ -felf -o $@

${CXX_OBJECTS}:			${CXX_SOURCES}
	mkdir -p $(@D)
	$(CC) $(CXX_FLAGS)

objects/kernel.bin:		objects/entry.o	${CXX_OBJECTS}
	mkdir -p $(@D)
	$(LD) -o $@ -T kernel/link.ld $^ --oformat binary

objects/os-image.bin:	${ASM_OBJECTS}	objects/kernel.bin
	mkdir -p $(@D)
	cat $^ > $@

output/floppy.img:		objects/os-image.bin
	mkdir -p $(@D)
	dd if=$< of=$@
	qemu-img resize -f raw $@ 1440k

clean:
	rm -rf objects output
