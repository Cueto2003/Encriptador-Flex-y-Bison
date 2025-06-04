%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string>
    #include <unordered_map> 
    #include <stdbool.h>



    #include <fstream>
    std::ofstream archivoSalida;
    std::ofstream decode;

    int yylex(void);
    extern FILE *yyin;
    /* Suppress default error output */
    int yyerror(char *s) { return 0; }

    extern int yyparse();
    extern void yylex_destroy();
    extern void yyrestart(FILE *input_file);

    void extern push_buffer_for_file(FILE *f);
    extern void yypop_buffer_state(void);

    unsigned int intentosMax = 0;
    unsigned int configDesfase = 0;
    unsigned int intentosUtilizados = 0;
    
    unsigned int contadorChar = 0;
    unsigned int ascii = 0;
    unsigned int contadorSalto = 0;
    unsigned int lineas = 0; 

    bool esArchivoTexto = false;
    bool primeraLinea = false; 
    bool encntradoEnEncabezado = false; 
    bool empezarAlf = false;
    bool encriptar = false;
    bool first = false; 
    bool oppen = false;
    char fname[256];

    char *segundoArchivo = NULL;

    unsigned int letraIndex = 0;
    std::string alfabeto_original = "ACDEFGHIKLMNPQRSTVWY";
    std::unordered_map<char, char> asociacion_letras;
    char letras[20];


    extern void BEGIN(int estado);

    std::unordered_map<char, char> InvertirAlfabeto(const std::unordered_map<char, char>& alfabeto);
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
%token            FLEC
%token <filename> DECHASHOTRO






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
        if(encriptar){
            int aux = contadorSalto -1; 
            decode << aux << '\n';
            contadorSalto = 0; 
        }
        encriptar = false; 

        char* texto = $1;
        char fname[256];
        int n1, n2;

        if (sscanf(texto, "#%255[^,],%d,%d", fname, &configDesfase, &intentosMax) == 3) {
            printf("Nombre de fichero: %s\n", fname);
            printf("  n1 = %d, n2 = %d\n", configDesfase, intentosMax);
        } else {
            yyerror((char *)"Formato inválido: se esperaba #<Nombre.fasta>,<num1>,<num2>");
        }

        /* abrir y empujar buffer…*/ 
        printf("El archivo que va a leer es: %s \n \n", fname);
        FILE *f = fopen(fname,"r");
        
        if(!f){
            printf("El archivo : %s no existe", $1); 
            return EXIT_FAILURE; 
        }
        if (f) push_buffer_for_file(f);
        
        first = false;
        decode << "#" << fname << "," << configDesfase << "," << intentosMax <<",";
    }
    
    elementos
    | FLECHA {
        primeraLinea = true; 
        if (!empezarAlf )
            contadorChar = 4;
            
    }elementosdos
    | DECHASHOTRO {
        char* texto = $1;
        char fname[256];
        printf("miVariable = %s\n", encriptar ? "true" : "false");
        first = false;
        if (sscanf(texto, "#%255[^,],%d,%d,%d", fname, &configDesfase, &intentosMax, &lineas) == 4) {
            printf("Nombre de fichero: %s\n", fname);
            printf("  n1 = %d, n2 = %d, n3 = %d\n", configDesfase, intentosMax, lineas);
        } else {
            yyerror("Formato inválido: se esperaba #<Nombre.fasta>,<num1>,<num2>,<num3>");
        }

        /* abrir y empujar buffer…*/ 
        printf("El archivo que va a leer es: %s \n \n", fname);
        FILE *f = fopen(fname,"r");
        
        if(!f){
            printf("El archivo : %s no existe", $1); 
            return EXIT_FAILURE; 
        }
        if (f) push_buffer_for_file(f);
    }
    | ENTER elemento_post
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
    |bloque
    
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

                        ascii = (unsigned char) $1;
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
                if (contadorChar == configDesfase && !encriptar){
                    
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
                                encntradoEnEncabezado = false;
                                empezarAlf = false;
                                primeraLinea = false;
                                
                                for (int i = 0; i < 20; i++) {
                                    letras[i] = '\0'; // o ' ' si prefieres espacios
                                }
                                letraIndex = 0; 
                                encriptar = true;
                                first = true; 
                                
                                
                                if(!esArchivoTexto){
                                    /* abrir y empujar buffer…*/ 
                                    asociacion_letras = InvertirAlfabeto(asociacion_letras);
                                    for (int i = 0; i < 256; i++) {
                                        if (asociacion_letras[i] != 0) {
                                            printf("'%c' -> '%c'\n", i, asociacion_letras[i]);
                                        }
                                    }
                                    
                                    printf("Segundo archivo %s",strdup(segundoArchivo));
                                    if(!oppen){
                                        printf("El archivo que va a leer es: %s \n \n", segundoArchivo);
                                        FILE *f = fopen(segundoArchivo,"r");
                                    
                                        if(!f){
                                            printf("El archivo : %s no existe", $1); 
                                            return EXIT_FAILURE; 
                                        }
                                        if (f) push_buffer_for_file(f);
                                        oppen = true; 
                                    }else{
                                        yypop_buffer_state();
                                        yypop_buffer_state();
                                    }
                                    
                                    
                                }else{
                                    yypop_buffer_state();
                                }
                            }
                        }
                    contadorChar = 0; 
                }
        
        if(encriptar && esArchivoTexto){
            if (first) {
                first = false; // Evita que vuelva a saltarse en futuras iteraciones
            } else {
                printf("Character : %c\n", $1);
                char original = $1;
                char encriptado = asociacion_letras.count(original) ? asociacion_letras[original] : original;
                archivoSalida << encriptado;
            }
        }
        if(encriptar && !esArchivoTexto){
            printf("Contador : %d" ,contadorSalto);
            if(contadorSalto < lineas){
                if (first) {
                    first = false; // Evita que vuelva a saltarse en futuras iteraciones
                } else {
                    printf("Character : %c\n", $1);
                    char original = $1;
                    char encriptado = asociacion_letras.count(original) ? asociacion_letras[original] : original;
                    archivoSalida << encriptado;
                }
            }else{
                yypop_buffer_state();
            }
        }

    }
    | PUNCTFASTA
    | ENTERO
    | ENTER {
        if (!encntradoEnEncabezado && primeraLinea ){
            intentosUtilizados++;
        }
            
        if(primeraLinea == true && !empezarAlf){
            primeraLinea = false ;
            contadorChar = 0;
            empezarAlf = true;
        }
        if(primeraLinea && empezarAlf){
            primeraLinea = false ;
        }
        if(encriptar){
            archivoSalida << '\n';
            contadorSalto++;
        }
    }
    | CHARMI{
        if(encriptar){
            char c = $1;
            char original = toupper(c);
            char encriptado = asociacion_letras.count(original) ? asociacion_letras[original] : original;

            archivoSalida << encriptado;
        }
    }
    |SPACE {
        archivoSalida << ' ';
    }
    |PUNCT
