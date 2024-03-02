%{
    #include "parser.h"
    #include "lex.yy.c"
    #include "tree.h"
    #include "errlist.h"
    #include "symbol.h"
    #include <assert.h>
    char errinfo[BUFLEN];
    int exit_code = 0;
    struct table_t arg_tab = {.handle=NULL};
    Tree result = NULL;
    void yyerror(const char *s);
    void log_err(char type, size_t line_no, const char *msg);
    FILE *err_stream = NULL;
    struct type_t ret_spec = {.handle=NULL};

    #define LOG_ERR(ERR_TYPE, LINE_NO, MSG) \
    do { \
        fprintf(err_stream, "Error type %d at Line %lu: %s\n", ERR_TYPE, LINE_NO, MSG); \
        exit_code = 1;\
    } while(0);

    #define CHECK_NUMERIC(NODE) \
    ((type_cat(NODE->info) == V_PRIM || type_cat(NODE->info) == E_RVAL) && (type_atom(NODE->info) == INT_T || type_atom(NODE->info) == FLOAT_T || type_atom(NODE->info) == NOT_T))

    #define CHECK_INT(NODE) \
    (type_atom(NODE->info) == INT_T && (type_cat(NODE->info) == V_PRIM || type_cat(NODE->info) == E_RVAL))

    #define TYPE_EQUAL(NODE1, NODE2) \
    (type_atom(NODE1->info) == type_atom(NODE2->info))

    #define EXP_ARITH(EXP1, EXP2, PARENT) \
    do { \
        enum Primitive ans = (int) type_atom(EXP1->info) ? type_atom(EXP1->info) : type_atom(EXP2->info); \
        if (!TYPE_EQUAL(EXP1, EXP2) && (int)type_atom(EXP1->info) && (int)type_atom(EXP2->info)) { \
            LOG_ERR(UNMATCH_OP, PARENT->line_no, "unmatched operands"); \
            PARENT->info = type_new_rval("", NOT_T); \
        } \
        else if (!CHECK_NUMERIC(EXP1) || !CHECK_NUMERIC(EXP2)) { \
            LOG_ERR(UNMATCH_OP, PARENT->line_no, "non-numeric value"); \
            PARENT->info = type_new_rval("", NOT_T); \
        } \
        else { \
            PARENT->info = type_new_rval("", ans); \
        } \
    } while(0);
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
    ;
ExtDefList: ExtDef ExtDefList {
        $1->sibling = $2;
        $$ = new_node("ExtDefList", $1->line_no, NULL, $1, NULL);
    }
    | /*empty*/ {
        $$ = new_node(NULL, 0, NULL, NULL, NULL);
    }
    ;
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
        // TODO: remove debug info
        // tab_traverse(ctx(), iter)
        // {
        //     printf("%s: CAT(%d), ATOM(%d);\n", type_name(iter), type_cat(iter), type_atom(iter));
        //     if (type_cat(iter) & FLAG_TAB)
        //     {
        //         tab_traverse(type_tab(iter), sub_iter)
        //         {
        //             printf("  %s: CAT(%d), ATOM(%d);\n", type_name(sub_iter), type_cat(sub_iter), type_atom(sub_iter));
        //         }
        //     }
        // }
        // puts("--------------------");
        ctx_bwd();
        spec_pop();
    }
    | Specifier ExtDecList error {
        log_err(MISSING_SEMI, $2->line_no, "missing semicolon");
    }
    | Specifier error {
        log_err(MISSING_SEMI, $1->line_no, "missing semicolon");
    }
    ;
ExtDecList: VarDec COMMA ExtDecList {
        $1->sibling = $2; 
        $2->sibling = $3;
        $$ = new_node("ExtDecList", $1->line_no, NULL, $1, NULL);
    }
    | VarDec {
        $$ = new_node("ExtDecList", $1->line_no, NULL, $1, NULL);
    }
    ;

/* specifier */
Specifier: TYPE {
        $$ = new_node("Specifier", $1->line_no, NULL, $1, NULL);
        struct type_t t = type_new_prim("", NOT_T);
        if (strcmp($1->property, "int") == 0) {
            type_set_atom(t, INT_T);
        }
        else if (strcmp($1->property, "float") == 0) {
            type_set_atom(t, FLOAT_T);
        }
        else if (strcmp($1->property, "char") == 0) {
            type_set_atom(t, CHAR_T);
        }
        spec_push(t);
    }
    | StructSpecifier {
        $$ = new_node("Specifier", $1->line_no, NULL, $1, NULL);
    }
    ;
