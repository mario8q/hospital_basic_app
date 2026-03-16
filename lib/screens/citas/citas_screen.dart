import 'package:flutter/material.dart';
import '../../models/cita.dart';
import '../../repositories/cita_repository.dart';
import 'cita_form_screen.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final _repo = CitaRepository();
  late Future<List<Cita>> _futuro;

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

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'confirmada': return Colors.green;
      case 'cancelada':  return Colors.red;
      default:           return Colors.orange;
    }
  }

  Future<void> _eliminar(Cita cita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar cita'),
        content: Text(
          '¿Eliminar la cita de ${cita.nombrePaciente} con Dr. ${cita.nombreMedico}?',
        ),
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
      await _repo.delete(cita.id!);
      _mostrarSnackbar('Cita eliminada correctamente');
      _cargar();
    } catch (e) {
      _mostrarSnackbar(e.toString(), error: true);
    }
  }

  Future<void> _abrirFormulario({Cita? cita}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CitaFormScreen(cita: cita),
      ),
    );
    if (resultado == true) {
      _mostrarSnackbar(
        cita == null ? 'Cita creada' : 'Cita actualizada',
      );
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Cita>>(
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

          final citas = snapshot.data ?? [];
          if (citas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No hay citas registradas',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: citas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final c = citas[index];
              final fecha = c.fechaHora;
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _colorEstado(c.estado),
                    child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    '${c.nombrePaciente} → Dr. ${c.nombreMedico}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${fecha.day}/${fecha.month}/${fecha.year}  ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                      ),
                      if (c.motivo != null && c.motivo!.isNotEmpty)
                        Text(
                          c.motivo!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _colorEstado(c.estado).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          c.estado.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: _colorEstado(c.estado),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.teal),
                        onPressed: () => _abrirFormulario(cita: c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminar(c),
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