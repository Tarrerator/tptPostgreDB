function Get-tptPostgreDBConnections {
    <#
    .SYNOPSIS
        Obtiene un inventario de conexiones activas de PostgreSQL.

    .DESCRIPTION
        Función pública. Enumera sesiones de base de datos excluyendo el PID actual,
        mostrando database, usuario, aplicación, cliente, estado y tiempo de inicio.
        Soporta -Credential o PGPASSWORD del entorno.

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
        Get-tptPostgreDBConnections -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'
        Devuelve todas las conexiones activas excepto la sesión actual.

    .OUTPUTS
        System.Management.Automation.PSObject[] con Database, User, Application, ClientAddress, State, StartedAt.
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

    # Query para obtener conexiones
    $query = @"
    SELECT datname, usename, application_name, client_addr::text AS client_addr, state, backend_start
    FROM pg_stat_activity
    WHERE pid <> pg_backend_pid()
    ORDER BY backend_start DESC;
"@

    $psqlArgs = $envConfig.Arguments + @($query)

    # Ejecutar psql
    $process = Start-Process -FilePath (Test-tptPostgreDBCommand) -ArgumentList $psqlArgs -NoNewWindow -PassThru -Wait

    if ($process.ExitCode -ne 0) {
        throw "Falló la ejecución de la consulta: Get-tptPostgreDBConnections."
    }

    # Parsear salida máquina-legible
    $output = $process.StandardOutput.ReadToEnd().Trim()
    $lines = $output -split "`n" | Where-Object { $_ -and $_ -notmatch "^Datname\|^Usename\|^Application_name\|^Client_addr\|^State\|^Backend_start" }

    foreach ($line in $lines) {
        $fields = $line -split "\t", 6
        if ($fields.Count -ge 6) {
            [PSCustomObject]@{
                Database = $fields[0]
                User = $fields[1]
                Application = $fields[2]
                ClientAddress = $fields[3]
                State = $fields[4]
                StartedAt = $fields[5]
            }
        }
    }
}
