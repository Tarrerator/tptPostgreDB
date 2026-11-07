# tptPostgreDB

Módulo PowerShell que envuelve `psql` (CLI oficial de PostgreSQL) para gestionar bases de datos PostgreSQL: conexiones, inventario y operaciones.
Parte de la suite *tarre pwsh tools* (TPT): prefijo `tpt` en módulos y funciones para evitar colisiones.

## Funciones

| Función | Descripción |
|---------|-------------|
| [Connect-tptPostgreDB](https://github.com/Tarrerator/tptPostgreDB/blob/main/Functions/Public/Connect-tptPostgreDB.ps1) | Establece una conexión rápida de validación con una base de datos PostgreSQL. |
| [Get-tptPostgreDBDatabases](https://github.com/Tarrerator/tptPostgreDB/blob/main/Functions/Public/Get-tptPostgreDBDatabases.ps1) | Obtiene un inventario de todas las bases de datos en un servidor PostgreSQL. |
| [Get-tptPostgreDBTables](https://github.com/Tarrerator/tptPostgreDB/blob/main/Functions/Public/Get-tptPostgreDBTables.ps1) | Obtiene un inventario de tablas en un servidor PostgreSQL, opcionalmente filtrado por esquema(s). |
| [Get-tptPostgreDBUsers](https://github.com/Tarrerator/tptPostgreDB/blob/main/Functions/Public/Get-tptPostgreDBUsers.ps1) | Obtiene un inventario de usuarios de PostgreSQL. |
| [Get-tptPostgreDBConnections](https://github.com/Tarrerator/tptPostgreDB/blob/main/Functions/Public/Get-tptPostgreDBConnections.ps1) | Obtiene un inventario de conexiones activas de PostgreSQL. |
| [Get-tptPostgreDBStatus](https://github.com/Tarrerator/tptPostgreDB/blob/main/Functions/Public/Get-tptPostgreDBStatus.ps1) | Obtiene información de estado del servidor PostgreSQL. |

## Requisitos

- PowerShell 7.2 o superior
- `psql` (CLI oficial de PostgreSQL) en el PATH
- .NET Core (para PowerShell Core) o .NET Framework (para PowerShell Desktop)

## Ejemplo de uso

```powershell
# Importar el módulo
Import-Module /home/hermes/code/tptPostgreDB/tptPostgreDB.psd1 -Force

# Probar conexión
Connect-tptPostgreDB -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'

# Listar bases de datos
Get-tptPostgreDBDatabases -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'

# Listar tablas (default: esquema 'public')
Get-tptPostgreDBTables -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'

# Listar usuarios
Get-tptPostgreDBUsers -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'

# Listar conexiones activas
Get-tptPostgreDBConnections -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'

# Obtener estado del servidor
Get-tptPostgreDBStatus -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'
```

## Configuración

Las credenciales pueden proporcionarse de dos maneras:

1. Usando `-Credential` con `-Username`:
   ```powershell
   Connect-tptPostgreDB -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin' -Credential $(Get-Credential)
   ```

2. Configurando la variable de entorno `PGPASSWORD`:
   ```powershell
   $env:PGPASSWORD='myPassword'
   Connect-tptPostgreDB -Server 'localhost' -Port 5432 -Database 'postgres' -Username 'admin'
   ```

# Configuración

El módulo utiliza un fichero centralizado de configuración YAML para todas las plataformas TPT: `~/.tpt/tpt_config.yaml`.

**Sección para tptPostgreDB:**
```yaml
platforms:
  tptPostgreDB:
    - name: postgres-prod
      server: postgres-prod.corp.local
      port: 5432
      database: postgres
      default: true
      tags: [producción]
    - name: postgres-lab
      server: postgres-lab.local
      port: 5432
      database: postgres
      default: false
      tags: [laboratorio]
```

- **`server`**: FQDN o IP del servidor PostgreSQL.
- **`port`**: Puerto del servidor (por defecto 5432).
- **`database`**: Nombre de la base de datos.
- **`default`**: Marca la plataforma predeterminada (solo una debe ser `true`).
- **`tags`**: Lista libre para clasificación.

**Nota:** Las credenciales NO deben incluirse en este fichero. Usar `Get-Credential` al conectarse.

## Licencia

GPL-3.0-or-later
