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
int incomplete_for_tables2 = 0;
char* currentKey = "";
char* currentTable = "";
char* currentSubTable = "";
char* mainTable = "";
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
%type <string> str Table Pair Lang DottedPair Key SubKey
%type <info> Value val 
%%

TOML  : Lang                    {   printf("%d, %d, %d\n",incomplete,incomplete_for_tables,incomplete_for_tables2);
                                    if(incomplete && incomplete_for_tables && incomplete_for_tables2)
                                        printf("{\t%s\n\t\t\t}\n\t\t}\n\t}\n}",$1);
                                    else if(incomplete && incomplete_for_tables)
                                        printf("{\t%s\n\t\t}\n\t}\n}",$1);
                                    else if(incomplete_for_tables && incomplete_for_tables2)
                                        printf("{\t%s\n\t\t}\n\t}\n}",$1);    
                                    else if(incomplete || incomplete_for_tables || incomplete_for_tables2)
                                        printf("{\t%s\n\t}\n}",$1);
                                    else 
                                        printf("{\t%s\n}",$1);
                                }

Lang  : Lang Pair '\n'          {   
                                    if(incomplete){
                                        char* temp;
                                        if(incomplete_for_tables) temp = strdup("\t},");
                                        else temp = strdup("},");
                                        asprintf(&$$,"%s\n\t%s\n\t%s",$1,temp,$2); 
                                        incomplete = 0;
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
                                    if(incomplete && dont_fix_it == 0){
                                        if(!dot_flag) {
                                            if(flag)
                                                asprintf(&$$,"%s,\n\t%s",$1,$2);
                                            else{
                                                char* temp;
                                                if(incomplete_for_tables && incomplete_for_tables2) temp = strdup("\t\t");
                                                else if(incomplete_for_tables) temp = strdup("\t");
                                                else temp = strdup("");
                                                asprintf(&$$,"%s\n%s\t},\n\t%s",$1,temp,$2);
                                                free(temp);
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
      | Lang Table              {   printf("%d, %d, %d, %d, mainTable = %s, currentSubTable = %s, currentTable = %s\n",incomplete,incomplete_for_tables,incomplete_for_tables2,dont_fix_it,mainTable,currentSubTable,currentTable);
                                    if(incomplete || (incomplete_for_tables && !dont_fix_it) || (incomplete_for_tables2 && !dont_fix_it)){
                                        char* temp;
                                        if(incomplete && incomplete_for_tables && incomplete_for_tables2)
                                            temp = strdup("\t\t}\n\t\t},");
                                        else if((incomplete_for_tables && incomplete && !dont_fix_it) || (incomplete_for_tables && !incomplete_for_tables2 && !incomplete && strcmp(mainTable,"") != 0) || (!incomplete_for_tables && incomplete_for_tables2)) {
                                            temp = strdup("\t}\n\t},");
                                            if(incomplete_for_tables == 0) incomplete_for_tables = 1;
                                        }
                                        else if((incomplete_for_tables2 && incomplete) || (incomplete_for_tables2 && incomplete_for_tables))
                                            temp = strdup("\t},");
                                        else temp = strdup("},");
                                        asprintf(&$$,"%s\n\t%s\n\t%s",$1,temp,$2); 
                                        free(temp);
                                        incomplete = 0;
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
                                    if(incomplete_for_tables && incomplete_for_tables2) temp = strdup("\t\t");
                                    else if(incomplete_for_tables || incomplete_for_tables2) temp = strdup("\t");
                                    else temp = strdup("");
                                    if($3.uniontype == 0) asprintf(&$$,"%s\"%s\" : \"%s\"",temp,$1,$3.valor.s);
                                    if($3.uniontype == 1) asprintf(&$$,"%s\"%s\" : %d",temp,$1,$3.valor.n);
                                    if($3.uniontype == 2) asprintf(&$$,"%s\"%s\" : %s",temp,$1,$3.valor.s);
                                    if($3.uniontype == 3) asprintf(&$$,"%s\"%s\" : %f",temp,$1,$3.valor.f);    
                                    free(temp);
                                }
DottedPair : Key'.'SubKey '=' Value {
                                        /* Entra quando chave muda */
                                        if(strcmp($1,currentKey) != 0){
                                            dot_flag = 0;        
                                            if(!strcmp(currentKey,"")) {
                                                dont_fix_it = 1;
                                            }
                                            incomplete = 1;
                                            
                                            char* temp;
                                            if(incomplete_for_tables2 && incomplete_for_tables) temp = strdup("\t\t");
                                            else if(incomplete_for_tables) temp = strdup("\t");
                                            else temp = strdup("");

                                            if($5.uniontype == 0) asprintf(&$$,"%s\"%s\" : {\n\t\t%s\"%s\" : \"%s\"",temp,$1,temp,$3,$5.valor.s);
                                            if($5.uniontype == 1) asprintf(&$$,"%s\"%s\" : {\n\t\t%s\"%s\" : %d",temp,$1,temp,$3,$5.valor.n);
                                            if($5.uniontype == 2) asprintf(&$$,"%s\"%s\" : {\n\t\t%s\"%s\" : %s",temp,$1,temp,$3,$5.valor.s);
                                            if($5.uniontype == 3) asprintf(&$$,"%s\"%s\" : {\n\t\t%s\"%s\" : %f",temp,$1,temp,$3,$5.valor.f);

                                            currentKey = strdup($1);
                                        }
                                        else{
                                            char* temp;
                                            if(incomplete_for_tables2 && incomplete_for_tables) temp = strdup("\t\t");
                                            else if(incomplete_for_tables) temp = strdup("\t");
                                            else temp = strdup("");

                                            if($5.uniontype == 0) asprintf(&$$,"%s\t\"%s\" : \"%s\"",temp,$3,$5.valor.s);
                                            if($5.uniontype == 1) asprintf(&$$,"%s\t\"%s\" : %d",temp,$3,$5.valor.n);
                                            if($5.uniontype == 2) asprintf(&$$,"%s\t\"%s\" : %s",temp,$3,$5.valor.s);
                                            if($5.uniontype == 3) asprintf(&$$,"%s\t\"%s\" : %f",temp,$3,$5.valor.f);

                                            free(temp);
                                        }
                                    }
Table : str                         {   
                                        
                                        int i;
                                        for(i = 0; i < strlen($1) && $1[i] != '.'; i++);
                                        if($1[i] == '.'){
                                            if(!strcmp(currentSubTable,"")) {
                                                dont_fix_it = 1;
                                            }
                                            char* oldSubTable = strdup(currentSubTable);

                                            currentSubTable = strdup($1+i+1);
                                            char* oldMainTable = strdup(mainTable);

                                            $1[i] = '\0';
                                            mainTable = strdup($1);

                                            if(strcmp(oldMainTable,mainTable) != 0 && !strcmp(oldMainTable,"") && strcmp(oldSubTable,"") != 0) incomplete_for_tables2 = 2;
                                            else incomplete_for_tables2 = 1;

                                            char* temp;
                                            if(incomplete_for_tables) temp = strdup("\t");
                                            else temp = strdup("");

                                            asprintf(&$$,"%s\"%s\" : {",temp,currentSubTable);
                                            free(temp);
                                            free(oldSubTable);
                                        }
                                        else{
                                            if(!strcmp(currentTable,"")) {
                                                dont_fix_it = 1;
                                            }
                                            incomplete_for_tables = 1;
                                            asprintf(&$$,"\"%s\" : {",$1);
                                            currentTable = strdup($1);
                                            incomplete_for_tables2 = 0;
                                            currentSubTable = strdup("");
                                        }
                                        currentKey = strdup("");
                                        /* Se for table com main key omitida */ 
                                        if(incomplete_for_tables2 == 2){
                                            asprintf(&$$,"\"%s\" : {\n\t\t\"%s\" : {",mainTable,currentSubTable);    
                                            incomplete_for_tables = 0;
                                            incomplete_for_tables2 = 1; /* reposição do valor usual */
                                        }
                                    }

Key   : str                         {$$ = $1;}
SubKey : str                        {$$ = $1;}
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