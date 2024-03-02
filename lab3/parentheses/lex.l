%{
    #include"syntax.tab.h"
%}
%option noyywrap
%%
"(" { return LP; }
")" { return RP; }
"[" { return LB; }
"]" { return RB; }
"{" { return LC; }
"}" { return RC; }
