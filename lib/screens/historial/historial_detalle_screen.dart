import 'package:flutter/material.dart';
import '../../models/historial_clinico.dart';
import '../../models/consulta.dart';
import '../../repositories/historial_repository.dart';
import 'consulta_form_screen.dart';

class HistorialDetalleScreen extends StatefulWidget {
  final HistorialClinico historial;

  const HistorialDetalleScreen({super.key, required this.historial});

  @override
  State<HistorialDetalleScreen> createState() => _HistorialDetalleScreenState();
}

class _HistorialDetalleScreenState extends State<HistorialDetalleScreen> {
  late List<Consulta> _consultas;

  @override
  void initState() {
    super.initState();
    // Ordenar consultas de más reciente a más antigua
    _consultas = List.from(widget.historial.consultas)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  Future<void> _agregarConsulta() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultaFormScreen(
          pacienteId: widget.historial.pacienteId,
        ),
      ),
    );
    if (resultado == true && mounted) {
      Navigator.pop(context, true); // Regresa a la lista y recarga
    }
  }

  Color _colorEspecialidad(String especialidad) {
    final colores = {
      'Cardiología': Colors.red,
      'Pediatría': Colors.orange,
      'Neurología': Colors.purple,
      'Medicina General': Colors.teal,
      'Ginecología': Colors.pink,
      'Oftalmología': Colors.blue,
      'Ortopedia': Colors.brown,
      'Dermatología': Colors.amber,
    };
    return colores[especialidad] ?? Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.historial.nombrePaciente),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarConsulta,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva consulta',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Encabezado del paciente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.withOpacity(0.1),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    widget.historial.nombrePaciente[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.historial.nombrePaciente,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('ID Paciente: ${widget.historial.pacienteId}'),
                    if (widget.historial.fechaNacimiento != null)
                      Text('Nacimiento: ${widget.historial.fechaNacimiento}'),
                    Text(
                      '${_consultas.length} consulta(s) registrada(s)',
                      style: const TextStyle(color: Colors.deepPurple),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Timeline de consultas
          Expanded(
            child: _consultas.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medical_information_outlined,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No hay consultas registradas',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _consultas.length,
                    itemBuilder: (context, index) {
                      final c = _consultas[index];
                      final esUltimo = index == _consultas.length - 1;
                      DateTime? fecha;
                      try {
                        fecha = DateTime.parse(c.fecha);
                      } catch (_) {}

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Línea del timeline
                            SizedBox(
                              width: 40,
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor:
                                        _colorEspecialidad(c.especialidad),
                                    child: const Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (!esUltimo)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Tarjeta de la consulta
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _colorEspecialidad(c.especialidad)
                                        .withOpacity(0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Encabezado de la consulta
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _colorEspecialidad(
                                                      c.especialidad)
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              c.especialidad,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: _colorEspecialidad(
                                                    c.especialidad),
                                              ),
                                            ),
                                          ),
                                          if (fecha != null)
                                            Text(
                                              '${fecha.day}/${fecha.month}/${fecha.year}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Médico
                                      Row(
                                        children: [
                                          const Icon(Icons.person,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Dr. ${c.medico}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Motivo
                                      _filaDetalle(
                                          Icons.help_outline, 'Motivo', c.motivo),
                                      const SizedBox(height: 4),

                                      // Diagnóstico
                                      _filaDetalle(
                                          Icons.medical_information,
                                          'Diagnóstico',
                                          c.diagnostico),
                                      const SizedBox(height: 4),

                                      // Tratamiento
                                      _filaDetalle(
                                          Icons.medication,
                                          'Tratamiento',
                                          c.tratamiento),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filaDetalle(IconData icon, String label, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}