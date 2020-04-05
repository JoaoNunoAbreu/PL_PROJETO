#include <stdio.h>
#include <stdlib.h>
#include "headers/Array.h"

void initArray(Array *a, int initialSize)
{
  a->array = (char *)malloc(initialSize * sizeof(char));
  a->used = 0;
  a->size = initialSize;
}

void insertArray(Array *a, char element)
{
  if (a->used == a->size)
  {
    a->size *= 2;
    a->array = (char *)realloc(a->array, a->size * sizeof(char));
  }
  a->array[a->used++] = element;
}

void closeArray(Array *a)
{
  a->array[a->used] = '\0';
}

char *getText(Array *a)
{
  if (a)
    return a->array;
  else
    return NULL;
}

void freeArray(Array *a)
{
  free(a->array);
  a->array = NULL;
  a->used = a->size = 0;
}
