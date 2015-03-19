%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
%}
%%
[a-zA-Z\-\.0-9/]+	{yylval = strdup(yytext); return WORD;}
\n					{return ENDOFLINE;}
%%
