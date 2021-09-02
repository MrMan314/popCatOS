[org	0x7C00]

begin:
	xor		ax,		ax
	mov		ds,		ax
	mov		es,		ax
	mov		fs,		ax
	mov		gs,		ax
	mov		ss,		ax
	mov		sp,		0x9000
	mov		sp,		bp
	jmp 	0x0:main

main:
	sti
	mov		[BOOTDRIVE],	dl
	mov		bx, 			REALMODETEXT
	call	PRINT
	call	PRINTLN
	call	KERNLOAD
	call	PMSWITCH
	jmp		$

PRINT:
	mov		al,				[bx]
	cmp		al, 			0
	je		PRINTDONE
	mov		ah, 			0x0E
	int		0x10
	add		bx, 			1
	jmp		PRINT

PRINTDONE:
	ret

PRINTLN:
	mov		ah, 			0x0E
	mov		al, 			0x0A
	int		0x10
	mov		al,				0x0D
	int		0x10
	ret

DISKLOAD:
	push	ax
	push	bx
	push	cx
	push	dx
	push	ax
.rst:
	mov		ah,	0x00
	int		0x13
	jc		.rst
	mov		ah,	0x02
	int		0x13
	jc		DISKERROR
	pop		cx
	cmp		al,	cl
	jne		SECTORSERROR
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	ret

DISKERROR:
	mov		bx,				DISKERRORTEXT
	call	PRINT
	jmp		DISKLOOP

SECTORSERROR:
	mov		bx,				SECTORSERRORTEXT
	call	PRINT

DISKLOOP:
	cli
	hlt

GDTSTART:
	dd		0x0000
	dd		0x0000

GDTCODE:
	dw		0xFFFF
	dw		0x0000
	db		0x0000
	db		0x009A
	db		0x00CF
	db		0x0000

GDTDATA:
	dw		0xFFFF
	dw		0x0000
	db		0x0000
	db		0x0092
	db		0x00CF
	db		0x0000

GDTEND:

GDTDESC:
	dw		GDTEND - GDTSTART - 1
	dd		GDTSTART

CODESEG	equ	GDTCODE-GDTSTART
DATASEG	equ	GDTDATA-GDTSTART

[bits	16]
PMSWITCH:
	cli
	lgdt	[GDTDESC]
	mov		eax,	cr0
	or		al,		1
	mov		cr0,	eax
	jmp		CODESEG:PMMAIN

KERNLOAD:
	cli
	mov		bx,		KERNLOADTEXT
	call	PRINT
	call	PRINTLN
	mov		bx,		KERNOFFSET
	mov		al,		0x32
	mov		dl,		[BOOTDRIVE]
	mov		ch,		0x00
	mov		cl,		0x02
	mov		dh,		0x00
	call	DISKLOAD
	mov		ah,				0x00
	mov		al,				0x13
	int		0x10
	ret

[bits	32]
A20CHECK:
	pushad
	mov	edi,	0x112345
	mov	esi,	0x012345
	mov	[esi],	esi
	mov	[edi],	edi
	cmpsd
	popad
	jne	CONT
	ret

A20ENABLE:
	in	al,		0x92
	or	al,		2
	out	0x92,	al
	ret

[bits	32]
PMMAIN:
	jmp		A20CHECK
	jmp		A20ENABLE
	jmp		$

CONT:
	mov		ax,		0x10
	mov		ds,		ax
	mov		es,		ax
	mov		fs,		ax
	mov		gs,		ax
	mov		ss,		ax
	mov		sp,		0x7C00
	jmp		0x8:	KERNOFFSET
	jmp		$

KERNOFFSET		equ	0x1000

BOOTDRIVE:			db	0x0
REALMODETEXT:		db	"Booting up...",								0
DISKERRORTEXT:		db	"DISK ERROR: ERROR READING DISK!",				0
SECTORSERRORTEXT:	db	"DISK ERROR: INVALID NUMBER OF SECTORS READ!",	0
KERNLOADTEXT:		db	"Loading Kernel...",							0

times	510-($-$$)	db	0
dw		0xAA55