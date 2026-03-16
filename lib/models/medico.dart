class Medico {
  final int? id;
  final String nombre;
  final String especialidad;
  final String? telefono;
  final String? email;

  Medico({
    this.id,
    required this.nombre,
    required this.especialidad,
    this.telefono,
    this.email,
  });

  factory Medico.fromMap(Map<String, dynamic> map) {
    return Medico(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      especialidad: map['especialidad'] as String,
      telefono: map['telefono'] as String?,
      email: map['email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'especialidad': especialidad,
      'telefono': telefono,
      'email': email,
    };
  }

  Medico copyWith({
    int? id,
    String? nombre,
    String? especialidad,
    String? telefono,
    String? email,
  }) {
    return Medico(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      especialidad: especialidad ?? this.especialidad,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
    );
  }
}