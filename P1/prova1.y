%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE *yyout;
int yyerror(const char *s);

#define MAX_VARS 100
#define MAX_STR 1024

typedef struct {
    char name[MAX_STR];
    int ival;
    char sval[MAX_STR];
    int is_string;
} var_t;

var_t vars[MAX_VARS];
int nvars = 0;

int yylex(void);

int set_var(const char *name, int ival, const char *sval, int is_string) {
    for (int i = 0; i < nvars; i++) {
        if (strcmp(vars[i].name, name) == 0) {
            vars[i].ival = ival;
            if (sval) strncpy(vars[i].sval, sval, MAX_STR);
            vars[i].is_string = is_string;
            return 0;
        }
    }
    strncpy(vars[nvars].name, name, MAX_STR);
    vars[nvars].ival = ival;
    if (sval) strncpy(vars[nvars].sval, sval, MAX_STR);
    vars[nvars].is_string = is_string;
    nvars++;
    return 0;
}

var_t* get_var(const char *name) {
    for (int i = 0; i < nvars; i++) {
        if (strcmp(vars[i].name, name) == 0) return &vars[i];
    }
    return NULL;
}

%}

%union {
    int ival;
    char *str;
}

%token <ival> NUM
%token <str> STRING
%token <str> ID
%token PLUS MINUS TIMES DIV
%token LPAREN RPAREN
%token ASSIGN PRINT COMMA
%token CONCAT LENGTH
%token EOL 0
%token ERROR

%type <ival> expression term factor
%type <str> string_expr string_list

%left PLUS MINUS
%left TIMES DIV

%%

program
    : 
    | program command EOL
    | program EOL
    ;

command
    : expression                { }
    | string_expr               { }
    | ID ASSIGN expression      { set_var($1, $3, NULL, 0); }
    | ID ASSIGN string_expr     { set_var($1, 0, $3, 1); }
    | PRINT print_args          { }
    ;

print_args
    : print_arg
    | print_args COMMA print_arg
    ;

print_arg
    : expression
    | string_expr
    ;

expression
    : expression PLUS term      { $$ = $1 + $3; }
    | expression MINUS term     { $$ = $1 - $3; }
    | term                      { $$ = $1; }
    | ID                        { var_t *v = get_var($1); if (v && !v->is_string) $$ = v->ival; else $$ = 0; }
    ;

term
    : term TIMES factor         { $$ = $1 * $3; }
    | term DIV factor           { $$ = $1 / $3; }
    | factor                    { $$ = $1; }
    ;

factor
    : NUM                       { $$ = $1; }
    | LPAREN expression RPAREN  { $$ = $2; }
    | LENGTH LPAREN string_expr RPAREN { $$ = strlen($3); }
    ;

string_expr
    : STRING                    { $$ = $1; }
    | ID                        { var_t *v = get_var($1); if (v && v->is_string) $$ = v->sval; else $$ = ""; }
    | CONCAT LPAREN string_list RPAREN { $$ = $3; }
    ;

string_list
    : string_expr               { $$ = strdup($1); }
    | string_list COMMA string_expr {
        char *tmp = malloc(strlen($1) + strlen($3) + 1);
        strcpy(tmp, $1); strcat(tmp, $3); $$ = tmp;
      }
    ;

%%
