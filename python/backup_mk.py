#!/usr/bin/python3

# Script de Cesar para cambiar los datos de los routers MK
# https://github.com/cesarsalva91/NeMikroPy

'''
Modulos que se deben instalar para que funcione:
sudo apt install python3-pip
pip install paramiko
'''

# Importacion de librerias a utilizar
import os, sys, csv, datetime, time, paramiko

# Verificacion de la existencia de los archivos
def verificar_archivos_csv(BaseDatos, Equipos):
  """Verifica si dos archivos CSV existen y son accesibles.
    Args:
      BaseDatos: La ruta al primer archivo CSV.
      Equipos: La ruta al segundo archivo CSV.
    Devuelve:
      True si ambos archivos existen y son accesibles, False en caso contrario.
      Imprime un mensaje de error si alguno de los archivos no existe o no es accesible.
    """
  if not os.path.exists(BaseDatos) or not os.access(BaseDatos, os.R_OK):
    print(f"Error: El archivo '{BaseDatos}' no existe o no es accesible.")
    return False
  if not os.path.exists(Equipos) or not os.access(Equipos, os.R_OK):
    print(f"Error: El archivo '{Equipos}' no existe o no es accesible.")
    return False

  return True
# FIN de la funcion para verificar los archivos

# Abre el archivo con los parametros de la DB y los guarda en una coleccion
def parametros_db(Ruta_DB):
  """Abre un archivo CSV y guarda los Parametros de la primera fila en una coleccion.
    Devuelve:
      Una coleccion con los valores de los Parametros, o None si ocurre un error.
      Imprime un mensaje de error si el archivo no se puede abrir o si está vacío.
    """
  try:
    # Se abre el archivo
    with open(Ruta_DB, 'r', newline='', encoding='utf-8') as Tmp_DB:
      Tmp_Reg = csv.reader(Tmp_DB)
      Parametros = next(Tmp_Reg, None)  # Lee la primera fila
      # Si el archivo esta vacio Muestra el mensaje de error
      if Parametros is None:
        print(f"Error: El archivo CSV '{Ruta_DB}' está vacío.")
        return None
      # Como se pudo leer todo devuelve los parametros
      return Parametros
  # Manejo de errores
  except Exception as Macana:
    print(f"Error al abrir o leer el archivo CSV: {Macana}")
    return None
# FIN de la funcion para extraer los parametros de la DB

# Guardo en la DB el resultado de hacer el backup
def reporte(Resultado):
  if Parametros:
    print()
    print("********************")
    print("Parametros del Servidor web:")
    print(f"Host: {Parametros[0]}")
    print(f"Usuario: {Parametros[1]}")
    print(f"Password: {Parametros[2]}")
    print(f"BaseDatos: {Parametros[3]}")
    print(f"Resultado: {Resultado}")
    print("********************")
    print()
  # espero 5 segundos para poder leer el mensaje
  time.sleep(5)
# FIN del reporte

'''
Router de pruebas MK
user: admin
pass: admin
ssh: 22
ip: 192.168.78.53
'''
# Creacion de backup de un router o sw Mikrotic
def backup_mk(therouter, theuser, thepassword, theport, theroute, archivo_bkp):
  """Copia archivos a un servidor remoto por SSH.
  Args:
    therouter: La dirección IP o nombre de host del servidor remoto.
    theuser: El nombre de usuario para la conexión SSH.
    thepassword: La contraseña para la conexión SSH.
    theport: El puerto SSH (por defecto 22).
    archivo_bkp: el nombre del backup a crear
    theroute: La ruta en el servidor donde se copiarán los archivos.
  """
  try:
    # Crea un cliente SSH
    ssh = paramiko.SSHClient()
    # Agrego la coneccion ssh como de confianza
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy()) 
    # Coneccion al servidor
    ssh.connect(therouter, username=theuser, password=thepassword, port=theport, timeout=10)
    # Crea un cliente SFTP
    sftp = ssh.open_sftp()
    # Creo el backup
    ssh.exec_command(f"/export terse file = {archivo_bkp};")
    ssh.exec_command("/system backup save dont-encrypt=yes name=($filename);")
    ssh.exec_command("put $filename' | tail -n 1 | tr -d '\r'")
    # Copio los archivos de backup
    archivo_origen = archivo_bkp + ".backup"
    sftp.get(archivo_origen, theroute)
    print(f"Archivo '{archivo_origen}' copiado a '{theroute}' correctamente.")
    archivo_origen = archivo_bkp + ".rsc"
    sftp.get(archivo_origen, theroute)
    print(f"Archivo '{archivo_origen}' copiado a '{theroute}' correctamente.")
    # Cierra la conexión SFTP y SSH
    sftp.close()
    ssh.close()
    return "OK"
  
  # Manejo de errores
  except paramiko.AuthenticationException:
    return "Error de autenticación. Verifica el usuario y la contraseña."
  except paramiko.SSHException as Macana:
    return (f"Error de SSH: {Macana}")
  except Exception as Macana:
    return (f"Error general: {Macana}")
