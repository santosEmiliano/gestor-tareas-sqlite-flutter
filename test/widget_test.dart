import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/base_datos.dart';
import 'package:gestor_tareas_local/main.dart';
import 'package:gestor_tareas_local/services/gestor_tareas.dart';

void main() {
  testWidgets('La pantalla inicial se muestra sin errores', (tester) async {
    // Base en memoria: no toca el disco ni la base real.
    final gestor = GestorTareas(BaseDatos(NativeDatabase.memory()));
    addTearDown(gestor.cerrar);

    await tester.pumpWidget(GestorTareasApp(gestor: gestor));
    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
