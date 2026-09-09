CC := gcc
CFLAGS := -std=c23 -Wall -Wextra -Werror -O3
LDFLAGS :=

SOURCES = $(wildcard *.c)
OBJECTS = $(SOURCES:%.c=obj/%.o)
TARGET = bloombuild

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

obj/%.o: %.c | obj
	$(CC) $(CFLAGS) -c -o $@ $<

obj:
	mkdir -p $@

clean:
	rm -rf obj $(TARGET)

rebuild: clean all

run: $(TARGET)
	./$(TARGET)

.PHONY: all clean rebuild run
