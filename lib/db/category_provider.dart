import 'dart:async';

import 'package:flutter_todo/model/category.dart';
import 'package:flutter_todo/db/database.dart';
import 'package:sqflite/sqflite.dart';

class CategoryProvider {
  static final _todoProvider = new CategoryProvider._internal();

  CategoryProvider._internal();

  factory CategoryProvider() {
    return _todoProvider;
  }

  Future<Database> _open() => new DatabaseHelper().getDatabase();

  Future _close() => new DatabaseHelper().closeDatabase();

  Future<Category> insert(Category category) async {
    await _open()
        .then(
            (database) => database.insert(Category.tableName, category.toMap()))
        .then((id) => category.id = id)
        .whenComplete(() async => _close());
    return category;
  }

  Future<List<Category>> getAllCategory() {
    return _open()
        .then((database) => database.query(Category.tableName,
            orderBy: '${Category.columnId} ASC'))
        .then((maps) {
      if (maps.length > 0) {
        List<Category> categoryList = [];
        maps.forEach((map) {
          categoryList.add(new Category.fromMap(map));
        });
        return categoryList;
      }
    }).whenComplete(() => _close());
  }
}
