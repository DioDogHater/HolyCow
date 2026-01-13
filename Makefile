# Compiles the HolyCow standard library in ./std and the source
# files in ./programs using the ./build/hcc compiler executable

all: helloworld test fibonacci

helloworld: programs/build/helloworld
	./programs/build/helloworld

test: programs/build/test
	./programs/build/test

fibonacci: programs/build/fibonacci
	./programs/build/fibonacci

programs/build/fibonacci: programs/fibonacci.hc std/stdlib.o std/stdlib.hhc build/hcc
	./build/hcc -d $< -o $@ -lstd/stdlib.o

programs/build/helloworld: programs/helloworld.hc std/stdlib.o std/stdlib.hhc build/hcc
	./build/hcc -d $< -o $@ -lstd/stdlib.o

programs/build/test: programs/test.hc std/stdlib.o std/stdlib.hhc build/hcc
	./build/hcc -d $< -o $@ -lstd/stdlib.o

std/stdlib.o: std/stdlib.hc build/hcc build/hcc
	./build/hcc -d -s $< -o std/stdlib
