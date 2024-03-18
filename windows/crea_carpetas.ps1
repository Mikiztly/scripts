#Script para leer un csv separado por comas
# Lee el contenido del archivo
$fileContent = Get-Content -Path "D:\basura\torralvo\Proveedores.csv"

# Itera sobre las líneas del archivo
foreach ($line in $fileContent) {
    # Divide la línea utilizando el punto y coma como separador
    $fields = $line -split ';'

    # Extrae los valores necesarios, cada campo por separado
    $cod = $fields[0].Trim()
    $razonSocial = $fields[1].Trim()

    # Crea el nombre de la carpeta
    $folderName = "$cod-$razonSocial"

    # Reemplaza caracteres no permitidos en nombres de carpetas
    $folderName = $folderName -replace '[\\/:*?"<>|]', '_'

    # Crea la carpeta
    $folderPath = "D:\basura\torralvo\$folderName"
    New-Item -ItemType Directory -Path $folderPath -Force
}
# Informo que ya termino
Write-Host "Proceso completado."
