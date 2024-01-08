section .text
    global _start

_start:
    ; receive segment:offset pair from the bootloader
    mov [add1], ax
    mov [add2], bx

    mov si, [add1]
    mov ds, [add2]

    mov byte [video_mode], 13
    mov byte [pixel_color], 0

    mov byte [line_length], 0
    mov byte [rectangle_width], 0

    mov word [left_indent], 10
    mov word [rectangle_indent], 0

    mov word [line_number], 10

    mov byte [rectangles], 0
    mov word [rectangle_height], 0

    mov byte [char_counter], 0
    mov byte [result], 0

    mov byte [page], 0
    mov byte [c], 0
    
    jmp menu


menu:
    mov byte [page], 0
    mov word [line_number], 10

    ; set text video mode
    mov ah, 00h 
    mov al, 2
    int 10h  

    ; print command disclaimer
    call find_current_cursor_position
    
    mov ax, [add2]
    mov es, ax
    mov bh, [page]
    mov bl, 07h
    mov cx, disclaimer_length

    mov ax, disclaimer
    add ax, word [add1]
    mov bp, ax

    mov ax, 1301h
    int 10h 

    call newline

    ; print reboot option
    ; print command disclaimer
    call find_current_cursor_position
    
    mov ax, [add2]
    mov es, ax
    mov bh, [page]
    mov bl, 07h
    mov cx, reboot_prompt_length

    mov ax, reboot_prompt
    add ax, word [add1]
    mov bp, ax

    mov ax, 1301h
    int 10h 

    ; read character
    mov ah, 00h
    int 16h

    cmp al, 'r'
    je reboot

    call newline

    ; input rectangle width
    call find_current_cursor_position
    
    mov ax, [add2]
    mov es, ax
    mov bh, [page]
    mov bl, 07h
    mov cx, rectangle_width_prompt_length
    
    mov ax, rectangle_width_prompt
    add ax, word [add1]
    mov bp, ax

    mov ax, 1301h
    int 10h 

    mov byte [result], 0
    call clear_buffer
    call read_buffer

    mov al, [result]
    mov byte [rectangle_width], al

    call newline

    ; input rectangle height
    call find_current_cursor_position
    
    mov ax, [add2]
    mov es, ax
    mov bh, [page]
    mov bl, 07h
    mov cx, rectangle_height_prompt_length
    
    mov ax, rectangle_height_prompt
    add ax, word [add1]
    mov bp, ax

    mov ax, 1301h
    int 10h 

    mov byte [result], 0
    call clear_buffer
    call read_buffer

    mov al, [result]
    mov byte [rectangle_height], al

    call newline


    ; input rectangle indent
    call find_current_cursor_position
    
    mov ax, [add2]
    mov es, ax
    mov bh, [page]
    mov bl, 07h
    mov cx, rectangle_indent_prompt_length
    
    mov ax, rectangle_indent_prompt
    add ax, word [add1]
    mov bp, ax

    mov ax, 1301h
    int 10h 

    mov byte [result], 0
    call clear_buffer
    call read_buffer

    mov al, [result]
    mov byte [rectangle_indent], al

    call newline

    ; input rectangle color
    call find_current_cursor_position
    
    mov ax, [add2]
    mov es, ax
    mov bh, [page]
    mov bl, 07h
    mov cx, rectangle_color_prompt_length

    mov ax, rectangle_color_prompt
    add ax, word [add1]
    mov bp, ax

    mov ax, 1301h
    int 10h 

    mov byte [result], 0
    call clear_buffer
    call read_buffer

    mov al, [result]
    mov byte [rectangle_color], al

    call newline
    
    call draw_rectangle

    ; read character
    mov ah, 00h
    int 16h

    call change_page_number
    jmp menu
    
    jmp end


reboot:
    call change_page_number

    ; set text video mode
    mov ah, 00h 
    mov al, 2
    int 10h 

    jmp 0000h:7c00h


