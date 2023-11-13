org 7c00h

section .data
    char_counter db 0  ; Character counter to keep track of the number of characters in the buffer

section .bss
    buffer resb 255   ; Define a 255-byte buffer for input

section .text
    global _start

_start:                         
    mov si, buffer              ;Initialize buffer
    mov byte [char_counter], 0  ; Initialize the character counter to 0

read_char:
    mov ah, 0h           ; Set AH to 0 for keyboard input
    int 16h              ; Call interrupt 16h to get a key press

    cmp al, 0Dh          ; Compare AL (input) with Enter (0Dh)
    je handle_enter      

    cmp al, 08h          ; Compare AL (input) with Backspace (08h)
    je handle_backspace 

    cmp byte [char_counter], 255  ; Compare character counter with 255 (buffer limit)
    je read_char         ; If the buffer is full, continue reading characters

    mov [si], al         ; Store the character in AL into the buffer 
    inc si               ; Increment SI to point to the next buffer location
    inc byte [char_counter] ; Increment the character counter

    mov ah, 0Ah          ; Set AH to 0Ah for display function
    mov bh, 0x00         ; Set BH to 0x00 for page 0
    mov cx, 1            ; Set CX to 1 for the number of characters to display
    int 10h              ; Call interrupt 10h to print the character on the screen

    mov ah, 2            ; Set AH to 2 for cursor movement
    inc dl               ; Increment DL (cursor column)
    int 10h              ; Call interrupt 10h to move the cursor

    jmp read_char        

handle_enter:
    cmp dl, 0            ; Compare DL (cursor column) with 0
    je newline           ; If DL is 0, jump to newline

    cmp byte [char_counter], 0  
    je newline           ; If the buffer is empty, jump to newline

    mov byte [si], 0     ; Clear the character in the buffer at [SI]
    mov si, buffer       ; Reset SI to point to the start of the buffer

    mov ah, 2            ; Set AH to 2 for cursor movement
    inc dh               ; Increment DH (cursor row)
    inc dh               ; Move to the next line
    mov dl, 0            ; Set DL to 0 (start column)
    int 10h              ; Call interrupt 10h to set the cursor position

    jmp print_buffer     

handle_backspace:
    cmp dl, 0            ; Compare DL (cursor column) with 0
    je prev_line         ; If DL is 0, jump to prev_line

    dec si               ; Decrement SI to move it back in the buffer
    dec byte [char_counter] ; Decrement the character counter

    mov ah, 2            ; Set AH to 2 for cursor movement
    dec dl               ; Decrement DL (cursor column)
    int 10h              ; Call interrupt 10h to move the cursor to the left

    mov ah, 0Ah          ; Set AH to 0Ah for display function
    mov al, ' '          ; Set AL to space character
    mov bh, 0x00         ; Set BH to 0x00 for page 0
    mov cx, 1            ; Set CX to 1 for the number of spaces to display
    int 10h              ; Call interrupt 10h to display a space

    jmp read_char        

print_buffer:
    lodsb                ; Load the next character from [SI] into AL

    test al, al          ; Test if AL is zero (end of the buffer)
    jz newline           ; If AL is zero, jump to newline

    mov ah, 0Ah          ; Set AH to 0Ah for display function
    mov bh, 0x00         ; Set BH to 0x00 for page 0
    mov cx, 1            ; Set CX to 1 for the number of characters to display
    int 10h              ; Call interrupt 10h to display the character

    mov ah, 2            ; Set AH to 2 for cursor movement
    inc dl               ; Increment DL (cursor column)
    int 10h              ; Call interrupt 10h to move the cursor to the right

    jmp print_buffer     

newline:
    mov ah, 2            ; Set AH to 2 for cursor movement
    inc dh               ; Increment DH (cursor row)
    mov dl, 0            ; Set DL to 0 (start column)
    int 10h              ; Call interrupt 10h to move the cursor to the beginning of a new line

    jmp _start           

prev_line:
    cmp dh, 0            ; Compare DH (cursor row) with 0
    je _start            ; If DH is 0, jump to the beginning of the program

    mov ah, 2            ; Set AH to 2 for cursor movement
    dec dh               ; Decrement DH (cursor row)
    mov dl, 79           ; Set DL to 79 (last column)
    int 10h              ; Call interrupt 10h to move the cursor to the previous line

    jmp _start           
