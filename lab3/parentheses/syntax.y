%{
    #include"lex.yy.c"
    void yyerror(const char *s);
    int result;
%}
%token LP RP LB RB LC RC
%%
String: String String
    | LP String RP
    | LB String RB
    | LC String RC
    | %empty
    ;
%%

void yyerror(const char *s){
    result = 0;
}

int validParentheses(char *expr){
    result = 1;
    yy_scan_string(expr);
    yyparse();
    return result;
}
