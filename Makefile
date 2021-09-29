RECURSIVE					= $(foreach d,	$(wildcard $(1:=/*)),$(call RECURSIVE,$d,$2) $(filter $(subst *,%,$2),$d))


GAS_BOOT_SRC				= $(call		RECURSIVE,src/boot,*.s)
GAS_KRNL_SRC				= $(call		RECURSIVE,src/kernel,*.s)
CPP_KRNL_SRC				= $(call		RECURSIVE,src/kernel,*.cpp)

GAS_BOOT_OBJ				= $(subst		src/,bin/,$(GAS_BOOT_SRC:.s=.elf))
GAS_KRNL_OBJ				= $(subst		src/,bin/,$(GAS_KRNL_SRC:.s=.elf))
CPP_KRNL_OBJ				= $(subst		src/,bin/,$(CPP_KRNL_SRC:.cpp=.elf))

ASM_BOOT_SRC				= $(call		RECURSIVE,src/boot,*.asm)
ASM_KRNL_SRC				= $(call		RECURSIVE,src/kernel,*.asm)

ASM_BOOT_OBJ				= $(subst		src/,bin/,$(ASM_BOOT_SRC:.asm=.bin))
ASM_KRNL_OBJ				= $(subst		src/,bin/,$(ASM_KRNL_SRC:.asm=.elf))

AS_FLAGS					= -c $(subst	bin/,src/,$(@:.elf=.s))		-o $@												-v
CPP_FLAGS					= -c $(subst	bin/,src/,$(@:.elf=.cpp))	-o $@	-I src/kernel/include -Wall -Wextra -Werror	-v

LD_KRN_FLAGS				= $^										-o $@	-T src/kernel/link.ld	--oformat=binary	-v
LD_GAS_FLAGS				= $^										-o $@	-Ttext 0x7C00			--oformat=binary	-v

ARCH						= i686
QEMU						= qemu-system-x86_64
AS							= $(ARCH)-elf-as
CC							= $(ARCH)-elf-g++
LD							= $(ARCH)-elf-ld

QEMU_FLAGS					= -drive file=$<,index=0,media=disk,format=raw -serial stdio

BOOTSECT					= bin/boot/boot.bin
KERNEL						= bin/kernel/kernel.bin
DISKIMG						= floppy.img

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
	dd if=/dev/zero			of=$@	conv=notrunc	bs=1024			count=1440
	dd if=$(BOOTSECT)		of=$@	conv=notrunc	bs=512	seek=0	count=1
	dd if=$(KERNEL)			of=$@	conv=notrunc	bs=512	seek=1

clean:
	rm -rf bin $(DISKIMG)
