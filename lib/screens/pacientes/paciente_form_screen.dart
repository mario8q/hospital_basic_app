import 'package:flutter/material.dart';
import '../../models/paciente.dart';
import '../../repositories/paciente_repository.dart';

class PacienteFormScreen extends StatefulWidget {
  final Paciente? paciente; // null = crear, con valor = editar

  const PacienteFormScreen({super.key, this.paciente});

  @override
  State<PacienteFormScreen> createState() => _PacienteFormScreenState();
}

class _PacienteFormScreenState extends State<PacienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = PacienteRepository();
  bool _cargando = false;

  // Controladores
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _dniCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _emailCtrl;
  DateTime? _fechaNacimiento;

  bool get _esEdicion => widget.paciente != null;

  @override
  void initState() {
    super.initState();
    final p = widget.paciente;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _dniCtrl = TextEditingController(text: p?.dni ?? '');
    _telefonoCtrl = TextEditingController(text: p?.telefono ?? '');
    _emailCtrl = TextEditingController(text: p?.email ?? '');
    _fechaNacimiento = p?.fechaNacimiento;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _dniCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fechaNacimiento = fecha);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final paciente = Paciente(
        id: widget.paciente?.id,
        nombre: _nombreCtrl.text.trim(),
        dni: _dniCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim().isEmpty
            ? null
            : _telefonoCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty
            ? null
            : _emailCtrl.text.trim(),
        fechaNacimiento: _fechaNacimiento,
      );

      if (_esEdicion) {
        await _repo.update(paciente);
      } else {
        await _repo.insert(paciente);
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
        title: Text(_esEdicion ? 'Editar Paciente' : 'Nuevo Paciente'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // DNI
              TextFormField(
                controller: _dniCtrl,
                decoration: const InputDecoration(
                  labelText: 'DNI *',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'El DNI es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Teléfono
              TextFormField(
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                  return regex.hasMatch(v) ? null : 'Email no válido';
                },
              ),
              const SizedBox(height: 16),

              // Fecha de nacimiento
              InkWell(
                onTap: _seleccionarFecha,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _fechaNacimiento == null
                        ? 'Seleccionar fecha'
                        : '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}',
                    style: TextStyle(
                      color: _fechaNacimiento == null
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
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