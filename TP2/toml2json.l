%{
#include "headers/Array.h"
int yyerror(char* s);
Array keyvalue;
int inside_3_quotes = 0;
%}

%option noyywrap yylineno
%x key value entreAspas
WHITESPACES ([ \n\t\r]+)
OffsetDateTime (([0-9]+)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])([Tt]([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9]|60)(\.[0-9]+)?(([Zz])|([\+|\-]([01][0-9]|2[0-3]):[0-5][0-9]))?)?)
LocalTime (([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9]|60)(\.[0-9]+)?)
%%


[=]                         {BEGIN value;return yytext[0];}
[\"\']                      {BEGIN entreAspas;initArray(&keyvalue,20);insertArray(&keyvalue,yytext[0]);}
[A-Za-z0-9_-]+              {
                                
                                // Tirar o espaço
                                if(yytext[yyleng-1] == ' ')
                                    yytext[yyleng-1] = '\0'; 

                                yylval.string = strdup(yytext); 
                                return str;
                            }
\[[.A-Za-z0-9_-]+\]         {   /* ------------------- Tables ------------------- */
                                yytext[yyleng-1] = '\0'; 
                                yylval.string = strdup(yytext+1); 
                                return str;
                            }
[\n]                        {} /* Para ignorar espaços entre pares */

<value>{
[\n]                                        {BEGIN 0; return yytext[0];}
(true|false)                                {yylval.info.uniontype = 2; yylval.info.valor.s = strdup(yytext); return val;}
[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$     {yylval.info.uniontype = 3; yylval.info.valor.f = atof(yytext); return val;}
[-+]?[0-9]+                                 {yylval.info.uniontype = 1; yylval.info.valor.n = atoi(yytext); return val;}
{OffsetDateTime}|{LocalTime}                {yylval.info.uniontype = 0; yylval.info.valor.s = strdup(yytext); return val;}
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
\\[^tnr]                    {
                                insertArray(&keyvalue,'\\');
                                insertArray(&keyvalue,'\\');
                            }
.                           {   
                                insertArray(&keyvalue,yytext[0]);
                            }
}



<*>{
#.*             {}
[ ]             {}
\.              {return yytext[0];} // Símbolos terminais
.               {yyerror("Simbolo desconhecido");}
}

%%