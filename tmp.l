%{
    #include <stdio.h>
    #include <string.h>
    #include <ctype.h>
    void strip_extra_spaces(char* str);
%}

%option noyywrap stack
%x R

%%

    int numberOfReplies;
    int hasReplies;

<R>\<\/ol\>                     { 
                                    yy_pop_state(); 
                                }
\<ol[^>]*\>                     { 
                                    hasReplies = 1;
                                    yy_push_state(R);
                                }
\<p\>\n*[^<]+                   {
                                    strip_extra_spaces(yytext+3);
                                    printf("commentText = %s\n",yytext+3);
                                    numberOfReplies = 0;
                                    hasReplies = 0;
                                }
\<\/li\>                        {
                                    printf("numberOfReplies Geral = %d\n",numberOfReplies);
                                    printf("hasReplies Geral = %d\n",hasReplies);
                                }
<R>\<p\>\n*[^<]+                {
                                    strip_extra_spaces(yytext+3);
                                    printf("reply = %s\n",yytext+3);
                                    numberOfReplies++;
                                }
<*>.|\n
%%

// Straight up copiada da net
void strip_extra_spaces(char* str) {
  int i, x;
  for(i=x=0; str[i]; ++i)
    if(!isspace(str[i]) || (i > 0 && !isspace(str[i-1])))
      str[x++] = str[i];
  str[x] = '\0';
} 

int main() {
    yylex();
    return 0;
}