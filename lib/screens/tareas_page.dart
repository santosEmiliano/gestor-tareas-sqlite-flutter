import 'package:flutter/material.dart';

import '../data/base_datos.dart';
import '../models/tarea.dart';
import '../services/gestor_tareas.dart';
import 'dialogo_editar_tarea.dart';

// Pantalla principal: agrega, lista, edita, completa y elimina tareas.
class TareasPage extends StatefulWidget {
  // Las pruebas pasan su propio gestor de la bd, la app normal no manda ninguno.
  final GestorTareas? gestor;

  const TareasPage({super.key, this.gestor});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();

  late final GestorTareas _gestor;
  // Solo cerramos la base si la abrimos nosotros.
  late final bool _creoGestor;

  List<Tarea> _tareas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _creoGestor = widget.gestor == null;
    _gestor = widget.gestor ?? GestorTareas(BaseDatos());
    _cargar();
  }

  // Lee las tareas de la base. Se llama al abrir la app y después de cada cambio.
  Future<void> _cargar() async {
    try {
      final tareas = await _gestor.listar();
      // Si la pantalla ya se cerró, no se actualiza nada.
      if (!mounted) return;
      setState(() {
        _tareas = tareas;
        _error = null;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las tareas: $e';
        _cargando = false;
      });
    }
  }

  Future<void> _agregarTarea() async {
    try {
      await _gestor.crear(_tituloController.text);
      _tituloController.clear();
      await _cargar();
    } on ArgumentError catch (e) {
      // Con un título vacío se avisa y no se guarda nada.
      _mostrarMensaje(e.message.toString());
    } catch (e) {
      _mostrarMensaje('No se pudo guardar la tarea: $e');
    }
  }

  // Corre una operación de la base y recarga la lista si salió bien.
  // Si falla, avisa con un mensaje en vez de petar la aplicación.
  Future<void> _ejecutar(
    Future<void> Function() operacion,
    String errorMensaje,
  ) async {
    try {
      await operacion();
      await _cargar();
    } on ArgumentError catch (e) {
      _mostrarMensaje(e.message.toString());
    } catch (e) {
      _mostrarMensaje('$errorMensaje: $e');
    }
  }

  Future<void> _alternarCompletada(Tarea tarea, bool completada) {
    return _ejecutar(
      () => _gestor.cambiarEstado(tarea.id, completada),
      'No se pudo actualizar la tarea',
    );
  }

  Future<void> _editarTarea(Tarea tarea) async {
    // La ventana devuelve el título nuevo, o null si se canceló.
    final nuevo = await showDialog<String>(
      context: context,
      builder: (_) => DialogoEditarTarea(tituloActual: tarea.titulo),
    );
    if (nuevo == null) return;
    await _ejecutar(
      () => _gestor.editarTitulo(tarea.id, nuevo),
      'No se pudo editar la tarea',
    );
  }

  Future<void> _eliminarTarea(Tarea tarea) {
    return _ejecutar(
      () => _gestor.eliminar(tarea.id),
      'No se pudo eliminar la tarea',
    );
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    if (_creoGestor) _gestor.cerrar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : _tareas.isEmpty
                  ? const Center(child: Text('Todavía no hay tareas guardadas'))
                  : ListView.builder(
                      itemCount: _tareas.length,
                      itemBuilder: (context, index) {
                        final tarea = _tareas[index];
                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: tarea.completada,
                              onChanged: (valor) {
                                if (valor != null) {
                                  _alternarCompletada(tarea, valor);
                                }
                              },
                            ),
                            title: Text(tarea.titulo),
                            subtitle: Text('ID: ${tarea.id}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editarTarea(tarea),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _eliminarTarea(tarea),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
