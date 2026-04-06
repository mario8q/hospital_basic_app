import 'package:flutter/material.dart';
import '../../models/historial_clinico.dart';
import '../../repositories/historial_repository.dart';

class HistorialFormScreen extends StatefulWidget {
  const HistorialFormScreen({super.key});

  @override
  State<HistorialFormScreen> createState() => _HistorialFormScreenState();
}

class _HistorialFormScreenState extends State<HistorialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = HistorialRepository();
  bool _cargando = false;

  final _pacienteIdCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _fechaNacCtrl = TextEditingController();

  @override
  void dispose() {
    _pacienteIdCtrl.dispose();
    _nombreCtrl.dispose();
    _fechaNacCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    try {
      final historial = HistorialClinico(
        pacienteId: _pacienteIdCtrl.text.trim(),
        nombrePaciente: _nombreCtrl.text.trim(),
        fechaNacimiento: _fechaNacCtrl.text.trim().isEmpty
            ? null : _fechaNacCtrl.text.trim(),
        consultas: [],
      );

      await _repo.crear(historial);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Historial'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ID del paciente
              TextFormField(
                controller: _pacienteIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID del paciente *',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                  helperText: 'Debe coincidir con el ID en PostgreSQL',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El ID es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Nombre
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del paciente *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Fecha de nacimiento
              TextFormField(
                controller: _fechaNacCtrl,
                decoration: const InputDecoration(
                  labelText: 'Fecha de nacimiento',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  hintText: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Crear Historial',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}