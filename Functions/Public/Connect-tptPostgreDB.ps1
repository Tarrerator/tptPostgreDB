function Connect-tptPostgreDB {
    <#
    .SYNOPSIS
        Establece una conexión rápida de validación con una base de datos PostgreSQL.

    .DESCRIPTION
        Función pública. Ejecuta un comando SELECT version() para verificar que
        la conexión a PostgreSQL funciona correctamente. No guarda estado (los parámetros
        se pasan a cada función de inventario). Soporta -Credential o PGPASSWORD del entorno.
        Acepta -Platform para resolver la conexión desde la configuración centralizada.

    .PARAMETER Server
        Host de PostgreSQL (default: localhost si $null). Si se usa -Platform y Server no se
        proporciona, se toma del YAML.
    .PARAMETER Port
        Puerto de PostgreSQL (default: 5432). Si se usa -Platform y Port no se proporciona,
        se toma del YAML.
    .PARAMETER Database
        Base de datos de PostgreSQL (default: 'postgres' si $null). Si se usa -Platform y
        Database no se proporciona, se toma del YAML.
    .PARAMETER Username
        Usuario de PostgreSQL.
    .PARAMETER Credential
        Credenciales PSCredential para la conexión. Requiere que también se proporcione -Username.
    .PARAMETER Platform
        Nombre de la plataforma desde la configuración centralizada (YAML).
        Si se proporciona, los valores de Server, Port y Database se toman del YAML a menos que
        se proporcionen explícitamente.
    .EXAMPLE
        Connect-tptPostgreDB -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'
        Valida la conexión usando el usuario 'admin' (PGPASSWORD del entorno o -Credential).

    .EXAMPLE
        Connect-tptPostgreDB -Username 'admin' -Credential (Get-Credential) -Platform db-prod
        Resuelve la plataforma db-prod desde el YAML centralizado.

    .OUTPUTS
        System.Management.Automation.PSObject con Server, Port, Database, Version, User, Connected.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Platform = $null,

        [string]$Server = $null,

        [int]$Port = 5432,

        [string]$Database = $null,

        [string]$Username = $null,

        [ValidateNotNull()][System.Management.Automation.PSCredential]$Credential = $null
    )

    Import-Module (Join-Path $PSScriptRoot -ChildPath 'TPT-Helpers.ps1') -Force

    # Resolver parámetros desde YAML si -Platform está presente
    if ($Platform) {
        $config = Get-tptPostgreDBConfig
        $selectedPlatform = $config | Where-Object { $_.name -eq $Platform }
        
        if (-not $selectedPlatform) {
            throw "Plataforma '$Platform' no encontrada en la configuración de tptPostgreDB."
        }

        # Usar valores del YAML solo si los parámetros no fueron proporcionados explícitamente
        if (-not $Server) { $Server = $selectedPlatform.server }
        if ($Port -eq 5432 -and $selectedPlatform.port) { $Port = $selectedPlatform.port }
        if (-not $Database) { $Database = $selectedPlatform.database }
    }

    # Resolver entorno y obtener argumentos
    $envConfig = Resolve-tptPostgreDBEnvironment -Server $Server -Port $Port -Database $Database -Username $Username -Credential $Credential

    # Verificar conexión ejecutando SELECT version()
    $versionQuery = 'SELECT version();'
    $psqlArgs = $envConfig.Arguments + @($versionQuery)

    # Ejecutar psql
    $process = Start-Process -FilePath (Test-tptPostgreDBCommand) -ArgumentList $psqlArgs -NoNewWindow -PassThru -Wait

    if ($process.ExitCode -ne 0) {
        throw "Falló la conexión a PostgreSQL en '$($envConfig.Server):$($envConfig.Port)' como usuario '$($envConfig.Username)' a la base de datos '$($envConfig.Database)'."
    }

    # La salida está en formato máquina-legible (sin cabecera), tomar primera línea
    $output = $process.StandardOutput.ReadToEnd().Trim()

    [PSCustomObject]@{
        Server = $envConfig.Server
        Port = $envConfig.Port
        Database = $envConfig.Database
        Version = $output
        User = $envConfig.Username
        Connected = $true
    }
}
