function Get-tptPostgreDBStatus {
    <#
    .SYNOPSIS
        Obtiene información de estado del servidor PostgreSQL.

    .DESCRIPTION
        Función pública. Devuelve versión del servidor y versión del cliente psql,
        junto con los parámetros de conexión usados. Soporta -Credential o PGPASSWORD del entorno.

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
        Get-tptPostgreDBStatus -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'
        Devuelve estado del servidor PostgreSQL y del cliente.

    .OUTPUTS
        System.Management.Automation.PSObject con Server, Port, Version, Database.
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

    # Query para obtener estado del servidor
    $versionQuery = 'SELECT version();'
    $psqlArgs = $envConfig.Arguments + @($versionQuery)

    # Ejecutar psql
    $process = Start-Process -FilePath (Test-tptPostgreDBCommand) -ArgumentList $psqlArgs -NoNewWindow -PassThru -Wait

    if ($process.ExitCode -ne 0) {
        throw "Falló la ejecución de la consulta: Get-tptPostgreDBStatus."
    }

    # Parsear salida máquina-legible
    $output = $process.StandardOutput.ReadToEnd().Trim()

    # Obtener versión del cliente psql
    $psqlVersion = & (Test-tptPostgreDBCommand) --version

    [PSCustomObject]@{
        Server = $envConfig.Server
        Port = $envConfig.Port
        Version = "Servidor: $output; Cliente: $psqlVersion"
        Database = $envConfig.Database
    }
}
