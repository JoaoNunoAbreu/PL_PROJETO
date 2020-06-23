typedef struct pair
{
    char *key;
    char *value;
    struct pair *next;
} * Pair;

Pair mkPair();
void unmkPair(Pair p);
void setKey(Pair p, char *key);
void setValue(Pair p, char *v);
void addPair(Pair p, Pair nextpair);
//void toString(Pair p);