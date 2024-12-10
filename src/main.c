#include <stdio.h>
#include "pico/stdlib.h"
#include "test.h"

int main(void) {
  stdio_init_all();
  printf("\014");
  //while (!stdio_usb_connected()) sleep_ms(50);
  // 0x0C or 0o014 clears the screen
  while (true) {
	novel();
  }
}