StructSpecifier: STRUCT ID LC DefList RC {
        $1->sibling = $2; 
        $2->sibling = $3;
        $3->sibling = $4;
        $4->sibling = $5;
        $$ = new_node("StructSpecifier", $1->line_no, NULL, $1, NULL);
        struct type_t t = type_new($2->property, D_STRUCT);
        type_set_tab(t, ctx_pass());
        ctx_bwd();
        if (!tab_add(ctx(), t)) {
            LOG_ERR(REDEF_STRUCT, $2->line_no, type_name(t));
        }
    }
    | STRUCT ID {
        $1->sibling = $2;
        $$ = new_node("StructSpecifier", $1->line_no, NULL, $1, NULL);
        struct type_t t = tab_get(ctx(), $2->property);
        spec_push(t);
    }
    ;

/* declarator */
VarDec: ID {
        $$ = new_node("VarDec", $1->line_no, NULL, $1, NULL);
        // assert(temp_spec.handle);
        struct type_t top = spec_top(), ans;
        if (type_cat(top) == D_STRUCT) {
            ans = type_new_cmplx($1->property, top);
        }
        else {
            ans = type_clone(top);
            type_set_name(ans, $1->property);
        }
        if (!tab_add(merge_def ? ctx() : ctx_pass(), ans)) {
            LOG_ERR(REDEF_VAR, $1->line_no, type_name(ans));
        }
    }
    | VarDec LB INT RB {
        $1->sibling = $2;
        $2->sibling = $3;
        $3->sibling = $4;
        $$ = new_node("VarDec", $1->line_no, NULL, $1, NULL);
        type_set_cat(tab_get(merge_def ? ctx() : ctx_pass(), $1->child->property), V_ARRAY);
        type_set_sub(tab_get(merge_def ? ctx() : ctx_pass(), $1->child->property), spec_top());
    }
    ;
FunDec: ID LP VarList RP {
        $1->sibling = $2;
        $2->sibling = $3;
        $3->sibling = $4;
        $$ = new_node("FunDec", $1->line_no, NULL, $1, NULL);
        struct type_t t = type_new($1->property, D_FUNC);
        type_set_atom(t, type_atom(spec_top()));
        ret_spec = spec_top();
        type_set_tab(t, ctx_pass());
        if (!tab_add(ctx(), t)) {
            LOG_ERR(REDEF_FUNC, $1->line_no, type_name(t));
        }
        merge_def = 1;
    }
    | ID LP RP {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("FunDec", $1->line_no, NULL, $1, NULL);
        struct type_t t = type_new($1->property, D_FUNC);
        type_set_atom(t, type_atom(spec_top()));
        ret_spec = spec_top();
        type_set_tab(t, ctx_pass());
        if (!tab_add(ctx(), t)) {
            LOG_ERR(REDEF_FUNC, $1->line_no, type_name(t));
        }
        merge_def = 1;
    }
    | ID LP VarList error {
        log_err(MISSING_CLOSING, $3->line_no, "missing closing symbol");
    }
    | ID LP error {
        log_err(MISSING_CLOSING, $2->line_no, "missing closing symbol");
    }
    ;
VarList: ParamDec COMMA VarList {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("VarList", $1->line_no, NULL, $1, NULL);
    }
    | ParamDec {
        $$ = new_node("VarList", $1->line_no, NULL, $1, NULL);
    }
    ;
ParamDec: Specifier VarDec {
        $1->sibling = $2;
        $$ = new_node("ParamDec", $1->line_no, NULL, $1, NULL);
        spec_pop();
    }
    ;

/* statement */
CompSt: LC DefList StmtList RC {
        $1->sibling = $2;
        $2->sibling = $3;
        $3->sibling = $4;
        $$ = new_node("CompSt", $1->line_no, NULL, $1, NULL);
    }
    ;
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
    ;
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
        if (type_atom($2->info) != type_atom(ret_spec) && type_atom($2->info) != NOT_T) {
            LOG_ERR(UNMATCH_RET, $1->line_no, "unmatched return type");
            // fprintf(err_stream, "%d %d\n", type_atom($2->info), type_atom(ret_spec));
        }
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
    ;

/* local definition */
DefList: Def DefList {
        $1->sibling = $2;
        $$ = new_node("DefList", $1->line_no, NULL, $1, NULL);
    }
    | /*empty*/ {
        $$ = new_node(NULL, 0, NULL, NULL, NULL);
    }
    ;
