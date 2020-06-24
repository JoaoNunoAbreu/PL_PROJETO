%{
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
int yyerror(char* s);
int flag = 0;
int dot_flag = 0;
int dot_flag2 = 0;
int incomplete = 0;
char* currentKey = "";
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

%token val
%type <s> Pair Lang DottedPair 
%type <info> SubKey Value Key val 
%%

TOML  : Lang                    {if(incomplete > 0) printf("{\t%s\n\t}\n}",$1); else printf("{\t%s\n}",$1);}

Lang  : Lang Pair '\n'          {   printf("incomplete = %d\n",incomplete);
                                    if(incomplete > 0){
                                      asprintf(&$$,"%s\n\t},\n\t%s",$1,$2); 
                                      incomplete--;
                                    }
                                    else {
                                      if(!flag) {
                                        asprintf(&$$,"%s\n\t%s",$1,$2); 
                                        flag = 1;
                                      }
                                      else{
                                        asprintf(&$$,"%s,\n\t%s",$1,$2); 
                                      }
                                    }
                                    dot_flag = 0;
                                }
      | Lang DottedPair '\n'    {   printf("incomplete = %d\n",incomplete);
                                    if(incomplete > 0){
                                      if(!dot_flag) {
                                        asprintf(&$$,"%s\n\t},\n\t%s",$1,$2);
                                        incomplete--;
                                        dot_flag = 1;
                                      }
                                      else {
                                        asprintf(&$$,"%s,\n\t%s",$1,$2);
                                      } 
                                    }
                                    else{
                                      if(!dot_flag) {
                                        if(flag)
                                          asprintf(&$$,"%s,\n\t%s",$1,$2);
                                        else 
                                          asprintf(&$$,"%s\n\t%s",$1,$2);
                                        dot_flag = 1;
                                      }
                                      else {
                                        asprintf(&$$,"%s,\n\t%s",$1,$2);
                                      } 
                                    }
                                    flag = 0;
                                }
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
DottedPair : Key'.'SubKey '=' Value {
                                    /* Entra na primeira iteração e quando chave muda */
                                    if(strcmp($1.valor.s,currentKey) != 0){
                                      printf("ENTREI com 1.valor.s = %s e currentKey = %s\n",$1.valor.s,currentKey);
                                      dot_flag = 0;        
                                      if(strcmp(currentKey,"") != 0) incomplete++;
                                      
                                      if($5.uniontype == 0)
                                        asprintf(&$$,"\"%s\" : {\n\t\t\"%s\" : \"%s\"",$1.valor.s,$3.valor.s,$5.valor.s);
                                      if($5.uniontype == 1)
                                        asprintf(&$$,"\"%s\" : {\n\t\t\"%s\" : %d",$1.valor.s,$3.valor.s,$5.valor.n);
                                      if($5.uniontype == 2)
                                        asprintf(&$$,"\"%s\" : {\n\t\t\"%s\" : %s",$1.valor.s,$3.valor.s,$5.valor.s);
                                      currentKey = strdup($1.valor.s);
                                      printf("currentKey = %s\n",currentKey);
                                    }
                                    else{
                                      if($5.uniontype == 0)
                                        asprintf(&$$,"\t\"%s\" : \"%s\"",$3.valor.s,$5.valor.s);
                                      if($5.uniontype == 1)
                                        asprintf(&$$,"\t\"%s\" : %d",$3.valor.s,$5.valor.n);
                                      if($5.uniontype == 2)
                                        asprintf(&$$,"\t\"%s\" : %s",$3.valor.s,$5.valor.s);
                                    }

                                    
                                  }

Key   : val                     {$$ = $1;}
SubKey : val                    {$$ = $1;}
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