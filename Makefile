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

QEMU_FLAGS =	-drive file=$<,index=0,media=disk,format=raw -serial stdio
AS_BIN_FLAGS = 	$^ -fbin -o $@ -L+
AS_ELF_FLAGS =	$^ -felf -o $@ -L+
CXX_FLAGS =		-ffreestanding -c $< -o $@ -I kernel/include -Wall -Wextra -Werror -v
LD_FLAGS =		-o $@ -T kernel/link.ld ${CXX_OBJECTS} -v

run:					floppy.img
	$(QEMU) $(QEMU_FLAGS)

${ASM_OBJECTS}:			${ASM_SOURCES}
	mkdir -p $(@D)
	$(AS) $(AS_BIN_FLAGS)

objects/kernel/entry.o:	kernel/entry.asm
	mkdir -p $(@D)
	$(AS) $(AS_ELF_FLAGS)

${CXX_OBJECTS}:			${CXX_SOURCES}
	mkdir -p $(@D)
	$(CC) $(CXX_FLAGS)

objects/kernel.bin:		objects/kernel/entry.o	${CXX_OBJECTS}
	mkdir -p $(@D)
	$(LD) $(LD_FLAGS)

objects/os-image.bin:	${ASM_OBJECTS}			objects/kernel.bin
	mkdir -p $(@D)
	cat $^ > $@

floppy.img:				objects/os-image.bin
	mkdir -p $(@D)
	dd if=$< of=$@
	qemu-img resize -f raw $@ 1440k

clean:
	rm -rf objects floppy.img
