E=toml2json
I=inputs/input3

$E: $E.y $E.l
	yacc $E.y
	flex $E.l
	cc y.tab.c -o $E Array.c

#fazer make teste em vez de executar só o programa
#faz com que mostre o output do flex para cada linha
teste: $E $I
	./$E < $I| paste -d : $I - | column -t -s :

clean:
	rm -f y.tab.c lex.yy.c $E

install: $a
	cp $a /usr/local/bin/