section .data
    msg_nivel_max db "Ingrese el nivel máximo (1-8): ", 0
    msg_nivel_leido db "Nivel máximo leído: ", 0
    msg_nivel_almacenado db "Nivel máximo válido almacenado: ", 0
    msg_racional db "Ingrese el numerador y denominador del racional a buscar (separados por espacio): ", 0
    msg_inicio_busqueda db "Iniciando búsqueda del racional...",  0x0A, 0
    msg_comparacion_num_den db "Comparando numerador y denominador...", 0x0A, 0
    msg_encontrado db "El número racional se encuentra en el árbol en la posición: (Nivel: %d, Posición: %d)", 0
    msg_no_encontrado db "El número racional no se encuentra en el árbol", 0x0A, 0
    msg_terminar db "Ingrese 1 para terminar el programa: ", 0
    msg_arbol_comienza db "El árbol comienza a construirse", 0x0A, 0
    msg_arbol_construido db "El árbol fue construido", 0x0A, 0
    msg_nodo_comienza db "Creando un nuevo nodo...", 0x0A, 0
    msg_regresar_padre db "Regresando al nodo padre después de crear hijos.", 0x0A, 0
    msg_salida db "Saliendo del programa", 0
    msg_menoranueve_validacion_exitosa db "Es menor a 9",  0x0A, 0
    msg_mayoracero_validacion_exitosa db "Es mayor a 0", 0x0A, 0
    newline db 0xA, 0

    ; Estructura del nodo del árbol
    nodo_size equ 24                ; Tamaño de cada nodo: 16 bytes (numerador y denominador) + 8 bytes (punteros L/R)
    null dq 0                       ; Puntero nulo para inicializar los nodos sin hijos

    heap_space times 1048576 db 0   ; 1MB para heap improvisado
    heap_pointer dq heap_space       ; Puntero del siguiente bloque libre en el heap

section .bss
    nivel_max resb 4                ; Nivel máximo ingresado por el usuario
    numerador_buscar resb 4         ; Numerador del racional a buscar
    denominador_buscar resb 4       ; Denominador del racional a buscar
    nivel_actual resb 4              ; Nivel actual para la búsqueda

section .text
    global _start

_start:
    ; Llamar a la función para pedir el nivel máximo
    call pedir_nivel_maximo

    ; Mensaje de depuración para indicar que el árbol va a empezar
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_arbol_comienza
    mov rdx, 30
    syscall

    ; Crear el árbol
    mov rsi, 0                       ; Inicializar nivel actual
    call crear_arbol                 ; Llamar a la función para construir el árbol

    ; Mensaje de depuración para indicar que el árbol fue construido
    ;mov rax, 1
    ;mov rdi, 1
    ;mov rsi, msg_arbol_construido
    ;mov rdx, 30
    ;syscall

    ; Solicitar el número racional a buscar
    call pedir_racional

    ; Buscar la fracción
    mov rdi, rax                     ; Pass pointer to the root of the tree
    call buscar_fraccion

    ; Preguntar al usuario si desea terminar el programa
    call preguntar_terminar

salir:

    ;Mensaje de depuracion para indicar la salida del programa
    ;mov rax, 1
    ;mov rdi, 1
    ;mov rsi, msg_salida
    ;mov rdx, 26
    ;syscall

    ; Salir del programa
    mov rax, 60                      ; syscall: exit
    xor rdi, rdi                     ; código de salida 0
    syscall

; Función para pedir el nivel máximo
pedir_nivel_maximo:
    ; Imprimir mensaje para pedir el nivel máximo
    mov rax, 1                       ; syscall: write
    mov rdi, 1                       ; file descriptor: stdout
    mov rsi, msg_nivel_max           ; mensaje para el usuario
    mov rdx, 31                      ; longitud del mensaje
    syscall

    ; Leer el número
    mov rax, 0                       ; syscall: read
    mov rdi, 0                       ; file descriptor: stdin
    mov rsi, nivel_max               ; dirección donde almacenar el nivel
    mov rdx, 4                       ; longitud a leer
    syscall

    ; Convertir carácter a número
    movzx rax, byte [nivel_max]      ; Cargar el primer carácter leído
    sub rax, '0'                     ; Convertir de carácter a número

    ; Limpiar el buffer
    mov byte [nivel_max + 1], 0      ; Asegurarse que no hay datos sobrantes

    ;Mensaje de depuracion para imprimir el nivel maximo leido
    ;mov rax, 1
    ;mov rdi, 1
    ;mov rsi, msg_nivel_leido
    ;mov rdx, 20
    ;syscall

    ; Validar que el nivel máximo sea entre 1 y 8
    cmp rax, 1                       ; Comprobar que sea al menos 1
    jl menor_a_uno                   ; Si es menor a 1, saltar a menor_a_uno
    cmp rax, 8                       ; Comprobar que no sea mayor a 8
    jg mayor_a_ocho                  ; Si es mayor a 8, saltar a mayor_a_ocho

    ; Almacenar el valor de vuelta
    mov [nivel_max], rax             ; Almacenar el nivel como entero

    ; Mensaje de depuracion para imprimir el nivel maximo ALMACENADO
    ;mov rax, 1
    ;mov rdi, 1
    ;mov rsi, msg_nivel_almacenado
    ;mov rdx, 30
    ;syscall

    ; Mensaje de validación exitosa
    mov rax, 1                       ; syscall: write
    mov rdi, 1                       ; file descriptor: stdout
    mov rsi, msg_mayoracero_validacion_exitosa
    mov rdx, 30
    syscall

    ret

