import 'package:flutter/material.dart';

// Ventana para cambiar el título. Devuelve el texto nuevo o null si se cancela.
class DialogoEditarTarea extends StatefulWidget {
  final String tituloActual;

  const DialogoEditarTarea({super.key, required this.tituloActual});

  @override
  State<DialogoEditarTarea> createState() => _DialogoEditarTareaState();
}

class _DialogoEditarTareaState extends State<DialogoEditarTarea> {
  // Arranca con el título que ya tenía la tarea.
  late final TextEditingController _controller = TextEditingController(
    text: widget.tituloActual,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar tarea'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Título',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
