; ---------- boot_bmi.asm ---------------------------------------
; 512‑baitu boot sektors  (x86 real‑mode, BIOS)
; Asamble:  nasm -f bin boot_bmi.asm -o boot_bmi.bin
; Testē:    qemu-system-x86_64 -drive if=floppy,file=boot_bmi.bin,format=raw -boot a -nographic

        org 0x7C00
        bits 16

; ------------------ dati / konstantes ------------------------------
weight      dq 78.0           ; kg
height      dq 1.2           ; m
ten         dq 10.0
msg         db "BMI: ",0

bmi10       dw 0              ; BMI x10 (integer)

; ------------------ start ------------------------------------------
start:
        cli
        xor ax, ax
        mov ds, ax
        mov es, ax
        sti

; --- FPU:  bmi*10  -----------------------------------------------
        fld     qword [weight]        ; st0 = w
        fld     qword [height]        ; st0 = h , st1 = w
        fmul    st0, st0              ; st0 = h²
        fdivp   st1, st0              ; st1 = w/h² , st0 popped  →  st0 = BMI
        fld     qword [ten]           ; st0 = 10 , st1 = BMI
        fmulp   st1, st0              ; st0 = BMI*10
        fistp   word  [bmi10]         ; saglabā veselu (noapaļots)   st0 popped

; --- drukā "BMI: " -------------------------------------------------
        mov si, msg
        call PutStr

; --- sadala bmi10 -> integer part + frac digit --------------------
        mov ax, [bmi10]       ; AX = BMI×10  (piem. 236)
        xor dx, dx
        mov bx, 10
        div bx                ; AX = int_part (23) , DL = frac digit (6)
        mov [frac], dl

        ; izdrukā int_part (1–3 cipari)
        call PrintDec         ; print AX (0–999)

        ; punkts
        mov al, '.'
        call PutChar

        ; izdrukā frac   (viens cipars)
        mov al, [frac]
        add al, '0'
        call PutChar

        ; bezgalīgs HLT
hang:   hlt
        jmp hang

; -------- apakšroutīnas -------------------------------------------
PutStr:                 ; DS:SI -> 0‑terminated
        lodsb
        or  al, al
        jz  .done
        call PutChar
        jmp PutStr
.done:  ret

PutChar:                ; AL = char
        mov ah, 0x0E
        mov bh, 0x00
        mov bl, 0x07
        int 0x10
        ret

; drukā 0‑999 decimāli (bez vadošām nullēm)
PrintDec:
        mov cx, 0            ; ciparu skaitītājs
.saveLoop:
        xor dx, dx
        mov bx, 10
        div bx               ; AX/=10 , DL=rem
        push dx              ; saglabā ciparu
        inc cx
        cmp ax, 0
        jne .saveLoop

.printLoop:
        pop dx
        add dl, '0'
        mov al, dl
        call PutChar
        loop .printLoop
        ret

; -------------- mainīgie ---------------
frac    db 0

; -------------- boot signature ----------
        times 510-($-$$) db 0
        dw 0xAA55
