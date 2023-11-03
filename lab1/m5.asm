go:
    mov ah, 09h    ; Function 09h = Write Character and Attribute at Cursor Position
    mov al, 'M' 
    mov bl, 13H    ; Attribute/Color
    mov cx, 8      ; Number of characters to write
    int 10h     

    mov ah, 02h    ; Function 02h = Set Cursor Position
    mov bh, 0      ; Page number
    mov dh, 0      ; Row
    mov dl, 8      ; Column
    int 10h