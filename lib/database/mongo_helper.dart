import 'package:mongo_dart/mongo_dart.dart';
import '../config/mongo_config.dart';

class MongoHelper {
  static Db? _db;

  static Future<Db> getDb() async {
    try {
      if (_db != null && _db!.isConnected) {
        print('MongoDB ya conectado');
        return _db!;
      }

      print('Conectando a MongoDB...');
      print('URL: ${MongoConfig.connectionString}');

      _db = await Db.create(MongoConfig.connectionString);
      await _db!.open();

      print('MongoDB conectado exitosamente');
      print('Base de datos: ${_db!.databaseName}');
      return _db!;

    } catch (e) {
      print('Error conectando MongoDB: $e');
      rethrow;
    }
  }

  static Future<DbCollection> getCollection() async {
    final db = await getDb();
    final col = db.collection(MongoConfig.collection);
    print('Colección: ${MongoConfig.collection}');
    return col;
  }

  static Future<void> close() async {
    await _db?.close();
    print('MongoDB desconectado');
  }
}