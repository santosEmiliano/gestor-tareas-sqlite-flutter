import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/base_datos.dart';
import 'package:gestor_tareas_local/services/gestor_tareas.dart';

void main() {
  late GestorTareas gestor;

  setUp(() {
    // Cada prueba arranca con una base nueva y vacía, en memoria.
    gestor = GestorTareas(BaseDatos(NativeDatabase.memory()));
  });

  tearDown(() => gestor.cerrar());

  group('Validación del título', () {
    test('rechaza un título vacío y no guarda nada', () async {
      expect(() => gestor.crear(''), throwsArgumentError);
      expect(await gestor.listar(), isEmpty);
    });

    test('rechaza un título de solo espacios', () async {
      expect(() => gestor.crear('   '), throwsArgumentError);
      expect(await gestor.listar(), isEmpty);
    });

    test('quita los espacios de los extremos al guardar', () async {
      await gestor.crear('  Comprar pan  ');
      final tareas = await gestor.listar();
      expect(tareas.single.titulo, 'Comprar pan');
    });

    test('al editar también rechaza un título vacío', () async {
      await gestor.crear('Original');
      final id = (await gestor.listar()).single.id;

      expect(() => gestor.editarTitulo(id, '  '), throwsArgumentError);
      // El título anterior sigue igual.
      expect((await gestor.listar()).single.titulo, 'Original');
    });
  });

  group('Almacenamiento en SQLite', () {
    test('crear y listar: la tarea nueva queda pendiente', () async {
      await gestor.crear('Estudiar Drift');

      final tareas = await gestor.listar();
      expect(tareas, hasLength(1));
      expect(tareas.single.titulo, 'Estudiar Drift');
      expect(tareas.single.completada, isFalse);
    });

    test('listar devuelve las más nuevas primero', () async {
      await gestor.crear('Primera');
      await gestor.crear('Segunda');

      final titulos = (await gestor.listar()).map((t) => t.titulo).toList();
      expect(titulos, ['Segunda', 'Primera']);
    });

    test('editar cambia el título de la tarea indicada', () async {
      await gestor.crear('Uno');
      await gestor.crear('Dos');
      final dos = (await gestor.listar()).first;

      await gestor.editarTitulo(dos.id, 'Dos editada');

      final titulos = (await gestor.listar()).map((t) => t.titulo).toSet();
      expect(titulos, {'Uno', 'Dos editada'});
    });

    test('cambiar estado marca y desmarca la tarea', () async {
      await gestor.crear('Tarea');
      final id = (await gestor.listar()).single.id;

      await gestor.cambiarEstado(id, true);
      expect((await gestor.listar()).single.completada, isTrue);

      await gestor.cambiarEstado(id, false);
      expect((await gestor.listar()).single.completada, isFalse);
    });

    test('eliminar borra solo la tarea indicada', () async {
      await gestor.crear('Se queda');
      await gestor.crear('Se va');
      final seVa = (await gestor.listar()).first;

      await gestor.eliminar(seVa.id);

      final tareas = await gestor.listar();
      expect(tareas, hasLength(1));
      expect(tareas.single.titulo, 'Se queda');
    });
  });
}
