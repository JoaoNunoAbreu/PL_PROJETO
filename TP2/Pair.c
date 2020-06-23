#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "headers/Pair.h"

Pair mkPair()
{
    Pair p = (Pair)malloc(sizeof(struct pair));
    p->key = "";
    p->value = "";
    p->next = NULL;
    return p;
}

void unmkPair(Pair p)
{
    Pair tmp;
    free(p->key);
    free(p->value);
    tmp = p;
    p = p->next;
    free(tmp);
    if (p && p->next)
    {
        unmkPair(p->next);
    }
}

void setKey(Pair p, char *key)
{
    if (p)
        p->key = strdup(key);
}

void setValue(Pair p, char *v)
{
    if (p)
        p->value = strdup(v);
}

void addPair(Pair p, Pair nextpair)
{
    Pair *pt = &p;
    while (*pt != NULL && (*pt)->next != NULL)
    {
        pt = &((*pt)->next);
    }
    (*pt)->next = nextpair;
    nextpair->next = NULL;
}

//char *toString(Pair p)
