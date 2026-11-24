import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/base_datos.dart';
import 'package:gestor_tareas_local/main.dart';
import 'package:gestor_tareas_local/services/gestor_tareas.dart';

void main() {
  late GestorTareas gestor;

  setUp(() {
    gestor = GestorTareas(BaseDatos(NativeDatabase.memory()));
  });

  tearDown(() => gestor.cerrar());

  // La base responde de forma asíncrona real, por eso se espera fuera del
  // reloj propio del test.
  Future<void> esperarBase(WidgetTester tester) async {
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }

  testWidgets('un título vacío muestra el aviso y no agrega nada', (
    tester,
  ) async {
    await tester.pumpWidget(GestorTareasApp(gestor: gestor));
    await esperarBase(tester);

    await tester.tap(find.text('Agregar tarea'));
    await esperarBase(tester);

    expect(find.text('El título no puede estar vacío'), findsOneWidget);
    expect(find.text('Todavía no hay tareas guardadas'), findsOneWidget);
  });

  testWidgets('una tarea agregada aparece en la lista', (tester) async {
    await tester.pumpWidget(GestorTareasApp(gestor: gestor));
    await esperarBase(tester);

    await tester.enterText(find.byType(TextField), 'Comprar pan');
    await tester.tap(find.text('Agregar tarea'));
    await esperarBase(tester);

    expect(find.text('Comprar pan'), findsOneWidget);
  });
}
