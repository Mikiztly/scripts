#!/bin/bash

# Script pensado para realizar BKP para equipos FORTINET los cuales mostraran via web si se ralizo o no el bkp "STATUS"
# Es necesario tener instalado APACHE y MARIADB
# https://github.com/candidornotar/bkp_fortinet

# Configuración de conexión SSH
HOST="xxx.xxx.xxx.xxx" #Ip del host
USER="xxxxxxxx" # User del host
PASSWORD="xxxxxxxx" # Pass del host
PUERTO_SSH="xxxx" # Puerto ssh
thename="xxxxxxxx"; # Nombre para mostrar en web
theclient="xxxxxxxx" # Empresa
theroute_a="/xxx/xxx/xxx/xxx/"; # Ruta donde se descarga el BK
theroute_b="/xxx/xxx/xxx/xxx"; # Ruta para cambiar Permisos, misma que theroute_a pero quitar / del final
COMANDO="execute backup full-config sftp $theroute_b/backup.conf 10.243.0.220:2781 strongsystems cxxXH9TKi&W8" # Comando a ejecutar
db_host="localhost"; # Direccion DB
db_user="xxxxxxxx"; # Usuario DB
db_pass="xxxxxxxx"; # Password DB
db_name="xxxxxxxx"; # DB nombre 

# Conexión SSH y ejecución del comando
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -p "$PUERTO_SSH" "$USER@$HOST" "$COMANDO"

# Renombrado y eliminacion
mv $theroute_b/backup.conf $theroute_b/`date +"%Y-%m-%d"`_"$thename"_backup.conf

# Verificar el estado de salida del comando "SSH" para determinar si la copia de seguridad se realizó correctamente
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
