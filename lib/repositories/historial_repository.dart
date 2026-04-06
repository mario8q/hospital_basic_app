import 'package:mongo_dart/mongo_dart.dart';
import '../database/mongo_helper.dart';
import '../models/historial_clinico.dart';
import '../models/consulta.dart';

class HistorialRepository {

  Future<HistorialClinico?> buscarPorPacienteId(String pacienteId) async {
    try {
      final col = await MongoHelper.getCollection();
      final doc = await col.findOne(where.eq('paciente_id', pacienteId));
      if (doc == null) {
        return null;
      }
      return HistorialClinico.fromJson(doc);
    } catch (e) {
      throw Exception('Error buscando historial: $e');
    }
  }

  Future<void> crear(HistorialClinico historial) async {
    try {
      final col = await MongoHelper.getCollection();
      final result = await col.insertOne(historial.toJson());
    } catch (e) {
      throw Exception('Error creando historial: $e');
    }
  }

  Future<void> agregarConsulta(String pacienteId, Consulta consulta) async {
    try {
      final col = await MongoHelper.getCollection();
      final result = await col.updateOne(
        where.eq('paciente_id', pacienteId),
        modify.push('consultas', consulta.toJson()),
      );
      if (result.nMatched == 0) {
        throw Exception('No se encontró historial para ese paciente');
      }
    } catch (e) {
      throw Exception('Error agregando consulta: $e');
    }
  }

  Future<List<HistorialClinico>> listarTodos() async {
    try {
      final col = await MongoHelper.getCollection();
      final docs = await col.find().toList();
      return docs.map((d) => HistorialClinico.fromJson(d)).toList();
    } catch (e) {
      throw Exception('Error listando historiales: $e');
    }
  }
}