%{
    #include"lex.yy.c"
    void yyerror(const char*);
%}

%token LC RC LB RB COLON COMMA
%token STRING NUMBER LEADINGZERO
%token TRUE FALSE VNULL
%%

Json:
      Value
    | Json COMMA error { puts("Comma after the close, recovered"); }
    | Json RB error { puts("Extra close, recovered"); }
    ;
Value:
      Object
    | Array
    | STRING
    | NUMBER
    | TRUE
    | FALSE
    | VNULL
    ;
Object:
      LC RC
    | LC Members RC
    | Object Value error { puts("Extra value after close, recovered"); }
    | LC Values RC error { puts("Comma instead of colon, recovered"); }
    | LC Member COMMA error { puts("Comma instead if closing brace, recovered"); }
    ;
Members:
      Member
    | Member COMMA Members
    | Members COMMA error { puts("Extra comma, recovered"); }
    ;
Member:
      STRING COLON Value
    | STRING COLON COLON Value error { puts("Double colon, recovered"); }
    | STRING COLON LEADINGZERO error { puts("Numbers cannot have leading zeroes, recovered"); }
    | STRING Value error { puts("Missing colon, recovered"); }
    ;
Array:
      LB RB
    | LB Values RB
    | LB Values RC error { puts("mismatch, recovered"); }
    | LB Members RB error { puts("Colon instead of comma, recovered"); }
    | LB Values error { puts("Unclosed array, recovered"); }
    ;
Values:
      Value
    | Value COMMA error { puts("extra comma, recovered"); }
    | Value COMMA COMMA error { puts("double extra comma, recovered"); }
    | Value COMMA Values
    | COMMA Values error { puts("missing value, recovered"); }
    ;
%%

void yyerror(const char *s){
    printf("syntax error: ");
}

int main(int argc, char **argv){
    if(argc != 2) {
        fprintf(stderr, "Usage: %s <file_path>\n", argv[0]);
        exit(-1);
    }
    else if(!(yyin = fopen(argv[1], "r"))) {
        perror(argv[1]);
        exit(-1);
    }
    yyparse();
    return 0;
}
