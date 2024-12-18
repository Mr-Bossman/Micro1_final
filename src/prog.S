.text
.syntax unified
.cpu    cortex-m0
.globl  novel

// void print_slowed(const char *str, size_t len);
print_slowed:
        push    {r4-r6, lr}
        movs    r5, r0
        cmp     r1, #0
        bne     .print_slowed_L0
        subs    r1, r1, #1
.print_slowed_L0:
        adds    r4, r5, r1
.print_slowed_L1:
        ldrb    r0, [r5]
        cmp     r0, #0
        beq     .print_slowed_L2
        cmp     r5, r4
        bne     .print_slowed_L3
.print_slowed_L2:
        pop     {r4-r6, pc}
.print_slowed_L3:
        bl      putchar
        ldr     r0, =#500
        bl      delay
        adds    r5, r5, #1
        b       .print_slowed_L1

// void delay(int);
delay:
        ldr     r1, =0x40054028
        ldr     r2, [r1]
.delay_L0:
        ldr     r3, [r1]
        subs    r3, r3, r2
        cmp     r3, r0
        blt     .delay_L0
        bx      lr

// bool check_button(int);
check_button:
        push    {r4-r6, lr}
        movs    r4, #1
        lsls    r4, r4, r0
        movs    r0, #0
        ldr     r5, =0xd0000004
.check_button_L0:
        ldr     r6, [r5]
        ands    r6, r4
        cmp     r6, #0
        beq     .check_button_L1
        ldr     r0, =#25000
        bl      delay
        movs    r0, #1
        b       .check_button_L0
.check_button_L1:
        pop     {r4-r6, pc}

// int check_button(void);
check_buttons:
        push    {r4, lr}
        movs    r0, #28
        movs    r4, #1
        bl      check_button
        cmp     r0, #1
        beq     .check_buttons_L0
        movs    r0, #27
        movs    r4, #0
        bl      check_button
        cmp     r0, #1
        beq     .check_buttons_L0
        mvns    r4, r4
.check_buttons_L0:
        movs    r0, r4
        pop     {r4, pc}

// int get_button(int);
get_button:
        push    {r4, lr}
        movs    r4, r0
.get_button_L0:
        bl      check_buttons
        cmp     r0, #0
        bmi     .get_button_L0
        cmp     r4, #0
        beq     .get_button_L1
        cmp     r0, r4
        bne     .get_button_L0
        movs    r0, #1
.get_button_L1:
        pop     {r4, pc}

// void set_sio(int);
set_sio:
        lsls    r0, r0, #3
        ldr     r1, =0x40014004
        adds    r0, r1
        movs    r1, #5
        str     r1, [r0]
        bx      lr

// void set_pad(int);
set_pad:
        lsls    r0, r0, #2
        ldr     r1, =0x4001c004
        adds    r0, r1
        movs    r2, #64
        ldr     r1, [r0]
        orrs    r1, r2
        str     r1, [r0]
        bx      lr

// int novel(void);
 novel:
        push    {r4-r7, lr}
        sub     sp, #116
        add     r5, sp, #4
        ldr     r1, =.novel.text
        movs    r2, #111
        mov     r0, r5
        bl      memcpy
        movs    r0, #28
        bl      set_sio
        movs    r0, #28
        bl      set_pad
        movs    r0, #27
        bl      set_sio
        movs    r0, #27
        bl      set_pad
        movs    r7, #0
        movs    r0, #1
        str     r0, [sp]
        mov     r4, r7
.novel_L0:
        mov     r0, r5
        ldr     r1, [sp]
        mov     r2, r1
        bl      lcd_int
        cmp     r0, #0
        bmi     .novel_L7
        mov     r5, r0
        movs    r6, #0
        mov     r0, r6
        bl      get_button
        cmp     r0, #2
        beq     .novel_L2
        cmp     r0, #0
        bne     .novel_L3
        movs    r0, #0
        cmp     r4, #0
        beq     .novel_L4
        subs    r5, r4, #2
        blt     .novel_L5
        subs    r4, r4, #1
        movs    r7, #0
.novel_L1:
        add     r0, sp, #4
        adds    r0, r0, r7
        movs    r1, #0
        mov     r2, r1
        bl      lcd_int
        adds    r7, r0, r7
        subs    r4, r4, #1
        bne     .novel_L1
        mov     r4, r5
        b       .novel_L6
.novel_L2:
        mov     r7, r6
        b       .novel_L6
.novel_L3:
        adds    r7, r5, r7
        b       .novel_L6
.novel_L4:
        mvns    r4, r0
        b       .novel_L6
.novel_L5:
        mov     r4, r5
        mov     r7, r0
.novel_L6:
        add     r0, sp, #4
        adds    r5, r0, r7
        ldrb    r0, [r0, r7]
        adds    r4, r4, #1
        cmp     r0, #0
        bne     .novel_L0
.novel_L7:
        movs    r5, #0
        mov     r0, r5
        ldr     r1, [sp]
        mov     r2, r1
        bl      lcd_int
        mov     r0, r5
        add     sp, #116
        pop     {r4-r7, pc}

