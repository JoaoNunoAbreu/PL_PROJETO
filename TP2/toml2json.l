%{
#include "headers/Array.h"
int yyerror(char* s);
Array keyvalue;
int inside_3_quotes = 0;
%}

%option noyywrap yylineno
%x key value entreAspas
WHITESPACES ([ \n\t\r]+)

%%


[=]                         {BEGIN value;return yytext[0];}
[\"\']                      {BEGIN entreAspas;initArray(&keyvalue,20);insertArray(&keyvalue,yytext[0]);}
[0-9]+                      {yylval.info.uniontype = 1; yylval.info.valor.n = atoi(yytext); return val;}
[A-Za-z0-9_-]+              {
                                // Tirar o espaço
                                if(yytext[yyleng-1] == ' ')
                                    yytext[yyleng-1] = '\0'; 

                                yylval.info.valor.s = strdup(yytext); 
                                yylval.info.uniontype = 0; 
                                return val;
                            }
[\n]                        {} /* Para ignorar espaços entre pares */

<value>{
[\n]                        {BEGIN 0; return yytext[0];}
(true|false)                {yylval.info.uniontype = 2; yylval.info.valor.s = strdup(yytext); return val;}
[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$ {yylval.info.uniontype = 3; yylval.info.valor.f = atof(yytext); return val;}
[-+]?[0-9]+                      {yylval.info.uniontype = 1; yylval.info.valor.n = atoi(yytext); return val;}
([\"\']|\"\"\"|\"\"\"\n|\'\'\'|\'\'\'\n)    {BEGIN entreAspas;initArray(&keyvalue,20);insertArray(&keyvalue,yytext[0]); if(strcmp(yytext,"\"") != 0 && strcmp(yytext,"'") != 0) {inside_3_quotes = 1;}; }
}

<entreAspas>{
(\"\"\"|\'\'\')/[\ \n#]     {   /* Representa o fim de multi line strings */
                                BEGIN value;
                                yylval.info.valor.s = strdup(getText(&keyvalue)+1); 
                                yylval.info.uniontype = 0;
                                inside_3_quotes = 0;
                                return val;
                            }
\\                          {
                                insertArray(&keyvalue,'\\');
                                insertArray(&keyvalue,'\\');
                            }
\\\"                        {
                                if(aspaOrPelica(&keyvalue) == 0){
                                    insertArray(&keyvalue,'\\');
                                }
                                insertArray(&keyvalue,'\"');
                            }
[\"]                        {   
                                if(aspaOrPelica(&keyvalue) == 0 && !inside_3_quotes){
                                    BEGIN value;
                                    yylval.info.valor.s = strdup(getText(&keyvalue)+1); 
                                    yylval.info.uniontype = 0;
                                    return val;
                                }
                                else if(aspaOrPelica(&keyvalue) == 1 || inside_3_quotes) {
                                    insertArray(&keyvalue,'\\');
                                    insertArray(&keyvalue,yytext[0]);
                                }
                            }
[\']                        {
                                if(aspaOrPelica(&keyvalue) == 1 && inside_3_quotes){

                                }
                                else if(aspaOrPelica(&keyvalue) == 1 && !inside_3_quotes){
                                    BEGIN value;
                                    yylval.info.valor.s = strdup(getText(&keyvalue)+1); 
                                    yylval.info.uniontype = 0;
                                    return val;
                                }
                                else if(aspaOrPelica(&keyvalue) == 0 || inside_3_quotes) {
                                    insertArray(&keyvalue,yytext[0]);
                                }
                            }
\\\n{WHITESPACES}           {}         
\n                          {
                                insertArray(&keyvalue,'\\');
                                insertArray(&keyvalue,'n');
                            }
.                           {
                                insertArray(&keyvalue,yytext[0]);
                            }
}



<*>{
#.*             {}
[ ]             {}
[\.]            {return yytext[0];} // Símbolos terminais
.               {yyerror("Simbolo desconhecido");}
}

%%