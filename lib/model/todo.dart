import 'package:flutter_todo/model/item.dart';
import 'package:flutter_todo/model/view_type.dart';

class Todo implements Item {
  static const String tableName = 'todo';

  static const String columnId = 'id';
  static const String columnNote = 'note';
  static const String columnDone = 'done';
  static const String columnDate = 'date';
  static const String columnCategoryId = 'category_id';

  int id;
  String note;
  String date;
  bool done;
  int categoryId;

  Todo({this.note, this.done = false, this.date});

  Map toMap() {
    Map map = {
      columnNote: note,
      columnDone: done == true ? 1 : 0,
      columnDate: date,
      columnCategoryId: categoryId
    };
    return map;
  }

  Todo.fromMap(Map map) {
    id = map[columnId];
    note = map[columnNote];
    done = map[columnDone] == 1;
    date = map[columnDate];
    categoryId = map[columnCategoryId];
  }

  @override
  ViewType getViewType() {
    return ViewType.TODO;
  }

}
