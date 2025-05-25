
#!/bin/bash
    clear
echo "<inicio de bison y flex>"
    flex -l scanner.l
    bison -dv Bison.y 
    gcc -o main Bison.tab.c lex.yy.c 
echo "<fin>"
