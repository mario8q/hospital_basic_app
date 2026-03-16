import 'package:flutter/material.dart';
import '../../models/medico.dart';
import '../../repositories/medico_repository.dart';
import 'medico_form_screen.dart';

class MedicosScreen extends StatefulWidget {
  const MedicosScreen({super.key});

  @override
  State<MedicosScreen> createState() => _MedicosScreenState();
}

class _MedicosScreenState extends State<MedicosScreen> {
  final _repo = MedicoRepository();
  late Future<List<Medico>> _futuro;

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

  Future<void> _eliminar(Medico medico) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar médico'),
        content: Text('¿Eliminar al Dr. ${medico.nombre}?'),
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
      await _repo.delete(medico.id!);
      _mostrarSnackbar('Médico eliminado correctamente');
      _cargar();
    } catch (e) {
      _mostrarSnackbar(e.toString(), error: true);
    }
  }

  Future<void> _abrirFormulario({Medico? medico}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MedicoFormScreen(medico: medico),
      ),
    );
    if (resultado == true) {
      _mostrarSnackbar(
        medico == null ? 'Médico creado' : 'Médico actualizado',
      );
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Médicos'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Medico>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

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

          final medicos = snapshot.data ?? [];
          if (medicos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No hay médicos registrados',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: medicos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final m = medicos[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(
                      m.nombre[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    'Dr. ${m.nombre}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${m.especialidad}  •  ${m.telefono ?? 'Sin teléfono'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.teal),
                        onPressed: () => _abrirFormulario(medico: m),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminar(m),
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