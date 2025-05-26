%{
    #include <stdio.h>
    #include <string.h>
    #include "Bison.tab.h"
    #include <unordered_map> // hacer alfabeto A-T
    void showError(char* other);

    static YY_BUFFER_STATE prev             = NULL;

    void push_buffer_for_file(FILE *f);

    unsigned int intentosMax = 0;
    unsigned int configDesfase = 0;
    

%}

PUNCT   [\.\,\;\:\?\!\¡\¿\"()\[\]\{\}\-\'\,]


%%

\n {
    
    return ENTER; 
}

"\x0D"       { /* nada: ignora carriage return */ }

"#"[A-Za-z0-9_]+".fasta",[0-9]+,[0-9]+  {
    /* yytext = "#File1.fasta,10,2" */
    char fname[256];
    int n1, n2;
    if (sscanf(yytext + 1, "%255[^,],%d,%d", fname, &configDesfase, &configDesfase) == 3) {
        printf("numero1: %d\n", configDesfase);
        printf("numero2: %d\n", configDesfase);
        printf("File Name: %s\n", fname);
        yylval.filename = fname;
        return ENTRADAHASH;
    }
}

">lcl|" {
    
    return FLECHA;
}

" " {
    return SPACE;
}


"#" {
        return HASH;
    }

[:_.]   {
        return PUNCTFASTA;
        }

[0-9]     {
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

void push_buffer_for_file(FILE *f) {

    prev = YY_CURRENT_BUFFER; 
    YY_BUFFER_STATE newb = yy_create_buffer(f, YY_BUF_SIZE);
    yy_switch_to_buffer(newb);
}