Def: Specifier DecList SEMI {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Def", $1->line_no, NULL, $1, NULL);
        spec_pop();
    }
    | Specifier DecList error {
        log_err(MISSING_SEMI, $2->line_no, "missing semicolon");
    }
    ;
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
    ;
Dec: VarDec {
        $$ = new_node("Dec", $1->line_no, NULL, $1, NULL);
    }
    | VarDec ASSIGN Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Dec", $1->line_no, NULL, $1, NULL);
        // if (type_atom($3->info) != type_atom(spec_top())) {
        //     LOG_ERR(UNMATCH_TYPE, $2->line_no, "unmatched type");
        // }
    }
    ;

/* Expression */
Exp: Exp ASSIGN Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (type_cat($1->info) == E_RVAL) {
            LOG_ERR(ASSIGN_RVAL, $2->line_no, "rvalue on the left side of assignment");
            $$->info = type_clone($1->info);
        }
        else if (!TYPE_EQUAL($1, $3)) {
            LOG_ERR(UNMATCH_TYPE, $2->line_no, "unmatched type");
            $$->info = type_clone($1->info);
        }
        else {
            $$->info = type_clone($1->info);
        }
    }
    | Exp AND Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (!TYPE_EQUAL($1, $3)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "unmatched operands");
            $$->info = type_new_rval("", INT_T);
        }
        else if (!CHECK_INT($1)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "non-numeric value");
            $$->info = type_new_rval("", INT_T);
        }
        else {
            $$->info = type_clone($1->info);
            type_set_cat($$->info, E_RVAL);
        }
    }
    | Exp OR Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (!TYPE_EQUAL($1, $3)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "unmatched operands");
            $$->info = type_new_rval("", INT_T);
        }
        else if (!CHECK_INT($1)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "non-numeric value");
            $$->info = type_new_rval("", INT_T);
        }
        else {
            $$->info = type_clone($1->info);
            type_set_cat($$->info, E_RVAL);
        }
    }
    | Exp LT Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (!TYPE_EQUAL($1, $3)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "unmatched operands");
            $$->info = type_new_rval("", INT_T);
        }
        else if (!CHECK_NUMERIC($1)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "non-numeric value");
            $$->info = type_new_rval("", INT_T);
        }
        else {
            $$->info = type_clone($1->info);
            type_set_cat($$->info, E_RVAL);
        }
    }
    | Exp LE Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (!TYPE_EQUAL($1, $3)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "unmatched operands");
            $$->info = type_new_rval("", INT_T);
        }
        else if (!CHECK_NUMERIC($1)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "non-numeric value");
            $$->info = type_new_rval("", INT_T);
        }
        else {
            $$->info = type_clone($1->info);
            type_set_cat($$->info, E_RVAL);
        }
    }
    | Exp GT Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (!TYPE_EQUAL($1, $3)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "unmatched operands");
            $$->info = type_new_rval("", INT_T);
        }
        else if (!CHECK_NUMERIC($1)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "non-numeric value");
            $$->info = type_new_rval("", INT_T);
        }
        else {
            $$->info = type_clone($1->info);
            type_set_cat($$->info, E_RVAL);
        }
    }
    | Exp GE Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (!TYPE_EQUAL($1, $3)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "unmatched operands");
            $$->info = type_new_rval("", INT_T);
        }
        else if (!CHECK_NUMERIC($1)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "non-numeric value");
            $$->info = type_new_rval("", INT_T);
        }
        else {
            $$->info = type_clone($1->info);
            type_set_cat($$->info, E_RVAL);
        }
    }
    | Exp NE Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (!TYPE_EQUAL($1, $3)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "unmatched operands");
            $$->info = type_new_rval("", INT_T);
        }
        else if (!CHECK_NUMERIC($1)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "non-numeric value");
            $$->info = type_new_rval("", INT_T);
        }
        else {
            $$->info = type_clone($1->info);
            type_set_cat($$->info, E_RVAL);
        }
    }
    | Exp EQ Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (!TYPE_EQUAL($1, $3)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "unmatched operands");
            $$->info = type_new_rval("", INT_T);
        }
        else if (!CHECK_NUMERIC($1)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "non-numeric value");
            $$->info = type_new_rval("", INT_T);
        }
        else {
            $$->info = type_clone($1->info);
            type_set_cat($$->info, E_RVAL);
        }
    }
    | Exp PLUS Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        EXP_ARITH($1, $3, $$);
        // if (!TYPE_EQUAL($1, $3)) {
        //     LOG_ERR(UNMATCH_OP, $2->line_no, "unmatched operands");
        //     $$->info = type_new_rval("", NOT_T);
        // }
        // else if (!CHECK_NUMERIC($1)) {
        //     LOG_ERR(UNMATCH_OP, $2->line_no, "non-numeric value");
        //     $$->info = type_new_rval("", NOT_T);
        // }
        // else {
        //     $$->info = type_clone($1->info);
        //     type_set_cat($$->info, E_RVAL);
