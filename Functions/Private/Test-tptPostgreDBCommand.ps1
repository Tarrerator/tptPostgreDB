function Test-tptPostgreDBCommand {
    <#
    .SYNOPSIS
        Verifica que psql esté disponible en el PATH.

    .DESCRIPTION
        Función privada. Si psql no está disponible, lanza un error con
        instrucciones de instalación para Debian o macOS. Devuelve el path absoluto de psql.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $psqlCommand = Get-Command psql -ErrorAction SilentlyContinue

    if (-not $psqlCommand) {
        throw 'psql no está disponible. Instálalo con: apt install postgresql-client (Debian) o brew install libpq (macOS).'
    }

    $psqlCommand.Path
}
