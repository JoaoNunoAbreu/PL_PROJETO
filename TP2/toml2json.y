%{
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
int yyerror(char* s);
int flag = 0;
%}
%union{

  char* s;
  int n;

  union Data {
    char* s;
    int n;
  } data;

  struct Info{
    int uniontype; // 0 - string, 1 - inteiro, 2 - boolean
    union Data valor;
  } info;
  
  
}

%token text num val
%type <s> text Pair Lang
%type <n> num
%type <info> Value Key val
%%

TOML  : Lang                    {printf("{\t%s\n}",$1);}

Lang  : Lang Pair '\n'          {if(!flag) {asprintf(&$$,"%s\n\t%s",$1,$2); flag = 1;}else asprintf(&$$,"%s,\n\t%s",$1,$2);}
      |                         {$$ = "";}
      ;

Pair  : Key '=' Value           {
                                    if($1.uniontype == 0 && $3.uniontype == 0)
                                      asprintf(&$$,"\"%s\" : \"%s\"",$1.valor.s,$3.valor.s);
                                    if($1.uniontype == 0 && $3.uniontype == 1)
                                      asprintf(&$$,"\"%s\" : %d",$1.valor.s,$3.valor.n);  
                                    if($1.uniontype == 1 && $3.uniontype == 0)
                                      asprintf(&$$,"\"%d\" : \"%s\"",$1.valor.n,$3.valor.s);  
                                    if($1.uniontype == 1 && $3.uniontype == 1)
                                      asprintf(&$$,"\"%d\" : %d",$1.valor.n,$3.valor.n);
                                    if($1.uniontype == 0 && $3.uniontype == 2)
                                      asprintf(&$$,"\"%s\" : %s",$1.valor.s,$3.valor.s);
                                    if($1.uniontype == 1 && $3.uniontype == 2)
                                      asprintf(&$$,"\"%d\" : %s",$1.valor.n,$3.valor.s);    
                                }

Key   : val                     {$$ = $1;}

Value : val                     {$$ = $1;}
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