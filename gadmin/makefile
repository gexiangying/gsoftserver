CC = $(BIN)gcc 
PRJ =	gadmin
INCPATH = -I/usr/local/include
LIBPATH = -L/usr/local/lib
LIBS = -llua53 -ltrace
LDFLAGS = -mwindows
SRCS :=$(wildcard *.c)
HPPS :=$(wildcard *.h)
OBJS :=$(patsubst %.c,%.o,$(SRCS))
RRCS_OBJS :=$(PRJ).res
WINDRES = $(BIN)windres
all:$(PRJ).exe 
$(PRJ).exe:$(OBJS) $(RRCS_OBJS)
	$(CC) -o $@ $(OBJS) $(RRCS_OBJS) $(LIBPATH) $(LIBS) $(LDFLAGS)
%.o:%.c	
	$(CC) $(CFLAGS) $(C_PROC) $(INCPATH) -c $< 
$(PRJ).res:$(PRJ).rc
	$(WINDRES) -O COFF -i "$(PRJ).rc" -o "$@"
install:
	cp $(PRJ).exe bin/
clean:
	-@rm *.o *.exe
