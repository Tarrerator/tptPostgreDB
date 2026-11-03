function Resolve-tptPostgreDBEnvironment {
    <#
    .SYNOPSIS
        Resuelve los parámetros de conexión para PostgreSQL.

    .DESCRIPTION
        Función privada. Toma parámetros de conexión Server, Port, Database, Username, Credential,
        resuelve valores predeterminados y construye un comando psql seguro con el vector de argumentos adecuado.
        Si no se proporciona Credential, intenta leer PGPASSWORD del entorno; si tampoco, lanza error.

    .PARAMETER Server
        Host de PostgreSQL (default: localhost si $null).
    .PARAMETER Port
        Puerto de PostgreSQL (default: 5432).
    .PARAMETER Database
        Base de datos de PostgreSQL (default: 'postgres' si $null).
    .PARAMETER Username
        Usuario de PostgreSQL.
    .PARAMETER Credential
        Credenciales PSCredential para la conexión.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter()]
        [string]$Server = $null,

        [Parameter()]
        [int]$Port = 5432,

        [Parameter()]
        [string]$Database = $null,

        [Parameter()]
        [string]$Username = $null,

        [Parameter()]
        [PSCredential]$Credential = $null
    )

    # Resolver valores predeterminados
    if (-not $Server) { $Server = 'localhost' }
    if (-not $Database) { $Database = 'postgres' }

    # Resolver credenciales
    if (-not $Credential) {
        $envPassword = $env:PGPASSWORD
        if (-not $envPassword) {
            throw 'No se proporcionó Credential y PGPASSWORD no está configurado en el entorno. Proporcione -Credential o configure PGPASSWORD.'
        }
        $ssPtr = [System.Runtime.InteropServices.Marshal]::StringToCoTaskMemUni([string]$envPassword)
        try {
            $securePassword = [System.Runtime.InteropServices.Marshal]::SecureStringFromCoTaskMemUni($ssPtr)
        } finally {
            [System.Runtime.InteropServices.Marshal]::FreeCoTaskMemUni($ssPtr)
        }
        $Credential = New-Object System.Management.Automation.PSCredential($Username, $securePassword)
    }

    # Construir vector de argumentos para psql
    $psqlArgs = @()
    $psqlArgs += "-h$Server"
    $psqlArgs += "-p$Port"
    $psqlArgs += "-d$Database"
    $psqlArgs += "-U$Username"
    $psqlArgs += "-w"
    $psqlArgs += "-At"
    $psqlArgs += "-F'"
    $psqlArgs += '-P"footer_off=1"'
    $psqlArgs += "ON_ERROR_STOP=1"

    # Construir objeto de conexión para retorno
    $connectionInfo = @{ Server = $Server; Port = $Port; Database = $Database; Username = $Username; Credential = $Credential; Arguments = $psqlArgs }

    $connectionInfo
}
