import 'package:postgres/postgres.dart';

class DBHelper {
  static PostgreSQLConnection? _connection;

  static Future<PostgreSQLConnection> getConnection() async {
    if (_connection != null && !_connection!.isClosed) {
      return _connection!;
    }

    _connection = PostgreSQLConnection(
      '10.0.2.2', // host
      5432,        // puerto
      'clinica',   // base de datos
      username: 'postgres',
      password: 'dastan31416',
    );

    await _connection!.open();
    return _connection!;
  }

  static Future<void> closeConnection() async {
    await _connection?.close();
  }
}