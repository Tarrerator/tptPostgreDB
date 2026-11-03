@{
    # Identidad del módulo
    RootModule           = 'tptPostgreDB.psm1'
    ModuleVersion        = '0.0.1'
    GUID                 = 'b8f7c5e9-2a1d-4b7c-9f3e-8d6c5b4a3e2f'
    Author               = 'TPT'
    CompanyName          = 'TPT'
    Copyright            = '(c) 2026 TPT'

    # Descripción
    Description          = 'Módulo PowerShell que envuelve psql (CLI oficial de PostgreSQL) para gestionar bases de datos PostgreSQL: conexiones, inventario y operaciones. Parte de la suite *tarre pwsh tools* (TPT): prefijo `tpt` en módulos y funciones para evitar colisiones.'

    # Compatibilidad
    PowerShellVersion    = '7.2'
    CompatiblePSEditions = @('Desktop', 'Core')

    # Exportaciones explícitas: nada de comodines
    FunctionsToExport    = @(
        'Connect-tptPostgreDB'
        'Get-tptPostgreDBDatabases'
        'Get-tptPostgreDBTables'
        'Get-tptPostgreDBUsers'
        'Get-tptPostgreDBConnections'
        'Get-tptPostgreDBStatus'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()

    PrivateData          = @{
        PSData = @{
            Tags         = @('PostgreSQL', 'psql', 'Database', 'Inventory')
            ProjectUri   = 'https://github.com/Tarrerator/tptPostgreDB'
            ReleaseNotes = 'Esqueleto del módulo: manifiesto, cargador y estructura Public/Private.'
        }
    }
}