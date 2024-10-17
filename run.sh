#!/bin/bash

# Compila el código fuente con NASM
nasm -f elf64 -g -o test2.o test2.asm

# Enlaza el objeto para crear el ejecutable
ld test2.o -o test2

# Inicia GDB
gdb ./test2
