%{
#include "headers/Array.h"
int yyerror(char* s);
Array keyvalue;
int bandeira = 0;
int enter_multi_lines = 0;
%}

%option noyywrap yylineno
%x key value entreAspas
WHITESPACES ([ \n\t\r]+)

%%


[=]                     {BEGIN value;return yytext[0];}
[\"\']                  {BEGIN entreAspas;initArray(&keyvalue,20);insertArray(&keyvalue,yytext[0]);}
[A-Za-z0-9_-]+          {
                            // Tirar o espaço
                            if(yytext[yyleng-1] == ' ')
                                yytext[yyleng-1] = '\0'; 

                            yylval.info.valor.s = strdup(yytext); 
                            yylval.info.uniontype = 0; 
                            return val;
                        }
[\n]                    {} /* Para ignorar espaços entre pares */

<value>{
[\n]                    {BEGIN 0; return yytext[0];}
(true|false)            {yylval.info.uniontype = 2; yylval.info.valor.s = strdup(yytext); return val;}
([\"\']|\"\"\")         {BEGIN entreAspas;initArray(&keyvalue,20);insertArray(&keyvalue,yytext[0]);}
}

<entreAspas>{
\"\"\"                  {
                            BEGIN value;
                            yylval.info.valor.s = strdup(getText(&keyvalue)+1); 
                            yylval.info.uniontype = 0;
                            return val;
                        }
\\\"                    {
                            if(aspaOrPelica(&keyvalue) == 0){
                                insertArray(&keyvalue,'\\');
                            }
                            insertArray(&keyvalue,'\"');
                        }
[\"]                    {
                            if(aspaOrPelica(&keyvalue) == 0){
                                BEGIN value;
                                yylval.info.valor.s = strdup(getText(&keyvalue)+1); 
                                yylval.info.uniontype = 0;
                                return val;
                            }
                            else if(aspaOrPelica(&keyvalue) == 1) {
                                insertArray(&keyvalue,'\\');
                                insertArray(&keyvalue,yytext[0]);
                            }
                        }
[\']                    {
                            if(aspaOrPelica(&keyvalue) == 1){
                                BEGIN value;
                                yylval.info.valor.s = strdup(getText(&keyvalue)+1); 
                                yylval.info.uniontype = 0;
                                return val;
                            }
                            else if(aspaOrPelica(&keyvalue) == 0) {insertArray(&keyvalue,yytext[0]);}
                        }
\\\n{WHITESPACES}       {}         
\n                      {
                            if(enter_multi_lines){
                                insertArray(&keyvalue,'\\');
                                insertArray(&keyvalue,'n');
                            }
                            else enter_multi_lines = 1;
                        }
.                       {
                            insertArray(&keyvalue,yytext[0]);
                        }
}



<*>{
#.*             {}
[ ]             {}
[\.]            {return yytext[0];} // Símbolos terminais
[0-9]+              {yylval.info.uniontype = 1; yylval.info.valor.n = atoi(yytext); return val;}
.               {yyerror("Simbolo desconhecido");}
}

%%