# Usa una imagen de Linux como base (en este caso Ubuntu)
FROM ubuntu:latest

# Actualiza la lista de paquetes e instala NASM y binutils
RUN apt-get update && apt-get install -y nasm binutils gdb && apt-get clean && rm -rf /var/lib/apt/lists/*

# Establece un directorio de trabajo
WORKDIR /usr/src/app

# Copia los archivos de tu proyecto al contenedor
COPY . .

# Comando por defecto para ejecutar
CMD nasm -f elf64 test2.asm -o test2.o && ld test2.o -o test2 && gdb ./test2

