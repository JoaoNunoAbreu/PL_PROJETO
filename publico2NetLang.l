%option noyywrap yylineno stack
%x P R T
%{
    #include <ctype.h>
    #include "comment.h"
    #include "Array.h"
%}

%%
    int nr_likes = 0;
    int nr_comment = 0;
    int nr_comment_total = 0;
    char* date;
    char* timestamp;
    Array comment;
    Comment com;
    Comment piece;

\[\<h3.+c                                           {   // Início de Comment Thread e para saber o número total de comentários e respetivas respostas
                                                        printf("{\n   \"commentThread\": [");
                                                        yytext[yyleng-2] = '\0';
                                                        nr_comment_total = atoi(yytext+97);
                                                    }
\<li                                                {   // Início de um comentário principal
                                                        piece = mkComment();
                                                        com = piece;
                                                        yy_push_state(P);
                                                        nr_comment++;
                                                    }
<P>\<ol                                             {   // Início da lista replies
                                                        yy_push_state(R);
                                                    }
<R>\<\/ol>                                          {   // Fim da lista de replies
                                                        yy_pop_state();
                                                    }
<R>\<li                                             {   // Início de uma reply
                                                        piece = mkComment();
                                                        nr_comment++;
                                                    }  
<R>\<\/li>                                          {   // Fim de uma reply
                                                        addComment(com,piece);
                                                    }        
<P>\<\/li>                                          {   // Fim de um comentário principal
                                                        printfComment(com,nr_comment,nr_comment_total);
                                                        unmkComment(com);
                                                        yy_pop_state();
                                                        
                                                    }

<T>{
[ ][ ][ ]+                                          {   } // Limpa espaços extra    
[ ][ ]                                              {   // 2 comentário = 1 comentário
                                                        insertArray(&comment,' ');
                                                        //strcat(comment," ");
                                                    }
[\n\t\r]+                                           {   } // Limpa whitespaces
\"                                                  {   // Aspas têm de ser protegidas
                                                        insertArray(&comment,'\\');
                                                        insertArray(&comment,'\"');
                                                    }
\<\/p\>                                             { 
                                                        closeArray(&comment);
                                                        setCommentText(piece,getText(&comment));
                                                        freeArray(&comment);
                                                        yy_pop_state();
                                                    }
.                                                   {   
                                                        insertArray(&comment,yytext[0]);
                                                    }
}

<*>data\-comment\-id=\"[^"]+                        {   // ID
                                                        setId(piece,yytext+17);
                                                    }
<*>rel=\"nofollow\"\>[^<]+                          {   // USER
                                                        yytext[yyleng-1] = '\0'; // Para tirar o último espaço
                                                        setUser(piece,yytext+15);
                                                    }
<*>\<h5[ ]class=\"comment__author\"\>[^<]+          {   // Quando a conta é desativada
                                                        setUser(piece,"Conta desactivada por violação das regras de conduta");
                                                    }                                                    
<*>\<a[ ]class=\"comment__permalink\"\>[^<]+        {   // DATE AND TIMESTAMP
                                                        char* token = strtok(yytext+30, " ");       
                                                        setDate(piece,strdup(token));
                                                        token = strtok(NULL, "-"); 
                                                        setTime(piece,strdup(token));
                                                    }
<*>\<p\>                                            {   // MENSAGEM
                                                        initArray(&comment,15);
                                                        yy_push_state(T);
                                                    }
\<\/ol>                                             {   // Fim de Comment Thread
                                                        printf("\n    ]\n}"); 
                                                    }
<*>.|\n                                             {}

%%

int main(int argc, char* argv[]){
    yylex();
    return 0;
}