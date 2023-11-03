org 0x7c00

               
mov ax, 1300h
mov al, 1                 
mov bl, 13H   
mov cx, msg_len                
mov dh, 0x01              
mov dl, 0x00               
mov bp, msg                

int 10H

jmp $                    

msg db "Hello World!"
msg_len equ $-msg
    
    