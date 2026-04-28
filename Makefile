# Compiles the HolyCow standard library in ./std and the source
# files in ./programs using the ./build/hcc compiler executable

ifeq ($(OS),Windows_NT)
	HCC := .\build\hcc.exe
	# For now, STDLIB will be the linux standard library even in Windows
	STDLIB := std/linux/stdlib.cow std/linux/linux.cow std/linux/memalloc.cow
	LIBRAYLIB := libraylib_win64.a
	EXT := .exe
else
	HCC := ./build/hcc
	STDLIB := std/linux/stdlib.cow std/linux/linux.cow std/linux/memalloc.cow
	LIBRAYLIB := libraylib_linux_x64.a
	EXT :=
endif

HCC_FLAGS := -d --silent

# Add your own projects here to compile
stdlib_projects = helloworld test tictactoe breakout snake json_example
raylib_projects = test3d physics

build := programs/build
src := programs
stdlib_execs = $(addsuffix $(EXT), $(addprefix $(build)/, $(stdlib_projects)))
raylib_execs = $(addsuffix $(EXT), $(addprefix $(build)/, $(raylib_projects)))
all_projects = $(stdlib_projects) $(raylib_projects)

.PHONY: all $(all_projects)

all: $(stdlib_execs) $(raylib_execs)

$(all_projects): %: $(build)/%$(EXT)
	$<

$(raylib_execs): $(build)/%$(EXT): $(src)/%.cow $(HCC)
	$(HCC) -c $(HCC_FLAGS) $< -o $@
	$(CC) -no-pie -nostdlib $@.o -o $@ -Lprograms/raylib -l:$(LIBRAYLIB) -lc -lm

$(stdlib_execs): $(build)/%$(EXT): $(src)/%.cow std/stdlib.o std/stdlib.hcw $(HCC)
	$(HCC) $(HCC_FLAGS) $< -o $@ -lstd/stdlib.o

# For now, linux by default
std/stdlib.o: $(STDLIB) std/stdlib.hcw $(HCC)
	$(HCC) -s $(HCC_FLAGS) $< -o std/stdlib
