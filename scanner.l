%{
    #include <stdio.h>
    #include <string.h>
    #include "Bison.tab.h"
    #include <unordered_map> // hacer alfabeto A-T
    void showError(char* other);

    static YY_BUFFER_STATE prev             = NULL;

    void push_buffer_for_file(FILE *f);


%}

PUNCT   [\.\,\;\:\?\!\¡\¿\"()\[\]\{\}\-\'\,]

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
            
            
            yylval.num = atoi(yytext);
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

    prev = YY_CURRENT_BUFFER; 
    YY_BUFFER_STATE newb = yy_create_buffer(f, YY_BUF_SIZE);
    yy_switch_to_buffer(newb);
}

