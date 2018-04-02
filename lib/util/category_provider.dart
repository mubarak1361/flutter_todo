import 'dart:async';

import 'package:flutter_todo/model/category.dart';
import 'package:flutter_todo/util/database.dart';
import 'package:sqflite/sqflite.dart';

class CategoryProvider{

  static final _todoProvider = new CategoryProvider._internal();

  CategoryProvider._internal();

  factory CategoryProvider() {
    return _todoProvider;
  }

  Future<Database> _open() async => await new DatabaseHelper().getDatabase();

  Future _close() async => await new DatabaseHelper().closedatabase();

  Future<Category> insert(Category category) async {
    await _open()
        .then((database) async =>
    await database.insert(Category.tableName, category.toMap()))
        .then((id) => category.id = id).whenComplete(() async => await _close());
    return category;
  }

  Future<List<Category>> getAllCategory() async {
    return _open()
        .then((database) async => await database.query(Category.tableName,
        orderBy: '${Category.columnId} ASC'))
        .then((maps) {
      if (maps.length > 0) {
        List<Category> categoryList = [];
        maps.forEach((map) {
          categoryList.add(new Category.fromMap(map));
        });
        return categoryList;
      }
    }).whenComplete(() async => _close());
  }


}