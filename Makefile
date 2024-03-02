CC=gcc
LEX=flex
YACC=bison

bin/bplc: syntax.tab.c bin tree.c
	$(CC) -o bin/bplc -lfl -ly syntax.tab.c tree.c

syntax.tab.c syntax.tab.h: syntax.y lex.yy.c tree.h errlist.h
	$(YACC) -t -d syntax.y

lex.yy.c: lex.l tree.h errlist.h
	$(LEX) lex.l

bin:
	mkdir bin

tree.out: tree.h tree.c
	$(CC) -g -o tree.out tree.c -D TREE_C_

2021212057-project1.zip: bin/bplc test report/2021212057-project1.pdf
	touch report/2021212057-project1.pdf bin
	zip -r 2021212057-project1.zip *

.PHONY: clean all bplc test

clean:
	@rm -rf bin syntax.tab.c syntax.tab.h lex.yy.c tree.out tree.o 2021212057-project1.zip test/*.out

all: bin/bplc tree.out

bplc: bin/bplc

test:
	bash ./test.sh
