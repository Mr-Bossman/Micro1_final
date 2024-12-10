.text
.syntax unified
.cpu    cortex-m0
.globl  novel

print_slowed:
        push    {r4, r5, r6, lr}
        movs    r5, r0
        cmp     r1, #0
        bne     .L2
        subs    r1, r1, #1
.L2:
        adds    r4, r5, r1
.L3:
        ldrb    r0, [r5]
        cmp     r0, #0
        beq     .L1
        cmp     r5, r4
        bne     .L5
.L1:
        pop     {r4, r5, r6, pc}
.L5:
        bl      putchar
        movs    r0, #1
        bl      sleep_ms
        adds    r5, r5, #1
        b       .L3


get_button:
        push    {r4, lr}
        movs    r4, r0
.L15:
        bl      getchar
        cmp     r0, #0
        ble     .L15
        cmp     r4, #0
        beq     .L10
        cmp     r0, r4
        bne     .L15
        movs    r0, #1
.L10:
        pop     {r4, pc}

 novel:
        push    {r4, r5, r6, r7, lr}
        sub     sp, #116
        add     r5, sp, #4
        ldr     r1, =.novel.text
.LPC0_0:
        movs    r2, #111
        mov     r0, r5
        bl      memcpy
        movs    r7, #0
        movs    r0, #1
        str     r0, [sp]
        mov     r4, r7
.LBB0_1:
        mov     r0, r5
        ldr     r1, [sp]
        mov     r2, r1
        bl      lcd_int
        cmp     r0, #0
        bmi     .LBB0_14
        mov     r5, r0
        movs    r6, #0
        mov     r0, r6
        bl      get_button
        cmp     r0, #115
        beq     .LBB0_9
        cmp     r0, #98
        bne     .LBB0_10
        movs    r0, #0
        cmp     r4, #0
        beq     .LBB0_11
        subs    r5, r4, #2
        blt     .LBB0_12
        subs    r4, r4, #1
        movs    r7, #0
.LBB0_7:
        add     r0, sp, #4
        adds    r0, r0, r7
        movs    r1, #0
        mov     r2, r1
        bl      lcd_int
        adds    r7, r0, r7
        subs    r4, r4, #1
        bne     .LBB0_7
        mov     r4, r5
        b       .LBB0_13
.LBB0_9:
        mov     r7, r6
        b       .LBB0_13
.LBB0_10:
        adds    r7, r5, r7
        b       .LBB0_13
.LBB0_11:
        mvns    r4, r0
        b       .LBB0_13
.LBB0_12:
        mov     r4, r5
        mov     r7, r0
.LBB0_13:
        add     r0, sp, #4
        adds    r5, r0, r7
        ldrb    r0, [r0, r7]
        adds    r4, r4, #1
        cmp     r0, #0
        bne     .LBB0_1
.LBB0_14:
        movs    r5, #0
        mov     r0, r5
        ldr     r1, [sp]
        mov     r2, r1
        bl      lcd_int
        mov     r0, r5
        add     sp, #116
        pop     {r4, r5, r6, r7, pc}

lcd_int:
        push    {r4, r5, r6, r7, lr}
        sub     sp, #20
        cmp     r1, #0
        ldr     r4, =lcd
.LPC1_0:
        beq     .LBB1_3
        movs    r3, #0
        mov     r1, r3
.LBB1_2:
        strb    r3, [r4, r1]
        adds    r1, r1, #1
        cmp     r1, #32
        bne     .LBB1_2
.LBB1_3:
        cmp     r0, #0
        beq     .LBB1_17
        ldrb    r1, [r0]
        cmp     r1, #0
        beq     .LBB1_18
        str     r2, [sp, #8]
        str     r4, [sp, #4]
        str     r0, [sp]
        adds    r0, r0, #1
        str     r0, [sp, #12]
        movs    r3, #0
        mov     r5, r3
        mov     r7, r3
        str     r3, [sp, #16]
.LBB1_6:
        subs    r6, r5, r7
        asrs    r2, r6, #31
        lsrs    r2, r2, #28
        adds    r0, r6, r2
        movs    r4, #15
        mov     r2, r0
        bics    r2, r4
        subs    r6, r6, r2
        cmp     r1, #10
        bne     .LBB1_8
        adds    r0, r7, r6
        adds    r7, r0, #1
        ldr     r0, [sp, #16]
        adds    r0, r0, #1
        str     r0, [sp, #16]
        b       .LBB1_15
.LBB1_8:
        cmp     r6, #0
        bne     .LBB1_12
        cmp     r1, #32
        beq     .LBB1_11
        cmp     r1, #9
        bne     .LBB1_12
.LBB1_11:
        adds    r7, r7, #1
.LBB1_12:
        asrs    r0, r0, #4
        ldr     r2, [sp, #16]
        adds    r3, r0, r2
        cmp     r3, #1
        bgt     .LBB1_16
        ldr     r0, [sp, #8]
        cmp     r0, #0
        beq     .LBB1_15
        lsls    r0, r3, #4
        ldr     r2, [sp, #4]
        adds    r0, r2, r0
        strb    r1, [r0, r6]
.LBB1_15:
        ldr     r0, [sp, #12]
        ldrb    r1, [r0, r5]
        adds    r5, r5, #1
        cmp     r1, #0
        bne     .LBB1_6
.LBB1_16:
        movs    r0, #2
        eors    r0, r3
        orrs    r6, r0
        rsbs    r1, r6, #0
        adcs    r1, r6
        ldr     r4, [sp, #4]
        ldr     r2, [sp, #8]
        ldr     r0, [sp]
        b       .LBB1_19
.LBB1_17:
        movs    r5, #0
        b       .LBB1_28
.LBB1_18:
        movs    r5, #0
        mov     r1, r5
.LBB1_19:
        cmp     r1, #0
        beq     .LBB1_28
        movs    r6, #0
.LBB1_21:
        ldrb    r1, [r0, r5]
        cmp     r1, #0
        beq     .LBB1_28
        cmp     r1, #10
        beq     .LBB1_28
        cmp     r5, #0
        bmi     .LBB1_28
        cmp     r1, #32
        beq     .LBB1_28
        cmp     r2, #0
        beq     .LBB1_27
        subs    r1, r4, r6
        movs    r3, #32
        strb    r3, [r1, #31]
        adds    r6, r6, #1
.LBB1_27:
        subs    r5, r5, #1
        b       .LBB1_21
.LBB1_28:
        cmp     r2, #0
        beq     .LBB1_32
        ldr     r0, =.L.str
.LPC1_1:
        movs    r6, #0
        mov     r1, r6
        str     r6, [sp, #16]
        bl      print_slowed
        movs    r7, #16
        mov     r0, r4
        mov     r1, r7
        bl      print_slowed
        ldr     r0, =.L.str.1
.LPC1_2:
        mov     r1, r6
        bl      print_slowed
        mov     r6, r4
        adds    r6, #16
        mov     r0, r6
        mov     r1, r7
        bl      print_slowed
        ldr     r0, =.L.str.2
.LPC1_3:
        ldr     r1, [sp, #16]
        bl      print_slowed
        mov     r0, r4
        mov     r1, r7
        bl      print_slowed
        ldrb    r0, [r4, #15]
        cmp     r0, #0
        bne     .LBB1_31
        ldr     r0, =.L.str.3
.LPC1_4:
        movs    r1, #0
        bl      print_slowed
.LBB1_31:
        movs    r1, #16
        mov     r0, r6
        bl      print_slowed
.LBB1_32:
        mov     r0, r5
        add     sp, #20
        pop     {r4, r5, r6, r7, pc}

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