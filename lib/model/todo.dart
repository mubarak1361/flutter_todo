class Todo {
  static String get TABLE_NAME => 'todo';

  static String get COLUMN_ID => 'id';
  static String get COLUMN_NOTE => 'note';
  static String get COLUMN_DONE => 'done';
  static String get COLUMN_DATE => 'date';

  int id;
  String note;
  String date;
  bool done;

  Todo({this.note, this.done = false, this.date});

  Map toMap() {
    Map map = {
      COLUMN_NOTE: note,
      COLUMN_DONE: done == true ? 1 : 0,
      COLUMN_DATE: date
    };
    return map;
  }

  Todo.fromMap(Map map) {
    id = map[COLUMN_ID];
    note = map[COLUMN_NOTE];
    done = map[COLUMN_DONE] == 1;
    date = map[COLUMN_DATE];
  }
}
