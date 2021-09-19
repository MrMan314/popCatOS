RECURSIVE =		$(foreach d,$(wildcard $(1:=/*)),$(call RECURSIVE,$d,$2) $(filter $(subst *,%,$2),$d))

CXX_SOURCES =	$(call RECURSIVE,kernel,*.cpp)
CXX_OBJECTS =	objects/${CXX_SOURCES:.cpp=.o}
ASM_SOURCES =	$(call RECURSIVE,boot,*.asm)
ASM_OBJECTS =	objects/${ASM_SOURCES:.asm=.o}

ARCH =			i686
QEMU =			qemu-system-x86_64
AS =			nasm
CC =			$(ARCH)-elf-g++
LD =			$(ARCH)-elf-ld

CXX_FLAGS =		-ffreestanding -c $< -o $@ -I kernel/include -Wall -Wextra -Werror
QEMU_FLAGS =	-drive file=$<,index=0,media=disk,format=raw -serial stdio

run:					floppy.img
	$(QEMU) $(QEMU_FLAGS)

${ASM_OBJECTS}:			${ASM_SOURCES}
	mkdir -p $(@D)
	$(AS) $^ -fbin -o $@

objects/kernel/entry.o:	kernel/entry.asm
	mkdir -p $(@D)
	$(AS) $^ -felf -o $@

${CXX_OBJECTS}:			${CXX_SOURCES}
	mkdir -p $(@D)
	$(CC) $(CXX_FLAGS)

objects/kernel.bin:		objects/kernel/entry.o	${CXX_OBJECTS}
	mkdir -p $(@D)
	$(LD) -o $@ -T kernel/link.ld $^ --oformat binary

objects/os-image.bin:	${ASM_OBJECTS}			objects/kernel.bin
	mkdir -p $(@D)
	cat $^ > $@

floppy.img:				objects/os-image.bin
	mkdir -p $(@D)
	dd if=$< of=$@
	qemu-img resize -f raw $@ 1440k

clean:
	rm -rf objects floppy.img
