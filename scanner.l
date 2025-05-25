%{
    #include <stdio.h>
    #include <string.h>
    #include "Bison.tab.h"
    void showError(char* other);

    
%}

PUNCT   [\.\,\;\:\?\!\¡\¿\"()\[\]\{\}\-\'\,]


%%

\n {
    printf("Salto de linea");
    return ENTER; 
}

"\x0D"       { /* nada: ignora carriage return */ }

"#"[A-Za-z0-9_]+".fasta",[0-9]+,[0-9]+  {
    /* yytext = "#File1.fasta,10,2" */
    char fname[256];
    int n1, n2;
    if (sscanf(yytext + 1, "%255[^,],%d,%d", fname, &n1, &n2) == 3) {
        printf("numero1: %d\n", n1);
        printf("numero2: %d\n", n2);
        printf("File Name: %s\n", fname);
    
        return ENTRADAHASH;
    }
}

">lcl|" {
    printf("FLECHA ");
    return FLECHA;
}

" " {
    printf("SPACE  ");
    return SPACE;
}


"#" {
        return HASH;
    }

[:_.]   {
        printf("PUNCTDOS ");
        return PUNCTFASTA;
        }

[0-9]     {
            printf("Entero ");
            yylval.num = atoi(yytext);
            return ENTERO;
        }

{PUNCT}  {
    /* yytext es un solo carácter de puntuación */
    yylval.palabra = strdup(yytext);
    return PUNCT;
}



[A-Z] {
    
    yylval.palabra = strdup(yytext);
    return CHARMA;
    }

[a-z] {
    printf("CHARMI ");
    yylval.palabra = strdup(yytext);
    return CHARMI;
    }


. {
    unsigned char c = yytext[0];
    fprintf(stderr,
        "Carácter inesperado: '%s' (ASCII %d)\n",
        yytext, c
    );
    return ERROR;
}




%%

int yywrap(void) { return 1; }