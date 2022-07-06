// Source: https://www.freedos.org/books/get-started/june25-c-programming.html

#include <stdio.h>
#include <conio.h>
#include <graph.h>
#include <system.h>

void hello() {
	short color;
	short row=1, col=1;

	_setvideomode(_TEXTC80);

	for (color = 0; color <= 15; color++) {
		_settextposition(row++, col++);
		_settextcolor(color);
		_setbkcolor(color ? 0 : 7);
		_outtext("Hello, world!");
	}

	getch();
	_setvideomode(_DEFAULTMODE);
}

// This will keep track of how many ticks that the system has been running for.
int timer_ticks = 0;

/**
 * Increment the 'timer_ticks' variable every time the
 * timer fires. By default, the timer fires 18.222 times
 * per second.
 */
void timer_handler(struct regs *r)
{
    /* Increment our 'tick count' */
    timer_ticks++;

    /* Every 18 clocks (approximately 1 second), we will
    *  display a message on the screen */
    if (timer_ticks % 18 == 0)
    {
        puts("One second has passed\n");
    }
}

int main(int argc, char *argv[]) {
	// Installe the handler to IRQ0.
	irq_install_handler(0, timer_handler);
	while (1) { }
	return 0;
}