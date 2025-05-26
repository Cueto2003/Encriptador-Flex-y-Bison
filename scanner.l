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
    unsigned int intentosUtilizados = 0;
    
    unsigned int contadorChar = 0;
    unsigned int ascii = 0;
    bool primeraLinea = false; 
    bool encntradoEnEncabezado = false; 
    bool empezarAlf = false;

    unsigned int letraIndex = 0;
    
    std::unordered_map<char, char> asociacion_letras;
    char letras[20];

%}

PUNCT   [\.\,\;\:\?\!\¡\¿\"()\[\]\{\}\-\'\,]

%%

\n {
    if (!encntradoEnEncabezado && primeraLinea ){
        intentosUtilizados++;
    }
        
    if(primeraLinea == true && !empezarAlf){
        printf("Entro al if ");
        primeraLinea = false ;
        contadorChar = 0;
        empezarAlf = true;
    }
    if(primeraLinea && empezarAlf){
        primeraLinea = false ;
    }

    return ENTER; 
}

"\x0D"       { /* nada: ignora carriage return */ }

"#"[A-Za-z0-9_]+".fasta",[0-9]+,[0-9]+  {
    /* yytext = "#File1.fasta,10,2" */
    char fname[256];
    int n1, n2;
    if (sscanf(yytext + 1, "%255[^,],%d,%d", fname, &configDesfase, &intentosMax) == 3) {
        yylval.filename = fname;
        encntradoEnEncabezado = false; 
        return ENTRADAHASH;
    }
}

">lcl|" {
    
    primeraLinea = true; 
    if (!empezarAlf )
        contadorChar = 4;
    return FLECHA;
}

" " {
    return SPACE;
}


"#" {
        return HASH;
    }

[:_.]   {
        
        if (primeraLinea && contadorChar <= configDesfase  && !empezarAlf ) {
                contadorChar++; 
                    if (contadorChar == configDesfase) {
                        ascii = (unsigned char) yytext[0];
                        /* ahora ascii tiene el código ASCII de ese carácter */
                        configDesfase = ascii;
                        encntradoEnEncabezado = true; 
                    }
            }
        
        return PUNCTFASTA;
        }

[0-9]     {
            if (primeraLinea && contadorChar <= configDesfase && !empezarAlf ) {
                contadorChar++; 
                    if (contadorChar == configDesfase) {
                        ascii = (unsigned char) yytext[0];
                        /* ahora ascii tiene el código ASCII de ese carácter */
                        configDesfase = ascii;
                        encntradoEnEncabezado = true; 
                    }
            }
            
            yylval.num = atoi(yytext);
            return ENTERO;
        }

{PUNCT}  {
    /* yytext es un solo carácter de puntuación */
    yylval.palabra = strdup(yytext);
    return PUNCT;
}



[A-Z] {
        if (primeraLinea && contadorChar <= configDesfase && !empezarAlf ) {
            contadorChar++; 
            
            if (contadorChar == configDesfase) {
                ascii = (unsigned char) yytext[0];
            /* ahora ascii tiene el código ASCII de ese carácter */
            configDesfase = ascii;
            encntradoEnEncabezado = true; 
            }
        }  
        if (encntradoEnEncabezado && !primeraLinea){
            contadorChar++; 
            printf("%d", contadorChar);
            printf("%c", yytext[0]);
                if (contadorChar == configDesfase){
                    
                    bool existe = false;
                        for (int i = 0; i < letraIndex; i++) {
                            if (letras[i] == yytext[0]) {
                                existe = true;
                                break;
                            }
                        }
                        if (!existe && letraIndex < 20) {
                            letras[letraIndex] = yytext[0];
                            letraIndex++;
                            printf("Encontro la letra %c y la puso en el index : %d ",yytext[0], letraIndex);
                            if (letraIndex >= 20) {
                                for( int i = 0; i< 20; i++){
                                    printf("Letra : %c \n" ,letras[i] );
                                }
                            }
                        }
                    contadorChar = 0; 
                }
        }
        yylval.palabra = strdup(yytext);
        return CHARMA;
    }

[a-z] {
        if (primeraLinea && contadorChar <= configDesfase && !empezarAlf) {
            contadorChar++; 
            if (contadorChar == configDesfase) {
                ascii = (unsigned char) yytext[0];
            /* ahora ascii tiene el código ASCII de ese carácter */
            configDesfase = ascii;
            encntradoEnEncabezado = true; 
            }
        }
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

