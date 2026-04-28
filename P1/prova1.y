%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;

void yyerror(const char *msg);

#define T_INT 0
#define T_STR 1

typedef struct {
    char *id_name;
    int data_type;
    int int_val;
    char *str_val;
} VariableInfo;

VariableInfo var_table[256];
int var_count = 0;

VariableInfo* lookup_var(const char *name) {
    for(int i = 0; i < var_count; i++) {
        if(strcmp(var_table[i].id_name, name) == 0) {
            return &var_table[i];
        }
    }
    return NULL;
}

void assign_var(char *name, int type, int v_int, char *v_str) {
    VariableInfo *var = lookup_var(name);
    if(var == NULL) {
        var = &var_table[var_count++];
        var->id_name = strdup(name);
    } else {
        if(var->data_type == T_STR && var->str_val) {
            free(var->str_val);
        }
    }
    
    var->data_type = type;
    if(type == T_INT) {
        var->int_val = v_int;
        var->str_val = NULL;
    } else {
        var->int_val = 0;
        var->str_val = strdup(v_str);
    }
}
%}

%union {
    int int_val;
    char *str_val;
    struct {
        int type; 
        int v_int;
        char *v_str;
    } expr_res;
}

%token ERROR
%token <int_val> NUM
%token <str_val> IDENT STRING
%token PRINT CONCAT LENGTH ASSIGN LPAREN RPAREN COMMA
%token PLUS MINUS TIMES DIV

%type <expr_res> expression
%type <str_val> concat_args

%left PLUS MINUS
%left TIMES DIV

%start program

%%

program
: cmd_list 
;

cmd_list
: command
| cmd_list command
;

command
: IDENT ASSIGN expression {
    assign_var($1, $3.type, $3.v_int, $3.v_str);
    free($1);
}
| PRINT LPAREN expr_list RPAREN {
}
| expression {
}
;

expr_list
: expression 
| expr_list COMMA expression 
;

concat_args
: expression {
    if($1.type == T_STR) {
        $$ = strdup($1.v_str);
    } else {
        char buffer[100];
        snprintf(buffer, sizeof(buffer), "%d", $1.v_int);
        $$ = strdup(buffer);
    }
}
| concat_args COMMA expression {
    char *next_str;
    char buffer[100];
    
    if($3.type == T_STR) {
        next_str = $3.v_str;
    } else {
        snprintf(buffer, sizeof(buffer), "%d", $3.v_int);
        next_str = buffer;
    }
    
    $$ = malloc(strlen($1) + strlen(next_str) + 1);
    strcpy($$, $1);
    strcat($$, next_str);
    free($1); 
}
;

expression
: NUM {
    $$.type = T_INT; $$.v_int = $1; $$.v_str = NULL;
}
| STRING {
    $$.type = T_STR; $$.v_int = 0; $$.v_str = strdup($1);
}
| IDENT {
    VariableInfo *var = lookup_var($1);
    if(var) {
        $$.type = var->data_type; 
        $$.v_int = var->int_val;
        $$.v_str = (var->data_type == T_STR) ? strdup(var->str_val) : NULL;
    } else {
        $$.type = T_INT; $$.v_int = 0; $$.v_str = NULL;
    }
    free($1);
}
| expression PLUS expression { $$.type = T_INT; $$.v_int = $1.v_int + $3.v_int; }
| expression MINUS expression { $$.type = T_INT; $$.v_int = $1.v_int - $3.v_int; }
| expression TIMES expression { $$.type = T_INT; $$.v_int = $1.v_int * $3.v_int; }
| expression DIV expression { 
    $$.type = T_INT; 
    $$.v_int = ($3.v_int != 0) ? ($1.v_int / $3.v_int) : 0; 
}
| LPAREN expression RPAREN { $$ = $2; }
| CONCAT LPAREN concat_args RPAREN {
    $$.type = T_STR; $$.v_int = 0; $$.v_str = $3;
}
| LENGTH LPAREN expression RPAREN {
    $$.type = T_INT; $$.v_str = NULL;
    if($3.type == T_STR && $3.v_str != NULL) {
        $$.v_int = strlen($3.v_str);
    } else {
        $$.v_int = 0;
    }
}
;

%%
