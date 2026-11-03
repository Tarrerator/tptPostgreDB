function Get-tptPostgreDBUsers {
    <#
    .SYNOPSIS
        Obtiene un inventario de usuarios de PostgreSQL.

    .DESCRIPTION
        Función pública. Enumera usuarios con privilegios (CREATE DB, SUPERUSER, REPLICATION)
        y estado de contraseña. Soporta -Credential o PGPASSWORD del entorno.

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
        Get-tptPostgreDBUsers -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'
        Devuelve todos los usuarios con privilegios y estado de contraseña.

    .OUTPUTS
        System.Management.Automation.PSObject[] con Name, CanCreateDB, IsSuperuser, CanRepl, HasPassword.
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

    # Query para obtener usuarios
    $query = @"
    SELECT usename, usecreatedb, usesuper, userepl, passwd IS NULL AS has_password
    FROM pg_user
    ORDER BY usename;
"@

    $psqlArgs = $envConfig.Arguments + @($query)

    # Ejecutar psql
    $process = Start-Process -FilePath (Test-tptPostgreDBCommand) -ArgumentList $psqlArgs -NoNewWindow -PassThru -Wait

    if ($process.ExitCode -ne 0) {
        throw "Falló la ejecución de la consulta: Get-tptPostgreDBUsers."
    }

    # Parsear salida máquina-legible
    $output = $process.StandardOutput.ReadToEnd().Trim()
    $lines = $output -split "`n" | Where-Object { $_ -and $_ -notmatch "^Usename\|^usecreatedb\|^usesuper\|^userepl\|^has_password" }

    foreach ($line in $lines) {
        $fields = $line -split "\t", 5
        if ($fields.Count -ge 5) {
            [PSCustomObject]@{
                Name = $fields[0]
                CanCreateDB = if ($fields[1] -eq 'True' -or $fields[1] -eq 't') { $true } else { $false }
                IsSuperuser = if ($fields[2] -eq 'True' -or $fields[2] -eq 't') { $true } else { $false }
                CanRepl = if ($fields[3] -eq 'True' -or $fields[3] -eq 't') { $true } else { $false }
                HasPassword = if ($fields[4] -eq 'True' -or $fields[4] -eq 't') { $true } else { $false }
            }
        }
    }
}
