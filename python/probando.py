#!/usr/bin/python3

import paramiko
import os

def copia_backup(therouter, theuser, thepassword, theport, theroute, archivos_origen):
    """Copia archivos a un servidor remoto por SSH.
    Args:
        therouter: La dirección IP o nombre de host del servidor remoto.
        theuser: El nombre de usuario para la conexión SSH.
        thepassword: La contraseña para la conexión SSH.
        theport: El puerto SSH (por defecto 22).
        archivos_origen: Una lista de rutas de archivos locales a copiar.
        theroute: La ruta en el servidor remoto donde se copiarán los archivos.
    """
    try:
        # Crea un cliente SSH
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())  # No recomendado para producción.

        # Conéctate al servidor
        ssh.connect(therouter, username=theuser, password=thepassword, port=theport, timeout=10)  # timeout=10 seg

        # Crea un cliente SFTP
        sftp = ssh.open_sftp()

        # Copia cada archivo
        for archivo_origen in archivos_origen:
            nombre_archivo = os.path.basename(archivo_origen)
            ruta_destino_completa = os.path.join(theroute, nombre_archivo)

            try:
                ssh.exec_command(f"/system backup save dont-encrypt=yes name=($filename);")
                # Copio los archivos de backup
                sftp.get(archivo_origen, ruta_destino_completa)
                print(f"Archivo '{nombre_archivo}' copiado a '{ruta_destino_completa}' correctamente.")
            except Exception as e:
                print(f"Error al copiar '{nombre_archivo}': {e}")

        # Cierra la conexión SFTP y SSH
        sftp.close()
        ssh.close()

    except paramiko.AuthenticationException:
        print("Error de autenticación. Verifica el usuario y la contraseña.")
    except paramiko.SSHException as e:
        print(f"Error de SSH: {e}")
    except Exception as e:
        print(f"Error general: {e}")
# FIN de la funcion que copia el backup

# Ejemplo de uso:
if __name__ == "__main__":
    therouter = "192.168.157.11"
    theuser = "dcasavilla"
    thepassword = "K3pcm2d6c@iT"
    theport = 22
    archivos_origen = ["backup-carrera-linux.backup", "backup-carrera-linux.rsc"]  # Reemplaza con tus rutas
    theroute = "/home/dcasavilla"  # Reemplaza con la ruta remota

    copia_backup(therouter, theuser, thepassword, theport, theroute, archivos_origen)
