import 'package:flutter/material.dart';
import '../../models/cita.dart';
import '../../models/paciente.dart';
import '../../models/medico.dart';
import '../../repositories/cita_repository.dart';
import '../../repositories/paciente_repository.dart';
import '../../repositories/medico_repository.dart';

class CitaFormScreen extends StatefulWidget {
  final Cita? cita;
  const CitaFormScreen({super.key, this.cita});

  @override
  State<CitaFormScreen> createState() => _CitaFormScreenState();
}

class _CitaFormScreenState extends State<CitaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _citaRepo = CitaRepository();
  bool _cargando = false;
  bool _cargandoDatos = true;

  List<Paciente> _pacientes = [];
  List<Medico> _medicos = [];

  Paciente? _pacienteSeleccionado;
  Medico? _medicoSeleccionado;
  DateTime? _fechaHora;
  String _estado = 'pendiente';
  final _motivoCtrl = TextEditingController();

  static const _estados = ['pendiente', 'confirmada', 'cancelada'];

  bool get _esEdicion => widget.cita != null;

  @override
  void initState() {
    super.initState();
    _motivoCtrl.text = widget.cita?.motivo ?? '';
    _estado = widget.cita?.estado ?? 'pendiente';
    _fechaHora = widget.cita?.fechaHora;
    _cargarDatos();
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  // Carga pacientes y médicos para los dropdowns
  Future<void> _cargarDatos() async {
    try {
      final pacientes = await PacienteRepository().getAll();
      final medicos = await MedicoRepository().getAll();
      setState(() {
        _pacientes = pacientes;
        _medicos = medicos;
        // Si es edición preseleccionar
        if (_esEdicion) {
          _pacienteSeleccionado = pacientes.firstWhere(
            (p) => p.id == widget.cita!.pacienteId,
            orElse: () => pacientes.first,
          );
          _medicoSeleccionado = medicos.firstWhere(
            (m) => m.id == widget.cita!.medicoId,
            orElse: () => medicos.first,
          );
        }
        _cargandoDatos = false;
      });
    } catch (e) {
      setState(() => _cargandoDatos = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _seleccionarFechaHora() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaHora ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha == null) return;

    if (!mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _fechaHora ?? DateTime.now(),
      ),
    );
    if (hora == null) return;

    setState(() {
      _fechaHora = DateTime(
        fecha.year, fecha.month, fecha.day,
        hora.hour, hora.minute,
      );
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaHora == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona fecha y hora'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final cita = Cita(
        id: widget.cita?.id,
        pacienteId: _pacienteSeleccionado!.id!,
        medicoId: _medicoSeleccionado!.id!,
        fechaHora: _fechaHora!,
        motivo: _motivoCtrl.text.trim().isEmpty
            ? null : _motivoCtrl.text.trim(),
        estado: _estado,
      );

      if (_esEdicion) {
        await _citaRepo.update(cita);
      } else {
        await _citaRepo.insert(cita);
      }

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
        title: Text(_esEdicion ? 'Editar Cita' : 'Nueva Cita'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _cargandoDatos
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Dropdown Paciente
                    DropdownButtonFormField<Paciente>(
                      value: _pacienteSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Paciente *',
                        prefixIcon: Icon(Icons.people),
                        border: OutlineInputBorder(),
                      ),
                      items: _pacientes.map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.nombre),
                      )).toList(),
                      onChanged: (v) => setState(() => _pacienteSeleccionado = v),
                      validator: (v) => v == null ? 'Selecciona un paciente' : null,
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Médico
                    DropdownButtonFormField<Medico>(
                      value: _medicoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Médico *',
                        prefixIcon: Icon(Icons.medical_services),
                        border: OutlineInputBorder(),
                      ),
                      items: _medicos.map((m) => DropdownMenuItem(
                        value: m,
                        child: Text('Dr. ${m.nombre} — ${m.especialidad}'),
                      )).toList(),
                      onChanged: (v) => setState(() => _medicoSeleccionado = v),
                      validator: (v) => v == null ? 'Selecciona un médico' : null,
                    ),
                    const SizedBox(height: 16),

                    // Fecha y hora
                    InkWell(
                      onTap: _seleccionarFechaHora,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha y hora *',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _fechaHora == null
                              ? 'Seleccionar fecha y hora'
                              : '${_fechaHora!.day}/${_fechaHora!.month}/${_fechaHora!.year}  '
                                '${_fechaHora!.hour}:${_fechaHora!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: _fechaHora == null ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Estado
                    DropdownButtonFormField<String>(
                      value: _estado,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                      items: _estados.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.toUpperCase()),
                      )).toList(),
                      onChanged: (v) => setState(() => _estado = v!),
                    ),
                    const SizedBox(height: 16),

                    // Motivo
                    TextFormField(
                      controller: _motivoCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Motivo de la consulta',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón guardar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        child: _cargando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _esEdicion ? 'Actualizar' : 'Guardar',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}