import 'consulta.dart';

class HistorialClinico {
  final String? id;
  final String pacienteId;
  final String nombrePaciente;
  final String? fechaNacimiento;
  final List<Consulta> consultas;

  HistorialClinico({
    this.id,
    required this.pacienteId,
    required this.nombrePaciente,
    this.fechaNacimiento,
    required this.consultas,
  });

  factory HistorialClinico.fromJson(Map<String, dynamic> json) {
    String? mongoId;
    if (json['_id'] != null) {
      mongoId = json['_id'] is Map
          ? json['_id']['\$oid']
          : json['_id'].toString();
    }
    return HistorialClinico(
      id: mongoId,
      pacienteId: json['paciente_id'] ?? '',
      nombrePaciente: json['nombre_paciente'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'],
      consultas: (json['consultas'] as List<dynamic>? ?? [])
          .map((c) => Consulta.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'paciente_id': pacienteId,
    'nombre_paciente': nombrePaciente,
    'fecha_nacimiento': fechaNacimiento,
    'consultas': consultas.map((c) => c.toJson()).toList(),
  };
}