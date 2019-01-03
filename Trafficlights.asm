data  segment
io8255a        equ 288h
io8255b        equ 289h
io8255c        equ 28ah
io8255con      equ 28bh
led      db   03fh,06h,05bh,04fh,066h,06dh,07dh,07h,07fh,06fh ;段码

buffer1  db   0,0         ;显示十位和个位的缓冲区
bz       dw   ?           ;位码
data  ends
code  segment
      assume cs:code,ds:data
start:  mov ax,data
        mov ds,ax
        mov dx,io8255con            ;将8255设为A口输出
        mov al,80h
        out dx,al
        mov di,offset buffer1       ;设di为显示缓冲区
        mov bl,81h 
onesecond:mov cx,110h               ;循环次数
          
loopout:  mov bh,02
position: mov byte ptr bz,bh
    push bx
    push di
    dec di
    add di, bz
    mov bl,[di]                     ;bl为要显示的数
    pop di
    mov bh,0
    mov si,offset led               
    add si,bx                       ;求出对应的led数码
    mov al,byte ptr [si]
    mov dx,io8255a                  ;8255的A口输出
    out dx,al
    mov al,byte ptr bz              ;相应的数码管亮
    mov dx,io8255c
    out dx,al
    pop bx
    push cx
        mov cx,100                 
delay:  loop delay                    
    pop cx

    mov al,00h
    out dx,al                         ;防止重影
    
    mov bh,byte ptr bz
    shr bh,1
    jnz position
    loop loopout                      
    mov  ax,word ptr [di]
    cmp  ah,00
    jnz  set
    cmp  al,00
    jnz  set
    call change
    mov  ax,0600
    mov  [di],al
    mov  [di+1],ah
    jmp  onesecond
set:mov  ax,word ptr [di]
    dec al
    aas
    mov [di],al                 ;al为ge位
    mov [di+1],ah               ;ah中为shi位
    cmp ax,0100
    jnbe slow
    cmp bl,80h
    jnb e  
    call scint2
    jmp  slow1
e:  call scint1
    jmp slow1
slow: mov al,bl
      mov dx,io8255b
      out dx,al
slow1:jmp onesecond
change proc                     ;路灯转换子程序
    cmp bl,81h
    jz a
    mov bl,81h
    jmp b
a:  mov bl,24h
b:  ret
change endp
scint1 proc                     ;闪烁子程序
    push ax                      
    push dx
    cmp bl,82h
    jz c
    mov bl,82h
    jmp d
c:  mov bl,80h
d:  mov al,bl
    mov dx,io8255b
    out dx,al
    pop dx
    pop ax  
    ret
scint1 endp
scint2 proc
    push ax
    push dx
    cmp bl,44h
    jz f
    mov bl,44h
    jmp g
f:  mov bl,04h
g:  mov al,bl
    mov dx,io8255b
    out dx,al
    pop dx
    pop ax
    ret
scint2 endp
code ends
    end start
