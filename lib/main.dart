import 'package:flutter/material.dart';

import 'screens/tareas_page.dart';
import 'services/gestor_tareas.dart';

void main() {
  runApp(const GestorTareasApp());
}

/// Punto de entrada de la aplicación.
/// La configuración del almacenamiento se agregará como parte de la tarea.
class GestorTareasApp extends StatelessWidget {
  // Las pruebas lo usan para no abrir la base real.
  final GestorTareas? gestor;

  const GestorTareasApp({super.key, this.gestor});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TareasPage(gestor: gestor),
    );
  }
}
