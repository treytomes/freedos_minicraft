// Source: https://www.freedos.org/books/get-started/june25-c-programming.html

#include <stdio.h>
#include <conio.h>
#include <graph.h>

int main(int argc, char *argv[]) {
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

	return 0;
}