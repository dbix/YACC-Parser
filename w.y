%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "symtab.c"

typedef struct {
    char thestr[25];
    int ival;
    int ttype;
} tstruct ; 

#define YYSTYPE tstruct

int yylex();
void yyerror( char *statement );

%}

%token tstart  
%token tfinish   
%token tbegin  
%token tend  
%token tprint  
%token tprintln  
%token tif  
%token twhile  
%token tlt  
%token tgt  
%token teq  
%token tfalse  
%token ttrue  
%token tassign  
%token tid
%token tint tfloat tbool 
%token tstrlit tintlit tfloatlit tboollit

%define locations

%%

p 
    : prog 
    ;

prog
    : tstart tfinish
    {
    
    }
    
    | tstart DL SL tfinish  
    {
        printf("Prog\n");
    }

    | tstart DL tfinish
    {
        printf("Prog\n");
    }
    ;

DL
    : DL D   
    {
        printf("declst\n");
    }
    
    | D        
    {
        printf("declst\n");
    }
    ;

D 
    : tid Dtail    
    {
        if (intab($1.thestr)) {
            printf("Error: variable %s is already declared\n", $1.thestr);
            $$.ttype = $2.ttype;
        } else {
            addtab($1.thestr);
            addtype($1.thestr, $2.ttype);
            $$.ttype = $2.ttype;
        }
    }
    ;

Dtail 
    : ',' tid Dtail
    { 
        if (intab($2.thestr)) {
            printf("Error: variable %s is already declared\n", $2.thestr);
            $$.ttype = $3.ttype;
        } else {
            addtab($2.thestr);
            addtype($2.thestr, $3.ttype); 
            $$.ttype = $3.ttype; 
        }
    }
    
    | ':' type ';'
    {
        $$.ttype = $2.ttype;
    }
    ;

type
    : tint 
    {
        $$.ttype = INT_TYPE;
    } 
    
    | tfloat 
    {
        $$.ttype = FLOAT_TYPE;
    } 
    
    | tbool 
    {
        $$.ttype = BOOL_TYPE;
    } 
    ;

SL 
    : SL S 
    {
        printf("statement list\n");
    }

    | S
    {
        printf("statement list\n");
    }
    ;

S
    : tprint tstrlit ';'   
    {
        printf("print lit\n");
        // printf("%s", $2.thestr); 
    }
    
    | tprint tid ';' 
    {
        printf("print id\n");
        if (intab($2.thestr))
            printf(
                "%s is declared line %d that\n", 
                $2.thestr, 
                @2.first_line
            );
        else
           printf(
                    "UNDECLARED:: %s, (line %d) \n", 
                    $2.thestr, 
                    yyloc.first_line
           );
    }
    
    |  tprintln ';'
    {
    
    }
    
    |  tid tassign expr ';'
    {
        printf("***assign***\n");
        if (intab($1.thestr)) printf("%s is declared\n", $1.thestr);
        else printf("UNDECLARED:: %s \n", $1.thestr);
        $1.ttype = gettype($1.thestr);
        if ($1.ttype > 0 ) {
            if ($1.ttype == INT_TYPE && $3.ttype == INT_TYPE) {
                printf("assign int into int\n");
            } else if ($1.ttype == BOOL_TYPE && $3.ttype == BOOL_TYPE) {
                printf("assign bool into bool\n");
            } else if ($1.ttype == FLOAT_TYPE && $3.ttype == FLOAT_TYPE) {
                printf("assign float into float\n");
            } else if ($1.ttype == FLOAT_TYPE && $3.ttype == INT_TYPE) {
                printf("assign int into float\n", $3.thestr);
            } else {
                printf(
                    "Incompatible ASSIGN types %d %d\n", 
                    $1.ttype,
                    $3.ttype
                );
            }
        } else {
            yyerror("Type Error :::");
        }


    }
    
    | error ';'    
    {
        printf("error in statement\n");
    }
;

