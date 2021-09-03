all: 					clean	run
run:					output/floppy.img
	qemu-system-i386 -fda $< -serial stdio
objects/boot.bin:		boot/boot.asm
	nasm $< -fbin -o $@
objects/entry.elf:		boot/entry.asm
	nasm $< -felf -o $@
objects/kernel:			kernel/kernel.cpp
	i686-elf-g++ -ffreestanding -c $< -o $@ -I kernel/include -Wall -Wextra -Werror
objects/kernel.bin:		objects/entry.elf objects/kernel
	i686-elf-ld -o $@ -T kernel/link.ld $^ --oformat binary
objects/os-image.bin:	objects/boot.bin objects/kernel.bin
	cat $^ > $@
output/floppy.img:		objects/os-image.bin
	dd if=$< of=$@
	qemu-img resize $@ 1440k
clean:
	rm -rf objects/* output/*
	mkdir -p objects output
