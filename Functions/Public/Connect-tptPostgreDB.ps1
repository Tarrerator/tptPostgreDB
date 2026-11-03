function Connect-tptPostgreDB {
    <#
    .SYNOPSIS
        Establece una conexión rápida de validación con una base de datos PostgreSQL.

    .DESCRIPTION
        Función pública. Ejecuta un comando SELECT version() para verificar que
        la conexión a PostgreSQL funciona correctamente. No guarda estado (los parámetros
        se pasan a cada función de inventario). Soporta -Credential o PGPASSWORD del entorno.

    .PARAMETER Server
        Host de PostgreSQL (default: localhost si $null).
    .PARAMETER Port
        Puerto de PostgreSQL (default: 5432).
    .PARAMETER Database
        Base de datos de PostgreSQL (default: 'postgres' si $null).
    .PARAMETER Username
        Usuario de PostgreSQL.
    .PARAMETER Credential
        Credenciales PSCredential para la conexión. Requiere que también se proporcione -Username.
    .EXAMPLE
        Connect-tptPostgreDB -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'
        Valida la conexión usando el usuario 'admin' (PGPASSWORD del entorno o -Credential).

    .OUTPUTS
        System.Management.Automation.PSObject con Server, Port, Database, Version, User, Connected.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [string]$Server = $null,

        [int]$Port = 5432,

        [string]$Database = $null,

        [string]$Username = $null,

        [ValidateNotNull()][System.Management.Automation.PSCredential]$Credential = $null
    )

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
