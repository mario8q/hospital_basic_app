import 'package:flutter/material.dart';
import '../../models/consulta.dart';
import '../../repositories/historial_repository.dart';

class ConsultaFormScreen extends StatefulWidget {
  final String pacienteId;

  const ConsultaFormScreen({super.key, required this.pacienteId});

  @override
  State<ConsultaFormScreen> createState() => _ConsultaFormScreenState();
}

class _ConsultaFormScreenState extends State<ConsultaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = HistorialRepository();
  bool _cargando = false;

  final _medicoCtrl = TextEditingController();
  final _motivoCtrl = TextEditingController();
  final _diagnosticoCtrl = TextEditingController();
  final _tratamientoCtrl = TextEditingController();
  String _especialidad = 'Medicina General';
  DateTime _fecha = DateTime.now();

  static const _especialidades = [
    'Cardiología', 'Dermatología', 'Ginecología',
    'Medicina General', 'Neurología', 'Oftalmología',
    'Ortopedia', 'Pediatría', 'Psiquiatría', 'Urología',
  ];

  @override
  void dispose() {
    _medicoCtrl.dispose();
    _motivoCtrl.dispose();
    _diagnosticoCtrl.dispose();
    _tratamientoCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fecha = fecha);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    try {
      final consulta = Consulta(
        fecha: _fecha.toIso8601String(),
        medico: _medicoCtrl.text.trim(),
        especialidad: _especialidad,
        motivo: _motivoCtrl.text.trim(),
        diagnostico: _diagnosticoCtrl.text.trim(),
        tratamiento: _tratamientoCtrl.text.trim(),
      );

      await _repo.agregarConsulta(widget.pacienteId, consulta);

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
        title: const Text('Nueva Consulta'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Fecha
              InkWell(
                onTap: _seleccionarFecha,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de consulta',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Médico
              TextFormField(
                controller: _medicoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del médico *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El médico es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Especialidad
              DropdownButtonFormField<String>(
                value: _especialidad,
                decoration: const InputDecoration(
                  labelText: 'Especialidad',
                  prefixIcon: Icon(Icons.medical_services),
                  border: OutlineInputBorder(),
                ),
                items: _especialidades.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                )).toList(),
                onChanged: (v) => setState(() => _especialidad = v!),
              ),
              const SizedBox(height: 16),

              // Motivo
              TextFormField(
                controller: _motivoCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Motivo de consulta *',
                  prefixIcon: Icon(Icons.help_outline),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El motivo es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Diagnóstico
              TextFormField(
                controller: _diagnosticoCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Diagnóstico *',
                  prefixIcon: Icon(Icons.medical_information),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El diagnóstico es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Tratamiento
              TextFormField(
                controller: _tratamientoCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Tratamiento *',
                  prefixIcon: Icon(Icons.medication),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El tratamiento es obligatorio' : null,
              ),
              const SizedBox(height: 32),

              // Botón guardar
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
                      : const Text('Guardar Consulta',
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