// }
    }
    | Exp MINUS Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (!TYPE_EQUAL($1, $3)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "unmatched operands");
            $$->info = type_new_rval("", NOT_T);
        }
        else if (!CHECK_NUMERIC($1)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "non-numeric value");
            $$->info = type_new_rval("", NOT_T);
        }
        else {
            $$->info = type_clone($1->info);
            type_set_cat($$->info, E_RVAL);
        }
    }
    | Exp MUL Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (!TYPE_EQUAL($1, $3)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "unmatched operands");
            $$->info = type_new_rval("", NOT_T);
        }
        else if (!CHECK_NUMERIC($1)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "non-numeric value");
            $$->info = type_new_rval("", NOT_T);
        }
        else {
            $$->info = type_clone($1->info);
            type_set_cat($$->info, E_RVAL);
}
    }
    | Exp DIV Exp {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (!TYPE_EQUAL($1, $3)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "unmatched operands");
            $$->info = type_new_rval("", NOT_T);
        }
        else if (!CHECK_NUMERIC($1)) {
            LOG_ERR(UNMATCH_OP, $2->line_no, "non-numeric value");
            $$->info = type_new_rval("", NOT_T);
        }
        else {
            $$->info = type_clone($1->info);
            type_set_cat($$->info, E_RVAL);
}
    }
    | LP Exp RP {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        $$->info = type_clone($2->info);
        type_set_cat($$->info, E_RVAL);
    }
    | MINUS Exp {
        $1->sibling = $2;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (!CHECK_NUMERIC($2)) {
            LOG_ERR(UNMATCH_OP, $1->line_no, "non-numeric value");
            $$->info = type_new_rval("", NOT_T);
        }
        $$->info = type_new_rval("", type_atom($2->info));
    }
    | NOT Exp {
        $1->sibling = $2;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (type_cat($2->info) != V_PRIM || type_atom($2->info) != INT_T) {
            LOG_ERR(UNMATCH_OP, $1->line_no, "non-int value of logical operator");
        }
        $$->info = type_new_rval("", INT_T);
    }
    | ID LP Args RP {
        $1->sibling = $2;
        $2->sibling = $3;
        $3->sibling = $4;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (tab_get(ctx(), $1->property).handle == NULL) {
            LOG_ERR(UNDEF_FUNC, $1->line_no, $1->property);
            $$->info = type_new_rval("", NOT_T);
        }else if (type_cat(tab_get(ctx(), $1->property)) != D_FUNC) {
            LOG_ERR(NON_FUNC, $1->line_no, $1->property);
            $$->info = type_new_rval("", NOT_T);
        }
        else {
            int flag = 1;
            struct table_t tab1 = type_tab(tab_get(ctx(), $1->property));
            struct table_t tab2 = arg_tab;
            for (struct type_t t1 = tab_next(tab1), t2 = tab_next(tab2); t1.handle && t2.handle; t1 = tab_next(tab1), t2 = tab_next(tab2)) {
                if (type_atom(t1) != type_atom(t2)) {
                    flag = 0;
                    break;
                }
            }
            if (!flag) {
                LOG_ERR(UNMATCH_ARG, $1->line_no, "unmatched arguments");
            }
            $$->info = type_new_rval("", type_atom(tab_get(ctx(), $1->property)));
        }
        arg_tab = tab_new();
    }
    | ID LP RP {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (tab_get(ctx(), $1->property).handle == NULL) {
            LOG_ERR(UNDEF_FUNC, $1->line_no, $1->property);
            $$->info = type_new_rval("", NOT_T);
        }else if (type_cat(tab_get(ctx(), $1->property)) != D_FUNC) {
            LOG_ERR(NON_FUNC, $1->line_no, $1->property);
            $$->info = type_new_rval("", NOT_T);
        }
        else if (tab_size(type_tab(tab_get(ctx(), $1->property))) != 0) {
            LOG_ERR(UNMATCH_ARG, $1->line_no, "missing arguments");
            $$->info = type_new_rval("", type_atom(tab_get(ctx(), $1->property)));
        }
        else {
            $$->info = type_new_rval("", type_atom(tab_get(ctx(), $1->property)));
        }
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
        if (type_cat($1->info) != V_ARRAY) {
            LOG_ERR(NON_ARRAY, $1->line_no, "non-array value");
            $$->info = type_new_prim("", NOT_T);
        }
        else {
            if (type_atom($1->info) != NOT_T) {
                $$->info = type_clone($1->info);
                type_set_cat($$->info, V_PRIM);
                if (type_atom($3->info) != INT_T) {
                    LOG_ERR(NON_IDX, $3->line_no, "non-int value of array index");
                    type_set_atom($$->info, NOT_T);
                }
            }
            else {
                $$->info = type_new_cmplx("", type_sub($1->info));
            }
        }
    }
    | Exp DOT ID {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        if (type_cat($1->info) != V_CMPLX) {
            LOG_ERR(NON_STRUCT, $1->line_no, "non-struct value");
            $$->info = type_new_prim("", NOT_T);
        }
        else {
            struct type_t t = tab_get(type_tab(type_sub($1->info)), $3->property);
            if (t.handle) {
                $$->info = type_clone(t);
            }
            else {
                LOG_ERR(NON_MEMBER, $3->line_no, $3->property);
                $$->info = type_new_prim("", NOT_T);
            }
        }
    }
    | ID {
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        struct type_t t = tab_get(ctx(), $1->property);
        if (t.handle) {
            $$->info = type_clone(t);
        }
        else {
            LOG_ERR(UNDEF_VAR, $1->line_no, $1->property);
            $$->info = type_new_prim("", NOT_T);
        }
    }
    | INT {
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        $$->info = type_new_rval("", INT_T);
    }
    | FLOAT {
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        $$->info = type_new_rval("", FLOAT_T);
    }
    | CHAR {
        $$ = new_node("Exp", $1->line_no, NULL, $1, NULL);
        $$->info = type_new_rval("", CHAR_T);
    }
    | ID ILLEGAL Exp error {
        log_err(ILLEGAL_OP, $2->line_no, "illegal operator");
    }
    | ILLEGAL error {
        log_err(LEXEME_ERROR, $1->line_no, $1->property);
    }
    ;
