# Viviana Beauty Room — Flujo de Trabajo con GitHub

---

## Reglas Base (aplican a todos)

- Nadie pushea directo a `main` ni a `develop`. Todo entra por **Pull Request**.
- Cada integrante trabaja únicamente en su rama `feature/`.
- **Una rama = una pantalla.** No mezclar trabajo de dos pantallas en la misma rama.
- Antes de crear tu rama, siempre partir desde `develop` actualizado.

---

## Estructura de Ramas

| Rama | Responsable | Propósito |
|---|---|---|
| `main` | Gabriel (solo merge final) | Código estable y revisado. Nadie pushea directo aquí |
| `develop` | Gabriel (aprueba PRs) | Rama de integración. Todo el equipo fusiona aquí vía PR |
| `feature/shared-components` | José Luis | Componentes reutilizables. **Debe mergearse primero** |
| `feature/login` | Rocío | Pantalla de Login |
| `feature/nueva-cita` | Miguel | Modal de Nueva Cita / Editar Cita |
| `feature/catalogo` | Gabriel | Pantalla de Catálogo de Servicios |
| `feature/agenda` | José Luis | Pantalla de Agenda |
| `feature/directorio` | Rocío | Pantalla de Directorio de Clientas |

---

## Flujo Diario por Integrante

Cada vez que vayas a trabajar, sigue estos pasos en orden:

### PASO 1 — Actualizar develop antes de empezar
*(Solo la primera vez o si llevas días sin jalar)*
```bash
git checkout develop
git pull origin develop
```

### PASO 2 — Crear tu rama desde develop
*(Solo se hace una vez por pantalla)*
```bash
git checkout -b feature/login
```
Sustituye `login` por el nombre de tu pantalla: `agenda`, `catalogo`, `directorio`, `nueva-cita`

### PASO 3 — Trabajar y guardar avances con commits frecuentes
```bash
git add .
git commit -m "feat: estructura base pantalla login"
git commit -m "feat: agregar AppTextField y PrimaryButton"
git commit -m "style: ajustar padding y colores"
```
> Haz commits cada vez que termines algo que funciona. No esperes a tener todo listo.

### PASO 4 — Subir tu rama a GitHub
```bash
git push origin feature/login
```
Esto sube **tu rama**. No toca `develop` ni `main`.

### PASO 5 — Abrir el Pull Request en GitHub
Entra a `github.com > tu repositorio` > verás un botón **"Compare & pull request"** > ponle título > asigna a **Gabriel como Reviewer** > crea el PR.

### PASO 6 — Si Gabriel pide cambios
```bash
# Haces la corrección en tu código
git add .
git commit -m "fix: corregir color botón según revisión"
git push origin feature/login
```
El PR se actualiza automáticamente. No necesitas abrir uno nuevo.

---

## Lo que NO debes hacer

```bash
# ❌ Esto salta la revisión de Gabriel
git checkout develop
git merge feature/login
git push
```

- Trabajar directamente en `develop` o `main`
- Hacer push sin haber hecho al menos un commit descriptivo

---

## Convención de Commits

Formato: `prefijo: descripcion breve en minusculas`

| Prefijo | Cuándo usarlo | Ejemplo |
|---|---|---|
| `feat:` | Agregar algo nuevo | `feat: estructura base pantalla login` |
| `fix:` | Corregir algo que no funcionaba | `fix: ajustar padding del logo` |
| `style:` | Cambios visuales sin lógica | `style: cambiar color botón a #D4748F` |
| `refactor:` | Reorganizar código sin cambiar comportamiento | `refactor: mover widgets a shared/` |
| `chore:` | Cambios de configuración | `chore: agregar fuente Poppins en pubspec.yaml` |

---

## Orden Crítico para este Sprint

> José Luis debe mergear `feature/shared-components` a `develop` **ANTES** de que los demás creen sus ramas. Si no, cada quien tendrá una copia distinta de los componentes y se generarán conflictos al integrar.

El orden en GitHub es:

1. José Luis abre PR de `shared-components` → Gabriel lo aprueba → merge a `develop`
2. Todos ejecutan:
```bash
git checkout develop
git pull origin develop
```
3. Cada quien crea su rama `feature/` y trabaja en paralelo
