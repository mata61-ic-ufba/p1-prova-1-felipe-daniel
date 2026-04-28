%{
#include "prova1.tab.h"
#include <stdlib.h>
#include <string.h>

void yyerror(const char *msg);
%}

%option noyywrap
%option yylineno

SPACE [ \t\r\n]+
DIGIT [0-9]
LETTER [a-zA-Z_]

%%

"//".* { }
{SPACE}                 { }

"print"                 { return PRINT; }
"concat"                { return CONCAT; }
"length"                { return LENGTH; }

{DIGIT}+                { 
                            yylval.int_val = atoi(yytext); 
                            return NUM; 
                        }

\"[^\"\r\n]*\"          { 
                            yytext[yyleng - 1] = '\0'; 
                            yylval.str_val = strdup(yytext + 1); 
                            return STRING; 
                        }

\"[^\"\r\n]*\r?\n       { return ERROR; }
\"[^\"\r\n]* { return ERROR; }

{LETTER}({LETTER}|{DIGIT})* { 
                            yylval.str_val = strdup(yytext); 
                            return IDENT; 
                        }

"="                     { return ASSIGN; }
"("                     { return LPAREN; }
")"                     { return RPAREN; }
","                     { return COMMA; }
"+"                     { return PLUS; }
"-"                     { return MINUS; }
"*"                     { return TIMES; }
"/"                     { return DIV; }

.                       { return ERROR; }

%%
