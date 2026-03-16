import 'package:postgres/postgres.dart';
import '../database/db_helper.dart';
import '../models/paciente.dart';

class PacienteRepository {

  // READ — listar todos
  Future<List<Paciente>> getAll() async {
    try {
      final conn = await DBHelper.getConnection();
      final results = await conn.mappedResultsQuery(
        'SELECT * FROM pacientes ORDER BY nombre',
      );
      return results
          .map((row) => Paciente.fromMap(row['pacientes']!))
          .toList();
    } on PostgreSQLException catch (e) {
      throw Exception('Error al obtener pacientes: ${e.message}');
    }
  }

  // READ — obtener uno por ID
  Future<Paciente?> getById(int id) async {
    try {
      final conn = await DBHelper.getConnection();
      final results = await conn.mappedResultsQuery(
        'SELECT * FROM pacientes WHERE id = @id',
        substitutionValues: {'id': id},
      );
      if (results.isEmpty) return null;
      return Paciente.fromMap(results.first['pacientes']!);
    } on PostgreSQLException catch (e) {
      throw Exception('Error al buscar paciente: ${e.message}');
    }
  }

  // CREATE
  Future<Paciente> insert(Paciente paciente) async {
    _validate(paciente);
    try {
      final conn = await DBHelper.getConnection();
      final results = await conn.mappedResultsQuery(
        '''INSERT INTO pacientes (nombre, dni, telefono, email, fecha_nacimiento)
           VALUES (@nombre, @dni, @telefono, @email, @fecha)
           RETURNING *''',
        substitutionValues: {
          'nombre': paciente.nombre,
          'dni': paciente.dni,
          'telefono': paciente.telefono,
          'email': paciente.email,
          'fecha': paciente.fechaNacimiento?.toIso8601String().split('T')[0],
        },
      );
      return Paciente.fromMap(results.first['pacientes']!);
    } on PostgreSQLException catch (e) {
      if (e.code == '23505') {
        throw Exception('Ya existe un paciente con ese DNI');
      }
      throw Exception('Error al crear paciente: ${e.message}');
    }
  }

  // UPDATE
  Future<Paciente> update(Paciente paciente) async {
    if (paciente.id == null) throw Exception('El paciente no tiene ID');
    _validate(paciente);
    try {
      final conn = await DBHelper.getConnection();
      final results = await conn.mappedResultsQuery(
        '''UPDATE pacientes
           SET nombre=@nombre, dni=@dni, telefono=@telefono,
               email=@email, fecha_nacimiento=@fecha
           WHERE id=@id
           RETURNING *''',
        substitutionValues: {
          'id': paciente.id,
          'nombre': paciente.nombre,
          'dni': paciente.dni,
          'telefono': paciente.telefono,
          'email': paciente.email,
          'fecha': paciente.fechaNacimiento?.toIso8601String().split('T')[0],
        },
      );
      if (results.isEmpty) throw Exception('Paciente no encontrado');
      return Paciente.fromMap(results.first['pacientes']!);
    } on PostgreSQLException catch (e) {
      if (e.code == '23505') throw Exception('DNI ya en uso por otro paciente');
      throw Exception('Error al actualizar: ${e.message}');
    }
  }

  // DELETE
  Future<void> delete(int id) async {
    try {
      final conn = await DBHelper.getConnection();
      final affected = await conn.execute(
        'DELETE FROM pacientes WHERE id = @id',
        substitutionValues: {'id': id},
      );
      if (affected == 0) throw Exception('Paciente no encontrado');
    } on PostgreSQLException catch (e) {
      throw Exception('Error al eliminar paciente: ${e.message}');
    }
  }

  // VALIDACIÓN interna
  void _validate(Paciente p) {
    if (p.nombre.trim().isEmpty) throw Exception('El nombre es obligatorio');
    if (p.dni.trim().isEmpty) throw Exception('El DNI es obligatorio');
    if (p.email != null && p.email!.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(p.email!)) {
        throw Exception('El email no tiene un formato válido');
      }
    }
  }
}