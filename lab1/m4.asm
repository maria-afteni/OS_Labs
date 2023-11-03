go:
    mov ah, 09h 
    mov al, 'M' 
    mov bl, 13H    ; Attribute/Color
    mov cx, 8      ; Number of characters to write
    int 10h 