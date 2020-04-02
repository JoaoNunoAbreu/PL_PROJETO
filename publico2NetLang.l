%option noyywrap yylineno stack
%x P R T
%{
    #include <ctype.h>
    #include "comment.h"
    void strip_extra_spaces(char* str);
%}

%%
    int nr_likes = 0;
    char* date;
    char* timestamp;
    char* comment = malloc(sizeof(char*));
    Comment com;
    Comment piece;

\<li                                                {   
                                                        piece = mkComment();
                                                        com = piece;
                                                        yy_push_state(P);
                                                    }
<P>\<ol                                             {     
                                                        yy_push_state(R);
                                                    }
<R>\<\/ol>                                          {   
                                                        yy_pop_state();
                                                    }
<R>\<li                                             {
                                                        piece = mkComment();
                                                    }  
<R>\<\/li>                                          {
                                                        addComment(com,piece);
                                                    }        
<P>\<\/li>                                          {  
                                                        printfComment(com);
                                                        unmkComment(com);
                                                        yy_pop_state();
                                                    }
<T>{
[ ][ ]+                                             {}
[\n\t\r]+                                           {}
\<\/p\>                                             {setCommentText(piece,comment);yy_pop_state();}
.                                                   {printf("entrou aqui");strcat(comment,yytext);}
}

<*>data\-comment\-id=\"[^"]+                        {   // ID
                                                        setId(piece,yytext+17);
                                                    }
<*>rel=\"nofollow\"\>[^<]+                          {   // USER
                                                        yytext[yyleng-1] = '\0'; // Para tirar o último espaço
                                                        setUser(piece,yytext+15);
                                                    }
<*>\<h5[ ]class=\"comment__author\"\>[^<]+          {   // Quando a conta é desativada
                                                        strip_extra_spaces(yytext+28);
                                                        setUser(piece,yytext+28);
                                                    }                                                    
<*>\<a[ ]class=\"comment__permalink\"\>[^<]+        {   // DATE AND TIMESTAMP
                                                        char* token = strtok(yytext+30, " ");       
                                                        setDate(piece,strdup(token));
                                                        token = strtok(NULL, "-"); 
                                                        setTime(piece,strdup(token));
                                                    }
<*>\<p\>[^<]+                                       {   // MENSAGEM
                                                        comment[0] = '\0';
                                                        yy_push_state(T);
                                                    }
<*>.|\n                                             {}

%%

void strip_extra_spaces(char* str) {
    int i, x;
    for(i=x=0; str[i]; ++i)
    if(!isspace(str[i]) || (i > 0 && !isspace(str[i-1])))
        if(str[i] != '\r' && str[i] != '\n')
            str[x++] = str[i];
    str[x] = '\0';
}  

int main(int argc, char* argv[]){
    printf("{\n   \"commentThread\": [");
    yylex();
    printf("\n    ]\n}");
    return 0;
}