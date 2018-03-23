import 'dart:async';
import 'dart:io';

import 'package:flutter_todo/model/todo.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  Database _database;
  final String _DB_NAME = 'todo_list.db';
  static final DatabaseHelper _databaseHelper = new DatabaseHelper._internal();
  final String _CREATE_TABLE_TODO = 'CREATE TABLE ' +
      Todo.TABLE_NAME +
      '(' +
      Todo.COLUMN_ID +
      ' INTEGER PRIMARY KEY AUTOINCREMENT,' +
      Todo.COLUMN_NOTE +
      ' TEXT,' +
      Todo.COLUMN_DONE +
      ' INTEGER,' +
      Todo.COLUMN_DATE +
      ' TEXT )';

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  Future<Database> getDatabase() async {
    if (_database == null)
      return _database = await _openDatabse(await _initDb());
    return _database;
  }

  Future<String> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    print(documentsDirectory);

    String path = join(documentsDirectory.path, _DB_NAME);

    // make sure the folder exists
    if (!await new Directory(dirname(path)).exists()) {
      try {
        await new Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        print(e);
      }
    }

    return path;
  }

  Future<Database> _openDatabse(String path) async {
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      //When creating the db, create the table
      await db.execute(_CREATE_TABLE_TODO);
    });
    return database;
  }

  Future closedatabase() async {
    if (_database != null) {
      await _database.close();
      _database = null;
    }
  }
}
