import 'package:postgres/postgres.dart';
import '../database/db_helper.dart';
import '../models/cita.dart';

class CitaRepository {

  // JOIN para traer nombres de paciente y médico
  Future<List<Cita>> getAll() async {
    try {
      final conn = await DBHelper.getConnection();
      final results = await conn.query(
        '''SELECT c.*, 
                  p.nombre AS nombre_paciente,
                  m.nombre AS nombre_medico
           FROM citas c
           JOIN pacientes p ON p.id = c.paciente_id
           JOIN medicos m ON m.id = c.medico_id
           ORDER BY c.fecha_hora DESC''',
      );
      return results.map((row) => Cita.fromMap(row.toColumnMap())).toList();
    } on PostgreSQLException catch (e) {
      throw Exception('Error al obtener citas: ${e.message}');
    }
  }

  Future<Cita> insert(Cita cita) async {
    _validate(cita);
    try {
      final conn = await DBHelper.getConnection();
      final results = await conn.query(
        '''INSERT INTO citas (paciente_id, medico_id, fecha_hora, motivo, estado)
           VALUES (@paciente_id, @medico_id, @fecha_hora, @motivo, @estado)
           RETURNING *''',
        substitutionValues: {
          'paciente_id': cita.pacienteId,
          'medico_id': cita.medicoId,
          'fecha_hora': cita.fechaHora.toIso8601String(),
          'motivo': cita.motivo,
          'estado': cita.estado,
        },
      );
      return Cita.fromMap(results.first.toColumnMap());
    } on PostgreSQLException catch (e) {
      throw Exception('Error al crear cita: ${e.message}');
    }
  }

  Future<Cita> update(Cita cita) async {
    if (cita.id == null) throw Exception('La cita no tiene ID');
    _validate(cita);
    try {
      final conn = await DBHelper.getConnection();
      final results = await conn.query(
        '''UPDATE citas
           SET paciente_id=@paciente_id, medico_id=@medico_id,
               fecha_hora=@fecha_hora, motivo=@motivo, estado=@estado
           WHERE id=@id
           RETURNING *''',
        substitutionValues: {
          'id': cita.id,
          'paciente_id': cita.pacienteId,
          'medico_id': cita.medicoId,
          'fecha_hora': cita.fechaHora.toIso8601String(),
          'motivo': cita.motivo,
          'estado': cita.estado,
        },
      );
      if (results.isEmpty) throw Exception('Cita no encontrada');
      return Cita.fromMap(results.first.toColumnMap());
    } on PostgreSQLException catch (e) {
      throw Exception('Error al actualizar cita: ${e.message}');
    }
  }

  Future<void> delete(int id) async {
    try {
      final conn = await DBHelper.getConnection();
      final affected = await conn.execute(
        'DELETE FROM citas WHERE id = @id',
        substitutionValues: {'id': id},
      );
      if (affected == 0) throw Exception('Cita no encontrada');
    } on PostgreSQLException catch (e) {
      throw Exception('Error al eliminar cita: ${e.message}');
    }
  }

  void _validate(Cita c) {
    if (c.pacienteId <= 0) throw Exception('Debe seleccionar un paciente');
    if (c.medicoId <= 0) throw Exception('Debe seleccionar un médico');
    if (c.fechaHora.isBefore(DateTime.now())) {
      throw Exception('La fecha debe ser futura');
    }
  }
}