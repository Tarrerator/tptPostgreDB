function Get-tptPostgreDBDatabases {
    <#
    .SYNOPSIS
        Obtiene un inventario de todas las bases de datos en un servidor PostgreSQL.

    .DESCRIPTION
        Función pública. Enumera bases de datos con encoding, owner, límite de conexión
        y conteo de conexiones activas. Usa patronímico para filtrar bases de datos.
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
        Get-tptPostgreDBDatabases -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'
        Devuelve todas las bases de datos con información de encoding, owner, etc.

    .OUTPUTS
        System.Management.Automation.PSObject[] con Name, Encoding, Owner, ConnectionLimit, ActiveConnections.
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

    # Query para obtener bases de datos
    $query = @"
    SELECT datname, pg_encoding_to_char(datencoding) AS encoding, pg_get_userbyid(datdba) AS owner, datconnlimit,
           (SELECT count(*) FROM pg_stat_activity WHERE datname = d.datname) AS active_conns
    FROM pg_database d
    ORDER BY datname;
"@

    $psqlArgs = $envConfig.Arguments + @($query)

    # Ejecutar psql
    $process = Start-Process -FilePath (Test-tptPostgreDBCommand) -ArgumentList $psqlArgs -NoNewWindow -PassThru -Wait

    if ($process.ExitCode -ne 0) {
        throw "Falló la ejecución de la consulta: Get-tptPostgreDBDatabases."
    }

    # Parsear salida máquina-legible
    $output = $process.StandardOutput.ReadToEnd().Trim()
    $lines = $output -split "`n" | Where-Object { $_ -and $_ -notmatch "^Datname\|^encoding\|^owner\|^datconnlimit\|^active_conns" }

    foreach ($line in $lines) {
        $fields = $line -split "\t", 5
        if ($fields.Count -ge 5) {
            [PSCustomObject]@{
                Name = $fields[0]
                Encoding = $fields[1]
                Owner = $fields[2]
                ConnectionLimit = $fields[3]
                ActiveConnections = [int]$fields[4]
            }
        }
    }
}
