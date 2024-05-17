# Credenciales de acceso al hipervisor
$hipervisorUsuario = "root"
$hipervisorContraseña = "Y1k1$#P2pndf"
$VMsource = "W10-22H2"
$VMclone = "W10-22H2-clone"
# $date = Get-Date
$Hostesxi = "192.168.69.2"

# Dirección IP o nombre del servidor del hipervisor
$hipervisorServidor = "192.168.69.2"

# Conexión al hipervisor
Connect-VIServer -Server $hipervisorServidor -User $hipervisorUsuario -Password $hipervisorContraseña

##Clone VM, disco virtual tipo thick y carpeta de almacenaiento de la VM
New-VM -VM $VMsource -Name $VMclone -VMHost $Hostesxi -DiskStorageFormat Thick

# Desconexión del hipervisor
Disconnect-VIServer -Server $hipervisorServidor -Force -Confirm:$false