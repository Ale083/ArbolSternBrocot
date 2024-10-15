section .data
    msg_nivel_max db "Ingrese el nivel máximo (1-8): ", 0
    msg_racional db "Ingrese el numerador y denominador del racional a buscar (separados por espacio): ", 0
    msg_encontrado db "El número racional se encuentra en el árbol en la posición: (Nivel: %d, Posición: %d)", 0
    msg_no_encontrado db "El número racional no se encuentra en el árbol", 0
    msg_terminar db "Ingrese 1 para terminar el programa: ", 0
    msg_arbol_comienza db "Arbol comienza a construirse ", 0
    msg_arbol_construido db "Arbol construido ",0
    msg_despues_ret db "Se retorno correctamente",0	
    msg_salida db "Saliendo del programa",0
    msg_menoranueve_validacion_exitosa db "Es menor a 9", 0
    msg_mayoracero_validacion_exitosa db "Es mayor a 0", 0
    newline db 0xA, 0

    heap_space times 1048576 db 0  ; 1mb para heap improvisado
    heap_pointer dq heap_space      ; Puntero del siguiente bloque libre en el heap

section .bss
    nivel_max resb 4               ; Nivel máximo ingresado por el usuario
    numerador_buscar resb 4        ; Numerador del racional a buscar
    denominador_buscar resb 4      ; Denominador del racional a buscar

section .text
    global _start

_start:
    ; Llamar a la función para pedir el nivel máximo
    call pedir_nivel_maximo

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_despues_ret
    mov rdx, 24
    syscall

    jmp terminar

terminar:
    ; Salir del programa
    mov rax, 60                    ; syscall: exit
    xor rdi, rdi                   ; código de salida 0
    syscall

; Función para pedir el nivel máximo
pedir_nivel_maximo:
    mov rax, 1                      ; syscall: write
    mov rdi, 1                      ; file descriptor: stdout
    mov rsi, msg_nivel_max          ; mensaje para el usuario
    mov rdx, 31                     ; longitud del mensaje
    syscall	;;;

    ; Leer el número
    mov rax, 0                      ; syscall: read
    mov rdi, 0                      ; file descriptor: stdin
    mov rsi, nivel_max              ; dirección donde almacenar el nivel
    mov rdx, 1                      ; longitud a leer
    syscall


    movzx eax, byte [nivel_max]     ; Cargar el byte como entero
    sub eax, '0'                    ; Convertir de carácter a número
    mov [nivel_max], eax            ; Almacenar de nuevo


    ; Verificar que el nivel máximo sea válido
    cmp dword [nivel_max], 1         ; Comprobar que sea al menos 1
    jl salir                         ; Si es menor a 1, salir del programa

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_mayoracero_validacion_exitosa
    mov rdx, 13
    syscall	;;;

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    cmp dword [nivel_max], 8         ; Comprobar que no sea mayor a 8
    jg salir                         ; Si es mayor a 8, salir del programa

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_menoranueve_validacion_exitosa
    mov rdx, 13
    syscall	;;;

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ret


salir:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_salida
    mov rdx, 22
    syscall
    


    ; Si el nivel es inválido, salir
    mov rax, 60                      ; syscall: exit
    xor rdi, rdi                     ; código de salida 0
    syscall



    ret
	


