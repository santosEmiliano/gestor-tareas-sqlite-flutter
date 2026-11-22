import '../data/base_datos.dart';
import '../models/tarea.dart';

// La pantalla se comunica con esta clase, no con la base directamente, este es el intermediario.
class GestorTareas {
  final BaseDatos base;

  GestorTareas(this.base);

  Future<List<Tarea>> listar() => base.listarTareas();

  Future<void> crear(String titulo) async {
    // trim() quita espacios al inicio y al final.
    final limpio = titulo.trim();
    // Si solo había espacios, queda vacío y no se guarda.
    if (limpio.isEmpty) {
      throw ArgumentError('El título no puede estar vacío');
    }
    await base.insertarTarea(limpio);
  }

  // Libera la conexión con la base.
  Future<void> cerrar() => base.close();
}
