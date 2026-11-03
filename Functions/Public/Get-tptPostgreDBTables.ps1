function Get-tptPostgreDBTables {
    <#
    .SYNOPSIS
        Obtiene un inventario de tablas en un servidor PostgreSQL, opcionalmente filtrado por esquema(s).

    .DESCRIPTION
        Función pública. Enumera tablas con tamaño y comentario. Acepta uno o más esquemas
        como wildcards (por ejemplo, 'public', 'schema1', 'schema2*'). Si no se proporciona,
        default a 'public'. Soporta -Credential o PGPASSWORD del entorno.

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
    .PARAMETER Schema
        Array opcional de esquemas a consultar. Por defecto @('public').
    .EXAMPLE
        Get-tptPostgreDBTables -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'
        Devuelve todas las tablas del esquema 'public'.

    .EXAMPLE
        Get-tptPostgreDBTables -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin' -Schema @('public', 'schema1')
        Devuelve tablas solo de los esquemas 'public' y 'schema1'.

    .OUTPUTS
        System.Management.Automation.PSObject[] con Schema, Name, Size, Comment.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [string]$Server = $null,

        [int]$Port = 5432,

        [string]$Database = $null,

        [string]$Username = $null,

        [ValidateNotNull()][System.Management.Automation.PSCredential]$Credential = $null,

        [string[]]$Schema = @('public')
    )

    # Resolver entorno y obtener argumentos
    $envConfig = Resolve-tptPostgreDBEnvironment -Server $Server -Port $Port -Database $Database -Username $Username -Credential $Credential

    # Construir patrón de esquema para la query (regex)
    $schemaPattern = if ($Schema) {
        $escapedSchemas = $Schema | ForEach-Object { [regex]::Escape($_) }
        -join ($escapedSchemas -join '|')
    } else {
        'public'
    }

    # Query para obtener tablas
    $query = @"
    SELECT t.schemaname, t.tablename,
           pg_size_pretty(pg_total_relation_size(t.schemaname||'.'||t.tablename)) AS size,
           obj_description((t.schemaname||'.'||t.tablename)::regclass, 'relation') AS comment
    FROM pg_tables t
    WHERE t.schemaname ~* '$schemaPattern'
    ORDER BY t.schemaname, t.tablename;
"@

    $psqlArgs = $envConfig.Arguments + @($query)

    # Ejecutar psql
    $process = Start-Process -FilePath (Test-tptPostgreDBCommand) -ArgumentList $psqlArgs -NoNewWindow -PassThru -Wait

    if ($process.ExitCode -ne 0) {
        throw "Falló la ejecución de la consulta: Get-tptPostgreDBTables."
    }

    # Parsear salida máquina-legible
    $output = $process.StandardOutput.ReadToEnd().Trim()
    $lines = $output -split "`n" | Where-Object { $_ -and $_ -notmatch "^Schemaname\|^Tablename\|^size\|^comment" }

    foreach ($line in $lines) {
        $fields = $line -split "\t", 4
        if ($fields.Count -ge 4) {
            [PSCustomObject]@{
                Schema = $fields[0]
                Name = $fields[1]
                Size = $fields[2]
                Comment = $fields[3]
            }
        }
    }
}
