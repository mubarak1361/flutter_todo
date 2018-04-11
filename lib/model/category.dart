import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Category {
  static final String tableName = 'category';

  static final String columnId = 'id';
  static final String columnName = 'name';

  static const String allLists = 'All Lists';
  static const String deFault = 'Default';
  static const String personal = 'Personal';
  static const String shopping = 'Shopping';
  static const String wishList = 'Wishlist';
  static const String work = 'Work';
  static const String finished = 'Finished';

  int id;
  String name;

  Category({this.id, @required this.name});

  Map toMap() {
    return <String, dynamic>{columnName: name};
  }

  Category.fromMap(Map map) {
    id = map[columnId];
    name = map[columnName];
  }

  IconData getIcon() {
    switch (name) {
      case personal:
        return FontAwesomeIcons.user;
      case shopping:
        return FontAwesomeIcons.shoppingCart;
      case wishList:
        return FontAwesomeIcons.heart;
      case work:
        return Icons.work;
      case finished:
        return Icons.check;
      default:
        return FontAwesomeIcons.list;
    }
  }
}
