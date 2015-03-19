%{
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <dirent.h>

#define TABLESIZE 32
#define YYSTYPE char *

char *tempkey = 0;

struct keyvalue{
	char* key;
	char* value;
};

struct keyvalue kvtable[TABLESIZE];

void initTable() {
	int count = 0;
	while(count != TABLESIZE){
		kvtable[count].key = 0;
		kvtable[count].value = 0;
		++count;
	}
}

int insertTable(char *key, char *value) {
	int start = 0;
	while(kvtable[start].key != 0){
		if(strcmp((kvtable[start]).key, key) == 0) {
			break;
		}
		++start;
		if(start == TABLESIZE) {
			return -1; // Returns an error if table is full
		}
	}
	kvtable[start].key = key;
	kvtable[start].value = value;
	return 0;
}

void printTable() {
	int count = 0;
	while(count != TABLESIZE) {
		if(kvtable[count].key != 0) {
			printf("\t%s\t%s\n",kvtable[count].key, kvtable[count].value);
		}
		++count;
	}
	printf("\n");
}

char *valueGivenKey(char* key){
	char* value = 0;
	int count = 0;
	while(count != TABLESIZE){
		if(kvtable[count].key != 0){
			if(strcmp(kvtable[count].key, key) == 0) {
				return kvtable[count].value;
			}
		}
		++count;
	}
	return value;
}

void yyerror(const char *str){
	fprintf(stderr, "error: %s\n", str);
}

int yywrap(){
	return 1;
}

main(){
	initTable();
	int running = 1;
	while(running == 1){
		printf("\tShell\n");
		yyparse();
	}
}

%}

%token WORD ENDOFLINE

%%
commands: | commands command;

command: single_word | multiple_word ENDOFLINE;

single_word: WORD ENDOFLINE{
				char* key = $1;
				char* value = valueGivenKey($1);
				if(value != 0) {
					key = value;
				}
				if(strcmp(key,"cd") == 0) {
					goHome();
				}
				else if(strcmp(key,"ls") == 0) {
					lookInside();
				}
				else if(strcmp(key,"alias") == 0) {
					printTable();
				}
				else {
					printf("\tInvalid command\n");
				}
			};
			
multiple_word: WORD{
					$$ = $1;
					char* value = valueGivenKey($1);
					if(value != 0) {
						$$ = value;
					}
					printf("\tSOON\n");
				}
				| multiple_word WORD{
					if(strcmp($1, "cd") == 0) {
						goToDir($2);
					}
					else if(strcmp($1, "alias") == 0) {
						$$ = $1;
						if(tempkey == 0){
							tempkey = $2;
						}
						else{
							insertTable(tempkey, $2);
							tempkey = 0;
						}
					}
					else{
						printf("\tVERY SOON\n");
					}
				};
%%

void lookInside() {
	char *cwd = (char*)get_current_dir_name();
	DIR* currentDir = opendir(cwd);
	struct dirent *folders = readdir(currentDir);
	while(folders != NULL){
		printf("\t%s", folders->d_name);
		folders = readdir(currentDir);
	}
	rewinddir(currentDir);
	printf("\n");

}

void goHome() {
	int error = chdir((char*)getenv("HOME"));
	if(error == 0){
		printf("\tChanged directory to HOME\n");
	}
	else{
		printf("\tError\n");
	}	
}

void goToDir(char *dest) {
	char *path = dest;
	int error = chdir(path);
	char *cwd = (char*)get_current_dir_name();
	if(error == 0){
		printf("\tChanged directory to %s\n", cwd);
	}
	else{
		printf("\tError: can't find %s\n", path);
	}
}
