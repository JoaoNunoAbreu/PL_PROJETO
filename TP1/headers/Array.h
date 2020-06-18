typedef struct {
  char *array;
  int used;
  int size;
} Array;

void initArray(Array *a, int initialSize);
void insertArray(Array *a, char element);
void closeArray(Array *a);
char* getText(Array *a);
void freeArray(Array *a);
