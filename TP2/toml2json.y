%{
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
int yylex();
int yyerror(char* s);

%}
%union{
  char* s;
  int n;
}
%token text 
%type <s> text Pair Key Value
%%

Lang  : Lang Pair '\n'          {printf("{\n\t%s\n}",$2);}
      |                         
      ;

Pair  : Key '=' Value           {asprintf(&$$,"\"%s\" : \"%s\"",$1,$3);}

Key   : text                    {$$ = $1;}

Value : text                    {$$ = $1;}
%%

#include "lex.yy.c"

int main(){
  yyparse();
  return 0;
}
int yyerror(char* s){
  printf("erro %d: %s junto a '%s'\n",yylineno,s,yytext);
  return 0;
}