# FIN de la creacion del backup

# Programa principal
if __name__ == "__main__":
  # Verificacion que se pasen los dos argumentos y sean archivos csv
  if len(sys.argv) != 3:
    print("Uso: python script.py <ruta_del_archivo1.csv> <ruta_del_archivo2.csv>")
    sys.exit(1)

  # Guardo los archivos csv en dos variables
  BaseDatos = sys.argv[1]
  Equipos = sys.argv[2]
  # Comprobamos que los archivos sean existan y sean accesibles
  if verificar_archivos_csv(BaseDatos, Equipos):
    print("Ambos archivos CSV existen y son accesibles:")
    print(f"Ruta del primer archivo: {BaseDatos}")
    print(f"Ruta del segundo archivo: {Equipos}")
  else:
    sys.exit(1)

  # Extraigo los parametros de la DB y los guardo en una coleccion, despues siempre utilizo esta coleccion para guardar un informe de la ejecucion del backup
  Parametros = parametros_db(BaseDatos)

  # Reccorro todos los registros del archivo Equipos para hacer el backup
  try:
    # Abro el archivo de Equipos pasado como parametro
    with open(Equipos, 'r', newline='', encoding='utf-8') as Tmp_Equipos:
      Tmp_Reg = csv.reader(Tmp_Equipos)
      # Lee la primera fila para acceder a los campos por nombre
      Encabezados = next(Tmp_Reg, None) 
      # Recorro cada fila del archivo
      for XLoop in Tmp_Reg:
        # Verifico que haya encabezados y creo un diccionario
        if Encabezados:
          datos = dict(zip(Encabezados, XLoop))
          # Guardo los campos en variables refiriendome a los encabezados
          therouter = datos.get("Router")
          thepassword = datos.get("Password")
          thename = datos.get("\ufeffNombre")
          theuser = datos.get("Usuario")
          theclient = datos.get("Cliente")
          theport = datos.get("Puerto")
          theroute = os.getcwd() + "/" + datos.get("Ruta") + "/" + thename
          # Imprimo las variables
          print()
          print("--------------------")
          print(f"Router: {therouter}")
          print(f"Password: {thepassword}")
          print(f"Nombre: {thename}")
          print(f"Usuario: {theuser}")
          print(f"Cliente: {theclient}")
          print(f"Puerto: {theport}")
          print(f"Ruta: {theroute}")
        else:
          print(f"El archivo '{Equipos}' no tiene encabezados.")
        # Si no existe creo el directorio para el backup
        if not os.path.exists(theroute):
          os.makedirs(theroute)
        # Creo el backup
        print()
        print("Creando backup...")
        # Obtengo la fecha y hora actual
        archivo_bkp = thename + "-" + datetime.datetime.now().strftime("%Y-%m-%d@%H-%M-%S")
        # Llama a la funcion para hacer el backup y guarda en la DB si se realizo bien o no el backup
        reporte(backup_mk(therouter, theuser, thepassword, theport, theroute, archivo_bkp))
  # Manejo de errores
  except Exception as Macana:
    print(f"Error en el programa principal: {Macana}")
  except OSError as Macana:
    print(f"Error al crear directorios: {Macana}")
