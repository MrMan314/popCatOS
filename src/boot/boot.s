.CODE16

.GLOBAL     _start
_start:
    CLI
    XORW    %AX,        %AX
    MOVW    %AX,        %DS
    MOVW    %AX,        %ES
    MOVW    %AX,        %FS
    MOVW    %AX,        %GS
    MOVW    %AX,        %SS
    MOVW    $0x9000,    %SP
    MOVW    %BP,        %SP
    LJMP    $0x0,       $MAIN

MAIN:
    MOV     $STARTMSG,  %SI
    CALL    PRINT
    MOVB    %DL,        BD
    MOVW    $0x1000,    %BX
    MOVB    $0x32,      %AL
    MOVB    BD,         %DL
    MOVB    $0x00,      %CH
    MOVB    $0x02,      %CL
    MOVB    $0x00,      %DH
    PUSH    %AX
    PUSH    %BX
    PUSH    %CX
    PUSH    %DX
    PUSH    %AX
.RST:
    MOV     $DISKRST,   %SI
    CALL    PRINT
    MOVB    $0x00,      %AH
    INT     $0x13
    JC      .RST
    MOVB    $0x02,      %AH
    INT     $0x13
    JC      .DISKERR
    POP     %CX
    CMP     %CL,        %AL
    JNE     .DISKERR
    POP     %DX
    POP     %CX
    POP     %BX
    POP     %AX
    CLI
    LGDT    (GDTDESC)
    MOVL    %CR0,       %EAX
    OR      $0x1,       %AL
    MOVL    %EAX,       %CR0
    LJMP    $CODESEG,   $PMMAIN
    CLI
    JMP     .HANG
.DISKERR:
    MOV     $DISKERR,   %SI
    CALL    PRINT
    CLI
.HANG:
    JMP     .HANG

GDTSTART:
    .LONG   0x0000
    .LONG   0x0000

GDTCODE:
    .LONG   0xFFFF
    .BYTE   0x0000
    .BYTE   0x009A
    .BYTE   0x00CF
    .BYTE   0x0000

GDTDATA:
    .WORD   0xFFFF
    .WORD   0x0000
    .BYTE   0x0000
    .BYTE   0x0092
    .BYTE   0x00CF
    .BYTE   0x0000

GDTEND:

GDTDESC:
    .WORD   GDTEND - GDTSTART - 1
    .LONG   GDTSTART

.EQU    CODESEG,    GDTCODE - GDTSTART
.EQU    DATASEG,    GDTDATA - GDTSTART

PRINT: PUSHA
PRINTSTART:
    XORB    %BH,    %BH
    MOVB    $0x0E,  %AH
    LODSB
    CMPB    $0x00,  %AL
    JE      PRINTDONE
    INT     $0x10
    JMP     PRINTSTART
PRINTDONE:
    POPA
    RET

.CODE32
PMMAIN:
    PUSHAL
    MOVL    $0x112345,  %EDI
    MOVL    $0x012345,  %ESI
    MOVL    %ESI,       (%ESI)
    MOVL    %EDI,       (%EDI)
    CMPSD
    POPAL
    JNE     .CONT
    INB     $0x92,      %AL
    OR      $0x02,      %AL
    OUT     %AL,        $0x92
    JMP     PMMAIN
.CONT:
    MOVW    $0x10,      %AX
    MOVW    %AX,        %DS
    MOVW    %AX,        %ES
    MOVW    %AX,        %FS
    MOVW    %AX,        %GS
    MOVW    %AX,        %SS
    MOVW    $0x7C00,    %SP
    JMPL    $0x8,       $0x1000
    JMP     .CONT

BD:         .WORD   0x0000
DISKERR:    .ASCIZ  "DISK I/O ERROR\r\n"
DISKRST:    .ASCIZ  "Resetting Disk...\r\n"
STARTMSG:   .ASCIZ  "popCatOS Bootloader\r\n"
.FILL   0x1FE-(.-_start), 0x01, 0x00
.WORD   0xAA55
