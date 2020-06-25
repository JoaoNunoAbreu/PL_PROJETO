%{
#include "headers/Array.h"
int yyerror(char* s);
Array keyvalue;
int bandeira = 0;
%}

%option noyywrap yylineno
%x key value entreAspas

%%

[=]             {BEGIN value;return yytext[0];}
[\"\']          {BEGIN entreAspas;initArray(&keyvalue,20);insertArray(&keyvalue,yytext[0]);}
[A-Za-z0-9_-]+  {
                    // Tirar o espaço
                    if(yytext[yyleng-1] == ' ')
                        yytext[yyleng-1] = '\0'; 
                    
                    yylval.info.valor.s = strdup(yytext); 
                    yylval.info.uniontype = 0; 
                    return val;
                }

<value>{
[\n]                {BEGIN 0; return yytext[0];}
(true|false)        {yylval.info.uniontype = 2; yylval.info.valor.s = strdup(yytext); return val;}
([\"\']|\"\"\")     {BEGIN entreAspas;initArray(&keyvalue,20);insertArray(&keyvalue,yytext[0]);}
}

<entreAspas>{
\"\"\"          {
                    BEGIN value;
                    yylval.info.valor.s = strdup(getText(&keyvalue)+1); 
                    yylval.info.uniontype = 0;
                    return val;
                }
\\\"            {
                    if(aspaOrPelica(&keyvalue) == 0){
                        insertArray(&keyvalue,'\\');
                    }
                    insertArray(&keyvalue,'\"');
                }
[\"]            {
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
[\']            {
                    if(aspaOrPelica(&keyvalue) == 1){
                        BEGIN value;
                        yylval.info.valor.s = strdup(getText(&keyvalue)+1); 
                        yylval.info.uniontype = 0;
                        return val;
                    }
                    else if(aspaOrPelica(&keyvalue) == 0) {insertArray(&keyvalue,yytext[0]);}
                }
[^"]{3}\n       {   /* Apenas queremos ter \n's nas strings que não têm 3 aspas antes (Multi-line basic strings) */
                    insertArray(&keyvalue,'\\');
                    insertArray(&keyvalue,'n');
                }
\n              {}
.               {
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