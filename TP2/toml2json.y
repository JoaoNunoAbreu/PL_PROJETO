%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
int yylex();
int yyerror(char* s);

%}
%token num
%%
Frase : '[' Lista ']'
      ;

Lista : num
      | num ',' Lista
      ;
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