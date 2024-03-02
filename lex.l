%{
    #include <stdlib.h>
    #include "syntax.tab.h"
    #include "tree.h"
    #include "errlist.h"
    #define BUFLEN (4096)
    size_t line = 1;
    char buffer[BUFLEN];
    char *parse_int(char *raw);
    #define CONCAT(STR1, STR2) strncat(strncpy(buffer, STR1, BUFLEN - 1), STR2, BUFLEN - 1 - strlen(buffer))
%}
%option noyywrap
literal_int     [0-9]+|0x[0-9a-fA-F]+
literal_float   [0-9]+"."[0-9]+
identifier      [a-zA-Z_][a-zA-Z0-9_]*
literal_char    \'.\'|\'\\x[0-9a-fA-F]{2}\'
%%

"//".*$         { /* ignore comments */ }
"/*"([^*]|[*][^/]|[*][*]+[^*/])*"*/"    { for (size_t i = 0; i < strlen(yytext); i++) if (yytext[i] == '\n') line++; }
[ \t\r]+        { /* ignore whitespace */ }
"\n"            { line++; }
"int"           { yylval.node = new_node("TYPE", line, yytext, NULL, NULL); return TYPE; }
"float"         { yylval.node = new_node("TYPE", line, yytext, NULL, NULL); return TYPE; }
"char"          { yylval.node = new_node("TYPE", line, yytext, NULL, NULL); return TYPE; }
"struct"        { yylval.node = new_node("STRUCT", line, NULL, NULL, NULL); return STRUCT; }
"if"            { yylval.node = new_node("IF", line, NULL, NULL, NULL); return IF; }
"else"          { yylval.node = new_node("ELSE", line, NULL, NULL, NULL); return ELSE; }
"while"         { yylval.node = new_node("WHILE", line, NULL, NULL, NULL); return WHILE; }
"return"        { yylval.node = new_node("RETURN", line, NULL, NULL, NULL); return RETURN; }
"."             { yylval.node = new_node("DOT", line, NULL, NULL, NULL); return DOT; }
";"             { yylval.node = new_node("SEMI", line, NULL, NULL, NULL); return SEMI; }
","             { yylval.node = new_node("COMMA", line, NULL, NULL, NULL); return COMMA; }
"="             { yylval.node = new_node("ASSIGN", line, NULL, NULL, NULL); return ASSIGN; }
"<"             { yylval.node = new_node("LT", line, NULL, NULL, NULL); return LT; }
">"             { yylval.node = new_node("GT", line, NULL, NULL, NULL); return GT; }
"<="            { yylval.node = new_node("LE", line, NULL, NULL, NULL); return LE; }
">="            { yylval.node = new_node("GE", line, NULL, NULL, NULL); return GE; }
"!="            { yylval.node = new_node("NE", line, NULL, NULL, NULL); return NE; }
"=="            { yylval.node = new_node("EQ", line, NULL, NULL, NULL); return EQ; }
"+"             { yylval.node = new_node("PLUS", line, NULL, NULL, NULL); return PLUS; }
"-"             { yylval.node = new_node("MINUS", line, NULL, NULL, NULL); return MINUS; }
"*"             { yylval.node = new_node("MUL", line, NULL, NULL, NULL); return MUL; }
"/"             { yylval.node = new_node("DIV", line, NULL, NULL, NULL); return DIV; }
"&&"            { yylval.node = new_node("AND", line, NULL, NULL, NULL); return AND; }
"||"            { yylval.node = new_node("OR", line, NULL, NULL, NULL); return OR; }
"!"             { yylval.node = new_node("NOT", line, NULL, NULL, NULL); return NOT; }
"("             { yylval.node = new_node("LP", line, NULL, NULL, NULL); return LP; }
")"             { yylval.node = new_node("RP", line, NULL, NULL, NULL); return RP; }
"["             { yylval.node = new_node("LB", line, NULL, NULL, NULL); return LB; }
"]"             { yylval.node = new_node("RB", line, NULL, NULL, NULL); return RB; }
"{"             { yylval.node = new_node("LC", line, NULL, NULL, NULL); return LC; }
"}"             { yylval.node = new_node("RC", line, NULL, NULL, NULL); return RC; }
{identifier}    { yylval.node = new_node("ID", line, yytext, NULL, NULL); return ID; }
{literal_char}  { yylval.node = new_node("CHAR", line, yytext, NULL, NULL); return CHAR; }
{literal_int}   { yylval.node = new_node("INT", line, parse_int(yytext), NULL, NULL); return INT;}
{literal_float} { yylval.node = new_node("FLOAT", line, yytext, NULL, NULL); return FLOAT; }
'\\x.*'         { yylval.node = new_node("ILLEGAL", line, CONCAT("illegal char ", yytext), NULL, NULL); return ILLEGAL; }
0x([0-9a-fA-F]|[g-zG-Z])+       { yylval.node = new_node("ILLEGAL", line, CONCAT("illegal hex ", yytext), NULL, NULL); return ILLEGAL; }
[0-9]{identifier}    { yylval.node = new_node("ILLEGAL", line, CONCAT("illegal identifier ", yytext), NULL, NULL); return ILLEGAL; }
.               { yylval.node = new_node("ILLEGAL", line, CONCAT("illegal symbol ", yytext), NULL, NULL); return ILLEGAL; }
%%

char *parse_int(char *raw) {
    if (raw[1] == 'x') {
        int val = 0;
        char *ptr;
        for (ptr = raw + 2; *ptr; ptr++) {
            val *= 16;
            if (*ptr <= '9') {
                val += *ptr - '0';
            }
            else if (*ptr <= 'Z') {
                val += *ptr - 'A' + 10;
            }
            else {
                val += *ptr - 'a' + 10;
            }
        }
        buffer[BUFLEN - 1] = 0;
        for (ptr = buffer + BUFLEN - 2; val; ptr--) {
            *ptr = val % 10 + '0';
            val /= 10;
        }
        return ++ptr;
    }
    else {
        return raw;
    }
}