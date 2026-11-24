import '../data/base_datos.dart';
import '../models/tarea.dart';

// La pantalla se comunica con esta clase, no con la base directamente, este es el intermediario.
class GestorTareas {
  final BaseDatos base;

  GestorTareas(this.base);

  Future<List<Tarea>> listar() => base.listarTareas();

  // Quita espacios sobrantes y rechaza el título si queda vacío.
  String _validarTitulo(String titulo) {
    final cadenalimpia = titulo.trim();
    if (cadenalimpia.isEmpty) {
      throw ArgumentError('El título no puede estar vacío');
    }
    return cadenalimpia;
  }

  Future<void> crear(String titulo) async {
    await base.insertarTarea(_validarTitulo(titulo));
  }

  Future<void> editarTitulo(int id, String titulo) async {
    // Igual se valida el título como al crear.
    await base.actualizarTitulo(id, _validarTitulo(titulo));
  }

  Future<void> cambiarEstado(int id, bool completada) async {
    await base.actualizarEstado(id, completada);
  }

  Future<void> eliminar(int id) async {
    await base.eliminarTarea(id);
  }

  // Libera la conexión con la base.
  Future<void> cerrar() => base.close();
}
