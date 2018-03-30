import 'package:flutter_todo/model/item.dart';
import 'package:flutter_todo/model/view_type.dart';

class Todo implements Item {
  static String get tableName => 'todo';

  static String get columnId => 'id';
  static String get columnNote => 'note';
  static String get columnDone => 'done';
  static String get columnDate => 'date';
  static String get columnCategoryId => 'category_id';

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
      //columnCategoryId: categoryId
    };
    return map;
  }

  Todo.fromMap(Map map) {
    id = map[columnId];
    note = map[columnNote];
    done = map[columnDone] == 1;
    date = map[columnDate];
    //categoryId = map[columnCategoryId];
  }

  @override
  ViewType getViewType() {
    return ViewType.TODO;
  }
}
