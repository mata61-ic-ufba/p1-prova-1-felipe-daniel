%option noyywrap
%{
#include "prova1.tab.h"
#include <string.h>
#include <stdio.h>

char yytext_buffer[1024];
%}

%%

"//".* { }
"print"                 { return PRINT; }
"concat"                { return CONCAT; }
"length"                { return LENGTH; }
[0-9]+                  { yylval.ival = atoi(yytext); return NUM; }
\"[^\"\r\n]*\"          { strncpy(yytext_buffer, yytext+1, yyleng-2); yytext_buffer[yyleng-2] = '\0'; yylval.str = strdup(yytext_buffer); return STRING; }
\"[^\"\r\n]*\r?\n       { return ERROR; }
\"[^\"\r\n]* { return ERROR; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return ID; }
"="                     { return ASSIGN; }
","                     { return COMMA; }
"+"                     { return PLUS; }
"-"                     { return MINUS; }
"*"                     { return TIMES; }
"/"                     { return DIV; }
"("                     { return LPAREN; }
")"                     { return RPAREN; }
\r?\n                   { return EOL; }
[ \t]+                  { }
.                       { return ERROR; }

%%
