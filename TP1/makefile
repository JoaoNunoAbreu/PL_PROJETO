publico2NetLang: publico2NetLang.l
	flex publico2NetLang.l
	cc -o publico2NetLang lex.yy.c comment.c Array.c
	./publico2NetLang < Publico_extraction_portuguese_comments_4.html > result.json

install: publico2NetLang
	cp publico2NetLang /usr/local/bin

clean:
	rm -f lex.yy.c publico2NetLang result.json