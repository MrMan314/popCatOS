RECURSIVE =					$(foreach d,$(wildcard $(1:=/*)),$(call RECURSIVE,$d,$2) $(filter $(subst *,%,$2),$d))


GAS_BOOT_SRC =				$(call RECURSIVE,boot,*.s)
GAS_KRNL_SRC =				$(call RECURSIVE,kernel,*.s)
CPP_KRNL_SRC =				$(call RECURSIVE,kernel,*.cpp)

GAS_BOOT_OBJ =				$(foreach word,	$(GAS_BOOT_SRC:.s=.elf),	objects/$(word))
GAS_KRNL_OBJ =				$(foreach word,	$(GAS_KRNL_SRC:.s=.elf),	objects/$(word))
CPP_KRNL_OBJ =				$(foreach word,	$(CPP_KRNL_SRC:.cpp=.elf),	objects/$(word))

ASM_BOOT_SRC =				$(call RECURSIVE,boot,*.asm)
ASM_KRNL_SRC =				$(call RECURSIVE,kernel,*.asm)

ASM_BOOT_OBJ =				$(foreach word, $(ASM_BOOT_SRC:.asm=.bin),	objects/$(word))
ASM_KRNL_OBJ =				$(foreach word,	$(ASM_KRNL_SRC:.asm=.elf),	objects/$(word))

ARCH =						i686
QEMU =						qemu-system-x86_64
AS =						$(ARCH)-elf-as
CC =						$(ARCH)-elf-g++
LD =						$(ARCH)-elf-ld

QEMU_FLAGS =				-drive file=$<,index=0,media=disk,format=raw -serial stdio

AS_FLAGS =					-c $(subst objects/,,$(@:.elf=.s))			-o $@											-v
CPP_FLAGS =					-c $(subst objects/,,$(@:.elf=.cpp))		-o $@	-I kernel/include -Wall -Wextra -Werror	-v

LD_KRN_FLAGS =				$^											-o $@	-T kernel/link.ld	--oformat=binary	-v
LD_GAS_FLAGS =				$^											-o $@	-Ttext 0x7C00		--oformat=binary	-v

BOOTSECT =					objects/boot/boot.bin
KERNEL = 					objects/kernel.bin
DISKIMG =					floppy.img

run:						$(DISKIMG)
	$(QEMU) $(QEMU_FLAGS)

$(GAS_KRNL_OBJ):			$(GAS_KRNL_SRC)
	mkdir -p $(@D)
	$(AS) $(AS_FLAGS)

$(GAS_BOOT_OBJ):			$(GAS_BOOT_SRC)
	mkdir -p $(@D)
	$(AS) $(AS_FLAGS)

$(BOOTSECT):				$(GAS_BOOT_OBJ)
	$(LD) $(LD_GAS_FLAGS)

$(CPP_KRNL_OBJ):			$(CPP_KRNL_SRC)
	mkdir -p $(@D)
	$(CC) $(CPP_FLAGS)

$(KERNEL):					$(GAS_KRNL_OBJ)	$(CPP_KRNL_OBJ)
	mkdir -p $(@D)
	$(LD) $(LD_KRN_FLAGS)

$(DISKIMG):					$(BOOTSECT)		$(KERNEL)
	mkdir -p $(@D)
	dd if=/dev/zero			of=$@	conv=notrunc	bs=1024			count=1440
	dd if=$(BOOTSECT)		of=$@	conv=notrunc	bs=512	seek=0	count=1
	dd if=$(KERNEL)			of=$@	conv=notrunc	bs=512	seek=1

clean:
	rm -rf objects $(DISKIMG)
