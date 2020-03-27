%option noyywrap yylineno stack
%x Comment
%{
    #include <ctype.h>
    void strip_extra_spaces(char* str);
%}

%%
    int nr_likes = 0; // Onde é que se contam likes ?????
    char* date;
    char* timestamp;

\<li[^>]*                                       {   // Início de cada parágrafo
                                                    printf("\n      {\n");
                                                }
\<\/li>                                         {   // Fim de cada parágrafo
                                                    printf("      },");
                                                }
rel=\"nofollow\"\>[^<]+                         {   // USER
                                                    yytext[yyleng-1] = '\0'; // Para tirar o último espaço
                                                    printf("        \"user\": \"%s\",\n",yytext+15);
                                                }
\<a[ ]href=\"\/utilizador\/perfil\/[^"]+        {   // ID
                                                    printf("        \"id\": \"%s\",\n",yytext+28);
                                                }
\<a[ ]class=\"comment__permalink\"\>[^<]+       {   // DATE AND TIMESTAMP
                                                    char* token = strtok(yytext+30, " ");       
                                                    date = strdup(token);
                                                    token = strtok(NULL, "-"); 
                                                    timestamp = strdup(token);
                                                    printf("        \"date\": \"%s\",\n        \"timestamp\": \"%s\",\n", date,timestamp);
                                                }
\<p\>[^<]+                                      {   // MENSAGEM
                                                    strip_extra_spaces(yytext+3);
                                                    printf("        \"commentText\": \"%s\"\n",yytext+3);
                                                }

\<ol[ ]class\=\"comments__list\"\>              {   // respostas
                                                    printf("        \"replies\": [");
                                                }
\<\/ol\>                                        {   // Fim das respostas
                                                    printf("]\n");
                                                }
.|\n                                            {}

%%

// Straight up copiada da net
void strip_extra_spaces(char* str) {
    int i, x;
    for(i=x=0; str[i]; ++i)
    if(!isspace(str[i]) || (i > 0 && !isspace(str[i-1])))
        if(str[i] != '\r')
            str[x++] = str[i];
    str[x] = '\0';
}  

int main(int argc, char* argv[]){
    printf("{\n   \"commentThread\": [");
    yylex();
    printf("}");
    return 0;
}