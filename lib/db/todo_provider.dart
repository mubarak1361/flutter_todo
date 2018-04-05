import 'dart:async';

import 'package:flutter_todo/model/todo.dart';
import 'package:flutter_todo/db/database.dart';
import 'package:sqflite/sqflite.dart';

class TodoProvider {
  static final _todoProvider = new TodoProvider._internal();

  TodoProvider._internal();

  factory TodoProvider() {
    return _todoProvider;
  }

  Future<Database> _open() => new DatabaseHelper().getDatabase();

  Future<Todo> insert(Todo todo) async {
    await _open()
        .then((database) => database.insert(Todo.tableName, todo.toMap()))
        .then((id) => todo.id = id)
        .whenComplete(() => _close());
    return todo;
  }

  Future<int> delete(int id) {
    return _open().then((database) {
      return database.delete(Todo.tableName,
          where: '${Todo.columnId} = ?', whereArgs: [id]);
    }).whenComplete(() => _close());
  }

  Future<int> update(Todo todo) {
    return _open().then((database) {
      return database.update(Todo.tableName, todo.toMap(),
          where: '${Todo.columnId} = ?', whereArgs: [todo.id]);
    }).whenComplete(() => _close());
  }

  Future<Todo> getTodo(int id) {
    return _open().then((database) {
      return database.query(Todo.tableName,
          columns: [
            Todo.columnId,
            Todo.columnNote,
            Todo.columnDone,
            Todo.columnDate
          ],
          where: '${Todo.columnId} = ?',
          whereArgs: [id]);
    }).then((maps) {
      if (maps.length > 0) {
        return new Todo.fromMap(maps.first);
      }
    }).whenComplete(() => _close());
  }

  Future<List<Todo>> getAllTodo() {
    return _open()
        .then((database) =>
            database.query(Todo.tableName, orderBy: '${Todo.columnId} DESC'))
        .then((maps) {
      if (maps.length > 0) {
        List<Todo> todoList = [];
        maps.forEach((map) {
          todoList.add(new Todo.fromMap(map));
        });
        return todoList;
      }
    }).whenComplete(() => _close());
  }

  Future _close() => new DatabaseHelper().closeDatabase();
}
