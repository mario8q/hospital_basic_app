import 'package:postgres/postgres.dart';
import '../database/db_helper.dart';
import '../models/medico.dart';

class MedicoRepository {

  Future<List<Medico>> getAll() async {
    try {
      final conn = await DBHelper.getConnection();
      final results = await conn.mappedResultsQuery(
        'SELECT * FROM medicos ORDER BY nombre',
      );
      return results.map((row) => Medico.fromMap(row['medicos']!)).toList();
    } on PostgreSQLException catch (e) {
      throw Exception('Error al obtener médicos: ${e.message}');
    }
  }

  Future<Medico> insert(Medico medico) async {
    _validate(medico);
    try {
      final conn = await DBHelper.getConnection();
      final results = await conn.mappedResultsQuery(
        '''INSERT INTO medicos (nombre, especialidad, telefono, email)
           VALUES (@nombre, @especialidad, @telefono, @email)
           RETURNING *''',
        substitutionValues: {
          'nombre': medico.nombre,
          'especialidad': medico.especialidad,
          'telefono': medico.telefono,
          'email': medico.email,
        },
      );
      return Medico.fromMap(results.first['medicos']!);
    } on PostgreSQLException catch (e) {
      throw Exception('Error al crear médico: ${e.message}');
    }
  }

  Future<Medico> update(Medico medico) async {
    if (medico.id == null) throw Exception('El médico no tiene ID');
    _validate(medico);
    try {
      final conn = await DBHelper.getConnection();
      final results = await conn.mappedResultsQuery(
        '''UPDATE medicos
           SET nombre=@nombre, especialidad=@especialidad,
               telefono=@telefono, email=@email
           WHERE id=@id
           RETURNING *''',
        substitutionValues: {
          'id': medico.id,
          'nombre': medico.nombre,
          'especialidad': medico.especialidad,
          'telefono': medico.telefono,
          'email': medico.email,
        },
      );
      if (results.isEmpty) throw Exception('Médico no encontrado');
      return Medico.fromMap(results.first['medicos']!);
    } on PostgreSQLException catch (e) {
      throw Exception('Error al actualizar médico: ${e.message}');
    }
  }

  Future<void> delete(int id) async {
    try {
      final conn = await DBHelper.getConnection();
      final affected = await conn.execute(
        'DELETE FROM medicos WHERE id = @id',
        substitutionValues: {'id': id},
      );
      if (affected == 0) throw Exception('Médico no encontrado');
    } on PostgreSQLException catch (e) {
      throw Exception('Error al eliminar médico: ${e.message}');
    }
  }

  void _validate(Medico m) {
    if (m.nombre.trim().isEmpty) throw Exception('El nombre es obligatorio');
    if (m.especialidad.trim().isEmpty) throw Exception('La especialidad es obligatoria');
    if (m.email != null && m.email!.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(m.email!)) {
        throw Exception('El email no tiene formato válido');
      }
    }
  }
}