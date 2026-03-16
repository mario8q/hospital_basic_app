import 'package:flutter/material.dart';
import '../../models/paciente.dart';
import '../../repositories/paciente_repository.dart';
import 'paciente_form_screen.dart';

class PacientesScreen extends StatefulWidget {
  const PacientesScreen({super.key});

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  final _repo = PacienteRepository();
  late Future<List<Paciente>> _futuro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    setState(() {
      _futuro = _repo.getAll(); // Solo asigna el Future, no lo ejecuta
    });
  }

  void _mostrarSnackbar(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? Colors.red : Colors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _eliminar(Paciente paciente) async {
    // Confirmación antes de eliminar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar paciente'),
        content: Text('¿Eliminar a ${paciente.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _repo.delete(paciente.id!);
      _mostrarSnackbar('Paciente eliminado correctamente');
      _cargar();
    } catch (e) {
      _mostrarSnackbar(e.toString(), error: true);
    }
  }

  Future<void> _abrirFormulario({Paciente? paciente}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PacienteFormScreen(paciente: paciente),
      ),
    );
    if (resultado == true) {
      _mostrarSnackbar(
        paciente == null ? 'Paciente creado' : 'Paciente actualizado',
      );
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Paciente>>(
        future: _futuro,
        builder: (context, snapshot) {
          // Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _cargar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Lista vacía
          final pacientes = snapshot.data ?? [];
          if (pacientes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No hay pacientes registrados',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Lista con datos
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: pacientes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final p = pacientes[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(
                      p.nombre[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    p.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('DNI: ${p.dni}  •  ${p.telefono ?? 'Sin teléfono'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.teal),
                        onPressed: () => _abrirFormulario(paciente: p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminar(p),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}