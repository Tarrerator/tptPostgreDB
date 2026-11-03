# Roadmap

## Conexión
- [x] Connect-tptPostgreDB: validación de conexión rápida con PostgreSQL.
- [ ] Fichero de configuración manual `~/.tpt/tptPostgreDB.yaml` (documentado, no programático).

## Inventario
- [x] Get-tptPostgreDBDatabases: inventario de bases de datos.
- [x] Get-tptPostgreDBTables: inventario de tablas con tamaño y comentario.
- [x] Get-tptPostgreDBUsers: inventario de usuarios con privilegios y estado de contraseña.
- [x] Get-tptPostgreDBConnections: inventario de conexiones activas.
- [x] Get-tptPostgreDBStatus: información de estado del servidor PostgreSQL.
- [ ] Get-tptPostgreDBIndex (índices con tamaño y tablas relacionadas).
- [ ] Get-tptPostgreDBSequence (secuencias con valores actuales).
- [ ] Get-tptPostgreDBReplication (pg_stat_replication).
- [ ] Get-tptPostgreDBQuery (top queries por tiempo de ejecución).

## Administración
- [ ] New-tptPostgreDBDatabase (crear nueva base de datos).
- [ ] Remove-tptPostgreDBDatabase (eliminar base de datos con manejo seguro de errores).
- [ ] New-tptPostgreDBUser (crear nuevo usuario con privilegios configurables).
- [ ] Remove-tptPostgreDBUser (eliminar usuario con manejo seguro de dependencias).

## Mantenimiento
- [ ] Invoke-tptPostgreDBVacuum (VACUUM/ANALYZE en tablas seleccionadas).
- [ ] Invoke-tptPostgreDBCheckpoint (forzar checkpoint del servidor).
- [ ] Invoke-tptPostgreDBRebalance (rebalancear shards/clúster si aplica).

## Observabilidad
- [ ] Get-tptPostgreDBMetrics (métricas de pg_stat_database con agregación temporal).
- [ ] Test-tptPostgreDBHealth (chequeo de salud integral con umbrales configurables).
- [ ] Invoke-tptPostgreDBLogRotation (rotación segura de logs del servidor).
- [ ] Get-tptPostgreDBWaitEvents (monitorear waits actuales del servidor).

## Calidad
- [ ] Testes Pester (tests unitarios y de integración).
- [ ] CI (GitHub Actions con lint, tests y release automation).
- [ ] Documentación (documentación de API en docfx o similar).
- [ ] Muestras (ejemplos de scripts de administración comunes).
