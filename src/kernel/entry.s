.EXTERN main
.EXTERN handler
CALL    main
PUSH    %EAX
CALL    handler
CLI
HLT