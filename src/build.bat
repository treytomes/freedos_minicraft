echo on

@echo This is how we build the project!

d:
cd \

@rem WCL is Watcom Link.  There is also WCC and WLINK.  Is there a WMAKE?
@rem wcl main.c
@rem main

@rem nasm timer.asm -o timer.exe
@rem nasm print.asm -o print.exe
nasm sound.asm -o sound.exe
sound