//int lcd_int(int col, int line, const char *str, bool clear, bool display);
lcd_int:
        push    {r4-r7, lr}
        sub     sp, #20
        cmp     r1, #0
        ldr     r4, =lcd
        beq     .lcd_int_L1
        movs    r3, #0
        mov     r1, r3
.lcd_int_L0:
        strb    r3, [r4, r1]
        adds    r1, r1, #1
        cmp     r1, #32
        bne     .lcd_int_L0
.lcd_int_L1:
        cmp     r0, #0
        beq     .lcd_int_L8
        ldrb    r1, [r0]
        cmp     r1, #0
        beq     .lcd_int_L9
        str     r2, [sp, #8]
        str     r4, [sp, #4]
        str     r0, [sp]
        adds    r0, r0, #1
        str     r0, [sp, #12]
        movs    r3, #0
        mov     r5, r3
        mov     r7, r3
        str     r3, [sp, #16]
.lcd_int_L2:
        subs    r6, r5, r7
        asrs    r2, r6, #31
        lsrs    r2, r2, #28
        adds    r0, r6, r2
        movs    r4, #15
        mov     r2, r0
        bics    r2, r4
        subs    r6, r6, r2
        cmp     r1, #10
        bne     .lcd_int_L3
        adds    r0, r7, r6
        adds    r7, r0, #1
        ldr     r0, [sp, #16]
        adds    r0, r0, #1
        str     r0, [sp, #16]
        b       .lcd_int_L6
.lcd_int_L3:
        cmp     r6, #0
        bne     .lcd_int_L5
        cmp     r1, #32
        beq     .lcd_int_L4
        cmp     r1, #9
        bne     .lcd_int_L5
.lcd_int_L4:
        adds    r7, r7, #1
.lcd_int_L5:
        asrs    r0, r0, #4
        ldr     r2, [sp, #16]
        adds    r3, r0, r2
        cmp     r3, #1
        bgt     .lcd_int_L7
        ldr     r0, [sp, #8]
        cmp     r0, #0
        beq     .lcd_int_L6
        lsls    r0, r3, #4
        ldr     r2, [sp, #4]
        adds    r0, r2, r0
        strb    r1, [r0, r6]
.lcd_int_L6:
        ldr     r0, [sp, #12]
        ldrb    r1, [r0, r5]
        adds    r5, r5, #1
        cmp     r1, #0
        bne     .lcd_int_L2
.lcd_int_L7:
        movs    r0, #2
        eors    r0, r3
        orrs    r6, r0
        rsbs    r1, r6, #0
        adcs    r1, r6
        ldr     r4, [sp, #4]
        ldr     r2, [sp, #8]
        ldr     r0, [sp]
        b       .lcd_int_L10
.lcd_int_L8:
        movs    r5, #0
        b       .lcd_int_L13
.lcd_int_L9:
        movs    r5, #0
        mov     r1, r5
.lcd_int_L10:
        cmp     r1, #0
        beq     .lcd_int_L13
        movs    r6, #0
.lcd_int_L11:
        ldrb    r1, [r0, r5]
        cmp     r1, #0
        beq     .lcd_int_L13
        cmp     r1, #10
        beq     .lcd_int_L13
        cmp     r5, #0
        bmi     .lcd_int_L13
        cmp     r1, #32
        beq     .lcd_int_L13
        cmp     r2, #0
        beq     .lcd_int_L12
        subs    r1, r4, r6
        movs    r3, #32
        strb    r3, [r1, #31]
        adds    r6, r6, #1
.lcd_int_L12:
        subs    r5, r5, #1
        b       .lcd_int_L11
.lcd_int_L13:
        cmp     r2, #0
        beq     .lcd_int_L15
        ldr     r0, =.L.str
        movs    r6, #0
        mov     r1, r6
        str     r6, [sp, #16]
        bl      print_slowed
        movs    r7, #16
        mov     r0, r4
        mov     r1, r7
        bl      print_slowed
        ldr     r0, =.L.str.1
        mov     r1, r6
        bl      print_slowed
        mov     r6, r4
        adds    r6, #16
        mov     r0, r6
        mov     r1, r7
        bl      print_slowed
        ldr     r0, =.L.str.2
        ldr     r1, [sp, #16]
        bl      print_slowed
        mov     r0, r4
        mov     r1, r7
        bl      print_slowed
        ldrb    r0, [r4, #15]
        cmp     r0, #0
        bne     .lcd_int_L14
        ldr     r0, =.L.str.3
        movs    r1, #0
        bl      print_slowed
.lcd_int_L14:
        movs    r1, #16
        mov     r0, r6
        bl      print_slowed
.lcd_int_L15:
        mov     r0, r5
        add     sp, #20
        pop     {r4-r7, pc}

.data
lcd:
        .zero   32

.novel.text:
        .asciz  "This is a really long string that should be printed on the lcd screen.\n I wonder if new lines work?\n Did they?"

.L.str:
        .asciz  "\033[H\033[2J\033[3J"

.L.str.1:
        .asciz  "\r\n"

.L.str.2:
        .asciz  "\r\n\n\n\r\f"

.L.str.3:
        .asciz  "\n"