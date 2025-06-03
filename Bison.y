%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string>
    #include <unordered_map> 

    int yylex(void);
    extern FILE *yyin;

    /* Suppress default error output */
    int yyerror(char *s) { return 0; }

    extern int yyparse();
    extern void yylex_destroy();
    extern void yyrestart(FILE *input_file);

    void extern push_buffer_for_file(FILE *f);

    unsigned int intentosMax = 0;
    unsigned int configDesfase = 0;
    unsigned int intentosUtilizados = 0;
    
    unsigned int contadorChar = 0;
    unsigned int ascii = 0;
    bool primeraLinea = false; 
    bool encntradoEnEncabezado = false; 
    bool empezarAlf = false;

    unsigned int letraIndex = 0;
    std::string alfabeto_original = "ACDEFGHIKLMNPQRSTVWY";
    std::unordered_map<char, char> asociacion_letras;
    char letras[20];
%}

%union {
    
    int       num;
    char*     filename;
    char     caracter;
}


%token <filename> ENTRADAHASH
%token <caracter>  CHARMA
%token <caracter>  CHARMI
%token <caracter>  PUNCT
%token <num>      ENTERO
%token            ERROR
%token            HASH
%token            FLECHA
%token <caracter> PUNCTFASTA
%token            SPACE 
%token            ENTER





%%



prog:
    /* cero o más bloques */
    /* empty */
    | bloques
;

bloques:
    bloque
    | bloques bloque
;

bloque:
    ENTRADAHASH 
    { 
        char* texto = $1;
        char fname[256];
        int n1, n2;

        if (sscanf(texto, "#%255[^,],%d,%d", fname, &configDesfase, &intentosMax) == 3) {
            printf("Nombre de fichero: %s\n", fname);
            printf("  n1 = %d, n2 = %d\n", configDesfase, intentosMax);
        } else {
            yyerror((char *)"Formato inválido: se esperaba #<Nombre.fasta>,<num1>,<num2>");
        }

        

        /* abrir y empujar buffer… */
        FILE *f = fopen(fname,"r");
        if(!f){
            printf("El archivo : %s no existe", $1); 
            return EXIT_FAILURE; 
        }
        if (f) push_buffer_for_file(f);
    }
    
    elementos
    | FLECHA {
        primeraLinea = true; 
        if (!empezarAlf )
            contadorChar = 4;
    }elementosdos
;

elementosdos:
    pre_enter ENTER{
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
    } post_enter
;

pre_enter:
    elemento_pre
    | pre_enter elemento_pre
;

elemento_pre:
    CHARMA {
            if (primeraLinea && contadorChar <= configDesfase  && !empezarAlf && !encntradoEnEncabezado ) {
                contadorChar++; 
                printf("CHARMA Carácter: %c \n", $1);
                if (contadorChar == configDesfase) {
                    printf("contadorChar = %d, configDesfase = %d\n", contadorChar, configDesfase);

                    ascii = (unsigned int) $1;
                        /* ahora ascii tiene el código ASCII de ese carácter */
                    printf("Carácter: %c | Código ASCII: %u\n", $1, ascii);

                    configDesfase = ascii;
                    encntradoEnEncabezado = true; 
                    contadorChar = 0; 
                }
            }
    } 
    | CHARMI{
            
            if (primeraLinea && contadorChar <= configDesfase  && !empezarAlf && !encntradoEnEncabezado) {
                contadorChar++; 
                    printf("CHARMI Pre Carácter: %c", $1 );
                    if (contadorChar == configDesfase) {
                        printf("contadorChar = %d, configDesfase = %d\n", contadorChar, configDesfase);

                        ascii = (unsigned int) $1;
                        /* ahora ascii tiene el código ASCII de ese carácter */
                        printf("Carácter: %c | Código ASCII: %u\n", $1, ascii);

                        configDesfase = ascii;
                        encntradoEnEncabezado = true; 
                    }
            }
    }
    | PUNCTFASTA{
        if (primeraLinea && contadorChar <= configDesfase  && !empezarAlf && !encntradoEnEncabezado) {
                contadorChar++; 
                printf("PUNTOFASTA Carácter: %c ", $1);
                    if (contadorChar == configDesfase) {
                        printf("contadorChar = %d, configDesfase = %d\n", contadorChar, configDesfase);

                        ascii = (unsigned int) $1;
                        /* ahora ascii tiene el código ASCII de ese carácter */
                        printf("Carácter: %c | Código ASCII: %u\n", $1, ascii);

                        configDesfase = ascii;
                        encntradoEnEncabezado = true; 
                    }
            }
    }
    | ENTERO   {
        if (primeraLinea && contadorChar <= configDesfase && !empezarAlf && !encntradoEnEncabezado) {
                contadorChar++; 
                printf("ENTERO Carácter: %c ", $1);
                    if (contadorChar == configDesfase) {
                        printf("contadorChar = %d, configDesfase = %d\n", contadorChar, configDesfase);

                        ascii = (unsigned int) $1;
                        /* ahora ascii tiene el código ASCII de ese carácter */
                        printf("Carácter: %c | Código ASCII: %u\n", $1, ascii);

                        configDesfase = ascii;
                        encntradoEnEncabezado = true; 
                    }
            }
    }
;

post_enter:
    elemento_post
    | post_enter elemento_post
;

