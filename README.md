# Gestor de tareas con SQLite

Práctica de Programación de Dispositivos Móviles (UAA, 7.º semestre). App Flutter que administra tareas con una base SQLite local, sin servidor ni conexión a internet.

## Tecnología de persistencia elegida

**Drift + drift_flutter**, sobre SQLite.

- **Drift** define la tabla como una clase Dart y genera el código de las consultas con `build_runner`, así que las operaciones se escriben sin SQL.
- **drift_flutter** abre la base con una sola llamada (`driftDatabase`) y escoge el almacenamiento según la plataforma: archivo SQLite en Android, iOS, Windows, Linux y macOS, y WebAssembly en el navegador. Con eso las seis plataformas comparten el mismo código.

Versiones tomadas de la documentación de Drift: `drift 2.35.3`, `drift_flutter 0.3.1`, `drift_dev 2.35.2`, `build_runner 2.16.2`.

### Qué no se usa

- Una lista en memoria: se pierde al cerrar la app.
- `shared_preferences` con JSON: no es SQLite y la práctica no lo acepta.
- MySQL o API REST: la práctica es de almacenamiento local.

## Diseño de la tabla

Tabla `tareas`:

| Columna | Tipo en SQLite | Tipo en Dart | Notas |
|---|---|---|---|
| `id` | `INTEGER` | `int` | Llave primaria con autoincremento. | 
| `titulo` | `TEXT` | `String` | Obligatorio. No se aceptan títulos vacíos ni de solo espacios. |
| `completada` | `INTEGER` (0 o 1) | `bool` | SQLite no tiene tipo booleano. Drift convierte 0/1 a `bool`. Por defecto  es`false`. |

## Organización de carpetas

```
lib/
├── main.dart                  arranque y tema
├── models/tarea.dart          modelo de la tarea
├── data/                      base Drift: tabla, apertura y consultas
├── services/                  reglas y validación (título no vacío)
└── screens/tareas_page.dart   pantalla
test/                          pruebas automatizadas
web/                           incluirá sqlite3.wasm y drift_worker.dart.js
```

La pantalla no ejecuta consultas dentro de `build()`: carga los datos en `initState` con un `Future` y vuelve a consultar después de cada escritura.

## Preparación

Requiere Flutter instalado (`flutter doctor -v`).

```bash
git clone <url-del-repositorio>
cd <carpeta-del-repositorio>
flutter pub get
flutter analyze
flutter test
flutter run -d chrome     # o macos, windows, linux o el id de flutter devices
```

Cuando se agregue Drift habrá que generar el código antes de ejecutar:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Plataformas verificadas

Pendiente. Se documentará aquí qué plataformas se ejecutaron y cuáles solo están previstas, junto con el resultado de las pruebas P1 a P6.

## Referencias

- https://drift.simonbinder.eu/
- https://drift.simonbinder.eu/setup/
- https://drift.simonbinder.eu/platforms/web/
- https://pub.dev/packages/drift_flutter
- https://docs.flutter.dev/data-and-backend/persistence/sqlite
