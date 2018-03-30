import 'dart:async';

import 'package:flutter_todo/model/todo.dart';
import 'package:flutter_todo/util/database.dart';
import 'package:sqflite/sqflite.dart';

class TodoProvider {
  static final _todoProvider = new TodoProvider._internal();

  TodoProvider._internal();

  factory TodoProvider() {
    return _todoProvider;
  }

  Future<Database> _open() async => await new DatabaseHelper().getDatabase();

  Future<Todo> insert(Todo todo) async {
    await _open()
        .then((database) async =>
    await database.insert(Todo.tableName, todo.toMap()))
        .then((id) => todo.id = id).whenComplete(() async => await _close());
    return todo;
  }

  Future<int> delete(int id) async {
    return await _open().then((database) async {
      return await database.delete(Todo.tableName,
          where: '${Todo.columnId} = ?', whereArgs: [id]);
    }).whenComplete(() async => await _close());
  }

  Future<int> update(Todo todo) async {
    return await _open().then((database) async {
      return await database.update(Todo.tableName, todo.toMap(),
          where: '${Todo.columnId} = ?', whereArgs: [todo.id]);
    }).whenComplete(() async => _close());
  }

  Future<Todo> getTodo(int id) async {
    return await _open().then((database) async {
      return await database.query(Todo.tableName,
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
    }).whenComplete(() async => _close());
  }

  Future<List<Todo>> getAllTodo() async {
    return await _open()
        .then((database) async => await database.query(Todo.tableName,
            orderBy: '${Todo.columnId} DESC'))
        .then((maps) {
      if (maps.length > 0) {
        List<Todo> todoList = [];
        maps.forEach((map) {
          todoList.add(new Todo.fromMap(map));
        });
        return todoList;
      }
    }).whenComplete(() async => _close());
  }

  Future _close() async => await new DatabaseHelper().closedatabase();
}
