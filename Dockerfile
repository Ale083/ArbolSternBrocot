# Usa una imagen de Linux como base (en este caso Ubuntu)
FROM ubuntu:latest

# Actualiza la lista de paquetes e instala NASM y binutils
RUN apt-get update && apt-get install -y nasm binutils gdb && apt-get clean && rm -rf /var/lib/apt/lists/*

# Establece un directorio de trabajo
WORKDIR /usr/src/app

# Copia los archivos de tu proyecto al contenedor
COPY . .

# Copia el script de ejecución
COPY run.sh .

# Comando por defecto para ejecutar el script
CMD ["./run.sh"]
