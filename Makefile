# Compiles the HolyCow standard library in ./std and the source
# files in ./programs using the ./build/hcc compiler executable

ifeq ($(OS),Windows_NT)
	HCC := .\build\hcc.exe
	# For now, STDLIB will be the linux standard library even in Windows
	STDLIB := std/linux/linux.cow std/linux/stdlib.cow
	HELLOWORLD := .\programs\build\helloworld.exe
	TEST := .\programs\build\test.exe
	TICTACTOE := .\programs\build\tictactoe.exe
	SNAKE := .\programs\build\snake.exe
	BREAKOUT := .\programs\build\breakout.exe
	FIBONACCI := .\programs\build\fibonacci.exe
	RAYLIB := .\programs\build\raylib.exe
	LIBRAYLIB := libraylibdll.a
else
	HCC := ./build/hcc
	STDLIB := std/linux/linux.cow std/linux/stdlib.cow
	HELLOWORLD := ./programs/build/helloworld
	TEST := ./programs/build/test
	TICTACTOE := ./programs/build/tictactoe
	SNAKE := ./programs/build/snake
	BREAKOUT := ./programs/build/breakout
	FIBONACCI := ./programs/build/fibonacci
	RAYLIB := ./programs/build/raylib
	LIBRAYLIB := libraylib.a
endif

HCC_FLAGS := -d --silent


all: $(HELLOWORLD) $(TEST) $(TICTACTOE) $(SNAKE) $(FIBONACCI) $(RAYLIB) $(BREAKOUT)

helloworld: $(HELLOWORLD)
	$<

test: $(TEST)
	$<

tictactoe: $(TICTACTOE)
	$<

snake: $(SNAKE)
	$<

breakout: $(BREAKOUT)
	$<

fibonacci: $(FIBONACCI)
	$<

raylib: $(RAYLIB)
	$<

$(RAYLIB): programs/raylib/main.cow $(HCC)
	$(HCC) -c $(HCC_FLAGS) $< -o $@
	cc -no-pie -nostdlib $@.o -o $@ -Lprograms/raylib -l:$(LIBRAYLIB) -lc -lm

$(FIBONACCI): programs/fibonacci.cow std/stdlib.o std/stdlib.hcw $(HCC)
	$(HCC) $(HCC_FLAGS) $< -o $@ -lstd/stdlib.o

$(HELLOWORLD): programs/helloworld.cow std/stdlib.o std/stdlib.hcw $(HCC)
	$(HCC) $(HCC_FLAGS) $< -o $@ -lstd/stdlib.o

$(TEST): programs/test.cow std/stdlib.o std/stdlib.hcw $(HCC)
	$(HCC) $(HCC_FLAGS) $< -o $@ -lstd/stdlib.o

$(TICTACTOE): programs/tictactoe.cow std/stdlib.o std/stdlib.hcw $(HCC)
	$(HCC) $(HCC_FLAGS) $< -o $@ -lstd/stdlib.o

$(SNAKE): programs/snake.cow std/stdlib.o std/stdlib.hcw $(HCC)
	$(HCC) $(HCC_FLAGS) $< -o $@ -lstd/stdlib.o

$(BREAKOUT): programs/breakout.cow std/stdlib.o std/stdlib.hcw $(HCC)
	$(HCC) $(HCC_FLAGS) $< -o $@ -lstd/stdlib.o

# For now, linux by default
std/stdlib.o: $(STDLIB) std/stdlib.hcw $(HCC)
	$(HCC) -s $(HCC_FLAGS) $(STDLIB) -o std/stdlib
