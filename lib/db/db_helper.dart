import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_model.dart';

class DBHelper {
  static Database? _db;
  static const String DB_NAME = 'expense.db';
  static const int DB_VERSION = 1;
  static const String TABLE = 'expenses';

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DB_NAME);

    return await openDatabase(path, version: DB_VERSION, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE $TABLE(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          category TEXT NOT NULL
        )
      ''');
    });
  }

  Future<int> insertExpense(Expense e) async {
    final db = await database;
    return await db.insert(TABLE, e.toMap());
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final rows = await db.query(TABLE, orderBy: 'date DESC');
    return rows.map((r) => Expense.fromMap(r)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(TABLE, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateExpense(Expense e) async {
    final db = await database;
    return await db.update(TABLE, e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }
}
