function Get-tptPostgreDBConfig {
    <#
    .SYNOPSIS
        Lee y valida el fichero de configuración centralizado para tptPostgreDB.
    
    .DESCRIPTION
        Lee el fichero YAML centralizado ~/.tpt/tpt_config.yaml, extrae la sección
        tptPostgreDB y valida su estructura y campos obligatorios. Retorna una matriz
        de objetos de plataforma con validación de plataforma predeterminada.
    
    .OUTPUTS
        [PSCustomObject[]] Matriz de objetos de plataforma validados.
    
    .EXAMPLE
        Get-tptPostgreDBConfig
        Lee la configuración centralizada y retorna plataformas PostgreDB validadas.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param()


    $yamlData = Convert-tptYamlToPSCustomObject

    if (-not $yamlData -or -not $yamlData.platforms.tptPostgreDB) {
        throw "No se encontró la sección 'tptPostgreDB' en la configuración YAML"
    }

    $platforms = $yamlData.platforms.tptPostgreDB
    $platformsArray = @()

    foreach ($platform in $platforms) {
        # Validar campos obligatorios según la documentación
        $requiredFields = @('name', 'server', 'database')
        $missingFields = $requiredFields | Where-Object { -not $platform.PSObject.Properties.Name.Contains($_) }
        
        if ($missingFields) {
            throw "Plataforma '$($platform.name)': campos obligatorios faltantes: $(Join-String -InputObject $missingFields)"
        }

        # Validar puerto (si se proporciona)
        if ($platform.PSObject.Properties.Name.Contains('port')) {
            if ($platform.port -lt 1 -or $platform.port -gt 65535) {
                throw "Plataforma '$($platform.name)': puerto inválido '$($platform.port)'"
            }
        } else {
            # Establecer puerto por defecto si no se proporciona
            $platform | Add-Member -NotePropertyName 'port' -NotePropertyValue 5432
        }

        # Validar campo default (debe ser bool
        if ($platform.PSObject.Properties.Name.Contains('default')) {
            if ($platform.default -isnot [bool]) {
                throw "Plataforma '$($platform.name)': campo 'default' debe ser booleano, se recibió $($platform.default)"
            }
        } else {
            # Establecer default false si no se proporciona
            $platform | Add-Member -NotePropertyName 'default' -NotePropertyValue $false
        }

        # Asegurar que tags es una matriz (si se proporciona
        if ($platform.PSObject.Properties.Name.Contains('tags')) {
            if ($platform.tags -isnot [array]) {
                throw "Plataforma '$($platform.name)': campo 'tags' debe ser una matriz"
            }
        } else {
            # Establecer tags vacío si no se proporciona
            $platform | Add-Member -NotePropertyName 'tags' -NotePropertyValue @()
        }

        $platformsArray += $platform
    }

    # Validar que hay al menos una plataforma predeterminada
    $defaultPlatforms = $platformsArray | Where-Object { $_.default -eq $true }
    if ($defaultPlatforms.Count -eq 0) {
        throw "No se encontró plataforma predeterminada en la configuración tptPostgreDB. Al menos una plataforma debe tener 'default: true'."
    }

    if ($defaultPlatforms.Count -gt 1) {
        throw "Múltiples plataformas predeterminadas en tptPostgreDB. Solo una plataforma debe tener 'default: true'."
    }

    $platformsArray
}