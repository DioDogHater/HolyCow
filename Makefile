# Compiles the HolyCow standard library in ./std and the source
# files in ./programs using the ./build/hcc compiler executable

all:	programs/build/helloworld \
	programs/build/test \
	programs/build/fibonacci \
	programs/build/tictactoe \
	programs/build/snake

helloworld: programs/build/helloworld
	./$<

test: programs/build/test
	./$<

tictactoe: programs/build/tictactoe
	./$<

snake: programs/build/snake
	./$<

fibonacci: programs/build/fibonacci
	./$<

programs/build/fibonacci: programs/fibonacci.hc std/stdlib.o std/stdlib.hhc build/hcc
	./build/hcc -d $< -o $@ -lstd/stdlib.o

programs/build/helloworld: programs/helloworld.hc std/stdlib.o std/stdlib.hhc build/hcc
	./build/hcc -d $< -o $@ -lstd/stdlib.o

programs/build/test: programs/test.hc std/stdlib.o std/stdlib.hhc build/hcc
	./build/hcc -d $< -o $@ -lstd/stdlib.o

programs/build/tictactoe: programs/tictactoe.hc std/stdlib.o std/stdlib.hhc build/hcc
	./build/hcc -d $< -o $@ -lstd/stdlib.o

programs/build/snake: programs/snake.hc std/stdlib.o std/stdlib.hhc build/hcc
	./build/hcc -d $< -o $@ -lstd/stdlib.o

# For now, linux by default
std/stdlib.o: std/linux/stdlib.hc std/stdlib.hhc build/hcc build/hcc
	./build/hcc -d -s $< -o std/stdlib