expr 
    : expr '+' term 
    {
        printf("***addition***\t");
        if ($1.ttype == INT_TYPE && $3.ttype == INT_TYPE) {
            $$.ttype = INT_TYPE;
            printf("int + int = int\n");
        } else if ($1.ttype == FLOAT_TYPE && $3.ttype == FLOAT_TYPE) {
            $$.ttype = FLOAT_TYPE;
            printf("float + float = float\n");
        } else if ($1.ttype == FLOAT_TYPE && $3.ttype == INT_TYPE) {
            $$.ttype = FLOAT_TYPE;
            printf("float + int = float\n");
        } else if ($1.ttype == INT_TYPE && $3.ttype == FLOAT_TYPE) {
            $$.ttype = FLOAT_TYPE;
            printf("int + float = float\n");
        } else {
            $$.ttype = -1;
            printf("bad expression types\n");
        }
    }

    | expr '-' term
    {
        printf("***subtraction***\t");
        if ($1.ttype == INT_TYPE && $3.ttype == INT_TYPE) {
            $$.ttype = INT_TYPE;
            printf("int - int = int\n");
        } else if ($1.ttype == FLOAT_TYPE && $3.ttype == FLOAT_TYPE) {
            $$.ttype = FLOAT_TYPE;
            printf("float - float = float\n");
        } else if ($1.ttype == FLOAT_TYPE && $3.ttype == INT_TYPE) {
            $$.ttype = FLOAT_TYPE;
            printf("float - int = float\n");
        } else if ($1.ttype == INT_TYPE && $3.ttype == FLOAT_TYPE) {
            $$.ttype = FLOAT_TYPE;
            printf("int - float = float\n");
        } else {
            $$.ttype = -1;
            printf("bad expression types\n");
        }
    }
    
    |  term      
    { 
        $$.ttype = $1.ttype; 
    }
    ;

term 
    : term '*' factor
    { 
        printf("***multiplication***\t");
        if ($1.ttype == INT_TYPE && $3.ttype == INT_TYPE) {
           $$.ttype = INT_TYPE;
           printf("int * int = int\n");
        } else if ($1.ttype == FLOAT_TYPE && $3.ttype == FLOAT_TYPE) {
           $$.ttype = FLOAT_TYPE;
           printf("float * float = float\n");
        } else if ($1.ttype == FLOAT_TYPE && $3.ttype == INT_TYPE) {
           $$.ttype = FLOAT_TYPE;
           printf("float * int = float\n");
        } else if ($1.ttype == INT_TYPE && $3.ttype == FLOAT_TYPE) {
           $$.ttype = FLOAT_TYPE; 
           printf("int * float = float\n");
        } else {
            $$.ttype = -1;
            printf("bad term types\n");
        }
    }

    | term '/' factor
    {
        printf("***division***\t");
        if (
            ($1.ttype == INT_TYPE || $1.ttype == FLOAT_TYPE) && 
            ($3.ttype == INT_TYPE || $3.ttype == FLOAT_TYPE)
        ) {
            $$.ttype = FLOAT_TYPE;
            printf("division always results in a float\n");
        } else {
            printf("Error: incompatible literals for division\n");
        }
    }
    
    | factor   
    { 
        $$.ttype = $1.ttype; 
    }
    ;

factor 
    : tid
    {
        // if ( intab($1.thestr) ) printf("%s is declared\n", $1.thestr);
        // else printf("UNDECLARED:: %s \n", $1.thestr);

        $$.ttype = gettype($1.thestr);

        if ($$.ttype > 0 ) ;
        else yyerror("Type Error :::");
    }

    | tintlit
    { 
        $$.ttype = INT_TYPE;
    }

    | tfloatlit
    {
        $$.ttype = FLOAT_TYPE;
    }
    
    | ttrue
    {
        $$.ttype = BOOL_TYPE;
    }

    | tfalse 
    {
        $$.ttype = BOOL_TYPE;
    }
;

%%

int main()
{
    yyparse();
    printf("---------------------\n");
    showtab();
}


//void yyerror(char *statement)  /* Called by yyparse on error */
//{
// printf ("error: %statement\n", statement);
// printf ("ERROR: %statement at line %d\n", statement, yylineno);
//}


