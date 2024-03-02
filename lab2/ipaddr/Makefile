CC=gcc
FLEX=flex
ipaddr:
	$(FLEX) lex.l
	$(CC) lex.yy.c --shared -fPIC -o libip.so
clean:
	@rm -f lex.yy.c *.out *.so
.PHONY: ipaddr
