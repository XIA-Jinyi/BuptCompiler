%{
    #include"lex.yy.c"
    void yyerror(const char*);
    int result;
%}
%token INT
%token ADD SUB MUL DIV EQ
%%
Quiz: Exp EQ { result = $1; }
    ;
Exp: Factor
    | Factor ADD Exp { $$ = $1 + $3; }
    | Factor SUB Exp { $$ = $1 - $3; }
    ;
Factor: INT
    | INT MUL Factor { $$ = $1 * $3; }
    | INT DIV Factor { $$ = $1 / $3; }
    ;
%%

void yyerror(const char *s){
    fprintf(stderr, "Syntax error: %s\n", s);
}

#ifndef CALC_MAIN
int evaluate(char *expr){
    YY_BUFFER_STATE buf;
    buf = yy_scan_string(expr);
    yyparse();
    yy_delete_buffer(buf);
    return result;
}
#else
int main(){
    yyparse();
    printf(" = %d\n", result);
}
#endif