;

elementos:
    elemento elementos 
    | 
;


elemento:
    CHARMA {
        
    }
    | PUNCT 
    | SPACE
    | ENTER {
        if (!encntradoEnEncabezado && primeraLinea ){
            intentosUtilizados++;
        }
            
        if(primeraLinea == true && !empezarAlf){
            primeraLinea = false ;
            contadorChar = 0;
            empezarAlf = true;
        }
        if(primeraLinea && empezarAlf){
            primeraLinea = false ;
        }
    }
    | CHARMI 
;





%%

int main(int argc, char **argv) {

    const char *filename = argv[1];
    const char *ext = strrchr(filename, '.');  // busca el último punto

    if (ext != NULL) {
        if (strcmp(ext, ".txt") == 0) {
            printf("tipo de archivo .txt\n");
            esArchivoTexto = true;
        } else if (strcmp(ext, ".cod") == 0) {
            printf("tipo de archivo .cod\n");
            esArchivoTexto = false;

            // Intercambio permanente en argv (solo afecta al programa en ejecución)
            
            char *temp = argv[1];
            argv[1] = argv[2];
            argv[2] = temp;
            segundoArchivo = strdup(argv[2]);
            
        } else {
            fprintf(stderr, "Error: El archivo debe terminar en .txt o .cod\n");
            return EXIT_FAILURE;
        }
    }


    if  (esArchivoTexto){
        archivoSalida.open("Original_document.cod");
        if (!archivoSalida.is_open()) {
            fprintf(stderr, "No se pudo abrir archivo_encriptado.txt\n");
            return EXIT_FAILURE;
        }

        decode.open("Instruction_to_decode.txt");
        if (!decode.is_open()) {
            fprintf(stderr, "No se pudo abrir archivo_encriptado.txt\n");
            return EXIT_FAILURE;
        }
    }else{
        archivoSalida.open("Desencriptado.txt");
        if (!archivoSalida.is_open()) {
            fprintf(stderr, "No se pudo abrir archivo_encriptado.txt\n");
            return EXIT_FAILURE;
        }
    }

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
        //yy_pop_buffer_state();
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
    if(encriptar){
        int aux = contadorSalto ; 
        decode << aux << '\n';
    }
    archivoSalida.close();
    decode.close();

    return EXIT_SUCCESS;
}

std::unordered_map<char, char> InvertirAlfabeto(const std::unordered_map<char, char>& alfabeto) {
    std::unordered_map<char, char> alfabetoInvertido;

    for (const auto& par : alfabeto) {
        // Si hay colisiones, esta operación sobrescribirá los duplicados
        alfabetoInvertido[par.second] = par.first;
    }

    return alfabetoInvertido;
}
