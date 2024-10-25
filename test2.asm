; test2.asm
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
    msg_despues_ret db "Se retorno correctamente",0	
    msg_numerador db "Numerador actual: ", 0
    msg_denominador db "Denominador actual: ", 0
    newline db 0xA, 0

    ; Definición de la estructura del nodo
    ; Offset 0: Numerador (8 bytes)
    ; Offset 8: Denominador (8 bytes)
    ; Offset 16: Puntero al hijo izquierdo (8 bytes)
    ; Offset 24: Puntero al hijo derecho (8 bytes)
    nodo_size equ 32                ; Tamaño de cada nodo: 32 bytes

    null dq 0                       ; Puntero nulo para inicializar los nodos sin hijos

    heap_space times 1048576 db 0    ; 1MB para heap improvisado
    heap_pointer dq heap_space      ; Puntero del siguiente bloque libre en el heap

section .bss
    nivel_max resd 1                 ; Nivel máximo ingresado por el usuario
    numerador_buscar resd 1          ; Numerador del racional a buscar
    denominador_buscar resd 1        ; Denominador del racional a buscar
    nivel_actual resd 1              ; Nivel actual para la búsqueda
    nodo_izq resq 1                  ; Espacio para el puntero del nodo izquierdo
    nodo_der resq 1                  ; Espacio para el puntero del nodo derecho

section .text
    global _start

_start:
    ; Llamar a la función para pedir el nivel máximo
    call pedir_nivel_maximo

    ; Llamar procedimiento para inicializar nodos
    call inicializar_nodos

    ; Mensaje de depuración para indicar que el árbol va a empezar
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_arbol_comienza
    mov rdx, 30
    syscall

    ; Crear el árbol
    mov rbx, 1                       ; Nivel inicial es 1
    mov rsi, [nodo_izq]              ; Cargar el nodo izquierdo inicial
    mov rdx, [nodo_der]              ; Cargar el nodo derecho inicial
    mov rcx, [nivel_max]             ; Cargar el nivel máximo desde la memoria
    call crear_arbol                  ; Llamar a la función para construir el árbol

    ; Mensaje de depuración para indicar que el árbol fue construido
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_arbol_construido
    mov rdx, 25
    syscall

    jmp terminar

terminar:
    ; Mensaje de depuración para indicar la salida del programa
    mov rax, 1                       ; syscall: write
    mov rdi, 1                       ; file descriptor: stdout
    mov rsi, msg_salida
    mov rdx, 19
    syscall

    ; Terminar del programa
    mov rax, 60                      ; syscall: exit
    xor rdi, rdi                     ; código de salida 0
    syscall

inicializar_nodos:
    push rbp
    mov rbp, rsp

    ; Crear el nodo izquierdo (0/1)
    mov rbx, 0               ; Numerador del nodo izquierdo
    mov rdi, 1               ; Denominador del nodo izquierdo
    call crear_nodo          ; Crear nodo izquierdo
    mov [nodo_izq], rax      ; Guardar el puntero al nodo izquierdo

    ; Crear el nodo derecho (1/0)
    mov rbx, 1               ; Numerador del nodo derecho
    mov rdi, 0               ; Denominador del nodo derecho
    call crear_nodo          ; Crear nodo derecho
    mov [nodo_der], rax      ; Guardar el puntero al nodo derecho

    pop rbp
    ret

; Función para pedir el nivel máximo
pedir_nivel_maximo:
    push rbp
    mov rbp, rsp

    ; Imprimir mensaje para pedir el nivel máximo
    mov rax, 1                      ; syscall: write
    mov rdi, 1                      ; file descriptor: stdout
    mov rsi, msg_nivel_max          ; mensaje para el usuario
    mov rdx, 31                     ; longitud del mensaje
    syscall

    ; Leer el número
    mov rax, 0                      ; syscall: read
    mov rdi, 0                      ; file descriptor: stdin
    mov rsi, nivel_max              ; dirección donde almacenar el nivel
    mov rdx, 4                      ; longitud a leer (4 bytes para un entero)
    syscall

    ; Convertir el input de ASCII a entero
    movzx eax, byte [nivel_max]     ; Cargar el byte como entero
    sub eax, '0'                    ; Convertir de carácter a número
    mov [nivel_max], eax            ; Almacenar de nuevo

    ; Verificar que el nivel máximo sea válido
    cmp dword [nivel_max], 1         ; Comprobar que sea al menos 1
    jl menor_a_uno                   ; Si es menor a 1, terminar del programa

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_mayoracero_validacion_exitosa
    mov rdx, 13
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    cmp dword [nivel_max], 8         ; Comprobar que no sea mayor a 8
    jg mayor_a_ocho                   ; Si es mayor a 8, terminar del programa

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_menoranueve_validacion_exitosa
    mov rdx, 13
    syscall	

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    pop rbp
    ret

