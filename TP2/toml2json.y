%{
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
int yyerror(char* s);
int flag = 0;
int dot_flag = 0;
int dont_fix_it = 0;
int incomplete = 0;
int incomplete_for_tables = 0;
char* currentKey = "";
char* currentTable = "";
%}
%union{

  char* string;
  char* s;
  float f;
  int n;

  union Data {
    char* s;
    float f;
    int n;
  } data;

  struct Info{
    int uniontype; // 0 - string, 1 - inteiro, 2 - boolean, 3 - float
    union Data valor;
  } info;
  
  
}

%token val str
%type <string> str Table Pair Lang DottedPair 
%type <info> SubKey Value Key val 
%%

TOML  : Lang                    {
                                    if(incomplete > 0 && incomplete_for_tables)
                                        printf("{\t%s\n\t\t}\n\t}\n}",$1);
                                    else if(incomplete > 0 || incomplete_for_tables)
                                        printf("{\t%s\n\t}\n}",$1);
                                    else 
                                        printf("{\t%s\n}",$1);}

Lang  : Lang Pair '\n'          {   
                                    if(incomplete > 0){
                                        char* temp;
                                        if(incomplete_for_tables) temp = strdup("\t},");
                                        else temp = strdup("},");
                                        asprintf(&$$,"%s\n\t%s\n\t%s",$1,temp,$2); 
                                        incomplete--;
                                        flag = 1;
                                        free(temp);
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
      | Lang DottedPair '\n'    {   
                                    if(incomplete > 0 && dont_fix_it == 0){
                                        if(!dot_flag) {
                                            if(flag)
                                                asprintf(&$$,"%s,\n\t%s",$1,$2);
                                            else{
                                                asprintf(&$$,"%s\n\t},\n\t%s",$1,$2);
                                                incomplete--;
                                            }
                                            dot_flag = 1;
                                        }
                                        else 
                                          asprintf(&$$,"%s,\n\t%s",$1,$2); 
                                    }
                                    else{
                                        dont_fix_it = 0;
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
      | Lang Table              {
                                  if((incomplete > 0 || incomplete_for_tables) && !dont_fix_it){
                                      char* temp;
                                      if(incomplete_for_tables && incomplete) temp = strdup("\t}\n\t},");
                                      else temp = strdup("},");
                                      asprintf(&$$,"%s\n\t%s\n\t%s",$1,temp,$2); 
                                      free(temp);
                                      incomplete--;
                                  }
                                  else {
                                      dont_fix_it = 0;
                                      if(flag || dot_flag){
                                          asprintf(&$$,"%s,\n\t%s",$1,$2);
                                      }
                                      else 
                                          asprintf(&$$,"%s\n\t%s",$1,$2);
                                  }
                                  flag = 0;
                                  dot_flag = 0;
                                }
      |                         {$$ = "";}
      ;

Pair  : Key '=' Value           { 
                                    char* temp;
                                    if(incomplete_for_tables) temp = strdup("\t");
                                    else temp = strdup("");
                                    if($1.uniontype == 0 && $3.uniontype == 0) asprintf(&$$,"%s\"%s\" : \"%s\"",temp,$1.valor.s,$3.valor.s);
                                    if($1.uniontype == 0 && $3.uniontype == 1) asprintf(&$$,"%s\"%s\" : %d",temp,$1.valor.s,$3.valor.n);  
                                    if($1.uniontype == 1 && $3.uniontype == 0) asprintf(&$$,"%s\"%d\" : \"%s\"",temp,$1.valor.n,$3.valor.s);  
                                    if($1.uniontype == 1 && $3.uniontype == 1) asprintf(&$$,"%s\"%d\" : %d",temp,$1.valor.n,$3.valor.n);
                                    if($1.uniontype == 0 && $3.uniontype == 2) asprintf(&$$,"%s\"%s\" : %s",temp,$1.valor.s,$3.valor.s);
                                    if($1.uniontype == 1 && $3.uniontype == 2) asprintf(&$$,"%s\"%d\" : %s",temp,$1.valor.n,$3.valor.s);   
                                    if($1.uniontype == 0 && $3.uniontype == 3) asprintf(&$$,"%s\"%s\" : %f",temp,$1.valor.s,$3.valor.f);
                                    if($1.uniontype == 1 && $3.uniontype == 3) asprintf(&$$,"%s\"%d\" : %f",temp,$1.valor.n,$3.valor.f);    
                                    free(temp);
                                }
DottedPair : Key'.'SubKey '=' Value {
                                        /* Entra na primeira iteração e quando chave muda */
                                        if(strcmp($1.valor.s,currentKey) != 0){
                                            dot_flag = 0;        
                                            if(!strcmp(currentKey,"")) {
                                                dont_fix_it = 1;
                                            }
                                            incomplete++;

                                            char* temp;
                                            if(incomplete_for_tables) temp = strdup("\t");
                                            else temp = strdup("");
                                            
                                            if($5.uniontype == 0) asprintf(&$$,"\t\"%s\" : {\n\t\t%s\"%s\" : \"%s\"",$1.valor.s,temp,$3.valor.s,$5.valor.s);
                                            if($5.uniontype == 1) asprintf(&$$,"\t\"%s\" : {\n\t\t%s\"%s\" : %d",$1.valor.s,temp,$3.valor.s,$5.valor.n);
                                            if($5.uniontype == 2) asprintf(&$$,"\t\"%s\" : {\n\t\t%s\"%s\" : %s",$1.valor.s,temp,$3.valor.s,$5.valor.s);
                                            if($5.uniontype == 3) asprintf(&$$,"\t\"%s\" : {\n\t\t%s\"%s\" : %f",$1.valor.s,temp,$3.valor.s,$5.valor.f);

                                            free(temp);

                                            currentKey = strdup($1.valor.s);
                                        }
                                        else{
                                            char* temp;
                                            if(incomplete_for_tables) temp = strdup("\t");
                                            else temp = strdup("");

                                            if($5.uniontype == 0) asprintf(&$$,"%s\t\"%s\" : \"%s\"",temp,$3.valor.s,$5.valor.s);
                                            if($5.uniontype == 1) asprintf(&$$,"%s\t\"%s\" : %d",temp,$3.valor.s,$5.valor.n);
                                            if($5.uniontype == 2) asprintf(&$$,"%s\t\"%s\" : %s",temp,$3.valor.s,$5.valor.s);
                                            if($5.uniontype == 3) asprintf(&$$,"%s\t\"%s\" : %f",temp,$3.valor.s,$5.valor.f);

                                            free(temp);
                                        }
                                    }
Table : str                         {
                                        if(!strcmp(currentTable,"")) {
                                            dont_fix_it = 1;
                                        }
                                        incomplete_for_tables = 1;
                                        asprintf(&$$,"\"%s\" : {",$1);
                                        currentTable = strdup($1);
                                    }
Key   : val                         {$$ = $1;}
SubKey : val                        {$$ = $1;}
Value : val                         {$$ = $1;}
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