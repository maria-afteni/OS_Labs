go:
    mov ah, 0x0A   ; Set AH to 0x0A to specify the "Write Character" function
    mov al, 'A'    
    mov bh, 0x00   
    mov cx, 0x01   
    int 0x10       