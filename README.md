# Parcial 3 – Arquitectura Monolítica: Odoo 19 desde el repositorio

Carpeta del proyecto: `Documentos\parcial3-odoo`
Guarda cada captura en `capturas\` con el nombre indicado (📸). Usa **Win + Shift + S** para capturar.

> **Para el grupo:** este repositorio trae solo nuestros archivos (`Dockerfile`, `docker-compose.yml`, los `.conf` y esta guía). El código de Odoo **no se sube** (pesa cientos de MB): cada uno lo clona en el paso 2.1. Probado en Windows 11 con Python 3.12, PostgreSQL 18 y Docker 29.

### Archivos del repositorio

| Archivo | Para qué |
|---|---|
| `GUIA-PASOS.md` | Esta guía |
| `odoo.local.conf` | Configuración para correr Odoo nativo (Fase 2) |
| `Dockerfile` | Construye la imagen de Odoo **desde el código clonado** (Fase 3) |
| `docker-compose.yml` | Levanta Odoo + PostgreSQL 16 en contenedores (Fase 3) |
| `odoo.docker.conf` | Configuración de Odoo dentro del contenedor |
| `.gitignore` / `.dockerignore` | Evitan subir el código de Odoo y el venv |

---

## FASE 1 – Requisitos (Windows 11)

Instala lo que falte. **Con cada instalador, deja las opciones por defecto**, salvo lo que se indica:

| Herramienta | Descarga | Nota |
|---|---|---|
| Git | https://git-scm.com/download/win | Por defecto |
| Python **3.12** | https://www.python.org/downloads/windows/ | ✅ Marca **"Add python.exe to PATH"**. No uses 3.13/3.14: algunas dependencias de Odoo 19 no tienen paquetes para esas versiones |
| PostgreSQL **16, 17 o 18** | https://www.postgresql.org/download/windows/ | Anota la contraseña que le pongas al usuario `postgres`. Si ya lo tienes, sirve cualquiera desde la 13 |
| Docker Desktop | https://www.docker.com/products/docker-desktop/ | Usa el backend WSL2 (te pedirá reiniciar) |
| Build Tools de C++ (por si acaso) | https://visualstudio.microsoft.com/visual-cpp-build-tools/ | Marca "Desarrollo para el escritorio con C++". Solo si `pip install` falla compilando algo |

Verifica en **PowerShell**:

```powershell
git --version
python --version
docker --version
Get-ChildItem "C:\Program Files\PostgreSQL"   # el nombre de la carpeta (16, 17, 18...) es tu versión de PostgreSQL
```

> En los comandos de abajo aparece `PostgreSQL\18`. **Cambia el 18 por tu versión.**

📸 `01-versiones.png` – PowerShell con las 4 versiones.

---

## FASE 2 – Odoo desde el repositorio (instalación nativa)

### 2.1 Clonar el repositorio del grupo y, dentro, el de Odoo (solo la rama 19.0, sin historial)

```powershell
cd "$HOME\Documents"
git clone https://github.com/MiguelAndy/Parcial3Odoo.git parcial3-odoo
cd parcial3-odoo
git clone --depth 1 --branch 19.0 https://github.com/odoo/odoo.git
```

> `--depth 1` evita descargar todo el historial (son varios GB). Tarda unos minutos.

📸 `02-git-clone.png` – terminal con el clone terminado.
📸 `03-estructura-repo.png` – la carpeta `odoo` abierta (se ven `addons`, `odoo`, `odoo-bin`, `requirements.txt`).

### 2.2 Entorno virtual y dependencias

```powershell
cd "$HOME\Documents\parcial3-odoo\odoo"
python -m venv venv
.\venv\Scripts\Activate.ps1
python -m pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
```

> Si `Activate.ps1` da error de "ejecución de scripts deshabilitada", corre una vez:
> `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

📸 `04-pip-install.png` – final de la instalación ("Successfully installed ...").

### 2.3 Crear el usuario de base de datos para Odoo

Odoo **no permite** conectarse con el superusuario `postgres`, así que creamos uno propio:

```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -c "CREATE ROLE odoo WITH LOGIN CREATEDB PASSWORD 'odoo';"
```

(Te pedirá la contraseña de `postgres` que pusiste al instalar.)

📸 `05-crear-usuario-bd.png` – mensaje `CREATE ROLE`.

### 2.4 Ejecutar Odoo

Con el venv activado y estando dentro de la carpeta `odoo`:

```powershell
python odoo-bin -c ..\odoo.local.conf
```

Cuando veas `HTTP service (werkzeug) running on ...:8069`, abre **http://localhost:8069**

📸 `06-odoo-bin-corriendo.png` – logs del servidor.

### 2.5 Crear la base de datos y probar

En el navegador:
- Master password: `admin123`
- Database name: `parcial3`
- Email / password: `admin` / `admin`
- Language: Spanish / Country: Peru
- Marca **Demo data** si quieres datos de ejemplo.

📸 `07-crear-bd.png` – formulario de creación.
📸 `08-odoo-dashboard.png` – pantalla principal de Odoo.

Instala un módulo (por ejemplo **Ventas** o **Inventario**) desde *Aplicaciones*:
📸 `09-modulo-instalado.png`

Al terminar, detén Odoo con **Ctrl + C** (para liberar el puerto 8069 antes de Docker).

---

## FASE 3 – Docker (nota extra)

El `Dockerfile` construye una imagen **desde el código que clonaste** (no usa la imagen oficial `odoo`), y `docker-compose.yml` levanta dos contenedores: `odoo-app` y `odoo-db` (PostgreSQL 16).

Abre Docker Desktop (que esté en verde, "Engine running") y en PowerShell:

```powershell
cd "$HOME\Documents\parcial3-odoo"
docker compose up -d --build
```

📸 `10-docker-build.png` – la construcción de la imagen.

```powershell
docker compose ps
docker compose logs -f odoo      # Ctrl+C para salir de los logs
```

📸 `11-docker-ps.png` – los 2 contenedores en estado *running/healthy*.
📸 `12-docker-desktop.png` – Docker Desktop mostrando los contenedores.

Abre **http://localhost:8069**, crea la base `parcial3docker` igual que en 2.5.
📸 `13-odoo-en-docker.png`

Comandos útiles:

```powershell
docker compose down        # detener
docker compose down -v     # detener y BORRAR los datos
docker images              # ver la imagen odoo-desde-fuente:19.0
```

---

## FASE 4 – Presentación

Cuando tengas las capturas, se arma la presentación con:
1. Qué es Odoo y qué es una arquitectura monolítica
2. Diagrama de arquitectura (navegador → Odoo → PostgreSQL)
3. Requisitos
4. Pasos de la instalación nativa (con capturas)
5. Pasos con Docker (Dockerfile + compose, con capturas)
6. Comparación nativo vs Docker
7. Problemas encontrados y cómo se resolvieron
8. Conclusiones

---

## Problemas comunes

| Error | Solución |
|---|---|
| `Using the database user 'postgres' is a security risk` | Usa el usuario `odoo` (paso 2.3) |
| `password authentication failed for user "odoo"` | Repite 2.3 o revisa `db_password` en `odoo.local.conf` |
| `pip` falla con *"Microsoft Visual C++ 14.0 is required"* | Instala los Build Tools de C++ y repite el `pip install` |
| `Address already in use` / puerto 8069 ocupado | Cierra el Odoo nativo (Ctrl+C) antes de levantar Docker |
| Docker: `error during connect` | Abre Docker Desktop y espera a que el motor esté corriendo |
| Los PDF no se generan | Falta `wkhtmltopdf`; no es necesario para el parcial |
