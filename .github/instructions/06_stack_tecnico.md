# Viviana Beauty Room — Stack Técnico y Arquitectura

> Este stack debe estar **completamente configurado antes de escribir la primera pantalla en Flutter**. La app depende de que el backend exista primero.

---

## Capa de Interfaz — Flutter

| Elemento | Decisión |
|---|---|
| Framework | Flutter — multiplataforma iOS, Android y Web desde un solo código |
| Gestión de estado | Riverpod — suficiente para el tamaño del proyecto, escalable |
| Navegación | Go Router — navegación declarativa compatible con deep links |
| Diseño | Paleta de marca: rosa `#D4748F`, negro `#1A1A1A`, blanco `#FAF8F8` |
| Tipografía | Poppins para cuerpo. Playfair Display para nombre de la marca |
| Iconografía | Lucide Icons — trazo fino, coherente con el estilo visual |

---

## Capa de Backend — Firebase

| Servicio | Uso en el proyecto |
|---|---|
| **Firestore** | Base de datos principal. Colecciones: `citas`, `clientas`, `servicios`, `horariosBlockeados` |
| **Firebase Auth** | Autenticación de Viviana y su hermana como usuaria secundaria |
| **Firebase Functions** | Lógica de negocio: validaciones, reglas de cancelación, cálculo de disponibilidad |
| **Firebase Cloud Messaging** | Notificaciones push para recordatorios de cita |
| **Firebase Storage** | Almacenamiento de fotos del catálogo de servicios |
| **Plan requerido** | Blaze (pago por uso). El plan gratuito (Spark) no permite llamadas a APIs externas |

> ℹ️ El plan Blaze requiere tarjeta de crédito registrada en Firebase, pero el costo real con el volumen actual de Viviana (máximo 5 citas diarias) es prácticamente cero.

---

## Modelo de Datos en Firestore

> Las colecciones deben definirse antes de escribir cualquier pantalla en Flutter. Si cambian después, impactan todo el proyecto.

| Colección | Campos principales |
|---|---|
| `citas` | `id`, `clientaId`, `servicioId`, `fechaHora`, `duracion`, `estado`, `montoAnticipo`, `anticipoPagado`, `notas`, `creadaEn` |
| `clientas` | `id`, `nombre`, `telefono`, `alergias`, `preferencias`, `notas`, `creadaEn` |
| `servicios` | `id`, `nombre`, `descripcion`, `precio`, `duracionMin`, `fotoUrl`, `activo`, `proximamente`, `esCombo`, `serviciosIncluidos` |
| `horariosBlockeados` | `id`, `fechaHora`, `duracionMin`, `motivo` |
| `usuarios` | `id`, `nombre`, `rol` (`ADMIN` \| `COLABORADORA`), `email` |

### Estados válidos para `citas.estado`

```
PENDIENTE → CONFIRMADA → COMPLETADA
PENDIENTE → CANCELADA
CONFIRMADA → REPROGRAMADA
CONFIRMADA → CANCELADA
```

---

## Orden de Implementación Recomendado

> El mismo equipo hace diseño, Flutter y backend. Este orden evita bloqueos entre tareas.

| Fase | Qué se hace | Por qué primero |
|---|---|---|
| 1 | Modelo de datos en Firestore | Todo lo demás depende de esto. Si cambia después, rompe Flutter y Functions |
| 2 | Firebase Auth + reglas de seguridad | Sin esto, cualquiera puede leer y escribir la base de datos |
| 3 | Firebase Functions con lógica de negocio | El backend debe existir antes de que Flutter lo consuma |
| 4 | Pantalla de Agenda | Es el núcleo de la app y el requerimiento principal |
| 5 | Catálogo de servicios | Segundo requerimiento explícito de Viviana |
| 6 | Directorio de clientas | Complementa el flujo de nueva cita |
| 7 | Pruebas, ajustes y entrega | Validación con Viviana antes de cerrar el proyecto |
