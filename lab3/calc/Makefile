CC=gcc
FLEX=flex
BISON=bison


.lex: lex.l
	$(FLEX) lex.l
.syntax: syntax.y
	$(BISON) -t -d syntax.y
calc: .lex .syntax
	$(CC) syntax.tab.c -lfl -ly -D CALC_MAIN -o calc.out
libcalc: .lex .syntax
	$(CC) syntax.tab.c -lfl -ly -fPIC --shared -o libcalc.so
clean:
	@rm -f lex.yy.c syntax.tab.* *.out *.so
