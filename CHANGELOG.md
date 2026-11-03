# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es/1.1.0/).

## [0.0.1] - 2026-11-03

### Añadido
- Esqueleto del módulo: manifiesto, cargador y estructura Public/Private.
- Connect-tptPostgreDB: validación de conexión a PostgreSQL vía psql.
- Get-tptPostgreDBDatabases, Get-tptPostgreDBTables, Get-tptPostgreDBUsers,
  Get-tptPostgreDBConnections, Get-tptPostgreDBStatus: inventario inicial.

### Documentación
- README.md: visión general, tabla de funciones, ejemplos de uso y configuración.
- ROADMAP.md: plan para inventario avanzado, administración, mantenimiento,
  observabilidad y calidad.

### Tareas pendientes
- Get-tptPostgreDBIndex (índices con tamaño)
- Get-tptPostgreDBSequence
- Get-tptPostgreDBReplication (pg_stat_replication)
- Get-tptPostgreDBQuery (top queries por tiempo)
- New-tptPostgreDBDatabase
- Remove-tptPostgreDBDatabase
- New-tptPostgreDBUser
- Remove-tptPostgreDBUser
- Invoke-tptPostgreDBVacuum (VACUUM/ANALYZE)
- Invoke-tptPostgreDBCheckpoint
- Get-tptPostgreDBMetrics (pg_stat_database + temporal)
- Test-tptPostgreDBHealth
- Testes Pester
- CI
