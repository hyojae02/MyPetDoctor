// lib/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pet.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pets.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE pets (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      age INTEGER NOT NULL,
      breed TEXT NOT NULL,
      gender TEXT NOT NULL,
      isNeutered INTEGER NOT NULL,
      weight REAL NOT NULL,
      imageUrl TEXT,
      allergies TEXT,
      specialNotes TEXT
    )
    ''');
  }

  Future<String> insertPet(Pet pet) async {
    final db = await instance.database;
    await db.insert('pets', pet.toMap());
    return pet.id;
  }

  Future<int> updatePet(Pet pet) async {
    final db = await instance.database;
    return db.update(
      'pets',
      pet.toMap(),
      where: 'id = ?',
      whereArgs: [pet.id],
    );
  }

  Future<int> deletePet(String id) async {
    final db = await instance.database;
    return await db.delete(
      'pets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Pet>> getAllPets() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('pets');
    return List.generate(maps.length, (i) => Pet.fromMap(maps[i]));
  }

  Future<Pet?> getPet(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'pets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Pet.fromMap(maps.first);
    }
    return null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}