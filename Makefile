CC=gcc
LEX=flex
YACC=bison
CC_FLAG=-O0
CXX_FLAG=$(CC_FLAG) -std=c++11

bin/bplc: bin parser.o tree.o symbol.o main.cpp
	$(CXX) $(CXX_FLAG) -o bin/bplc main.cpp parser.o tree.o symbol.o -lfl -ly

bin:
	mkdir bin

tree.o: tree.c
	$(CC) $(CC_FLAG) -c tree.c -o tree.o

tree.out: tree.c
	$(CC) $(CC_FLAG) -g -o tree.out tree.c -D MAIN_

symbol.o: symbol.cpp
	$(CXX) $(CXX_FLAG) -c symbol.cpp -o symbol.o

symbol.out: symbol.cpp
	$(CXX) $(CXX_FLAG) -g -o symbol.out symbol.cpp -D MAIN_

parser.o: syntax.tab.c
	$(CC) $(CC_FLAG) -c syntax.tab.c -o parser.o

parser.out: syntax.tab.c
	$(CC) $(CC_FLAG) -g -o parser.out syntax.tab.c -D MAIN_

syntax.tab.c: syntax.y lex.yy.c
	$(YACC) -t -d syntax.y

lex.yy.c: lex.l
	$(LEX) lex.l

2021212057-project2.zip: bin/bplc test report/2021212057-project2.pdf
	zip -r 2021212057-project2.zip *

.PHONY: clean all bplc test

clean:
	@rm -rf bin syntax.tab.c syntax.tab.h lex.yy.c *.out *.o 2021212057-project2.zip test/*.out

all: 2021212057-project2.zip

bplc: bin/bplc

test:
	-sh ./test.sh
