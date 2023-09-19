all: lab0 lab1 lab2 lab3 labfast
        nasm -f elf64 -g func.s
        gcc -g -static -z noexecstack -no-pie -o labasm main.c stb/stb_image_write.h stb/stb_image.h func.o -lm

clean:
        rm -rf *.o


labfast:
        gcc -Ofast -static -D c_func -o labf main.c func.c func.h stb/stb_image.h stb/stb_image_write.h -lm


lab3:
        gcc -O3 -g -static -D c_func -o labc3 main.c func.c func.h stb/stb_image.h stb/stb_image_write.h -lm



lab2:
        gcc -O2 -g -static -D c_func -o labc2 main.c func.c func.h stb/stb_image.h stb/stb_image_write.h -lm

lab1:
        gcc -O1 -g -static -D c_func -o labc1 main.c func.c func.h stb/stb_image.h stb/stb_image_write.h -lm


lab0:
        gcc -O0 -g -static -D c_func -o labc0 main.c func.c func.h stb/stb_image.h stb/stb_image_write.h -lm
