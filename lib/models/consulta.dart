class Consulta {
  final String fecha;
  final String medico;
  final String especialidad;
  final String motivo;
  final String diagnostico;
  final String tratamiento;

  Consulta({
    required this.fecha,
    required this.medico,
    required this.especialidad,
    required this.motivo,
    required this.diagnostico,
    required this.tratamiento,
  });

  factory Consulta.fromJson(Map<String, dynamic> json) {
    return Consulta(
      fecha: json['fecha'] ?? '',
      medico: json['medico'] ?? '',
      especialidad: json['especialidad'] ?? '',
      motivo: json['motivo'] ?? '',
      diagnostico: json['diagnostico'] ?? '',
      tratamiento: json['tratamiento'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'fecha': fecha,
    'medico': medico,
    'especialidad': especialidad,
    'motivo': motivo,
    'diagnostico': diagnostico,
    'tratamiento': tratamiento,
  };
}