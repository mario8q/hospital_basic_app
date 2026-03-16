class Paciente {
  final int? id;
  final String nombre;
  final String dni;
  final String? telefono;
  final String? email;
  final DateTime? fechaNacimiento;

  Paciente({
    this.id,
    required this.nombre,
    required this.dni,
    this.telefono,
    this.email,
    this.fechaNacimiento,
  });

  // Desde la respuesta de PostgreSQL
  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      dni: map['dni'] as String,
      telefono: map['telefono'] as String?,
      email: map['email'] as String?,
      fechaNacimiento: map['fecha_nacimiento'] != null
          ? DateTime.parse(map['fecha_nacimiento'].toString())
          : null,
    );
  }

  // Para insertar/actualizar
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'dni': dni,
      'telefono': telefono,
      'email': email,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String().split('T')[0],
    };
  }

  // Para editar con campos modificados
  Paciente copyWith({
    int? id,
    String? nombre,
    String? dni,
    String? telefono,
    String? email,
    DateTime? fechaNacimiento,
  }) {
    return Paciente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      dni: dni ?? this.dni,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
    );
  }
}