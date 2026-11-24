import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/tarea.dart';

// Archivo que genera build_runner con el código de las consultas.
part 'base_datos.g.dart';

// Cada fila de la tabla se convierte directo en un objeto Tarea.
@UseRowClass(Tarea)
class Tareas extends Table {
  // Llave primaria autoincremental.
  IntColumn get id => integer().autoIncrement()();

  // Texto obligatorio.
  TextColumn get titulo => text()();

  // SQLite lo guarda como 0 o 1, y Drift lo entrega como bool.
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class BaseDatos extends _$BaseDatos {
  // En las pruebas se le pasa una base en memoria en lugar de la real.
  BaseDatos([QueryExecutor? ejecutor]) : super(ejecutor ?? _abrirConexion());

  @override
  int get schemaVersion => 1;

  // SELECT: devuelve todas las tareas, las más nuevas primero.
  Future<List<Tarea>> listarTareas() {
    return (select(tareas)..orderBy([(t) => OrderingTerm.desc(t.id)])).get();
  }

  // INSERT: guarda una tarea nueva y devuelve el id que le tocó.
  Future<int> insertarTarea(String titulo) {
    return into(tareas).insert(TareasCompanion.insert(titulo: titulo));
  }

  // UPDATE: cambia solo el título de la tarea con el id del parámetro.
  Future<int> actualizarTitulo(int id, String titulo) {
    return (update(tareas)..where((t) => t.id.equals(id))).write(
      TareasCompanion(titulo: Value(titulo)),
    );
  }

  // UPDATE: marca la tarea como completada o pendiente.
  Future<int> actualizarEstado(int id, bool completada) {
    return (update(tareas)..where((t) => t.id.equals(id))).write(
      TareasCompanion(completada: Value(completada)),
    );
  }

  // DELETE: borra la tarea con ese id.
  Future<int> eliminarTarea(int id) {
    return (delete(tareas)..where((t) => t.id.equals(id))).go();
  }

  // drift_flutter elige dónde guardar el archivo según la plataforma.
  static QueryExecutor _abrirConexion() {
    return driftDatabase(name: 'gestor_tareas');
  }
}
