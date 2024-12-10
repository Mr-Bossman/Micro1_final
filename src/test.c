//-gdwarf-4 -g -o output.s -fno-verbose-asm -S -target arm-linux-gnueabi --gcc-toolchain=/opt/compiler-explorer/arm/gcc-12.2.0/arm-unknown-linux-gnueabi --sysroot=/opt/compiler-explorer/arm/gcc-12.2.0/arm-unknown-linux-gnueabi/arm-unknown-linux-gnueabi/sysroot -fcolor-diagnostics -fno-crash-diagnostics -Os -nostdlib -mcpu=cortex-m0 -mthumb -mfloat-abi=soft -ffreestanding example.c
//-g -o output.s -fno-verbose-asm -S -Os -nostdlib -mcpu=cortex-m0 -mthumb -mfloat-abi=soft -ffreestanding example.c
#include <stdbool.h>
#ifndef NULL
#define NULL ((void*)0)
#endif

#if 0

#define size_t unsigned int
void print_slowed(const char *str, size_t len);
int get_button(int c);

#else
#include <stdio.h>
#include "pico/stdlib.h"

void print_slowed(const char *str, size_t len) {
	if (len == 0)
		len = -1;
	while (*str && len--) {
		putchar(*str);
		fflush(stdout);
		sleep_ms(1);
		str++;
	}
}

int get_button(int c) {
	while (true) {
		int ch = getchar();
		if (ch <= 0)
			continue;
		//while (ch != '\n' && getchar() != '\n');
		if (c == 0)
			return ch;
		if (c == ch)
			return 1;
	}
}
#endif

static inline void* memset(void * dest, int val, size_t len) {
	register unsigned char *ptr = (unsigned char*)dest;
	while (len-- > 0)
		*ptr++ = val;
	return dest;
}

static inline void* memcpy(void *dest, const void *src, size_t len) {
	char *d = dest;
	const char *s = src;
	while (len--)
		*d++ = *s++;
	return dest;
}

static int lcd_int(int col, int line, const char *str, bool clear, bool display);

//emulate the lcd screen
static inline int print_lcd(int col, int line, const char *str, bool clear) {
	return lcd_int(col, line, str, clear, true);
}

static inline int clear_lcd(void) {
	return lcd_int(0, 0, NULL, true, true);
}

static inline int calculate_lcd(int col, int line, const char *str) {
	return lcd_int(col, line, str, false, false);
}

//emulate the lcd screen
static int lcd_int(int col, int line, const char *str, bool clear, bool display) {
	static char lcd[2][16] = {0};
	int i = 0, skip = 0, c = 0, l = 0;

	if (clear)
		memset(lcd, 0, sizeof(lcd));

	// sanity check position
	if (line == -1) {
		line = col / 16;
		col = col % 16;
	}
	if (col < 0 || col > 15 || line < 0 || line > 1)
		return -1;

	for (;str && str[i]; i++) {
		// implement new line
		c = (i + col - skip) % 16;
		if (str[i] == '\n') {
			line++;
			skip += c + 1;
			continue;
		}
		l = ((i + col - skip) / 16) + line;

		// skip leading whitespace on new lines
		if(c == 0 && (str[i] == ' ' || str[i] == '\t' || str[i] == '\n'))
			skip++;

		// stop if we reach the end of the screen
		if (l > 1)
			break;
		if (display)
			lcd[l][c] = str[i];
	}

	// don't word wrap across pages
	if(c == 0 && l == 2) {
		while(str[i] != 0 && str[i] != '\n' && str[i] != ' ' && i >= 0) {
			if (display) {
				lcd[1][15-c] = ' ';
				c++;
			}
			i--;
		}
	}
	if (display) {
		// 0x0C or 0o014 clears the screen
		print_slowed("\033[H\033[2J\033[3J", 0);
		print_slowed(lcd[0], 16);
		print_slowed("\r\n", 0);
		print_slowed(lcd[1], 16);
		print_slowed("\r\n\n\n\r\014", 0);
		print_slowed(lcd[0], 16);
		if(!lcd[0][15])
			print_slowed("\n", 0);
		print_slowed(lcd[1], 16);
	}
	return i;
}

static int print_text(const char *text) {
	size_t offset = 0;
	for (int i = 0; text[offset]; i++) {
		int ret = print_lcd(0, 0, text + offset, true);
		if (ret < 0)
			return ret;
		//printf("On page %d\nPress 's' to skip, 'b' to go back, or any other key to continue\n", i);
		int ch = get_button(0);
		if (ch == 's') {
			offset = 0;
		} else if (ch == 'b') {
			if (i-- == 0)
				continue;
			offset = 0;
			for (int b = 0; b < i; b++)
				offset += calculate_lcd(0, 0, text + offset);
			i--;
		} else {
			offset += ret;
		}

	}
	return 0;
}


__attribute__((unused))
static
int novel(void) {
	char text[] = "This is a really long string that should be printed on the lcd screen.\n I wonder if new lines work?\n Did they?";

	print_text(text);

	clear_lcd();

	return 0;
}
