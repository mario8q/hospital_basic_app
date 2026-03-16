class Cita {
  final int? id;
  final int pacienteId;
  final int medicoId;
  final DateTime fechaHora;
  final String? motivo;
  final String estado;

  // Para mostrar en pantalla (joins)
  final String? nombrePaciente;
  final String? nombreMedico;

  Cita({
    this.id,
    required this.pacienteId,
    required this.medicoId,
    required this.fechaHora,
    this.motivo,
    this.estado = 'pendiente',
    this.nombrePaciente,
    this.nombreMedico,
  });

  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map['id'] as int?,
      pacienteId: map['paciente_id'] as int,
      medicoId: map['medico_id'] as int,
      fechaHora: DateTime.parse(map['fecha_hora'].toString()),
      motivo: map['motivo'] as String?,
      estado: map['estado'] as String? ?? 'pendiente',
      nombrePaciente: map['nombre_paciente'] as String?,
      nombreMedico: map['nombre_medico'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'paciente_id': pacienteId,
      'medico_id': medicoId,
      'fecha_hora': fechaHora.toIso8601String(),
      'motivo': motivo,
      'estado': estado,
    };
  }

  Cita copyWith({
    int? id,
    int? pacienteId,
    int? medicoId,
    DateTime? fechaHora,
    String? motivo,
    String? estado,
  }) {
    return Cita(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      medicoId: medicoId ?? this.medicoId,
      fechaHora: fechaHora ?? this.fechaHora,
      motivo: motivo ?? this.motivo,
      estado: estado ?? this.estado,
    );
  }
}