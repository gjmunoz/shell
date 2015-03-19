LEX = lex
YACC = yacc -d

CC = cc

shell: y.tab.o lex.yy.o
		$(CC) -o shelldemo y.tab.o lex.yy.o -ll -lm
		
lex.yy.o: lex.yy.c y.tab.h
lex.yy.o y.tab.o: shell_lex.txt

y.tab.c y.tab.h: shell_yacc.txt
		$(YACC) -v shell_yacc.txt
		
lex.yy.c: shell_lex.txt
		$(LEX) shell_lex.txt
		
clean:
	-rm -f *.o lex.yy.c *.tab.* shelldemo *.output
