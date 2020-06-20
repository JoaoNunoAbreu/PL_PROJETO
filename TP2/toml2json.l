%{
int yyerror(char* s);
%}

%option noyywrap yylineno
%x entreAspas
%%
#.*             {}
[\ ]            {}

[=\n]           return yytext[0]; // Símbolos terminais
[0-9]+          {yylval.n = atoi(yytext)    ; return text;}
[a-zA-Z]+       {yylval.s = strdup(yytext)  ; return text;}
["][^"\n]*["]   {yytext[yyleng-1] = '\0'; yylval.s = strdup(yytext+1)  ; return text;}

.               {yyerror("Simbolo desconhecido");}
%%