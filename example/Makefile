LDFLAGS+=	-lc

hello: hello.o
	$(LD) -o hello hello.o $(LDFLAGS)

hello.o: hello.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c hello.c
