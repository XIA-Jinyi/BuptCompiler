%{
    #include "lex.yy.c"
    #include "tree.h"
    #include "errlist.h"
    int exit_code = 0;
    Tree result = NULL;
    void yyerror(const char *s);
    void log_err(char type, size_t line_no, const char *msg);
%}
%union {
    struct Head *node;
}
%token <node> ID INT FLOAT CHAR STRUCT RETURN IF ELSE WHILE PLUS MINUS MUL DIV
    AND OR LT LE GT GE NE EQ NOT ASSIGN TYPE LP RP LB RB LC RC SEMI COMMA DOT
    ILLEGAL
%type <node> Program ExtDefList ExtDef ExtDecList Specifier StructSpecifier
    VarDec FunDec VarList ParamDec CompSt StmtList Stmt DefList Def DecList Dec
    Exp Args
%right ELSE
%left ASSIGN
%left AND OR
%left LT LE GT GE NE EQ
%left PLUS MINUS
%left MUL DIV
%right NOT
%left LP RP LB RB DOT
%%

/* high-level definition */
Program: ExtDefList {
        $$ = new_node("Program", $1->line_no, NULL, $1, NULL);
        result = $$;
    }
ExtDefList: ExtDef ExtDefList {
        $1->sibling = $2;
        $$ = new_node("ExtDefList", $1->line_no, NULL, $1, NULL);
    }
    | /*empty*/ {
        $$ = new_node(NULL, 0, NULL, NULL, NULL);
    }
ExtDef: Specifier ExtDecList SEMI {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("ExtDef", $1->line_no, NULL, $1, NULL);
    }
    | Specifier SEMI {
        $1->sibling = $2;
        $$ = new_node("ExtDef", $1->line_no, NULL, $1, NULL);
    }
    | Specifier FunDec CompSt {
        $1->sibling = $2; 
        $2->sibling = $3;
        $$ = new_node("ExtDef", $1->line_no, NULL, $1, NULL);
    }
    | Specifier ExtDecList error {
        log_err(MISSING_SEMI, $2->line_no, "missing semicolon");
    }
    | Specifier error {
        log_err(MISSING_SEMI, $1->line_no, "missing semicolon");
    }
ExtDecList: VarDec COMMA ExtDecList {
        $1->sibling = $2; 
        $2->sibling = $3;
        $$ = new_node("ExtDecList", $1->line_no, NULL, $1, NULL);
    }
    | VarDec {
        $$ = new_node("ExtDecList", $1->line_no, NULL, $1, NULL);
    }

/* specifier */
Specifier: TYPE {
        $$ = new_node("Specifier", $1->line_no, NULL, $1, NULL);
    }
    | StructSpecifier {
        $$ = new_node("Specifier", $1->line_no, NULL, $1, NULL);
    }
StructSpecifier: STRUCT ID LC DefList RC {
        $1->sibling = $2; 
        $2->sibling = $3;
        $3->sibling = $4;
        $4->sibling = $5;
        $$ = new_node("StructSpecifier", $1->line_no, NULL, $1, NULL);
    }
    | STRUCT ID {
        $1->sibling = $2;
        $$ = new_node("StructSpecifier", $1->line_no, NULL, $1, NULL);
    }

/* declarator */
VarDec: ID {
        $$ = new_node("VarDec", $1->line_no, NULL, $1, NULL);
    }
    | VarDec LB INT RB {
        $1->sibling = $2;
        $2->sibling = $3;
        $3->sibling = $4;
        $$ = new_node("VarDec", $1->line_no, NULL, $1, NULL);
    }
FunDec: ID LP VarList RP {
        $1->sibling = $2;
        $2->sibling = $3;
        $3->sibling = $4;
        $$ = new_node("FunDec", $1->line_no, NULL, $1, NULL);
    }
    | ID LP RP {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("FunDec", $1->line_no, NULL, $1, NULL);
    }
    | ID LP VarList error {
        log_err(MISSING_CLOSING, $3->line_no, "missing closing symbol");
    }
    | ID LP error {
        log_err(MISSING_CLOSING, $2->line_no, "missing closing symbol");
    }
VarList: ParamDec COMMA VarList {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("VarList", $1->line_no, NULL, $1, NULL);
    }
    | ParamDec {
        $$ = new_node("VarList", $1->line_no, NULL, $1, NULL);
    }
ParamDec: Specifier VarDec {
        $1->sibling = $2;
        $$ = new_node("ParamDec", $1->line_no, NULL, $1, NULL);
    }

/* statement */
CompSt: LC DefList StmtList RC {
        $1->sibling = $2;
        $2->sibling = $3;
        $3->sibling = $4;
        $$ = new_node("CompSt", $1->line_no, NULL, $1, NULL);
    }
StmtList: Stmt StmtList {
        $1->sibling = $2;
        $$ = new_node("StmtList", $1->line_no, NULL, $1, NULL);
    }
    | /*empty*/ {
        $$ = new_node(NULL, 0, NULL, NULL, NULL);
    }
    | Stmt Def DefList StmtList error {
        log_err(DEF_AFTER_STMT, $2->line_no, "def after stmt");
    }
