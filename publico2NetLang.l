%option noyywrap yylineno

%{
    #include <ctype.h>
    void strip_extra_spaces(char* str);
%}

%%

    int n = 0;
    char* date;
    char* timestamp;

rel=\"nofollow\"\>[^<]+                         {   // USER
                                                    yytext[strlen(yytext-1)] = '\0'; // Para tirar o último espaço
                                                    printf("user = %s\n",yytext+15);
                                                }
\<a[ ]href=\"\/utilizador\/perfil\/[^"]+        {   // ID
                                                    printf("id = %s\n",yytext+28);
                                                }
\<a[ ]class=\"comment__permalink\"\>[^<]+       {   // DATE AND TIMESTAMP
                                                    char* token = strtok(yytext+30, " ");
                                                    date = strdup(token);
                                                    token = strtok(NULL, "-"); 
                                                    timestamp = strdup(token);
                                                    printf("date = %s\ntimestamp = %s\n", date,timestamp);
                                                }
\<p\>\n*[^<]+                                   {   // COMMENT TEXT
                                                    strip_extra_spaces(yytext+3);
                                                    printf("commentText = %s\n",yytext+3);
                                                }
.|\n                                            {}
<<EOF>>                                         {printf("n = %d", n); return 0;}

%%

void strip_extra_spaces(char* str) {
  int i, x;
  for(i=x=0; str[i]; ++i)
    if(!isspace(str[i]) || (i > 0 && !isspace(str[i-1])))
      str[x++] = str[i];
  str[x] = '\0';
} 

int main(int argc, char* argv[]){
    yylex();
    return 0;
}