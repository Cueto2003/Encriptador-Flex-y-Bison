%{
    #include <stdio.h>
    #include <stdlib.h>

    int yylex(void);
    extern FILE *yyin;

    /* Suppress default error output */
    int yyerror(char *s) { return 0; }

    extern int yyparse();
    extern void yylex_destroy();
    extern void yyrestart(FILE *input_file);

    void extern push_buffer_for_file(FILE *f);
%}

%union {
    
    int       num;
    char*     filename;
    char*     palabra;
    char*     punc;
}


%token <filename> ENTRADAHASH
%token <palabra>  CHARMA
%token <palabra>  CHARMI
%token <palabra>  PUNCT
%token            ENTERO
%token            ERROR
%token            HASH
%token            FLECHA
%token            PUNCTFASTA
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
        printf("Nombre de fichero: %s\n", $1);

        /* abrir y empujar buffer… */
        FILE *f = fopen($1,"r");
        if(!f){
            printf("El archivo : %s no existe", $1); 
            return EXIT_FAILURE; 
        }
        if (f) push_buffer_for_file(f);
    }
    
    elementos
    | FLECHA elementosdos
;

elementosdos:
    pre_enter ENTER post_enter
;

pre_enter:
    elemento_pre
    | pre_enter elemento_pre
;

elemento_pre:
    CHARMA
    | CHARMI
    | PUNCTFASTA
    | ENTERO    
;

post_enter:
    elemento_post
    | post_enter elemento_post
;

elemento_post:
    CHARMA
    | PUNCTFASTA
    | ENTERO
    |   ENTER
;

elementos:
    elemento elementos 
    |
;


elemento:
    CHARMA
    | PUNCT 
    | SPACE
    | ENTER
    | CHARMI
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