%option noyywrap yylineno stack
%x R
%{
    #include <ctype.h>
    int n = 0;
    void strip_extra_spaces(char* str);
%}

%%
    int nr_likes = 0; // Onde é que se contam likes ?????
    char* date;
    char* timestamp;
    int numberOfReplies = 0;

rel=\"nofollow\"\>[^<]+                         {   // USER
                                                    yytext[yyleng-1] = '\0'; // Para tirar o último espaço
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
<R>\<\/ol\>                                     { 
                                                    yytext[4]='\0'; 
                                                    printf("](%s)",yytext+2);
                                                    printf("numberOfReplies = %d",numberOfReplies);
                                                    yy_pop_state(); 
                                                }
\<ol[^>]*\>                                     { 
                                                    yytext[3]='\0'; 
                                                    printf("\nReply (%s)[",yytext+1);
                                                    yy_push_state(R);
                                                }
\<p\>\n*[^<]+                                   {
                                                    strip_extra_spaces(yytext+3);
                                                    printf("commentText = %s\n",yytext+3);
                                                }
<R>\<p\>\n*[^<]+                                {
                                                    strip_extra_spaces(yytext+3);
                                                    printf("reply = %s\n",yytext+3);
                                                    numberOfReplies++;
                                                }
<*>.|\n                                         {}

%%

// Straight up copiada da net
void strip_extra_spaces(char* str) {
  int i, x;
  for(i=x=0; str[i]; ++i)
    if(!isspace(str[i]) || (i > 0 && !isspace(str[i-1])))
      str[x++] = str[i];
  str[x] = '\0';
} 

int main(int argc, char* argv[]){
    yylex();
    printf("n = %d", n);
    return 0;
}