REM El servicio RDP de Windows tiene un periodo de prueba de 180 días, con esto se borra el valor
REM del registro que cuenta esos días y lo vuelve a 0, HAY QUE REINICIAR EL SERVIDOR para que tome los cambios
REM como el script esta pensado para que se ejecute automaticamente no muestro mensajer por consola

REM Lo primero es borrar la entrada en el registro
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod" /f

REM Ahora fuerzo el reinicio del servidor
shutdown /r /f

REM Esto se puede programar cada 175 dias para tener una "licencia permanente" del servidio RDP