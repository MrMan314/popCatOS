RECURSIVE =		$(foreach d,$(wildcard $(1:=/*)),$(call RECURSIVE,$d,$2) $(filter $(subst *,%,$2),$d))

CXX_SOURCES =	$(call RECURSIVE,kernel,*.cpp)
CXX_OBJECTS =	objects/${CXX_SOURCES:.cpp=.o}

ARCH =			i686
QEMU =			qemu-system-x86_64
AS =			$(ARCH)-elf-as
CC =			$(ARCH)-elf-g++
LD =			$(ARCH)-elf-ld

QEMU_FLAGS =	-drive file=$<,index=0,media=disk,format=raw -serial stdio
AS_FLAGS =		$^ -o $@ -v
CXX_FLAGS =		-ffreestanding -c $< -o $@ -I kernel/include -Wall -Wextra -Werror -v
LD_FLAGS =		-o $@ -T kernel/link.ld ${CXX_OBJECTS} -v
LD_AS_FLAGS =	-o $@ $^ -Ttext 0x7C00 --oformat=binary -v

run:						floppy.img
	$(QEMU) $(QEMU_FLAGS)

objects/boot/boot.elf:		boot/boot.s
	mkdir -p $(@D)
	$(AS) $(AS_FLAGS)

objects/boot/boot.bin:		objects/boot/boot.elf
	$(LD) $(LD_AS_FLAGS)

objects/kernel/entry.elf:	kernel/entry.s
	mkdir -p $(@D)
	$(AS) $(AS_FLAGS)

${CXX_OBJECTS}:				${CXX_SOURCES}
	mkdir -p $(@D)
	$(CC) $(CXX_FLAGS)

objects/kernel.bin:			objects/kernel/entry.elf	${CXX_OBJECTS}
	mkdir -p $(@D)
	$(LD) $(LD_FLAGS)

floppy.img:					objects/boot/boot.bin		objects/kernel.bin
	mkdir -p $(@D)
	dd if=/dev/zero				of=$@					bs=1024			count=1440
	dd if=objects/boot/boot.bin	of=$@	conv=notrunc	bs=512	seek=0	count=1
	dd if=objects/kernel.bin	of=$@	conv=notrunc	bs=512	seek=1

clean:
	rm -rf objects floppy.img