menor_a_uno:
    ; Mensaje para cuando el nivel es menor a 1
    mov rax, 1                       ; syscall: write
    mov rdi, 1                       ; file descriptor: stdout
    mov rsi, msg_mayoracero_validacion_exitosa  ; Puedes cambiar esto por un mensaje diferente si lo deseas
    mov rdx, 30
    syscall
    jmp salir                        ; Salir del programa

mayor_a_ocho:
    ; Mensaje para cuando el nivel es mayor a 8
    mov rax, 1                       ; syscall: write
    mov rdi, 1                       ; file descriptor: stdout
    mov rsi, msg_menoranueve_validacion_exitosa
    mov rdx, 30
    syscall
    jmp salir                        ; Salir del programa

; Función para crear un nuevo nodo
crear_nodo:     
    ; Reservar memoria para un nodo
    mov rax, heap_pointer            ; Obtener el puntero actual del heap
    mov rbx, rax                     ; Guardar la dirección actual del nodo
    add rax, nodo_size               ; Avanzar el puntero para el siguiente nodo
    mov [heap_pointer], rax          ; Actualiza el puntero del heap
    ;Inicializar el nodo
    xor rdi, rdi                     ; Inicializar puntero izquierdo
    xor rsi, rsi                     ; Inicializar puntero derecho
    mov [rbx + 16], rdi               ; Establecer hijo izquierdo a null
    mov [rbx + 24], rsi               ; Establecer hijo derecho a null
    ret


; Función para crear el árbol de Stern-Brocot
crear_arbol:
    ; Argumentos: rsi = nivel actual, rdx = nivel máximo
    cmp rsi, [nivel_max]             ; Si hemos alcanzado el nivel máximo, retornar
    jge .fin

    ;Mensaje de depuracion para revisar si se empiezan a crear los nodos
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_nodo_comienza
    mov rdx, 24
    syscall


    ; Crear nodo hijo izquierdo (L)
    call crear_nodo                  ; Crear un nuevo nodo en el heap para el hijo izquierdo
    mov dword [rax], 0               ; Inicializar el numerador del hijo izquierdo (0)
    mov dword [rax + 8], 1           ; Inicializar el denominador del hijo izquierdo (1)
    mov [rdi + 16], rax               ; Guardar el puntero al hijo izquierdo


    ; Llamada recursiva para construir el subárbol izquierdo
    add rsi, 1                       ; Incrementar el nivel
    mov rdi, [rdi + 16]              ; Actualizar el puntero al hijo izquierdo
    call crear_arbol                 ; Llamada recursiva para el hijo izquierdo

    ; Mensaje de depuracion para saber cuando se esta regresando al nodo padre
    ;mov rax, 1
    ;mov rdi, 1
    ;mov rsi, msg_regresar_padre
    ;mov rdx, 50
    ;syscall


    ; Regresar al nodo padre
    dec rsi                          ; Decrementar el nivel al volver al nodo padre


    ; Crear nodo hijo derecho (R)
   ; mov rdi, [rdi + 24]              ; Regresar al nodo padre
    call crear_nodo                  ; Crear un nuevo nodo en el heap para el hijo derecho
    mov dword [rax], 1               ; Inicializar el numerador del hijo derecho (1)
    mov dword [rax + 8], 0           ; Inicializar el denominador del hijo derecho (0)
    mov [rdi + 24], rax               ; Guardar el puntero al hijo derecho

    ; Llamada recursiva para construir el subárbol derecho
    add rsi, 1                       ; Incrementar el nivel
    mov rdi, [rdi + 24]              ; Actualizar el puntero al hijo derecho
    
    call crear_arbol                 ; Llamada recursiva para el hijo derecho

