# Gestor de tareas con SQLite

Práctica de Programación de Dispositivos Móviles (UAA, 7.º semestre). App Flutter que administra tareas con una base SQLite local, sin servidor ni conexión a internet.

## Tecnología de persistencia elegida

**Drift + drift_flutter**, sobre SQLite.

- **Drift** define la tabla como una clase Dart y genera el código de las consultas con `build_runner`, así que las operaciones se escriben sin SQL.
- **drift_flutter** abre la base con una sola llamada (`driftDatabase`) y escoge el almacenamiento según la plataforma: archivo SQLite en Android, iOS, Windows, Linux y macOS, y WebAssembly en el navegador. Con eso las seis plataformas comparten el mismo código.

Versiones usadas: `drift 2.35.4`, `drift_flutter 0.3.1`, `drift_dev 2.35.3`, `build_runner 2.17.1`.

En web, SQLite corre como WebAssembly. Por eso `web/` incluye `sqlite3.wasm` y `drift_worker.dart.js` (el worker donde vive la base), tomados del release `drift-2.35.4` de Drift, la misma versión de `drift` instalada. Si se actualiza `drift`, hay que volver a descargarlos del release correspondiente.

### Qué no se usa

- Una lista en memoria: se pierde al cerrar la app.
- `shared_preferences` con JSON: no es SQLite y la práctica no lo acepta.
- MySQL o API REST: la práctica es de almacenamiento local.

## Diseño de la tabla

Tabla `tareas`:

| Columna | Tipo en SQLite | Tipo en Dart | Notas |
|---|---|---|---|
| `id` | `INTEGER` | `int` | Llave primaria con autoincremento. Edición y borrado se hacen por `id`. |
| `titulo` | `TEXT` | `String` | Obligatorio. No se aceptan títulos vacíos ni de solo espacios. |
| `completada` | `INTEGER` (0 o 1) | `bool` | SQLite no tiene tipo booleano. Drift convierte 0/1 a `bool`. Por defecto es `false`. |

Operaciones: `INSERT` (agregar tarea), `SELECT` (listar tareas), `UPDATE` (editar título y cambiar estado) y `DELETE` (eliminar tarea por `id`).

## Organización de carpetas

```
lib/
├── main.dart                          arranque y tema
├── models/tarea.dart                  modelo de la tarea
├── data/base_datos.dart               tabla, apertura de la base y consultas
├── services/gestor_tareas.dart        reglas y validación (título no vacío)
└── screens/
    ├── tareas_page.dart               pantalla principal
    └── dialogo_editar_tarea.dart      ventana para editar el título
test/
├── widget_test.dart                   arranque de la pantalla
├── gestor_tareas_test.dart            validación y operaciones de almacenamiento
└── tareas_page_test.dart              alta desde la pantalla
web/                                   incluye sqlite3.wasm y drift_worker.dart.js
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
flutter run -d macos      # o windows, linux o el id de flutter devices
```

### Web

```bash
flutter run -d web-server --web-port=8080
```

Después abrir `http://localhost:8080` en el navegador. En web la base se guarda por origen y por perfil del navegador, así que conviene usar siempre el mismo puerto: con otro puerto es otro origen y las tareas no aparecen. Con `web-server`, cerrar la pestaña no detiene el servidor, lo que deja probar que los datos sobreviven.

### Código generado

El archivo `lib/data/base_datos.g.dart` ya está en el repositorio, así que no hace falta generarlo para ejecutar. Solo se regenera si cambia la tabla:

```bash
dart run build_runner build
```

## Plataformas verificadas

| Plataforma | Estado | Detalle |
|---|---|---|
| macOS | Ejecutada | macOS 26.6.2, Flutter 3.47.0 |
| Web | Ejecutada | Chrome 158, en `localhost:8080` |

### Pruebas P1 a P6

Todas se hicieron a mano, cerrando por completo la app (macOS) o la pestaña (web) y abriéndola de nuevo, no con hot reload.

| # | Prueba | macOS | Chrome |
|---|---|---|---|
| P1 | Agregar tres tareas, cerrar y abrir | Pasó | Pasó |
| P2 | Marcar una como completada y reiniciar | Pasó | Pasó |
| P3 | Cambiar un título y reiniciar | Pasó | Pasó |
| P4 | Eliminar una tarea y reiniciar | Pasó | Pasó |
| P5 | Agregar un título vacío o de solo espacios | Pasó | Pasó |
| P6 | Recargar y cerrar/abrir la pestaña en el mismo origen y perfil | No aplica | Pasó |

### Limitaciones

- Los datos son locales de cada instalación: no se sincronizan entre plataformas.
- En web los datos dependen del origen y del perfil. No se probó el modo incógnito ni el borrado de datos del sitio.
- `flutter test` usa una base en memoria, así que las pruebas automáticas no comprueban la persistencia entre reinicios, eso lo probé a mano con la tabla anterior.

### Pruebas automatizadas

```bash
flutter test
```

- `gestor_tareas_test.dart`: rechazo de títulos vacíos o de solo espacios (al crear y al editar), recorte de espacios, y crear, listar, editar, cambiar estado y eliminar sobre una base en memoria.
- `tareas_page_test.dart`: un título vacío muestra el aviso y no agrega nada; un título válido aparece en la lista.
- `widget_test.dart`: la pantalla inicial se muestra sin errores.

## Referencias

- **Drift, configuración:** cómo definir la tabla como clase Dart, el archivo generado con build_runner, las dependencias y cómo abrir la base con `driftDatabase`. https://drift.simonbinder.eu/setup/
- **Drift, plataforma web:** por qué la web necesita `sqlite3.wasm` y un worker, que van en `web/` y que deben ser de la misma versión de drift; uso de `DriftWebOptions`. https://drift.simonbinder.eu/platforms/web/
- **Releases de Drift en GitHub:** de aquí se descargaron `sqlite3.wasm` y `drift_worker.js` de la versión exacta (drift-2.35.4). https://github.com/simolus3/drift/releases
- **Drift, tablas:** cómo se define una tabla como clase Dart, que `integer().autoIncrement()` crea la llave primaria y que `boolean()` se guarda como INTEGER con 1 o 0. https://drift.simonbinder.eu/dart_api/tables/
- **Drift, escrituras:** cómo se hacen insert, update y delete, y que para actualizar solo algunos campos se usa la clase "companion" con `Value`. https://drift.simonbinder.eu/dart_api/writes/
- **Drift, consultas:** que un select empieza con `select(tabla)` y se ejecuta con `get()`, y que `orderBy` con `OrderingTerm` y el modo `desc` ordena de forma descendente. https://drift.simonbinder.eu/dart_api/select/
- **Drift, pruebas:** que se puede usar `NativeDatabase.memory()` para probar sobre una base en memoria, abriéndola en `setUp` y cerrándola en `tearDown`. https://drift.simonbinder.eu/testing/
- **Flutter, guardar datos con SQLite:** cómo se insertan, leen, actualizan y borran datos con `Future`, y que esa guía usa `sqflite`, que solo soporta macOS, iOS y Android, por lo que no servía para web. https://docs.flutter.dev/cookbook/persistence/sqlite