menor_a_uno:
    ; Mensaje para cuando el nivel es menor a 1
    mov rax, 1                       ; syscall: write
    mov rdi, 1                       ; file descriptor: stdout
    mov rsi, msg_mayoracero_validacion_exitosa
    mov rdx, 13
    syscall
    jmp terminar

mayor_a_ocho:
    ; Mensaje para cuando el nivel es mayor a 8
    mov rax, 1                       ; syscall: write
    mov rdi, 1                       ; file descriptor: stdout
    mov rsi, msg_menoranueve_validacion_exitosa
    mov rdx, 13
    syscall
    jmp terminar

; Función para crear un nuevo nodo
crear_nodo:     
    push rbp
    mov rbp, rsp

    ; Obtener la dirección del nuevo nodo desde heap_pointer
    mov rax, [heap_pointer]           ; Cargar heap_pointer en rax
    add rax, 0                         ; rax = current heap_pointer

    ; Incrementar heap_pointer
    mov rdi, [heap_pointer]
    add rdi, nodo_size
    mov [heap_pointer], rdi            ; Actualizar heap_pointer

    ; Almacenar el numerador y denominador en el nodo
    mov [rax], rbx                      ; Guardar numerador en offset 0
    mov [rax + 8], rdi                  ; Guardar denominador en offset 8

    ; Inicializar los punteros a hijos (nulos por ahora)
    mov qword [rax + 16], 0             ; Puntero a hijo izquierdo
    mov qword [rax + 24], 0             ; Puntero a hijo derecho

    pop rbp
    ret

; Función para crear el árbol de Stern-Brocot
crear_arbol:
    push rbp
    mov rbp, rsp

    ; Argumentos:
    ; rbx = nivel actual
    ; rsi = puntero al nodo izquierdo
    ; rdx = puntero al nodo derecho
    ; rcx = nivel máximo

    ; Verifica si hemos alcanzado el nivel máximo
    cmp rbx, rcx                      ; Comparar nivel actual con nivel máximo
    jg .fin_crear_arbol               ; Si nivel actual > nivel máximo, terminar

    ; Calcular la fracción mediadora (num1 + num2) / (den1 + den2)
    mov rax, [rsi]                     ; Cargar numerador del nodo izquierdo
    mov rdi, [rdx]                     ; Cargar numerador del nodo derecho
    add rax, rdi                       ; num1 + num2
    mov rdi, [rsi + 8]                 ; Cargar denominador del nodo izquierdo
    mov rsi, [rdx + 8]                 ; Cargar denominador del nodo derecho
    add rsi, rdi                       ; den1 + den2

    ; Guardar los nuevos numerador y denominador para el nuevo nodo
    ; Usaremos rbx para el numerador y rcx para el denominador temporalmente
    ; pero es mejor usar un registro temporal
    mov rdi, rsi                       ; Denominador mediador
    mov rbx, rax                       ; Numerador mediador

    ; Crear un nuevo nodo con la fracción mediadora
    call crear_nodo                     ; Crear nodo mediador
    mov rdi, rax                       ; Nodo mediador ahora está en rax

    ; Actualizar el árbol: Asignar el hijo izquierdo y derecho
    ; Para simplificar, asumiremos que el nodo padre tiene espacio para hijos
    ; Aquí deberías pasar el puntero del padre para asignar los hijos

    ; Llamada recursiva para crear el hijo izquierdo
    mov rsi, rax                       ; Nuevo límite derecho
    call crear_arbol                    ; Incrementa el nivel dentro de crear_arbol

    ; Llamada recursiva para crear el hijo derecho
    mov rdx, rax                       ; Nuevo límite izquierdo
    call crear_arbol

    pop rbp
    ret

.fin_crear_arbol:
    pop rbp
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
    je terminar                       ; Llamar a la función de terminar el programa

    jmp preguntar_terminar           ; Repetir la pregunta