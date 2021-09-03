all: 					clean	run
run:					output/floppy.img
	qemu-system-i386 -L lib/pc-bios -fda $< -serial stdio
objects/boot.bin:		boot/boot.s
	nasm $< -fbin -o $@
objects/entry.elf:		boot/entry.s
	nasm $< -felf -o $@
objects/kernel:			kernel/kernel.cpp
	i386-elf-g++ -ffreestanding -c $< -o $@ -I kernel/include -Wall -Wextra -Werror
objects/kernel.bin:		objects/entry.elf objects/kernel
	i386-elf-ld -o $@ -Ttext 0x1000 $^ --oformat binary
objects/os-image.bin:	objects/boot.bin objects/kernel.bin
	cat $^ > $@
output/floppy.img:		objects/os-image.bin
	dd if=$< of=$@
	qemu-img resize $@ 1440k
clean:
	rm -rf objects/os-image.bin objects/* output/*
