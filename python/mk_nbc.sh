#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# Script creado por Mikiztly (https://github.com/Mikiztly/scripts/blob/main/bash/mk_nbc.sh) para realizar backups de los equipos de red de Nubicom
# Lo que hace es leer de 2 archivos csv los datos que se necesitan para crear los backups:
# db_server.csv (datos para la conexion al servidor mysql): se cargan los datos de la siguiente manera: nombre del host, usuario, contraseña, nombre de la DB
# mk_nbc.csv (datos para hacer la copia del backup): se cargan los datos de la siguiente manera: IP del equipo, contraseña, nombre, usuario, cliente, puerto, directorio del backup
# IMPORTANTE: los archivos csv tienen como separador de campo la coma (,) SIN ESPACIOS
# Para ejecutar el script se deben pasar 2 argumentos: primero el archivo csv donde estan los datos de mysql y segunto el archivo csv que tiene los datos de los equipos a realizar el backup

# Verificamos que los archivos existan
if [ ! -f "$1" ] || [ ! -f "$2" ]; then
  echo "Error: Alguno de los archivos de configuracion no existe"
  echo "Se debe pasar como argumento: $0 <server_mysql.txt> <equipos.csv>"
  exit 1
fi

# Cargo los datos del servidor mysql
IFS=, read -r db_host db_user db_pass db_name < "$1"
  echo "Servidor web"
  echo "Host: ${db_host}"
  echo "Usuario: ${db_user}"
  echo "Password: ${db_pass}"
  echo "BaseDatos: ${db_name}"
  echo "*****************"

# Abrimos el archivo para recorrer los registros y guardarlos en las variables
while IFS=, read -r thename therouter theport theuser thepassword theclient theroute; do
  echo "Router: ${therouter}" # IP del equipo
  echo "Password: ${thepassword}" # Contraseña
  echo "Nombre: ${thename}" # Nombre de router MK
  echo "Usuario: ${theuser}" # Usuario de ingreso al router MK
  echo "Cliente: ${theclient}" # Cliente
  echo "Puerto: ${theport}" # Puerto de ingreso al router MK
  # Se crea la ruta completa para guardar el backup, con $PWD llego al directorio donse se ejecuta el script, por ejemolo: home/usuario/backups
  theroute_a="${PWD}/${theroute}/${thename}/" # Ruta completa donde se descarga el backup
  echo "Ruta: ${theroute_a}"  # Ruta donde se descarga el BK
  echo "-------------------"

  # Chequeamos que exista el directorio
  if [[ ! -d "$theroute_a" ]]; then
    echo
    # Si no existe el directorio lo creamos
    echo "Creando el directorio ${theroute_a}"
    mkdir -p "$theroute_a"
  fi

  # Realizamos la copia de seguridad
  echo
  echo "Copia de seguridad"
  NOW=$(date +%Y-%m-%d_%H%M%S)
  archivo="${theroute_a}backup-${NOW}.bkp"
  touch "$archivo"
  
#  thefile=$(sshpass -p $thepassword ssh -o ConnectTimeout=10 $theuser@$therouter -p $theport ':local filename ([/system identity get name] . "-" . [:pick [/system clock get date] 7 11] . [:pick [/system clock get date] 0 3] . [:pick [/system clock get date] 4 6] . "-" . [:pick [/system clock get time] 0 2] . [:pick [/system clock get time] 3 5]); /export terse file=$filename; /system backup save dont-encrypt=yes name=($filename); put $filename' | tail -n 1 | tr -d '\r');
#  sshpass -p $thepassword scp -P $theport -o ConnectTimeout=5 $theuser@$therouter:/"$thefile.backup" $theroute_a &&
#  sshpass -p $thepassword scp -P $theport -o ConnectTimeout=5 $theuser@$therouter:/"$thefile.rsc" $theroute_a

  # Verificar el estado de salida del comando "scp" para determinar si la copia de seguridad se realizó correctamente
#  if [ $? -eq 0 ]; then
#    status="OK"
#  else
#    status="NO"
#  fi

  # Permisos Directorios y archivos
  chmod -R 754 "$theroute_a"
  #chown -R :backups $theroute_a
  chown -R :dcasavilla "$theroute_a"

  # Conectarse a la base de datos y ejecutar una consulta SQL para insertar los datos
#  mysql -h $db_host -u $db_user -p $db_pass $db_name << EOF
#  INSERT INTO backup_logs (status, date, client, system_name) VALUES ('$status', NOW(), '$theclient', '$thename');
#  EOF

  # Pausamos el script por 1 minuto
  echo "Pausa de 1 minuto"
  sleep 10

done < "$2"
