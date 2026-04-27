%option noyywrap
%{
#include "prova1.tab.h"
#include <string.h>
#include <stdio.h>

char yytext_buffer[1024];
%}

%%

"//".*                 { /* ignora comentários de uma linha */ }
"print"                { return PRINT; }
"concat"               { return CONCAT; }
"length"               { return LENGTH; }
[0-9]+                  { yylval.ival = atoi(yytext); return NUM; }
"\"([^\"]*)\""        { strncpy(yytext_buffer, yytext+1, yyleng-2); yytext_buffer[yyleng-2] = '\0'; yylval.str = strdup(yytext_buffer); return STRING; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.str = strdup(yytext); return ID; }
"="                    { return ASSIGN; }
","                    { return COMMA; }
"+"                    { return PLUS; }
"-"                    { return MINUS; }
"*"                    { return TIMES; }
"/"                    { return DIV; }
"("                    { return LPAREN; }
")"                    { return RPAREN; }
\r?\n                  { return EOL; }
[ \t]+                  { /* ignora espacos em branco */ }
.                        { return ERROR; }

%%
