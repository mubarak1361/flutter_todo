import 'package:flutter/foundation.dart';

class Category {
  static String get tableName => 'category';

  static String get columnId => 'id';
  static String get columnName => 'name';

  int id;
  String name;

  Category({this.id, @required this.name});

  Map toMap() {
    Map map = {columnName: name};
    return map;
  }

  Category.fromMap(Map map) {
    id = map[columnId];
    name = map[columnName];
  }
}
