
#!/bin/bash
    clear
echo "<inicio de bison y flex>"
    flex -l scanner.l
    bison -dv Bison.y 
    g++ -std=c++23 -o main Bison.tab.c lex.yy.c 
echo "<fin>" estas son mis instrucciones 