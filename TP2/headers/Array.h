typedef struct
{
  char *array;
  int used;
  int size;
} Array;

void initArray(Array *a, int initialSize);
void insertArray(Array *a, char element);
void closeArray(Array *a);
char *getText(Array *a);
void freeArray(Array *a);
int aspaOrPelica(Array *a); // 0 se for aspa, 1 se for pelica, -1 se nenhum
