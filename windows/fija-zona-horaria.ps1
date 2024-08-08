# Creado por Mikiztly (https://github.com/Mikiztly) para establecer la zona horaria de Windows por medio de gpo

# Primero guardo el valor de la zona horaria en una variable
$Zona = Get-TimeZone
# Ahora me fijo si la zona horaria actual esta bien
if ($Zona = "Argentina Standard Time") {
  Write-Host "La zona horaria ya está configurada como 'Argentina Standard Time'." $Zona
} else {
  # Si la zona horaria es distinta de "Argentina Standard Time" fijar la zona horaria en "Argentina Standard Time"
  # Set-TimeZone -Name "Argentina Standard Time"
  Write-Host "Zona horaria establecida correctamente a 'Argentina Standard Time'. " $Zona
}
