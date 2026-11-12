import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/resena.dart';

class ResenasDb {
  ResenasDb._();

  static final ResenasDb instancia = ResenasDb._();

  static const _nombreArchivo = 'misrecetas.db';
  static const _tabla = 'resenas';

  Future<Database>? _db;

  // Abre la base de datos una sola vez.
  Future<Database> get _database {
    return _db ??= _abrir();
  }

  Future<Database> _abrir() async {
    final ruta = join(
      await getDatabasesPath(),
      _nombreArchivo,
    );

    return openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tabla (
            recetaId INTEGER PRIMARY KEY,
            comentario TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Inserta una reseña o reemplaza la de esa receta.
  Future<int> guardar(Resena resena) async {
    final db = await _database;

    return db.insert(
      _tabla,
      resena.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Recupera la reseña de una receta.
  Future<Resena?> obtenerPorReceta(int recetaId) async {
    final db = await _database;

    final filas = await db.query(
      _tabla,
      where: 'recetaId = ?',
      whereArgs: [recetaId],
      limit: 1,
    );

    if (filas.isEmpty) return null;

    return Resena.fromMap(filas.first);
  }
}