.fin:
    ret

; Función para pedir un número racional a buscar
pedir_racional:
    mov rax, 1                       ; syscall: write
    mov rdi, 1                       ; file descriptor: stdout
    mov rsi, msg_racional            ; mensaje para el usuario
    mov rdx, 50                      ; longitud del mensaje
    syscall

    ; Leer el numerador
    mov rax, 0                       ; syscall: read
    mov rdi, 0                       ; file descriptor: stdin
    mov rsi, numerador_buscar        ; dirección donde almacenar el numerador
    mov rdx, 4                       ; longitud a leer
    syscall

    ; Leer el denominador
    mov rax, 0                       ; syscall: read
    mov rdi, 0                       ; file descriptor: stdin
    mov rsi, denominador_buscar      ; dirección donde almacenar el denominador
    mov rdx, 4                       ; longitud a leer
    syscall

    ret

; Función para buscar una fracción en el árbol
buscar_fraccion:
    ; Argumentos: rdi = puntero al nodo, rsi = numerador, rdx = denominador, r10 = nivel

    ;Mensaje de depuracion para revisar si se esta iniciando la busqueda del racional:
    ;mov rax, 1
    ;mov rdi, 1
    ;mov rsi, msg_inicio_busqueda
    ;mov rdx, 30
    ;syscall

    ; Guardar el nivel actual
    mov [nivel_actual], r10

    ; Comparar numerador
    cmp [rdi], rsi                   ; Comparar numerador
    je .encontrado

    ; Comparar denominador
    cmp [rdi + 8], rdx               ; Comparar denominador
    je .encontrado

    ;Mensaje de depuracion para revisar si se compararon los numeradores y denominadores:
    ;mov rax, 1
    ;mov rdi, 1
    ;mov rsi, msg_comparacion_num_den
    ;mov rdx, 40
    ;syscall


    ; Buscar en hijos izquierdo y derecho
    ; Hijo izquierdo
   cmp qword [rdi + 16], 0          ; Verificar si hay hijo izquierdo
    je .buscar_derecho               ; Si no hay, buscar en derecho
    push r10                         ; Guardar nivel actual
    add r10, 1                       ; Incrementar nivel
    call buscar_fraccion             ; Llamar recursivamente al hijo izquierdo
    pop r10                          ; Restaurar nivel

.buscar_derecho:
    cmp qword [rdi + 24], 0          ; Verificar si hay hijo derecho
    je .no_encontrado                ; Si no hay, terminar
    push r10                         ; Guardar nivel actual
    add r10, 1                       ; Incrementar nivel
    call buscar_fraccion             ; Llamar recursivamente al hijo derecho
    pop r10                          ; Restaurar nivel

.no_encontrado:

    ;Mensaje de depuracion para indicar que el numero racional NO fue encontrado
    ;mov rax, 1
    ;mov rdi, 1
    ;mov rsi, msg_no_encontrado
    ;mov rdx, 33
    ;syscall

    ret

.encontrado:

    ;Mensaje de depuracion para indicar que el numero racional fue encontrado
    ;mov rax, 1
    ;mov rdi, 1
    ;mov rsi, msg_encontrado
    ;mov rdx, 28
    ;syscall

    ; Mostrar resultado
    mov rax, 1                       ; syscall: write
    mov rdi, 1                       ; file descriptor: stdout
    mov rsi, msg_encontrado          ; mensaje para el usuario
    mov rdx, 50                      ; longitud del mensaje
    syscall
    ret

; Función para preguntar al usuario si desea terminar el programa
preguntar_terminar:
    mov rax, 1                       ; syscall: write
    mov rdi, 1                       ; file descriptor: stdout
    mov rsi, msg_terminar            ; mensaje para el usuario
    mov rdx, 50                      ; longitud del mensaje
    syscall

    ; Leer la entrada del usuario
    mov rax, 0                       ; syscall: read
    mov rdi, 0                       ; file descriptor: stdin
    mov rsi, nivel_max               ; dirección donde almacenar la respuesta
    mov rdx, 4                       ; longitud a leer
    syscall

    cmp byte [nivel_max], '1'        ; Si la entrada es '1', terminar
    je salir                       ; Llamar a la función de terminar el programa

    jmp preguntar_terminar           ; Repetir la pregunta

