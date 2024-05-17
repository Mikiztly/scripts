#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# Script pensado para realizar BKP para equipos MIKROTIK los cuales mostraran via web si se ralizo o no el bkp "STATUS"
# Es necesario tener instalado APACHE y MARIADB
# https://github.com/candidornotar/bkp_mikrotik

# Configurar las variables
therouter="xxx.xxx.xxx.xxx"; # ip del router MK
thepassword="xxxxxxxx"; # Password del router MK
thename="xxxxxxxx"; # Nombre de router MK
theuser="xxxxxxxx"; # Usuario de ingreso al router MK
theclient="xxxxxxxx"
theport="xxxxx"; # Puerto de ingreso al router MK
theroute_a="/xxx/xxx/xxx/xxx/"; # Ruta donde se descarga el BK
theroute_b="/xxx/xxx/xxx/xxx"; # Ruta para cambiar Permisos, misma que theroute_a pero quitar / del final
db_host="localhost"; # Direccion DB
db_user="xxxxxxxx"; # Usuario DB
db_pass="xxxxxxxx"; # Password DB
db_name="xxxxxxxx"; # DB

# Función para hacer la copia de seguridad
function backup_files {
  thefile=$(sshpass -p $thepassword ssh -o ConnectTimeout=10 $theuser@$therouter -p $theport ':local filename ([/system identity get name] . "-" . [:pick [/system clock get date] 7 11] . [:pick [/system clock get date] 0 3] . [:pick [/system clock get date] 4 6] . "-" . [:pick [/system clock get time] 0 2] . [:pick [/system clock get time] 3 5]); /export terse file=$filename; /system backup save dont-encrypt=yes name=($filename); put $filename' | tail -n 1 | tr -d '\r');
  sshpass -p $thepassword scp -P $theport -o ConnectTimeout=5 $theuser@$therouter:/"$thefile.backup" $theroute_a &&
  sshpass -p $thepassword scp -P $theport -o ConnectTimeout=5 $theuser@$therouter:/"$thefile.rsc" $theroute_a
}

# Realizar la copia de seguridad
backup_files

# Verificar el estado de salida del comando "scp" para determinar si la copia de seguridad se realizó correctamente
if [ $? -eq 0 ]; then
  status="OK"
else
  status="NO"
fi

# Permisos Directorios
chmod 754 $theroute_b
chown :backups $theroute_b

# Permisos Archivos
chown :backups $theroute_a*
chmod 754 $theroute_a*

# Conectarse a la base de datos y ejecutar una consulta SQL para insertar los datos
mysql -h $db_host -u $db_user -p$db_pass $db_name << EOF
INSERT INTO backup_logs (status, date, client, system_name) VALUES ('$status', NOW(), '$theclient', '$thename');
EOF
