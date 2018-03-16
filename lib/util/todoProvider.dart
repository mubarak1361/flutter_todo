import 'dart:async';

import 'package:flutter_todo/model/todo.dart';
import 'package:flutter_todo/util/database.dart';
import 'package:sqflite/sqflite.dart';

class TodoProvider {
  static final _todoProvider = new TodoProvider._internal();
  Database database;

  TodoProvider._internal();

  factory TodoProvider() {
    return _todoProvider;
  }

  Future open() async => database = await new DatabaseHelper().getDatabase();

  Future<Todo> insert(Todo todo) async {
    todo.id = await database.insert(Todo.TABLE_NAME, todo.toMap());
    return todo;
  }

  Future<int> delete(int id) async {
    return await database.delete(Todo.TABLE_NAME,
        where: "${Todo.COLUMN_ID} = ?", whereArgs: [id]);
  }

  Future<int> update(Todo todo) async {
    return await database.update(Todo.TABLE_NAME, todo.toMap(),
        where: "${Todo.COLUMN_ID} = ?", whereArgs: [todo.id]);
  }

  Future<Todo> getTodo(int id) async {
    List<Map> maps = await database.query(Todo.TABLE_NAME,
        columns: [
          Todo.COLUMN_ID,
          Todo.COLUMN_NOTE,
          Todo.COLUMN_DONE,
          Todo.COLUMN_DATE
        ],
        where: "${Todo.COLUMN_ID} = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return new Todo.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Todo>> getAllTodo() async {
    List<Map> maps = await database.query(Todo.TABLE_NAME, orderBy: '${Todo.COLUMN_ID} DESC');
    List<Todo> todoList;
    if (maps.length > 0) {
      todoList = [];
      maps.forEach((map) {
        todoList.add(new Todo.fromMap(map));
      });
      return todoList;
    }
    return null;
  }

  Future close() async => await new DatabaseHelper().closedatabase();
}
