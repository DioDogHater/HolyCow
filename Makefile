# Compiles the HolyCow standard library in ./std and the source
# files in ./programs using the ./build/hcc compiler executable

ifeq ($(OS),Windows_NT)
	HCC := .\build\hcc.exe
    HELLOWORLD := .\programs\build\helloworld.exe
	TEST := .\programs\build\test.exe
	TICTACTOE := .\programs\build\tictactoe.exe
	SNAKE := .\programs\build\snake.exe
	FIBONACCI := .\programs\build\fibonacci.exe
else
	HCC := ./build/hcc
    HELLOWORLD := ./programs/build/helloworld
	TEST := ./programs/build/test
	TICTACTOE := ./programs/build/tictactoe
	SNAKE := ./programs/build/snake
	FIBONACCI := ./programs/build/fibonacci
endif


all: $(HELLOWORLD) $(TEST) $(TICTACTOE) $(SNAKE) $(FIBONACCI)

helloworld: $(HELLOWORLD)
	$<

test: $(TEST)
	$<

tictactoe: $(TICTACTOE)
	$<

snake: $(SNAKE)
	$<

fibonacci: $(FIBONACCI)
	$<

$(FIBONACCI): programs/fibonacci.hc std/stdlib.o std/stdlib.hhc $(HCC)
	$(HCC) -d $< -o $@ -lstd/stdlib.o

$(HELLOWORLD): programs/helloworld.hc std/stdlib.o std/stdlib.hhc $(HCC)
	$(HCC) -d $< -o $@ -lstd/stdlib.o

$(TEST): programs/test.hc std/stdlib.o std/stdlib.hhc $(HCC)
	$(HCC) -d $< -o $@ -lstd/stdlib.o

$(TICTACTOE): programs/tictactoe.hc std/stdlib.o std/stdlib.hhc $(HCC)
	$(HCC) -d $< -o $@ -lstd/stdlib.o

$(SNAKE): programs/snake.hc std/stdlib.o std/stdlib.hhc $(HCC)
	$(HCC) -d $< -o $@ -lstd/stdlib.o

# For now, linux by default
std/stdlib.o: std/linux/stdlib.hc std/stdlib.hhc $(HCC)
	$(HCC) -d -s $< -o std/stdlib
