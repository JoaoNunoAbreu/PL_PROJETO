publico2NetLang: publico2NetLang.l
	flex publico2NetLang.l
	cc -o publico2NetLang lex.yy.c comment.c

install: publico2NetLang
	cp publico2NetLang /usr/local/bin

clean:
	rm -f lex.yy.c publico2NetLang