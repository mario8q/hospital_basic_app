import 'package:flutter/material.dart';
import '../../models/medico.dart';
import '../../repositories/medico_repository.dart';

class MedicoFormScreen extends StatefulWidget {
  final Medico? medico;
  const MedicoFormScreen({super.key, this.medico});

  @override
  State<MedicoFormScreen> createState() => _MedicoFormScreenState();
}

class _MedicoFormScreenState extends State<MedicoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = MedicoRepository();
  bool _cargando = false;

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _especialidadCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _emailCtrl;

  bool get _esEdicion => widget.medico != null;

  // Especialidades predefinidas
  static const _especialidades = [
    'Cardiología', 'Dermatología', 'Ginecología',
    'Medicina General', 'Neurología', 'Oftalmología',
    'Ortopedia', 'Pediatría', 'Psiquiatría', 'Urología',
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.medico;
    _nombreCtrl = TextEditingController(text: m?.nombre ?? '');
    _especialidadCtrl = TextEditingController(text: m?.especialidad ?? '');
    _telefonoCtrl = TextEditingController(text: m?.telefono ?? '');
    _emailCtrl = TextEditingController(text: m?.email ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _especialidadCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    try {
      final medico = Medico(
        id: widget.medico?.id,
        nombre: _nombreCtrl.text.trim(),
        especialidad: _especialidadCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim().isEmpty
            ? null : _telefonoCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty
            ? null : _emailCtrl.text.trim(),
      );

      if (_esEdicion) {
        await _repo.update(medico);
      } else {
        await _repo.insert(medico);
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
        title: Text(_esEdicion ? 'Editar Médico' : 'Nuevo Médico'),
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
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Especialidad con autocompletado
              Autocomplete<String>(
                initialValue: TextEditingValue(
                  text: _especialidadCtrl.text,
                ),
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) return _especialidades;
                  return _especialidades.where((e) => e
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (value) => _especialidadCtrl.text = value,
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  // Sincronizar con nuestro controller
                  controller.text = _especialidadCtrl.text;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Especialidad *',
                      prefixIcon: Icon(Icons.medical_services),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _especialidadCtrl.text = v,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'La especialidad es obligatoria' : null,
                  );
                },
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