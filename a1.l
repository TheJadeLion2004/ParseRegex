%{
	#include <stdlib.h>
	#include "y.tab.h"
	void yyerror(char *);
	extern char mytext[];
%}

%%

[ab]		{ return *yytext;}

[()|*]		{ return *yytext; }

[ \n\t]	{ }

.	{yyerror("unknown character");}
%%

int yywrap(void) {
    return 1;
}



