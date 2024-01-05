#!/bin/bash

# Leer el nombre del archivo de la línea de comando (Ej. ./crea_carpetas.sh prueba.txt), utiliza cada lina como nombre de la carpeta
archivo=$1

# Leer el contenido del archivo
while read linea; do
  mkdir "${linea:-1}"
done < "$archivo"