elemento_post:
    CHARMA{
            
            contadorChar++; 
                if (contadorChar == configDesfase){
                    
                    bool existe = false;
                        for (int i = 0; i < letraIndex; i++) {
                            if (letras[i] == $1) {
                                existe = true;
                                break;
                            }
                        }
                        if (!existe && letraIndex < 20) {
                            letras[letraIndex] = $1;
                            letraIndex++;
                            printf("Encontro la letra %c y la puso en el index : %d ",$1, letraIndex);
                            if (letraIndex >= 20) {
                                for( int i = 0; i< 20; i++){
                                    printf("Letra : %c \n" ,letras[i] );
                                }
                                for (int i = 0; i < 20; i++) {
                                    asociacion_letras[alfabeto_original[i]] = letras[i];
                                }
                                asociacion_letras['B'] = 'Z';
                                asociacion_letras['J'] = 'X';
                                asociacion_letras['O'] = 'U';
                                asociacion_letras['U'] = 'O';
                                asociacion_letras['Z'] = 'B';
                                asociacion_letras['X'] = 'J';
                                for (int i = 0; i < 256; i++) {
                                    if (asociacion_letras[i] != 0) {
                                        printf("'%c' -> '%c'\n", i, asociacion_letras[i]);
                                    }
                                }

                            }
                        }
                    contadorChar = 0; 
                }
    }
    | PUNCTFASTA
    | ENTERO
    | ENTER {
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
    }
;

elementos:
    elemento elementos 
    |
;


elemento:
    CHARMA {

            if (primeraLinea && contadorChar <= configDesfase  && !empezarAlf && !encntradoEnEncabezado ) {
                contadorChar++; 
                printf("CHARMA Carácter: %c ", $1);
                    if (contadorChar == configDesfase) {
                        printf("contadorChar = %d, configDesfase = %d\n", contadorChar, configDesfase);

                        ascii = (unsigned int) $1;
                        /* ahora ascii tiene el código ASCII de ese carácter */
                        printf("Carácter: %c | Código ASCII: %u\n", $1, ascii);

                        configDesfase = ascii;
                        encntradoEnEncabezado = true; 
                    }
            }
            contadorChar++; 
            printf("contadorChar = %d\n", contadorChar);
        
                if (contadorChar == configDesfase){
                    
                    bool existe = false;
                        for (int i = 0; i < letraIndex; i++) {
                            if (letras[i] == $1) {
                                existe = true;
                                break;
                            }
                        }
                        if (!existe && letraIndex < 20) {
                            letras[letraIndex] = $1;
                            letraIndex++;
                            printf("Encontro la letra %c y la puso en el index : %d ",$1, letraIndex);
                            if (letraIndex >= 20) {
                                for( int i = 0; i< 20; i++){
                                    printf("Letra : %c \n" ,letras[i] );
                                }
                                for (int i = 0; i < 20; i++) {
                                    asociacion_letras[alfabeto_original[i]] = letras[i];
                                }
                                asociacion_letras['B'] = 'Z';
                                asociacion_letras['J'] = 'X';
                                asociacion_letras['O'] = 'U';
                                asociacion_letras['U'] = 'O';
                                asociacion_letras['Z'] = 'B';
                                asociacion_letras['X'] = 'J';
                                for (int i = 0; i < 256; i++) {
                                    if (asociacion_letras[i] != 0) {
                                        printf("'%c' -> '%c'\n", i, asociacion_letras[i]);
                                    }
                                }

                            }
                        }
                    contadorChar = 0; 
                }
    }
    | PUNCT 
    | SPACE
    | ENTER {
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
    }
    | CHARMI {

            printf("CHARMI Elemeto Carácter: %c", $1 );
            if (primeraLinea && contadorChar <= configDesfase  && !empezarAlf && !encntradoEnEncabezado ) {
                contadorChar++; 
                
                    if (contadorChar == configDesfase) {
                        printf("contadorChar = %d, configDesfase = %d\n", contadorChar, configDesfase);

                        ascii = (unsigned int) $1;
                        /* ahora ascii tiene el código ASCII de ese carácter */
                        printf("Carácter: %c | Código ASCII: %u\n", $1, ascii);

                        configDesfase = ascii;
                        encntradoEnEncabezado = true; 
                    }
            }

    }
;





%%

int main(int argc, char **argv) {
    if (argc > 1) {
        for (int i = 1; i < argc; i++) {
            yyin = fopen(argv[i], "r");
            if (!yyin) {
                perror(argv[i]);
                continue;
            }

            /* Reinicia el scanner para que lea de yyin */
            yyrestart(yyin);

            printf("=== Analizando %s ===\n", argv[i]);
            if (yyparse() == 0) {
                printf("Entrada válida en %s \n\n", argv[i]);
                
            } else {
                printf("Entrada NO válida en %s \n\n", argv[i]);
                return EXIT_FAILURE;
            }

            fclose(yyin);
            /* Limpia cualquier estado interno de Flex */
            yylex_destroy();
        }
    } else {
        /* Modo interactivo o stdin si no hay args */
        yyin = stdin;
        if (yyparse() == 0) {
            printf("Entrada válida (stdin).\n");
        } else {
            printf("Entrada NO válida (stdin).\n");
            return EXIT_FAILURE;
        }
    }
    return EXIT_SUCCESS;
}