read_buffer:
    read_char:
        ; read character
        mov ah, 00h
        int 16h

        ; check if the ENTER key was introduced
        cmp al, 0dh
        je handle_enter

        ; check if the BACKSPACE key was introduced
        cmp al, 08h
        je handle_backspace

        ; add character into the buffer and increment its pointer
        mov [si], al
        inc si
        inc byte [char_counter]

        ; display character as TTY
        mov ah, 0eh
        mov bl, 07h
        int 10h

        jmp read_char
    
    handle_enter:
        mov byte [si], 0
        mov si, buffer
        call convert_input_int
        jmp end_read_buffer

    handle_backspace:
        call find_current_cursor_position

        cmp byte [char_counter], 0
        je read_char

        ; clear last buffer char 
        dec si
        dec byte [char_counter]

        ; move cursor to the left
        mov ah, 02h
        mov bh, 0
        dec dl
        int 10h

        ; print space instead of the cleared char
        mov ah, 0ah
        mov al, ' '
        mov bh, 0
        mov cx, 1
        int 10h

        jmp read_char

    end_read_buffer:

    ret


clear_buffer:
    mov byte [char_counter], 0
    mov byte [si], 0
    mov si, buffer

    ret


draw_rectangle:
    ; set graphic video mode
    mov ah, 00h 
    mov al, [video_mode]
    int 10h  

    ; dark blue rectangle
    mov al, byte [rectangle_height]
    mov byte [rectangles], al
    mov byte [pixel_color], 1
    call draw_rect


    
    ret


draw_rect:

    rect_loop:
        mov al, byte [rectangle_width]
        mov byte [line_length], al

        mov al, byte [rectangle_indent]
        mov byte [left_indent], al
        mov cx, [left_indent]
        call draw_line

        cmp byte [rectangles], 0
        je end_rect_loop

        dec byte [rectangles]
        jmp rect_loop

    end_rect_loop:

    ret


draw_line:

    draw_pixel:
        mov ah, 0ch
        mov bh, byte [page]
        mov al, [rectangle_color]
        mov dx, [line_number]          
        int 10h

        inc cx

        dec byte [line_length]
        cmp byte [line_length], 0
        jne draw_pixel

    inc word [line_number]
    
    ret


convert_input_int:
    xor ax, ax
    xor bx, bx

    convert_digit:
        lodsb

        sub al, '0'
        xor bh, bh
        imul bx, 10
        add bl, al
        mov [result], bl

        dec byte [char_counter]
        cmp byte [char_counter], 0
        jne convert_digit

    ret


change_page_number:
    inc byte [page]
    mov ah, 05h
    mov al, [page]
    int 10h

    ret


find_current_cursor_position:
    mov ah, 03h
    mov bh, byte [page]
    int 10h

    ret


newline:
    call find_current_cursor_position

    mov ah, 02h
    mov bh, 0
    inc dh
    mov dl, 0
    int 10h

    ret

end:


section .data
    disclaimer db ""
    disclaimer_length equ 0

    reboot_prompt db "Press r to reboot or any other key to continue: "
    reboot_prompt_length equ 47

    rectangle_width_prompt db "Width of rectangular: "
    rectangle_width_prompt_length equ 22

    rectangle_indent_prompt db "Start point: "
    rectangle_indent_prompt_length equ 13

    rectangle_height_prompt db "Height of rectangular: "
    rectangle_height_prompt_length equ 23

    
    rectangle_color_prompt db "Rectangle color (0-15): "
    rectangle_color_prompt_length equ 24 



section .bss
    video_mode resb 1
    pixel_color resb 1

    line_length resb 1
    rectangle_width resb 1

    left_indent resb 2
    rectangle_indent resb 2

    line_number resb 2

    rectangles resb 1
    rectangle_height resb 2

    char_counter resb 1
    result resb 1

    page resb 1
    c resb 1

    add1 resb 2
    add2 resb 2
    buffer resb 100

    rectangle_color resb 1
