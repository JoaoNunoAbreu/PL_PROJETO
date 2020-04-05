#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "headers/Comment.h"

Comment mkComment()
{

    Comment c = (Comment)malloc(sizeof(struct comment));
    c->likes = 0;
    c->hasReplies = 0;
    c->numberOfReplies = 0;
    c->next = NULL;
    return c;
}

void unmkComment(Comment c)
{

    Comment tmp;
    free(c->id);
    free(c->user);
    free(c->date);
    free(c->timestamp);
    free(c->commentText);
    tmp = c;
    c = c->next;
    free(tmp);
    if (c && c->next)
    {
        unmkComment(c->next);
    }
}

void setId(Comment c, char *id)
{
    if (c)
        c->id = strdup(id);
}

void setUser(Comment c, char *user)
{
    if (c)
        c->user = strdup(user);
}

void setDate(Comment c, char *date)
{
    if (c)
        c->date = strdup(date);
}

void setTime(Comment c, char *timestamp)
{
    if (c)
        c->timestamp = strdup(timestamp);
}

void setCommentText(Comment c, char *commentText)
{
    if (c)
        c->commentText = strdup(commentText);
}

void setLikes(Comment c, int likes)
{
    if (c)
        c->likes = likes;
}

void setHasReplies(Comment c, int hasReplies)
{
    if (c)
        c->hasReplies = hasReplies;
}

void setNumberOfReplies(Comment c, int numberOfReplies)
{
    if (c)
        c->numberOfReplies = numberOfReplies;
}

void addComment(Comment comment, Comment reply)
{

    Comment *pt = &comment;
    (*pt)->numberOfReplies += 1;
    (*pt)->hasReplies = 1;
    while (*pt != NULL && (*pt)->next != NULL)
    {
        pt = &((*pt)->next);
    }
    (*pt)->next = reply;
    reply->next = NULL;
}

void printfReply(Comment c, int f)
{

    printf("\n          {\n");
    printf("            \"id\": \"%s\",\n", c->id);
    printf("            \"user\": \"%s\",\n", c->user);
    printf("            \"date\": \"%s\",\n            \"timestamp\": \"%s\",\n", c->date, c->timestamp);
    printf("            \"commentText\": \"%s\",\n", c->commentText);
    printf("            \"likes\": \"%d\",\n", c->likes);
    printf("            \"hasReplies\": \"%d\",\n", c->hasReplies);
    printf("            \"numberOfReplies\": \"%d\",\n", c->numberOfReplies);
    printf("            \"replies\": []");
    if (f == 0) // Para não colocar vírgula na última reply
        printf("\n          }");
    else
        printf("\n          },");
}

void printfComment(Comment c, int nr_comment, int nr_comment_total)
{

    int i = 0;
    Comment *pt = &c;
    printf("\n      {\n");
    printf("        \"id\": \"%s\",\n", c->id);
    printf("        \"user\": \"%s\",\n", c->user);
    printf("        \"date\": \"%s\",\n        \"timestamp\": \"%s\",\n", c->date, c->timestamp);
    printf("        \"commentText\": \"%s\",\n", c->commentText);
    printf("        \"likes\": \"%d\",\n", c->likes);
    printf("        \"hasReplies\": \"%d\",\n", c->hasReplies);
    printf("        \"numberOfReplies\": \"%d\",\n", c->numberOfReplies);
    printf("        \"replies\": [");
    while (*pt && (*pt)->next)
    {
        i++;
        printfReply((*pt)->next, c->numberOfReplies - i);
        pt = &((*pt)->next);
    }
    if (c->hasReplies)
        printf("\n        ]");
    else
        printf("]");
    if (nr_comment != nr_comment_total)
        printf("\n      },");
    else
        printf("\n      }");
}