# Nombre del servicio que quieres reiniciar
$serviceName = "BeeAgent"

# Obtener el estado del servicio
$service = Get-Service -Name $serviceName

# Verificar si el servicio existe
if ($null -eq $service) {
    Write-Host "El servicio $serviceName no existe."
    exit 1
}

# Detener el servicio si está corriendo
if ($service.Status -eq 'Running') {
    Write-Host "Deteniendo el servicio $serviceName..."
    Stop-Service -Name $serviceName -Force
    # Esperar a que el servicio se detenga
    $service.WaitForStatus('Stopped', '00:01:00')
}

# Iniciar el servicio
Write-Host "Iniciando el servicio $serviceName..."
Start-Service -Name $serviceName

# Verificar el estado del servicio
$service = Get-Service -Name $serviceName
if ($service.Status -eq 'Running') {
    Write-Host "El servicio $serviceName se ha reiniciado correctamente."
} else {
    Write-Host "Hubo un problema al reiniciar el servicio $serviceName."
    exit 1
}