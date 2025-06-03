%{
    #include <stdio.h>
    #include <string.h>
    #include "Bison.tab.h"
    #include <unordered_map> // hacer alfabeto A-T
    void showError(char* other);

    static YY_BUFFER_STATE prev             = NULL;

    void push_buffer_for_file(FILE *f);
    #define YY_USE_BUFFER_STACK

    

%}

PUNCT   [\.\,\;\:\?\!\¡\¿\"()\[\]\{\}\-\'\,]
%x ENCRIPTAR
%x ENCONTRADO 

%%

\n {
    

    return ENTER; 
}

"\x0D"       { /* nada: ignora carriage return */ }

"#"[A-Za-z0-9_]+".fasta",[0-9]+,[0-9]+  {
    /* yytext = "#File1.fasta,10,2" */
    yylval.filename = strdup(yytext);
    return ENTRADAHASH; 
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
        
        
        yylval.caracter = yytext[0]; 
        return PUNCTFASTA;
        }

[0-9]     {
            
            
            yylval.caracter = yytext[0];
            return ENTERO;
        }

{PUNCT}  {
    /* yytext es un solo carácter de puntuación */
    yylval.caracter = yytext[0];
    return PUNCT;
}



[A-Z] {
        yylval.caracter = yytext[0];
        return CHARMA;
    }

[a-z] {
        printf("%c",yytext[0]);
        yylval.caracter = yytext[0];
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
    if (!f) {
        fprintf(stderr, "Error: archivo nulo en push_buffer_for_file\n");
        exit(EXIT_FAILURE);
    }

    YY_BUFFER_STATE nuevo = yy_create_buffer(f, YY_BUF_SIZE);
    if (!nuevo) {
        fprintf(stderr, "Error: no se pudo crear buffer\n");
        exit(EXIT_FAILURE);
    }

    yypush_buffer_state(nuevo);  // ← Guarda el buffer actual y cambia al nuevo
}