Args: Exp COMMA Args {
        $1->sibling = $2;
        $2->sibling = $3;
        $$ = new_node("Args", $1->line_no, NULL, $1, NULL);
        tab_add(arg_tab, $1->info);
    }
    | Exp {
        $$ = new_node("Args", $1->line_no, NULL, $1, NULL);
        tab_add(arg_tab, $1->info);
    }
    ;
%%

void yyerror(const char *s) { fprintf(stderr, "%s\n", s); }

void log_err(char type, size_t line_no, const char *msg) {
    fprintf(err_stream, "Error type %c at Line %lu: %s\n", type, line_no, msg);
    exit_code = 1;
}

int parse(FILE *fin, FILE *fout, FILE *ferr) {
    if (!fin) {
        fin = stdin;
    }
    if (!fout) {
        fout = stdout;
    }
    if (!ferr) {
        ferr = stderr;
    }
    err_stream = ferr;
    ctx_init();
    arg_tab = tab_new();
    yyin = fin;
    yyparse();
    if (!exit_code) {
        print_tree(fout, result, 0);
    }
    empty_tree(result);
    if (result) {
        free(result);
        result = NULL;
    }
    return exit_code;
}

#ifdef MAIN_
int main(int argc, char **argv) {
    if (argc != 2) {
        exit(1);
    }
    FILE *fin = fopen(argv[1], "rb"), *fout = NULL, *ferr = NULL;
    if (!fin) {
        exit(1);
    }
    size_t len = strlen(argv[1]);
    if (!strcmp(argv[1] + len - 4, ".bpl")) {
        strcpy(argv[1] + len - 3, "out");
        fout = fopen(argv[1], "wb");
        ferr = fopen(argv[1], "wb");
    }
    if (!fout) {
        exit(1);
    }
    int retval = parse(fin, fout, stderr);
    if (fin) {
        fclose(fin);
    }
    if (fout) {
        fclose(fout);
    }
    if (ferr) {
        fclose(ferr);
    }
    return retval;
}
#endif
