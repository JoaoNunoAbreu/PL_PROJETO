typedef struct comment
{
    char *id;
    char *user;
    char *date;
    char *timestamp;
    char *commentText;
    int likes;
    int hasReplies;
    int numberOfReplies;
    struct comment *next;
} * Comment;

Comment mkComment();
void unmkComment(Comment c);
void addComment(Comment comment, Comment reply);
void printfComment(Comment c, int nr_comment, int nr_comment_total);
void printfReply(Comment c, int f);
void setId(Comment c, char *id);
void setUser(Comment c, char *user);
void setDate(Comment c, char *timestamp);
void setTime(Comment c, char *timestamp);
void setCommentText(Comment c, char *commentText);
void setLikes(Comment c, int likes);
void setHasReplies(Comment c, int hasReplies);
void setNumberOfReplies(Comment c, int numberOfReplies);