Stmt: Exp SEMI {
        $1->sibling = $2;
        $$ = new_node("Stmt", $1->line_no, NULL, $1, NULL);
    }
    | CompSt {
        $$ = new_node("Stmt", $1->line_no, NULL, $1, NULL);
    }
    | RETURN Exp SEMI {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Stmt", $1->line_no, NULL, $1, NULL);
    }
    | RETURN Exp error {
        log_err(MISSING_SEMI, $2->line_no, "missing semicolon");
    }
    | IF LP Exp RP Stmt %prec ELSE {
        $1->sibling = $2;
        $2->sibling = $3;
        $3->sibling = $4;
        $4->sibling = $5;
        $$ = new_node("Stmt", $1->line_no, NULL, $1, NULL);
    }
    | IF LP Exp RP Stmt ELSE Stmt {
        $1->sibling = $2;
        $2->sibling = $3;
        $3->sibling = $4;
        $4->sibling = $5;
        $5->sibling = $6;
        $6->sibling = $7;
        $$ = new_node("Stmt", $1->line_no, NULL, $1, NULL);
    }
    | WHILE LP Exp RP Stmt {
        $1->sibling = $2;
        $2->sibling = $3;
        $3->sibling = $4;
        $4->sibling = $5;
        $$ = new_node("Stmt", $1->line_no, NULL, $1, NULL);
    }
    | Exp error {
        log_err(MISSING_SEMI, $1->line_no, "missing semicolon");
    }

/* local definition */
DefList: Def DefList {
        $1->sibling = $2;
        $$ = new_node("DefList", $1->line_no, NULL, $1, NULL);
    }
    | /*empty*/ {
        $$ = new_node(NULL, 0, NULL, NULL, NULL);
    }
Def: Specifier DecList SEMI {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Def", $1->line_no, NULL, $1, NULL);
    }
    | Specifier DecList error {
        log_err(MISSING_SEMI, $2->line_no, "missing semicolon");
    }
DecList: Dec {
        $$ = new_node("DecList", $1->line_no, NULL, $1, NULL);
    }
    | Dec COMMA DecList {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("DecList", $1->line_no, NULL, $1, NULL);
    }
    | ILLEGAL error {
        log_err(LEXEME_ERROR, $1->line_no, $1->property);
    }
Dec: VarDec {
        $$ = new_node("Dec", $1->line_no, NULL, $1, NULL);
    }
    | VarDec ASSIGN Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Dec", $1->line_no, NULL, $1, NULL);
    }

/* Expression */
Exp: Exp ASSIGN Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp AND Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp OR Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp LT Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp LE Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp GT Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp GE Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp NE Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp EQ Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp PLUS Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp MINUS Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp MUL Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp DIV Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | LP Exp RP {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | MINUS Exp {
        $1->sibling = $2;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | NOT Exp {
        $1->sibling = $2;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | ID LP Args RP {
        $1->sibling = $2;
        $2->sibling = $3;
        $3->sibling = $4;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | ID LP RP {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | ID LP Args error {
        log_err(MISSING_CLOSING, $3->line_no, "missing closing symbol");
    }
    | ID LP error {
        log_err(MISSING_CLOSING, $2->line_no, "missing closing symbol");
    }
    | Exp LB Exp RB {
        $1->sibling = $2;
        $2->sibling = $3;
        $3->sibling = $4;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | Exp DOT ID {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | ID {
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | INT {
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | FLOAT {
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | CHAR {
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
    }
    | ID ILLEGAL Exp error {
        log_err(ILLEGAL_OP, $2->line_no, "illegal operator");
    }
    | ILLEGAL error {
        log_err(LEXEME_ERROR, $1->line_no, $1->property);
    }
Args: Exp COMMA Args {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Args", $1->line_no, NULL, $1, NULL);
    }
    | Exp {
        $$ = new_node("Args", $1->line_no, NULL, $1, NULL);
    }
%%

void yyerror(const char *s) { /* fprintf(stderr, "%s\n", s); */ }

void log_err(char type, size_t line_no, const char *msg) {
    fprintf(stdout, "Error type %c at Line %lu: %s\n", type, line_no, msg);
    exit_code = 1;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        exit(1);
    }
    FILE *fin = fopen(argv[1], "rb"), *fout = stdout;
    if (!fin) {
        exit(1);
    }
    size_t len = strlen(argv[1]);
    if (!strcmp(argv[1] + len - 4, ".bpl")) {
        strcpy(argv[1] + len - 3, "out");
        fout = freopen(argv[1], "wb", stdout);
    }
    if (!fout) {
        exit(1);
    }
    yyin = fin;
    yyparse();
    if (!exit_code) {
        print_tree(stdout, result, 0);
    }
    empty_tree(result);
    if (result) {
        free(result);
        result = NULL;
    }
    return exit_code;
}
