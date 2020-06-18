%{
int yyerror(char* s);
%}

%option noyywrap yylineno
%%
[ \n]           {}
#.*             {}

[0-9]+          return num;

.               {yyerror("Simbolo desconhecido");}
%%